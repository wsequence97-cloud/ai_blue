# Spark BroadcastHashJoin执行原理

## 一、面试主答

BroadcastHashJoin（BHJ）常用于大表关联小表，但需要先区分两个概念：广播变量是 Spark 提供的通用只读共享变量机制；BroadcastHashJoin 则是 Spark SQL 利用广播机制实现的一种 Join 策略，广播变量本身不会自动完成哈希关联。

BHJ 的执行过程可以概括为 **小表 Build、大表 Probe**：

1. Spark 选择较小的一侧作为 Build Side，按 Join Key 构建 `HashedRelation`。
2. `BroadcastExchange` 将构建好的小表哈希结构广播到各个 Executor。
3. 大表作为 Streamed Side，保留原有分区；每个分区逐行提取 Join Key，在 Executor 本地查询哈希结构。
4. 命中后还要比较真实 Key，确认相等才输出结果，因此哈希冲突不会造成错误关联。

它的核心优势是避免大表为了 Join 按 Key 进行 Shuffle，适合维表能够放入 Driver 和每个 Executor 内存的场景。判断是否使用 BHJ 时，不能只看表的总大小，还要考虑 Join 类型、统计信息、Executor 数量、广播超时以及关联后的结果膨胀。

## 二、关键流程或代码

例如订单事实表关联地区维表：

```sql
SELECT /*+ BROADCAST(d) */
       f.order_id,
       f.amount,
       d.region_name
FROM fact_order f
JOIN dim_region d
  ON f.region_id = d.region_id;
```

假设数据如下：

| fact_order | region_id | amount |
| --- | ---: | ---: |
| O1 | 1 | 100 |
| O2 | 3 | 80 |
| O3 | 1 | 50 |
| O4 | 2 | 70 |

| dim_region.region_id | region_name |
| ---: | --- |
| 1 | 浙江 |
| 2 | 江苏 |
| 3 | 安徽 |

执行过程：

```text
Build Side：dim_region
    按 region_id 构建 HashedRelation
    {1 -> 浙江, 2 -> 江苏, 3 -> 安徽}
                 |
          BroadcastExchange
                 |
       广播到每个 Executor

Probe Side：fact_order 的各个分区
    O1: hash(1) -> 定位桶 -> 比较 Key -> 浙江 -> 输出 O1,100,浙江
    O2: hash(3) -> 定位桶 -> 比较 Key -> 安徽 -> 输出 O2,80,安徽
    O3: hash(1) -> 定位桶 -> 比较 Key -> 浙江 -> 输出 O3,50,浙江
    O4: hash(2) -> 定位桶 -> 比较 Key -> 江苏 -> 输出 O4,70,江苏
```

典型物理计划可表示为：

```text
BroadcastHashJoin [region_id], [region_id], Inner, BuildRight
:- Scan fact_order
+- BroadcastExchange
   +- Scan dim_region
```

其中 `BuildRight` 表示右侧维表用于构建哈希结构。平均情况下，单次哈希查询接近 `O(1)`，整体 Build 与 Probe 的时间复杂度可近似理解为 `O(M + N)`；但每个 Executor 都要保存一份大小约为 `O(M)` 的广播数据。

## 三、本次讨论后的复盘结论

- **原有理解**：大表关联小表时，把小表复制到 Executor，再用哈希让大表各分区本地关联。
- **需要修正**：这描述的是 BroadcastHashJoin，而不是广播变量的全部用途；广播变量只负责高效分发只读数据，不会自动建哈希表或执行 Join。
- **补充理解**：哈希发生在小表 Build 和大表 Probe 两个阶段。Probe 先通过哈希值定位桶，再比较真实 Key，因此即使发生哈希冲突，也不会产生错误结果。
- **判断标准**：优先评估 Build Side 能否被 Driver 收集并被每个 Executor 持有，再结合 Join 类型、统计信息、广播阈值和输出规模判断是否适合 BHJ。
- **一句话记忆**：小表 Build 成 `HashedRelation` 并广播，大表各分区本地 Probe，不让大表为 Join 做 Shuffle。

## 四、高频追问

### 1. 两个不同的 Key 哈希到同一个位置怎么办？

这是哈希冲突。哈希结构不会只根据哈希值认定匹配，而是在定位到候选桶后继续比较真实 Join Key。不同 Key 即使进入同一个桶，也不会被错误关联；冲突较多时主要影响查询性能。

### 2. 小表中存在重复 Join Key 怎么处理？

重复 Key 不是哈希冲突。`HashedRelation` 会保留该 Key 对应的多条记录，大表的一条记录命中后可能输出多条结果。这属于一对多 Join 的正常结果膨胀，需要关注内存和输出数据量。

### 3. 广播 Join 能解决所有数据倾斜吗？

不能。BHJ 可以避免大表按 Join Key Shuffle，因此能够绕开 SortMergeJoin 中由热点 Key 引起的 Shuffle 分区倾斜；但它不能消除大表原始分区不均，也不能解决重复 Key 导致的输出结果爆炸。

### 4. 哪些情况不适合使用 BroadcastHashJoin？

- 小表无法安全放入 Driver 或每个 Executor 的内存。
- Executor 数量很多，广播副本带来的集群总内存开销过高。
- Join 类型不支持指定的一侧作为 Build Side，例如普通 BHJ 通常不能执行 Full Outer Join。
- 小表统计信息不准确、广播传输超时，或关联结果会大幅膨胀。
- 即使使用 `BROADCAST` Hint，Spark 仍会结合 Join 类型和执行条件判断能否采用该策略。

## 五、项目或开发场景映射

在数仓场景中，可以将订单、日志等大事实表作为 Streamed Side，将地区、商品分类、状态码等较小维表作为 Build Side。优化前应通过表统计信息和执行计划确认维表大小，并在运行时观察广播耗时、Executor 内存和 Join 输出行数。

如果项目中存在事实表关联小维表的 SQL，可以重点检查物理计划是否出现 `BroadcastHashJoin` 和 `BroadcastExchange`。当前卡片只给出通用判断方法，不在缺少执行计划和运行指标时宣称项目已经使用 BHJ 或获得了具体性能收益。

## 六、参考依据

- [Apache Spark RDD Programming Guide：Broadcast Variables](https://spark.apache.org/docs/latest/rdd-programming-guide)
- [Apache Spark SQL Performance Tuning：Join Strategy Hints 与广播阈值](https://spark.apache.org/docs/latest/sql-performance-tuning.html)
