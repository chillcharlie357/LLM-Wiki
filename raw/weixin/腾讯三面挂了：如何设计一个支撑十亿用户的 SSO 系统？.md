---
title: "腾讯三面挂了：如何设计一个支撑十亿用户的 SSO 系统？"
source: "https://mp.weixin.qq.com/s/aL57rWaPejWyKsGMlm7keQ"
author:
  - "[[Fox爱分享]]"
published:
created: 2026-07-24
description: "架构设计的本质，不是追求完美的\x26quot;强一致\x26quot;，而是管理\x26quot;不确定性\x26quot;。"
tags:
  - "clippings"
---
Fox爱分享 Fox爱分享 *2026年7月23日 18:30*

最近帮一个准备跳槽腾讯 CSIG（云与智慧产业事业群）的兄弟做面试复盘。这哥们做 ToB 系统出身，5 年资深开发，底层源码也啃过不少。本以为拿个 Offer 十拿九稳，结果在最后一道场景设计题上翻了车。

到三面（架构总监面），面试官抛了一道经典场景题。先抛个基础版热身：

> "我在 PC 端登录了 QQ 空间（qzone.qq.com），再打开腾讯视频（v.qq.com），系统自动就登录了。这个同域下的自动登录，你怎么实现？"

这哥们答："简单，把 Cookie 的 domain 设为顶级域名 `.qq.com` ，所有子域都能读到。"—— **这一步他答对了** ，同域共享 Cookie 确实是基础操作。

面试官点点头，话锋一转，扔出真正的考点：

> "那如果打开的是京东（jd.com，用微信登录），或者任何一个跟 `.qq.com` 完全无关的一级域名，怎么实现'一次登录，全网通行'？不同的一级域名之间，Cookie 能共享吗？"

这才是翻车现场。candidate 还是那句"设 domain 不就行了"，被面试官三连问直接打回：

> "qq.com 和 jd.com 是完全不同的一级域名，浏览器同源策略允许 A 域读 B 域的 Cookie 吗？"  
> "10 亿用户，你的 Redis 集群存得下 10 亿个 Session 吗？"  
> "用户在 QQ 空间点了退出，如果腾讯视频那边网络抖动，怎么保证同步退出？"

单点登录（SSO）看似简单，实则暗藏杀机。今天咱们就拆解这套能抗住十亿级用户的现代身份体系，看看大厂究竟是怎么玩转 SSO 的。

先说清楚 candidate 答对的那部分，免得你被绕进去。

- **场景 A（同域）**
	`video.qq.com` 和 `music.qq.com` 同属 `.qq.com` 。确实可以通过 `domain=.qq.com` 共享 Cookie，这是基础题。
- **场景 B（跨一级根域）**
	`taobao.com` 与 `tmall.com` （同集团可控域可协商共享）、以及腾讯体系外的 `jd.com` 。

**硬约束** ：浏览器同源策略（Same-Origin Policy）下，A 域 **根本读不到** B 域的 Cookie。随着 Safari ITP、Chrome 第三方 Cookie 限制收紧，跨域种 Cookie 更是难上加难。

**结论** ：跨一级根域的"一次登录全网通行"，必须引入独立的第三方认证中心（Passport / Auth Server），靠协议而非 Cookie 共享来解决。

二、架构推演：从 CAS 票据到 OIDC

先同步一个认知：很多教程还在讲古老的 CAS 协议。CAS 是 SSO 的鼻祖，它的"票据流转"是理解 SSO 的元神；但在大厂内部，主流早已转向 **OAuth 2.0 / OIDC（OpenID Connect）** ——OIDC 在 OAuth 授权之上补了一层身份层（ID Token），让业务系统能直接拿到"这是谁"。

CAS 的票据机制依然值得懂，它揭示了 SSO 的核心骨架——浏览器、业务端、认证中心三者之间如何流转：

![[raw/assets/weixin/sso-system/sso-flow.webp]]

▲ SSO 架构流程图

看懂这张图，你就掌握了 SSO 的骨架：

1. **阶段一（首次登录）**
	业务系统发现无票据，把用户重定向到认证中心。认证中心校验账号密码后，种下全局会话（TGC），并带着授权码（Code）跳回业务系统。
2. **阶段二（票据兑换）**
	业务系统拿 Code，走 **后端通道** 去认证中心换取用户凭证（OIDC 下即 ID Token + 用户信息），再生成自己业务域内的 Token。

三、核心难点：十亿级用户怎么扛？（Token 化）

