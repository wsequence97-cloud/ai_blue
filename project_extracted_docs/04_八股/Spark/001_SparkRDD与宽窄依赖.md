# Spark RDD与宽窄依赖

## 一句话结论

RDD是Spark最基础的分布式、不可变、可恢复数据集合抽象：数据被划为多个分区并行处理，血缘记录其来源和转换。窄宽依赖决定分区之间是否需要重分发数据，宽依赖通常带来Shuffle和新的Stage。

## 核心因果链

HDFS或其他数据源 → 创建包含多个分区的基础RDD
Transformation不修改原RDD → 生成新RDD并记录血缘
Action触发执行 → Spark按分区生成Task计算结果
分区丢失 → 依据血缘重新计算该分区 → 实现容错
子分区最多依赖一个父分区 → 窄依赖 → 通常可连续执行、无Shuffle
子分区依赖多个父分区 → 宽依赖 → 跨分区汇集数据、通常产生Shuffle

## 实际开发例子

若用Spark处理项目ODS蓝军内容表当天分区：读取`pt`数据得到rdd0，`filter`空内容、`map`成`<content_type,1>`均是窄依赖；`reduceByKey`统计类型数量时，一个结果分区需汇集多个上游分区数据，属于宽依赖。

## 易错点

- RDD不是Parquet等数据格式，也不等于创建后立即全量入内存。
- 源RDD没有父RDD；父RDD数量多不必然是宽依赖，如union。
- 判断标准是子分区依赖几个父分区，不是看有几个父RDD。

## 30秒面试回答

RDD是Spark最基础的分布式数据抽象，全称是弹性分布式数据集。它把数据切成多个分区，由不同Task并行处理；RDD不可变，`map`、`filter`等转换不会修改原RDD，而是生成新RDD并记录血缘。Transformation采用惰性执行，RDD创建后不会因此全量常驻内存，遇到`count`、`save`等Action才真正调度计算；分区丢失时可按血缘重算。窄依赖指一个子分区最多依赖一个父分区，通常不需要Shuffle；宽依赖指一个子分区需多个父分区的数据，通常会产生Shuffle和新的Stage，例如`reduceByKey`。

## 高频追问

- RDD为什么不可变：保证稳定血缘，避免并行修改冲突。
- cache和RDD关系：首次Action计算后缓存分区，减少重复血缘重算。
- 宽依赖为什么Shuffle：同Key或重分区数据原本分散，需跨分区汇集。

## 官网依据

- [Spark RDD Programming Guide](https://spark.apache.org/docs/latest/rdd-programming-guide.html)：说明RDD的分区并行、惰性Transformation、Action触发、缓存和容错重算。
- [Spark RDD API](https://spark.apache.org/docs/latest/api/java/org/apache/spark/rdd/RDD.html)：说明RDD具有分区、计算函数、依赖、可选分区器和位置偏好等核心属性。
- [Spark Shuffle Operations](https://spark.apache.org/docs/latest/rdd-programming-guide.html)：说明`reduceByKey`、`join`等需跨分区重分发数据的操作及其成本。
