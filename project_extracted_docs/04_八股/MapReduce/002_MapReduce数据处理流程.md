# MapReduce数据处理流程

## 一句话结论

MapReduce先把输入记录转换为中间KV，再借助分区和Shuffle让相同Key汇聚到同一Reduce，最后写出新的HDFS结果文件。Map端负责分区、缓存、溢写和归并，Reduce端负责拉取、归并、分组和业务计算，从而兼顾同Key聚合与多Map并行处理，提高集群资源利用与吞吐，并提升分布式聚合效率和稳定性。

## 核心因果链

InputSplit经RecordReader解析为记录 → Map输出中间KV
Partitioner按Key和Reduce数量计算分区 → 相同Key进入同一Reduce
KV写入内存缓冲 → 达阈值后按分区、Key排序并Spill到本地磁盘
多个Spill文件归并 → 得到按分区组织、分区内Key有序的Map本地输出
每个Reduce在Map输出可用时拉取自己的分区数据 → 归并排序并按Key分组
reduce()处理每组Value → OutputFormat写入新的HDFS结果文件

## 实际开发例子

若统计AI蓝军项目ODS蓝军内容表中各`content_type`的内容数量，Map输出`<类型,1>`；相同类型数据经Shuffle汇入同一Reduce求和，结果写入新的DWD结果分区，不改写ODS源表，供下游查询。

## 易错点

- 分区由Key和Reduce数量决定，默认通常采用哈希。
- Spill阈值可配置，80%不是固定规则。
- Spill写Map本地磁盘，最终结果才通过OutputFormat写HDFS。

## 30秒面试回答

MapReduce内部处理时，RecordReader先将InputSplit解析为记录，Map将记录输出为中间KV。Partitioner根据Key和Reduce数量计算分区，保证相同Key进入同一Reduce。Map输出先进入内存缓冲，达到可配置阈值后按分区、Key排序并溢写到本地磁盘，多次Spill再归并为Map输出。每个Reduce从所有Map拉取自己的分区，归并排序并按Key分组，对每组Value调用reduce完成业务计算，最后由OutputFormat写入新的HDFS结果文件。分区数等于Reduce数，Map端的本地有序文件为Reduce拉取和分组创造条件。经典实现通常保证分区内Key有序。

## 高频追问

- Reduce数与Group By：决定输出分区；同Key同Reduce、多Key同任务；热点Key会倾斜。
- 为什么先缓冲再Spill：减少小I/O，同时防止内存溢出。
- Shuffle范围：Map端分区排序到Reduce端拉取归并排序。

## 官网依据

- [Map Parameters](https://hadoop.apache.org/docs/r2.6.4/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html#Map_Parameters)：说明Map输出进入内存缓冲、达到阈值后后台排序并溢写，以及最后归并文件。
- [Partitioner](https://hadoop.apache.org/docs/stable1/mapred_tutorial.html)：说明分区由Key导出，分区数与Reduce任务数相同，默认使用HashPartitioner。
- [Reducer API](https://hadoop.apache.org/docs/current/api/org/apache/hadoop/mapreduce/Reducer.html)：说明Reduce依次经历Shuffle、Sort和Reduce三个阶段。
