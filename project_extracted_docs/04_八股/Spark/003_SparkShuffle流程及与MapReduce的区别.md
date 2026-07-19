# Spark Shuffle流程及与MapReduce的区别

## 一句话结论

Spark在宽依赖处通过Shuffle按目标分区重新分发数据，让相同Key汇集到同一个下游Task完成聚合或Join。它与MapReduce的核心目的相同，但Spark按DAG灵活切Stage，Executor可复用本地中间数据和缓存，不必在每个计算边界都写HDFS业务文件。

## 核心因果链

Action触发Job → Driver发现宽依赖 → 上游Stage按分区执行Task
上游Task按目标分区组织KV → `reduceByKey`可先局部聚合 → 写Executor本地Shuffle文件
执行内存不足 → Spill本地磁盘并归并 → 不能把Spark理解为纯内存计算
宽依赖形成Stage边界 → 下游Task从所有上游Task拉取属于自己分区的数据块
下游在执行内存中合并、聚合或Join → 数据过大仍会Spill本地磁盘
窄依赖可在同一Stage连续执行 → 最终`write`才写HDFS业务结果

## 实际开发例子

假设用Spark统计ODS蓝军内容表当天各`content_type`数量：上游分区输出`<类型,1>`，按类型Shuffle；每个下游Task拉取所有上游中属于自己类型分区的数据并求和，最后写出新的结果分区。该示例不代表项目当前实际使用Spark。

## 易错点

- Spark Shuffle不是只在内存中，Map和下游端都可能Spill本地磁盘。
- `reduceByKey`只保证同Key同分区，不保证业务结果按Key有序。
- Spark也支持分区器和自定义分区规则，分区数不等于Key种类数。

## 30秒面试回答

Spark Shuffle 发生在`reduceByKey`、`join`、`repartition`等宽依赖处。上游Task先按目标分区组织数据，`reduceByKey`可在Map侧局部聚合，随后将供下游拉取的Shuffle数据写到Executor本地；内存不足时会Spill到本地磁盘。下游Task从所有上游Task拉取属于自己分区的数据，合并并完成聚合或Join，数据过大也会落盘。它和MapReduce的Shuffle都用于让同Key汇集，但MapReduce单个Job模板固定，复杂流程常以多个Job和HDFS中间结果串联；Spark按DAG的宽依赖切Stage，窄依赖连续执行，Executor还能复用进程和缓存，从而降低重复启动和读取开销。

## 高频追问

- 为什么`reduceByKey`比`groupByKey`省网络：可先在上游分区局部聚合。
- Spark与MR是否都用本地磁盘：都可能使用，Spark并非纯内存。
- Shuffle与Stage关系：宽依赖通常是Stage边界，窄依赖不切分。

## 官网依据

- [Spark Shuffle Operations](https://spark.apache.org/docs/latest/rdd-programming-guide.html)：说明Shuffle重分发、`reduceByKey`等触发场景、Map端文件和内存不足时的Spill。
- [Spark Tuning Guide](https://spark.apache.org/docs/latest/tuning.html)：说明执行内存用于Shuffle、Join、排序、聚合，存储内存用于缓存，以及统一内存管理。
- [Hadoop MapReduce Tutorial](https://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html)：说明Map输出排序后交给Reduce的固定MapReduce处理模型。
