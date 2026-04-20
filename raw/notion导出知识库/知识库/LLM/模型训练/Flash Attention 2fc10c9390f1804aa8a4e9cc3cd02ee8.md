# Flash Attention

所有者: he leyang
标签: 模型训练
上级 页面: 模型训练 (../%E6%A8%A1%E5%9E%8B%E8%AE%AD%E7%BB%83%202fb10c9390f180c2ba98f55e1178f575.md)
创建时间: 2026年2月3日 10:58

GPU **HBM（高带宽显存，容量大但慢）** ，**SRAM（片上缓存，容量小但极快）**

[https://courses.cs.washington.edu/courses/cse599m/23sp/notes/flashattn.pdf](https://courses.cs.washington.edu/courses/cse599m/23sp/notes/flashattn.pdf)

[](https://zhuanlan.zhihu.com/p/668888063)

Flash Attention原理

矩阵乘法可以通过分片累加并行计算，但softmax不行，依赖全局的分母，所以要采用**online-softmax**优化。

# 矩阵乘法Tiling

```python
# 外三层循环:遍历分片(Block level)
for ii from 0 to N step b:
    for jj from 0 to N step b:
        for kk from 0 to N step b:
            # 内三层循环:执行具体分片的矩阵乘法(Element level)
            for i from ii to min(ii+b, N):
                for j from jj to min(jj+b, N):
                    for k from kk to min(kk+b, N):
                        C[i][j] += A[i][k] * B[K][j]
```

![image.png](Flash%20Attention/image.png)

假设矩阵 **A**(N×N)、**B**(N×N)、**C**(N×N) 都被分成 **2×2** 的块(每块大小 b×b):

## 矩阵分片结构

```
矩阵 A (N×N):              矩阵 B (N×N):              矩阵 C (N×N):
┌─────┬─────┐              ┌─────┬─────┐              ┌─────┬─────┐
│ A₀₀ │ A₀₁ │              │ B₀₀ │ B₀₁ │              │ C₀₀ │ C₀₁ │
├─────┼─────┤              ├─────┼─────┤              ├─────┼─────┤
│ A₁₀ │ A₁₁ │              │ B₁₀ │ B₁₁ │              │ C₁₀ │ C₁₁ │
└─────┴─────┘              └─────┴─────┘              └─────┴─────┘
```

## 分片乘法累加过程

以计算 **C₀₀** 为例,需要将 A 的第0行块与 B 的第0列块进行乘法累加:

```
C₀₀ = A₀₀ × B₀₀ + A₀₁ × B₁₀
      └───┬───┘   └───┬───┘
      第1次累加    第2次累加
      (kk=0)      (kk=b)
```

完整的计算流程:

```
┌─────────────────────────────────────────────────────────┐
│  C₀₀ = A₀₀×B₀₀ + A₀₁×B₁₀                               │
│  C₀₁ = A₀₀×B₀₁ + A₀₁×B₁₁                               │
│  C₁₀ = A₁₀×B₀₀ + A₁₁×B₁₀                               │
│  C₁₁ = A₁₀×B₀₁ + A₁₁×B₁₁                               │
└─────────────────────────────────────────────────────────┘
```

## 三层循环对应关系

- **外层 ii 循环**: 遍历 A 的行块、C 的行块 (选择 C 的哪一行块)
- **外层 jj 循环**: 遍历 B 的列块、C 的列块 (选择 C 的哪一列块)
- **内层 kk 循环**: 遍历累加维度 (A 的列块 * B 的行块)

```
ii=0, jj=0:  计算 C₀₀
  └─ kk=0:  C₀₀ += A₀₀ × B₀₀
  └─ kk=b:  C₀₀ += A₀₁ × B₁₀

ii=0, jj=b:  计算 C₀₁
  └─ kk=0:  C₀₁ += A₀₀ × B₀₁
  └─ kk=b:  C₀₁ += A₀₁ × B₁₁

...(以此类推)
```

> **关键优势**: 分片后的小块矩阵可以**并行计算**,且每个块可以加载到**更快的内存层级**(如 SRAM/Cache),减少昂贵的全局内存访问。
> 

# 3-Pass Softmax

1. 计算最大值
2. 计算全局的指数和
3. 计算softmax分数

$\text{softmax}(\{x_1, \dots, x_N\}) = \left\{ \frac{e^{x_i}}{\sum_{j=1}^N e^{x_j}} \right\}_{i=1}^N$

> 其中${x_1,…,x_N}$就是$QK^T$，`pre-softmax logits`
1.  提前计算好$x$，保存在HBM中，需要$O(N^2)$显存，可能会爆显存
 2. online计算$x_i$，每次循环load QK到SRAM，计算$x_i$
> 

![image.png](Flash%20Attention/image%201.png)

> **瓶颈**：`pre-softmax logits`显存需求为$O(N^2)$，如果没有足够到的SRAM来保存，需要重新访问QK，计算`x_i`。
> 

# 2-Pass Online Softmax

去掉对全局$x_N$的依赖，第一步和第二步共享$x_i$减少一次访存。

$$
\begin{aligned}
d'_i &= \sum_{j=1}^{i} e^{x_j - m_i} \\
&= \left( \sum_{j=1}^{i-1} e^{x_j - m_i} \right) + e^{x_i - m_i} \\
&= \left( \sum_{j=1}^{i-1} e^{x_j - m_{i-1}} \right) e^{m_{i-1} - m_i} + e^{x_i - m_i} \\
&= d'_{i-1} e^{m_{i-1} - m_i} + e^{x_i - m_i}
\end{aligned}
$$

![image.png](Flash%20Attention/image%202.png)

> 2-pass算法相对于3-pass算法，可以减少一次整体的load Q, K以及减少一次对$x_i$的online-recompute，因为在2-pass的第一个pass中，$x_i$是被两次计算共享的。
> 

# `Multi-pass Self-Attention`

原始的`Multi-pass Self-Attention`：

![image.png](Flash%20Attention/image%203.png)

> 只是在2-pass online softmax基础上增加了attention计算
$o_i$依赖$o_{i-1}$，需要两个pass
> 

# FlashAttention数学原理

## 1-pass FlashAttention

对$o_i$进行优化，消除$o_{i-1}$的依赖，合并两个pass

![image.png](Flash%20Attention/image%204.png)

![image.png](Flash%20Attention/image%205.png)

## 分片FlashAttention

1. 第一步：计算局部得分与最大值
    - $x_i \leftarrow Q[k,:] K^T[:, (i-1)b : ib]$: 计算当前 $Q$ 的某一行与 $K$ 的第 $i$ 个分块的点积。
    - $m_i^{(\text{local})} = \max(x_i[j])$: 找到当前块内的局部最大值。
    - $m_i = \max(m_{i-1}, m_i^{(\text{local})})$: 关键步骤。 将之前的全局最大值与当前块的局部最大值对比，更新截至目前看到的全局最大值 $m_i$。
2. 更新分母（归一化项）
    - $d'_{i}$ *的更新:*
    
    $$
    d'i \leftarrow d'_{i-1} e^{m_{i-1}-m_i} + \sum e^{x_i[j]-m_i}
    $$
    
    - 这里使用了 **指数修正**。因为最大值$m_i$ 可能已经变了，所以需要将旧的分母 $d'_{i-1}$ *乘*以一个缩放因子 *$e^{m_{i-1}-m_i}$*，再加上当前块的指数和。
    - $o’_i$的修正同理，$d'_{i}$和$m'_i$更新了，要在旧的项上乘上修正因子：

$$
\boldsymbol{o}_i^{\prime} \leftarrow \boldsymbol{o}_{i-1}^{\prime} \frac{d_{i-1}^{\prime} e^{m_{i-1}-m_i}}{d_i^{\prime}}+\sum_{j=1}^b \frac{e^{\boldsymbol{x}_i[j]-m_i}}{d_i^{\prime}} V[j+(i-1) b,:]
$$

1. 更新输出结果（加权和）
    - $o'_i$ **的更新：对旧的输出结果 *$o'_{i-1}$* 进行缩放，并加上当前分块贡献的新值，整个过程都在 SRAM 中完成，不需要写回 HBM。

![Snipaste_2026-02-03_15-40-37.png](Flash%20Attention/Snipaste_2026-02-03_15-40-37.png)

![Snipaste_2026-02-03_15-40-42.png](Flash%20Attention/Snipaste_2026-02-03_15-40-42.png)

![image.png](Flash%20Attention/image%206.png)

# FlashAttention V1工程实现

![image.png](Flash%20Attention/image%207.png)

- 前向传播：online-softmax和tilling优化

![image.png](Flash%20Attention/image%208.png)

- 反向传播：主要优化是recompute+tiling
    - 前向传播时不会保留S和P矩阵（因为是online计算的），所以反向传播的时候重新分块加载QKV，online计算