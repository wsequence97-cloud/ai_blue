# MapReduce基于YARN运行原理

## 一句话结论

MapReduce负责处理数据，YARN负责为作业分配资源并启动任务。一个MapReduce作业由MRAppMaster协调，Map和Reduce任务在YARN分配的Container中运行，并尽量靠近HDFS数据实现并行计算；资源管理与具体计算相互分离，多个应用和计算框架可共享集群资源，提高整体资源利用率。

## 核心因果链

Client准备Jar、配置和InputSplit并暂存HDFS → 向RM提交作业描述
RM分配首个Container → 对应NM启动MRAppMaster
AM获取作业和InputSplit元数据 → 协调每个Split对应的Map任务
AM按数据位置偏好向RM申请Map任务Container → NM启动Map任务并直读HDFS
Map中间结果经Shuffle分发 → AM申请Reduce任务Container并由NM启动
Reduce汇总后按HDFS写流程输出 → AM通知RM释放Container资源

## 实际开发例子

AI蓝军项目中，ODS蓝军内容表清洗写入DWD蓝军内容表。若该Hive任务采用MapReduce引擎，Map可并行读取ODS分区，执行结果写入DWD分区，不直接改写ODS源表。

## 易错点

- 大Jar和配置通常先暂存HDFS，RM接收作业描述和资源引用。
- NM管理本机Container的启动与资源状态，不负责HDFS读写。
- AM协调整个作业的任务和进度，不只协调一个节点。

## 30秒面试回答

MapReduce运行在YARN上时，客户端准备程序、配置和HDFS输入输出路径，相关资源通常先暂存HDFS，再向RM提交作业描述。RM先分配一个Container，由相应NM启动MRAppMaster。AM获取作业和InputSplit元数据，先向RM申请Map任务所需Container；RM尽量按数据位置分配，NM启动Map任务。Map任务直接从HDFS读取数据并计算，Map输出经过Shuffle后，AM再申请Reduce任务Container，NM启动Reduce任务。Reduce汇总结果后按HDFS写流程写出文件；作业结束后，AM通知RM释放资源。其中AM不传输HDFS数据，只协调资源和任务；NM只管理本机Container，Map和Reduce任务直接访问HDFS，这样计算资源和数据存储得以协同利用。

## 高频追问

- RM、NM、AM的职责：RM全局资源，NM本机Container，AM单作业协调。
- 为什么Map尽量靠近数据：减少跨节点读取，提升集群并行吞吐。
- Map任务如何知道输入路径：Job配置给InputFormat，后者查询HDFS文件与Block位置。

## 官网依据

- [YARN Architecture](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/YARN.html)：说明RM、NM和每应用AM在资源分配、节点管理和作业协调上的职责划分。
- [InputFormat API](https://hadoop.apache.org/docs/current/api/org/apache/hadoop/mapreduce/InputFormat.html)：说明InputFormat如何生成InputSplit，并将每个逻辑切分分配给一个Mapper。
- [MapReduce Tutorial](https://hadoop.apache.org/docs/current1/mapred_tutorial.html)：说明输入可被多个Map并行处理，且任务可尽量安排到数据所在节点。
