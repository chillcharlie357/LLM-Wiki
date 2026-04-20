---
title: Redis
source: https://www.notion.so/31a10c9390f18066ac87f4ef06447f49
---

# Redis

## Redis 实现消息队列

| 特性 | Redis Stream | Redis List | Redis pub/sub | Kafka | RabbitMQ |
| --- | --- | --- | --- | --- | --- |
| 消费者组 | 原生支持 | 需自己实现 | 不支持 | 支持 | 支持 |
| 消息确认 | ACK 机制 | 需业务层处理 | 无 | 支持 | 支持 |
| 消息持久化 | 支持 | 支持 | 不支持 | 支持 | 支持 |
| 消息回溯 | 支持 | 不支持 | 不支持 | 支持 | 不支持 |
| 部署复杂度 | 低 | 低 | 低 | 高 | 中 |
| 运维成本 | 低 | 低 | 低 | 高 | 中 |
| 适用规模 | 中小规模 | 简单队列 | 实时通知 | 大规模 | 中大规模 |

参考：[Redis 队列对比](https://zhuanlan.zhihu.com/p/758609965)

- Redis List 是双向链表，可以用 `LPUSH + RPOP` 或 `RPUSH + LPOP` 实现队列。
- 轮询会浪费 CPU；`BRPOP` 可阻塞，但异常时可能丢消息。
- List 出队即删，只适合单消费者。

## Pub/Sub 底层实现

Redis Pub/Sub 是典型的观察者模式实现，核心是两个结构：`pubsub_channels` 和 `pubsub_patterns`。

### 频道订阅：`pubsub_channels`

- Key 是频道名，Value 是订阅该频道的客户端链表。
- 订阅时创建或追加，退订时删除链表节点，空链表会被移除。

### 模式订阅：`pubsub_patterns`

- 使用链表存储 `{pattern, client}` 节点。
- 因为模式匹配无法 O(1) 查找，只能遍历整条链表。

### 发布消息：`PUBLISH`

1. 在 `pubsub_channels` 中查找精确频道并向所有订阅者广播。
2. 遍历 `pubsub_patterns`，匹配模式订阅并发送。

### 核心特点

| 特性 | 精确订阅 | 模式订阅 |
| --- | --- | --- |
| 底层结构 | Dict + List | List |
| 查找效率 | O(1) | O(N) |
| 存储位置 | `server.pubsub_channels` | `server.pubsub_patterns` |

### 常见坑

- Fire and Forget：客户端掉线会直接丢消息。
- 消费慢时会在输出缓冲区堆积，造成内存压力。