面试官问"Redis 存不下 Session 怎么办"，这是区分 P6 和 P7 的分水岭——但分水岭不在"用不用 Redis"，而在" **把什么放进 Redis、查多少次** "。

- **P6 思路**
	"扩容 Redis 集群，搞分片。"（方向没错，但没回答"怎么降压力"）
- **P7 思路**
	"去 Session 化，用 JWT 做无状态验签，把高频请求的存储压力从 Redis 卸载到 CPU。"

1\. 传统 Session 模式的瓶颈

业务系统拿到用户信息后若生成 `JSESSIONID` 存 Redis，10 亿用户哪怕 1% 在线，内存与连接数开销都极其恐怖；且每次请求都要查缓存，网络 IO 极易成为瓶颈。

2\. JWT 方案的本质

业务系统拿到用户信息后，不存 Session，而是签发一个加密的 JWT 返回前端。 **后端不再为每次请求查库，只用 CPU 验签** 。扩容 1000 台机器也无需同步状态。

**但要诚实** ：JWT 不是"消灭 Redis"，而是 **重新分配了 Redis 的职责** ——它把"每次请求都查"变成"低频操作才查"。真正十亿级系统里，Google、微信、阿里大量采用 opaque token + 中心化 session 存储，而非纯 JWT，原因恰恰是 JWT 难撤销、密钥要轮换、塞进 Cookie 易超 4KB。 **JWT 适合读多写少、跨域广、要水平扩展的场景；撤销频繁、claims 重时，opaque token + 中心化存储反而更稳。选型是 trade-off，不是非黑即白。**

四、安全悖论：无状态怎么踢人？

如果面试官懂安全，绝不会就此罢休。他会点出 JWT 的命门：

> "JWT 无状态意味着一旦签发，过期前无法撤销。用户改密码或被封号，黑客手里的旧 JWT 还能用，你怎么踢人？"

收口解法： **Access Token + Refresh Token 双令牌 + 轻量黑名单** 。

1\. 双 Token 架构

- **Access Token（短效）**
	有效期极短（如 5 分钟）。日常请求使用，本地验签不打 Redis，性能极高。
- **Refresh Token（长效）**

**流转逻辑** ：Access Token 过期，前端拿 Refresh Token 找服务端换新。服务端这一步查 Redis——若用户状态异常，拒绝刷新，强制下线。

![[raw/assets/weixin/sso-system/dual-token.webp]]

▲ 双 Token 架构：Access 短效本地验签 vs Refresh 长效存 Redis

2\. 为什么 Redis 这次扛得住？两个维度：

- **流量维度（QPS 降 99%）**
	Session 模式 100% 请求查 Redis；双 Token 下 Access Token 挡掉 99% 流量（本地验签），仅每 5 分钟过期时才查一次 Redis。
- **存储维度（冷热分离）**
	Redis 只存"活跃用户"的 Refresh Token；长期不活跃的下沉到 HBase / RocksDB 冷存储。

注意区分：这里"Redis 压力小"指的是 **高频验签被 JWT 卸载** ；Refresh Token 本身仍是千万级 key 正常驻留 Redis——它承担的是"低频但必须有状态"的操作，并非被消灭。

3\. 5 分钟安全真空期怎么补？

面试官继续发难："这 5 分钟内黑客疯狂操作怎么办？"

最终兜底： **JTI（JWT ID）极速黑名单** 。仅在管理员"主动踢人 / 封号"的极端场景，把该 JWT 的唯一标识 `jti` 写入 Redis， **Key 的 TTL 严格等于该 JWT 剩余有效期（最长不到 5 分钟）** 。Redis 只存"被踢的极少数"，内存近乎为零，5 分钟后自动释放，却实现了无状态架构下的秒级精准踢人。

（进阶补刀：用户改密码的"全量吊销"，靠批量失效 Refresh Token + 缩短 Access Token 容忍窗口实现，属另一层操作，面试可主动点出以示完整。）

五、代码落地：Java 版 Token 交换与安全细节

光说不练假把式，面试官要看落地能力。不仅要写出逻辑，还要防住 XSS 与 CSRF。

@RestController

