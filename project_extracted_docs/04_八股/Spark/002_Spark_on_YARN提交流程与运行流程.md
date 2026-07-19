# Spark on YARN提交流程与运行流程

## 一句话结论

Spark on YARN 由YARN负责分配Container，Driver负责把用户逻辑拆成Job、Stage和Task并调度给Executor。以下主线以cluster模式为例：Driver随AM在集群内运行，Executor是应用专属、可长期复用的计算进程；同一Application可因多次Action触发多个Job，YARN不负责Spark算子的DAG切分。

## 核心因果链

客户端获取`applicationId` → 将Jar、依赖和配置暂存HDFS → 让远端Container可取得资源
客户端携AM启动上下文和资源引用提交RM → RM调度AM Container → 对应NM启动AM
cluster模式下AM内运行Driver → Driver创建SparkContext并向YARN申请Executor Container
RM分配Executor资源 → 多个NM启动Executor → Executor向Driver注册
Action触发Job → Driver按宽窄依赖切Stage → 每个Stage按分区拆Task
Executor读取HDFS、执行Task和Shuffle → 写出结果 → 应用结束后释放Executor资源

## 实际开发例子

假设项目ODS到DWD的加工使用Spark：Driver将读取当天`pt`分区、字段加工、维表关联和写入DWD组织成DAG；`write`触发Job，Executor并行处理分区。读取和字段加工通常可连续执行；DWD结果由Executor写入目标分区。同一应用再次统计或写出时，还会触发新的Job。关联是否切出新Stage、是否Shuffle，仍需以真实提交参数和执行计划为准。

## 易错点

- 客户端不直接命令NM启动AM，而是向RM提交AM启动上下文。
- Executor不是Task；一个Executor在应用期间可执行多个Task并可缓存数据。
- client模式Driver在提交端，AM主要负责申请Executor资源。

## 30秒面试回答

Spark提交到YARN时，客户端先获取applicationId，并把程序Jar、依赖和配置上传到HDFS暂存目录，再携带AM的资源需求、启动信息和资源引用向RM提交Application。RM分配AM Container，由对应NM启动AM；在cluster模式下Driver运行在AM内。Driver创建SparkContext后申请Executor Container，RM分配资源，多个NM启动Executor并向Driver注册。Executor是应用专属的长期进程，可连续执行多个Task。YARN只负责资源分配，具体Task调度由Driver完成并持续接收任务。运行中Action触发Job，Driver按Shuffle边界切分Stage，再按分区生成Task并下发给Executor。Executor读取HDFS、执行计算和Shuffle、写出结果；应用结束后释放资源。

## 高频追问

- Driver与AM关系：cluster模式Driver在AM内；client模式二者分离。
- 为什么先暂存HDFS：远端AM和Executor不能直接访问客户端本地文件，需共享资源位置。
- Job、Stage、Task关系：Action触发Job，Shuffle切Stage，分区生成Task。

## 官网依据

- [Spark Cluster Overview](https://spark.apache.org/docs/latest/cluster-overview.html)：说明Driver、Cluster Manager、Executor、Job、Stage、Task的职责与层级。
- [Submitting Applications](https://spark.apache.org/docs/latest/submitting-applications.html)：说明` spark-submit`、部署模式和应用依赖分发方式。
- [Running Spark on YARN](https://spark.apache.org/docs/latest/running-on-yarn.html)：说明YARN的client/cluster模式、AM与Container语义。
