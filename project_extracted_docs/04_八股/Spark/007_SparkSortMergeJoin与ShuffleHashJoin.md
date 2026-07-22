# Spark SortMergeJoin与ShuffleHashJoin

## 一、面试主答

SortMergeJoin（SMJ）和 ShuffleHashJoin（SHJ）都用于等值 Join。在两侧数据没有满足 Join 要求的分区方式、且不能使用广播 Join 时，它们通常都需要先按照 Join Key 对两张表进行 Shuffle，使相同 Key 的数据进入相同的下游分区。这里是按 Key 的哈希值重新分区，并不是一个 Key 独占一个分区。

两者的主要区别在于下游 Task 的关联方式：

1. **SortMergeJoin**：两侧 Shuffle 后，在各自分区内按 Join Key 排序，然后使用类似归并排序的方式顺序比较并输出匹配数据。
2. **ShuffleHashJoin**：两侧 Shuffle 后，每个下游 Task 选择较小一侧的当前分区构建哈希结构，再逐行读取较大一侧的对应分区进行 Probe，不需要对两侧排序。
3. **选型区别**：SMJ 有额外排序成本，但可以借助 Spill 处理较大数据，更适合两张大表关联；SHJ 省去排序，平均哈希查询较快，但要求每个 Task 的 Build Side 分区能够安全放入执行内存。

因此可以把两者概括为：**SMJ 是两边 Shuffle、两边排序、顺序 Merge；SHJ 是两边 Shuffle、小侧 Build、大侧 Probe。**

## 二、关键流程或代码

假设订单表和地区表按照 `region_id` 关联：

```sql
SELECT o.order_id, o.amount, r.region_name
FROM fact_order o
JOIN dim_region r
  ON o.region_id = r.region_id;
```

两种策略都要先让相同 `region_id` 进入相同下游分区：

```text
共同阶段：
fact_order  --Exchange hashpartitioning(region_id)--+
                                                   +--> 对应下游分区
dim_region  --Exchange hashpartitioning(region_id)-+

SortMergeJoin：
订单分区：[1:O1, 1:O3, 2:O4, 4:O5]  --排序--+
                                                  +--> 双指针顺序 Merge
地区分区：[1:浙江, 2:江苏, 3:安徽]      --排序--+

ShuffleHashJoin：
地区分区（较小）--Build--> {1 -> 浙江, 2 -> 江苏, 3 -> 安徽}
订单分区（较大）--Probe--> O1:1 -> 浙江，O4:2 -> 江苏
```

对应的典型物理计划为：

```text
SortMergeJoin [region_id], [region_id], Inner
:- Sort [region_id ASC]
:  +- Exchange hashpartitioning(region_id)
+- Sort [region_id ASC]
   +- Exchange hashpartitioning(region_id)

ShuffledHashJoin [region_id], [region_id], Inner, BuildRight
:- Exchange hashpartitioning(region_id)
+- Exchange hashpartitioning(region_id)
```

`BuildRight` 表示 SHJ 使用右侧当前分区构建哈希结构。它与 BroadcastHashJoin 的区别是：BHJ 把整张小表广播到各 Executor，而 SHJ 只在每个下游 Task 中为 Build Side 的对应 Shuffle 分区建哈希结构。

## 三、本次讨论后的复盘结论

- **我原来容易混淆的点：** 已经理解两种策略通常都需要按 Join Key Shuffle，并认为区别主要是下游 Task 分别采用排序归并和哈希查询；但没有明确 Shuffle 重新分区、SMJ 分区内排序以及 SHJ 分区级 Build 的边界。
- **修正后的理解：** Shuffle 负责让相同 Key 的两侧数据进入同一个下游分区；SMJ 在 Shuffle 后分别排序并 Merge，SHJ 在 Shuffle 后使用较小一侧的当前分区 Build、较大一侧 Probe。
- **以后判断问题的标准：** 先判断是否需要数据重分布，再判断下游是“排序后顺序归并”还是“小侧建哈希、大侧查询”，最后评估排序成本、Build Side 内存和数据倾斜。
- **一句话记忆：** SMJ 两边 Shuffle 后排序归并；SHJ 两边 Shuffle 后分区级小表 Build、大表 Probe。

## 四、高频追问

### 1. SortMergeJoin 和 ShuffleHashJoin 一定会让两侧都 Shuffle 吗？

不一定。如果输入已经具备与 Join Key 兼容的分区布局，Spark 可能复用现有分区，消除一侧或两侧的 `Exchange`。因此“两边都 Shuffle”是普通未预分区场景下的典型情况，不是绝对规则。

### 2. SortMergeJoin 为什么更适合两张大表？

SMJ 不需要把任意一侧的整个分区长期保存在哈希表中，排序过程可以在内存不足时 Spill 到磁盘，因此面对较大分区时稳定性通常更好。代价是两侧都需要排序，会增加 CPU、磁盘 I/O 和执行时间。

### 3. ShuffleHashJoin 为什么可能比 SortMergeJoin 快？

SHJ 不需要对两侧分区排序，小侧构建哈希结构后，大侧单次查询平均接近 `O(1)`。但性能优势建立在 Build Side 的每个分区足够小、能够安全放入 Task 执行内存的前提下。

### 4. 两种 Join 如何受到数据倾斜影响？

热点 Key 会让对应的 Shuffle 分区远大于其他分区，两种策略都会出现慢 Task。SMJ 可能产生大量排序和 Spill；SHJ 如果热点落在 Build Side，还可能形成过大的哈希结构，引起严重内存压力。若倾斜来自重复 Key 导致的关联结果爆炸，单纯更换 Join 策略也无法消除输出膨胀。

### 5. 三种常见等值 Join 如何快速区分？

| Join策略 | 主要数据移动 | 下游关联方式 | 主要限制 |
| --- | --- | --- | --- |
| BroadcastHashJoin | 小表广播，大表通常不为 Join Shuffle | 整张小表 Build，大表 Probe | 广播数据必须能被各 Executor 持有 |
| ShuffleHashJoin | 两侧通常按 Key Shuffle | 分区级小侧 Build、大侧 Probe | Build Side 的单个分区必须能放入内存 |
| SortMergeJoin | 两侧通常按 Key Shuffle | 两侧排序后顺序 Merge | 存在排序和 Spill 开销 |

## 五、项目或开发场景映射

- **通用开发场景：** 两张大型事实表进行等值关联时，可以优先观察 SMJ；若其中一侧整体无法广播，但经过 Shuffle 后每个分区明显更小，可以评估 SHJ。
- **本项目可真实使用的表述：** 面对订单、日志等数据关联，可以通过 `EXPLAIN` 检查 `Exchange`、`SortMergeJoin`、`ShuffledHashJoin` 和 `BuildRight` 等节点，再结合 SQL UI 中的 Shuffle、Spill、Task 时长和内存指标判断瓶颈。
- **不能过度表述的部分：** 缺少真实执行计划、表统计信息和运行指标时，不能仅根据“两张表一大一小”断言 Spark 一定采用 SHJ，也不能宣称切换策略后获得了具体性能收益。

## 六、参考依据

- [Apache Spark SQL Performance Tuning](https://spark.apache.org/docs/latest/sql-performance-tuning.html)：说明 `MERGE`、`SHUFFLE_HASH` 等 Join Strategy Hint，以及 Hint 和 Join 类型的适用边界。
- [Apache Spark RDD Programming Guide：Shuffle Operations](https://spark.apache.org/docs/latest/rdd-programming-guide)：说明 Shuffle 涉及数据重新分布、网络传输、排序与磁盘 I/O 等成本。