public class SsoLoginController {

@Autowired

private SsoService ssoService;

/\*\*

\* 业务系统的回调接口

\* /callback?code=ST-99999

\*/

@GetMapping("/callback")

public void loginCallback(@RequestParam("code") String code,

HttpServletResponse response) {

// 1. 【后端通道】拿 Code 去换取用户凭证 (内部网络 RPC/HTTP)

// 进阶：移动端 / SPA 建议加 PKCE，防 Code 截获重放；OIDC 下此处拿到 ID Token

SsoUser user = ssoService.validateAndRetrieveUser(code);

if (user!= null) {

// 2. 【核心】签发 JWT (无状态，高频请求免查库)

String accessToken = JwtUtil.createAccessToken(user.getId());

// 签发 RefreshToken：写 httpOnly Cookie 传输，同时存 Redis 用于校验/吊销 (7天)

String refreshToken = JwtUtil.createAndStoreRefreshToken(user.getId());

// 3. 写入当前域名的 Cookie (防 XSS)

Cookie accessCookie = new Cookie("access\_token", accessToken);

accessCookie.setHttpOnly(true);

accessCookie.setPath("/");

accessCookie.setSecure(true); // 生产必须 HTTPS

// accessCookie.setAttribute("SameSite", "None"); // 跨站调用必加

response.addCookie(accessCookie);

// 4. 【安全细节】Refresh Token 严格限制读取路径，防业务接口越权读取

Cookie refreshCookie = new Cookie("refresh\_token", refreshToken);

refreshCookie.setHttpOnly(true);

refreshCookie.setPath("/auth/refresh"); // 关键：路径隔离

refreshCookie.setSecure(true);

response.addCookie(refreshCookie);

response.sendRedirect("/home");

} else {

response.sendRedirect("/error");

}

}

}

六、架构权衡：单点登出（SLO）的边界

补上开篇的第三个坑："怎么保证全网同步退出？"

这是公网工程上的 **最终一致性妥协** ——复杂公网环境下，百分百实时的单点登出并不存在。拍胸脯保证绝对一致的，要么没做过大流量系统，要么在回避问题。

架构师的解法是组合拳兜底：

1. **尽最大努力（后端广播）**
	认证中心遍历所有已注册子系统，并行发送 Logout 请求。能通知一个是一个。
2. **前端联动（跨域清除）**
3. **最终兜底（短效 Token）**
	即便广播全部超时失败，Access Token 只有 5 分钟寿命，到点全网自动下线。

**话术总结** ："公网下没有强一致的实时 SLO，我们用'后端广播 + 前端埋点'尽力同步，配短效 Token 作最终兜底，在极致体验和系统高可用之间取得最佳平衡。"

七、架构师自问：如果面试官继续追问

真到 P8 面，上面这套还会被继续深挖。备好三个高频追问，能让你从"背过"变成"真懂"：

1. **JWT 密钥怎么轮换？**
	签名密钥泄露等于全网沦陷。大厂用非对称签名（RS256），公钥通过 JWKS 端点下发，业务端只验不放私钥；轮换时新旧密钥并行一段宽限期，旧 token 在窗口内仍有效。
2. **Redis 挂了怎么办？**
	Refresh Token 换不发，全网强制下线？实际靠多级缓存 + 本地降级：Redis 故障时用本地布隆过滤器 / 短缓存顶住读，写入走异步补偿，保住可用性。
3. **批量过期雷暴怎么防？**
	若上亿 Access Token 同 TTL 签发，5 分钟一到集体刷新，Redis 瞬时被打爆。解法：签发时给 TTL 加随机 jitter（如 5±2 分钟），把流量摊平。

总结

面试大厂的 SSO，千万别只背"设置 Cookie Domain"。

- **协议演进**
	懂 CAS 票据流转，拥抱 OAuth2 / OIDC（认清代际差异与身份层）。
- **无状态化**
	用 JWT 卸载高频验签压力，但认清它是混合架构，Redis 仍承担低频状态。
- **安全闭环**
	Access + Refresh 双 Token + JTI 黑名单，破解"无状态无法踢人"悖论。
- **架构权衡**
	承认 SLO 局限，用组合拳兜底；选型是 trade-off，不是非黑即白。

> 架构设计的本质，不是追求完美的"强一致"，而是管理"不确定性"。

我是 Fox，一个死磕 Java 后端技术的架构师。如果这篇复盘对你有帮助，欢迎 **点赞转发** ，关注公众号 **Fox爱分享** ，回复「面试 **」领取完整JAVA+AI面试八股文 + 场景题资料，我们下期见！**

大厂面试题 · 目录

<iframe allow="clipboard-write; web-share" src="chrome-extension://eigdjhmgnaaeaonimdklocfekkaanfme/side-panel.html?context=iframe"></iframe>
