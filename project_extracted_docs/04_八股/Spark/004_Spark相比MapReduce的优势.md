# Spark相比MapReduce的优势

## 一、面试主答

Spark相比MapReduce的优势，核心不是“纯内存计算”，而是通过更灵活的执行模型减少多阶段计算中的调度和I/O开销。

1. **执行模型更灵活。** Spark把多个算子组织成DAG，并以宽依赖形成的Shuffle为Stage边界。`map`、`filter`等窄依赖算子可以在同一个Task中流水线执行，不必为每一步单独生成HDFS中间结果；复杂MapReduce流程则通常需要串联多个Job。
2. **计算资源可以复用。** Executor是Application期间的长生命周期进程，可以连续执行多个Task，并复用缓存、广播变量和已经申请的资源，从而减少进程启动及资源申请开销。但窄依赖能够流水线执行的原因是分区依赖关系，而不是Executor复用。
3. **采用惰性计算。** Transformation只记录转换关系，遇到Action才触发Job。Spark可以根据完整DAG划分Stage并组织执行；MapReduce单个Job通常遵循Map、Shuffle、Reduce的阶段模型，复杂逻辑需要由多个Job衔接。
4. **更适合数据复用场景。** Spark可通过`cache/persist`复用已计算分区，因此适合多步骤ETL、迭代计算和交互式分析。不过Spark并非完全不落盘，Shuffle和内存不足时仍可能使用Executor本地磁盘；简单、稳定的一次性超大批处理也要结合资源与运维要求选型。

## 二、关键流程或代码

| 对比维度 | Spark | MapReduce |
| --- | --- | --- |
| 执行组织 | 用DAG组织算子，以Shuffle划分Stage | 单个Job主要按Map、Shuffle、Reduce阶段执行 |
| 中间数据 | 窄依赖可在同一Task中流水线处理；Shuffle数据可能写本地磁盘 | 复杂流程通常由多个Job串联，Job之间常通过HDFS保存结果 |
| 进程与资源 | Executor可连续执行多个Task，并复用缓存和广播变量 | 不同Task和Job之间的数据、进程复用能力相对有限 |
| 计算触发 | Transformation惰性执行，Action触发Job | Job提交后按既定阶段执行 |
| 典型场景 | 多步骤ETL、迭代计算、交互式分析 | 简单稳定、一次性的离线批处理 |

## 三、本次讨论后的复盘结论

- **我原来容易混淆的点：** 原来把Executor复用理解成窄依赖可以在同一个Stage中流水线执行的原因，并容易把“减少HDFS读写”说成“Spark不落盘”。
- **修正后的理解：** 窄依赖允许一个子分区按确定的父分区链连续计算，因此多个算子可以在同一个Task中执行；Executor复用解决的是进程启动、资源申请和缓存复用开销。Spark只是不必在每个计算步骤之间写HDFS，Shuffle或内存不足时仍可能写本地磁盘。
- **以后判断问题的标准：** 先区分“算子为什么能放进同一个Stage”和“Task由什么进程执行”，再分别比较计算链路、HDFS中间结果、Shuffle落盘和资源复用。
- **一句话记忆：** DAG减少计算链路切割，Executor减少运行开销，缓存减少重复计算。

## 四、高频追问

### 追问1：Executor复用为什么不是窄依赖流水线执行的原因？

窄依赖描述的是分区之间的依赖关系：一个子分区只需要少量确定的父分区，所以同一个Task可以沿着算子链连续计算。Executor只是承载Task的长生命周期进程，它的复用减少了进程启动和资源申请开销，但不决定Stage如何划分。

### 追问2：Spark是不是只在宽依赖处才会落盘？

不能这样绝对表述。宽依赖会产生Shuffle，Shuffle数据通常由Executor写入本地文件；即使没有Shuffle，内存压力、缓存级别或结果写出也可能涉及磁盘。Spark的优势是减少复杂流程中反复写入和读取HDFS中间结果，而不是完全取消磁盘I/O。

### 追问3：什么情况下MapReduce仍可能更合适？

对于逻辑简单、一次性执行、数据规模很大且对延迟不敏感的离线批处理，如果现有Hadoop环境成熟、内存资源有限并且更看重稳定性，MapReduce仍有使用价值。选型不能只比较理论速度，还要考虑任务类型、资源成本和运维体系。

## 五、项目或开发场景映射

- **通用开发场景：** 加工ODS数据时，读取分区、过滤空值、转换字段等窄依赖操作可以在同一个Task中连续执行；按业务维度聚合时才通过Shuffle重新分区，最终写出DWD或汇总结果。
- **本项目可真实使用的表述：** AI蓝军仓库中存在ODS到DWD的清洗、字段转换、关联和聚合链路，可以用这些SQL分析如果迁移到Spark后哪些算子可流水线执行、哪些操作可能触发Shuffle。
- **不能过度表述的部分：** 当前仓库材料不能证明项目实际使用Spark执行这些SQL，因此不能声称真实Stage数、Shuffle数据量、缓存命中率或性能提升比例。

## 六、参考依据

- [Spark RDD Programming Guide](https://spark.apache.org/docs/latest/rdd-programming-guide.html)：说明Transformation的惰性执行、Action触发计算、持久化以及Shuffle行为。
- [Hadoop MapReduce Tutorial](https://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html)：说明MapReduce的Map、Shuffle、Reduce处理阶段及任务执行模型。
