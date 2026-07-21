# MapReduce数据处理流程

## 一、面试主答

1. MapReduce先把输入记录转换成中间KV，再通过Shuffle让相同Key进入同一个Reduce，最后生成新的结果文件。它解决的是分散数据如何并行处理并按Key汇总的问题。
2. Map端输出KV后，Partitioner依据Key和Reduce数量计算目标分区。数据先写内存缓冲，达到可配置阈值后按分区和Key排序并Spill到本地磁盘；多次Spill会归并成Map本地输出。
3. 每个Reduce从所有Map输出中拉取属于自己分区的数据，再归并排序、按Key分组，对每组Value调用`reduce()`完成聚合，最终由OutputFormat写入HDFS。
4. Reduce数量决定并行分区和通常的输出文件数量，不等于不同Key的数量。一个Reduce可处理多个Key，但同一个Key必须进入同一Reduce；热点Key因此可能造成数据倾斜。

## 二、关键流程或代码

```text
输入：abca、bc
Map：<a,1><b,1><c,1><a,1>；<b,1><c,1>
Partition：按hash(Key)和Reduce数确定目标分区
Spill/Merge：分区内按Key有序，写Map本地磁盘
Shuffle：各Reduce从所有Map拉取自己的分区
Group：a→[1,1]，b→[1,1]，c→[1,1]
Reduce/Output：<a,2><b,2><c,2> → HDFS
```

## 三、本次讨论后的复盘结论

- **我原来容易混淆的点：** 曾不清楚分区规则是否预先知道，并把Reduce数量理解成`resource_id`等业务Key的种类数量。
- **修正后的理解：** 目标分区由Partitioner结合Key和Reduce数量计算；Reduce数表示运行并行度，一个Reduce可以处理多个Key，但相同Key会被送到同一Reduce。
- **以后判断问题的标准：** 先区分业务分组Key、Shuffle分区和Reduce任务三层，再分析数据是否均匀。
- **一句话记忆：** Key决定去哪个Reduce，Reduce数决定有几条并行通道。

## 四、高频追问

### 追问1：为什么Map输出要先缓冲再Spill？

每产生一条KV就写磁盘会形成大量小I/O，全部留在内存又可能溢出。先在内存中批量组织，达到阈值后排序并写本地磁盘，是吞吐与内存上限之间的折中；80%只是常见配置值，不是固定定义。

### 追问2：Shuffle具体从哪里到哪里？

面试中通常把Map输出的分区、排序、Spill和归并，到Reduce跨节点拉取并归并排序这一段统称为Shuffle。核心判断是中间数据是否按目标分区重新组织并传给下游。

### 追问3：Reduce数量为什么会影响数据倾斜？

增加Reduce可以提高多个分区之间的并行度，但无法自动拆开单个热点Key，因为相同Key必须进入同一Reduce。若某个`resource_id`数据特别多，对应Reduce仍会成为长尾任务，需要单独治理热点Key。

## 五、项目或开发场景映射

- **通用开发场景：** 统计内容类型数量时，Map输出`<content_type,1>`，Shuffle汇集同类型数据，Reduce求和并写出结果。
- **本项目可真实使用的表述：** 项目ADS SQL存在按`resource_id`分组以及按内容类型统计的逻辑，可用于解释分组Key和聚合结果。
- **不能过度表述的部分：** 不能声称项目实际使用MapReduce引擎，或曾出现某个Key倾斜、特定Spill次数和性能收益，除非执行计划或运行记录能够证明。

## 六、参考依据

- [MapReduce Tutorial](https://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html)：说明Map输出缓冲、分区、排序、Spill、Shuffle及Reduce输出流程。
- [Reducer API](https://hadoop.apache.org/docs/current/api/org/apache/hadoop/mapreduce/Reducer.html)：说明Reducer的Shuffle、Sort与Reduce阶段。
