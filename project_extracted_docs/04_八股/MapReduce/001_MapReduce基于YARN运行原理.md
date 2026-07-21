# MapReduce基于YARN运行原理

## 一、面试主答

1. MapReduce负责数据计算，YARN负责集群资源管理。客户端把HDFS输入输出路径写入Job配置，并提交程序资源和作业信息；ResourceManager先分配一个Container，由对应NodeManager启动MRAppMaster。
2. MRAppMaster负责这一整个作业：读取作业和InputSplit信息，向ResourceManager申请Map、Reduce任务所需Container，监控任务进度并处理重试。它不是只管理一个节点，也不亲自处理业务数据。
3. ResourceManager尽量按HDFS数据位置安排Map Container，各节点的NodeManager负责启动和管理本机Container；Map任务直接读取HDFS，中间结果经Shuffle交给Reduce，Reduce再把结果直接写入HDFS。
4. 一个作业的任务通常分散在多个节点并行执行，Map数量主要由InputSplit决定，Reduce数量由作业配置决定。NodeManager不负责规划作业或读写HDFS，ApplicationMaster也不是一台固定机器上的常驻公共服务。

## 二、关键流程或代码

```text
Client提交作业 → RM分配首个Container → NM启动MRAppMaster
MRAppMaster读取InputSplit → 向RM申请任务Container
RM按资源与数据位置调度 → 各NM启动Map Task
Map直读HDFS → Shuffle → 各NM启动Reduce Task
Reduce直写HDFS → MRAppMaster结束并释放资源
```

## 三、本次讨论后的复盘结论

- **我原来容易混淆的点：** 曾认为一个NM管理多个AM、一次MapReduce作业通常集中在一个节点，并认为Reduce需要向NM申请创建HDFS输出文件。
- **修正后的理解：** NM只管理本机Container；AM运行在某个Container中，却协调分散在多个节点的整个作业。任务进程直接访问HDFS，NM只负责容器生命周期和节点资源状态。
- **以后判断问题的标准：** 按“全局资源、本机容器、单个应用、具体计算”四层区分RM、NM、AM和Task。
- **一句话记忆：** RM分资源，NM管本机，AM管作业，Task做计算。

## 四、高频追问

### 追问1：RM、NM和AM分别负责什么？

RM掌握全局资源并进行调度，NM汇报并管理本机Container。AM只服务一个Application，负责申请资源、协调任务和监控进度；Map、Reduce Task才执行具体计算。

### 追问2：为什么Map任务尽量靠近HDFS数据？

Map通常需要读取大量输入数据，把计算安排到数据所在节点或同机架，可以减少跨节点、跨机架传输。无法完全本地化时仍可远程读取，数据本地性是调度偏好，不是硬性保证。

### 追问3：MapReduce怎么知道HDFS输入路径？

输入路径由客户端放入Job配置，而不是RM猜出来。InputFormat依据配置查询文件并生成InputSplit，Split携带逻辑范围和位置提示，供AM安排Map任务。

## 五、项目或开发场景映射

- **通用开发场景：** 一张按天分区的大表可生成多个InputSplit，对应Map任务分散到多个节点读取；Reduce聚合后把新结果写回HDFS。
- **本项目可真实使用的表述：** DWD蓝军内容SQL读取ODS的`${bizdate}`分区并覆盖写入DWD当天分区，这是仓库可确认的输入输出关系。
- **不能过度表述的部分：** 仓库不能证明该SQL实际由MapReduce on YARN执行，因此不能声称真实Container数量、任务节点分布或数据本地率。

## 六、参考依据

- [Apache Hadoop YARN](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html)：说明RM、NM、ApplicationMaster和Container的职责划分。
- [MapReduce Tutorial](https://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html)：说明作业提交、输入切分、任务执行和数据本地性。
