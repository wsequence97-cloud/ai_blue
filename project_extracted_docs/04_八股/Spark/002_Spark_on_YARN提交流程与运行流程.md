# Spark on YARN提交流程与运行流程

## 一、面试主答

1. Spark on YARN要分提交和运行两条线：提交解决“应用进程如何被YARN拉起”，运行解决“Driver如何把业务代码拆成Task执行”。下面以cluster模式为主线。
2. 提交时，`spark-submit`先向RM创建Application，获得`applicationId`等提交信息；再把应用Jar、依赖和配置暂存到HDFS等共享位置。客户端携AM启动上下文和资源引用提交RM，RM分配AM Container，NM启动其中的AM/Driver；Driver再申请Executor Container，RM调度后由NM启动Executor并向Driver注册。
3. 运行时，Driver初始化SparkContext和调度器；转换操作先形成DAG，Action才触发Job。DAG Scheduler按Shuffle切Stage，Task Scheduler按分区生成并下发Task，Executor执行读取、计算、Shuffle和写出，并把状态、结果反馈给Driver。
4. 上半段“Action到Task执行”属于运行流程，不应混进提交步骤。客户端不会直接命令NM启动AM，Executor也不会主动申请Task；Task完成后Executor通常仍会复用，Application结束或动态资源回收时才释放。

## 二、关键流程或代码

```text
提交流程：spark-submit → RM创建Application，返回applicationId
          → 上传Jar、依赖、配置到共享staging位置
          → 向RM提交AM启动上下文 → RM分配AM Container
          → NM启动AM/cluster模式Driver → Driver申请Executor
          → RM分配Executor Container → NM启动Executor并向Driver注册

运行流程：转换操作形成DAG → Action触发Job → Shuffle切Stage
          → 按分区生成Task → Driver下发给Executor → 执行并反馈
          → 各Stage完成 → Job完成 → Application结束后释放资源
```

## 三、本次讨论后的复盘结论

- **我原来容易混淆的点：** 曾把概述中的“提交到执行结束”与下方“AM、Driver、Executor启动步骤”当成同一段流程，也把RM分配资源、客户端启动AM、NM准备环境混成一条线。
- **修正后的理解：** 下方步骤主要是提交和进程拉起；`Action → Job → Stage → Task`属于进程启动后的运行流程。客户端提交给RM，RM决定Container调度，NM只在本机启动Container。
- **以后判断问题的标准：** 先问当前是在“拉起AM、Driver、Executor”，还是在“切Job、Stage、Task”；前者是YARN资源流程，后者是Driver内部调度流程。
- **一句话记忆：** 提交把人拉齐，运行把活拆开。

## 四、高频追问

### 追问1：为什么要先获得applicationId？

它是YARN中本次应用的唯一身份，用于后续提交、状态查询、日志定位和资源暂存目录的归属。拿到ID不代表AM或Executor资源已经分配，只是完成了创建Application这一步。

### 追问2：为什么把Jar、依赖和配置放到HDFS等共享位置？

AM和Executor可能被调度到远端节点，不能依赖提交机器的本地路径。YARN会将这些程序资源分发并本地化到Container工作目录；上传的是运行代码和依赖，不是业务输入数据本身。

### 追问3：cluster模式和client模式最核心的区别是什么？

cluster模式中Driver运行在集群内的AM进程中，提交客户端可退出。client模式中Driver留在提交端，AM主要负责向YARN申请Executor资源，因此提交端需要持续可用。

## 五、项目或开发场景映射

- **通用开发场景：** Spark读取当天ODS分区，完成字段转换和维表关联后写入DWD；提交阶段拉起Driver、Executor，`write`触发运行阶段的Job和Task调度。
- **本项目可真实使用的表述：** 仓库SQL能确认ODS到DWD的分区读取、字段加工和写入逻辑，可作为讲解业务输入输出和DAG背景的依据。
- **不能过度表述的部分：** 当前材料没有Spark提交脚本、YARN日志或执行计划，不能声称项目实际运行在Spark on YARN，也不能描述真实Executor数、Stage数和资源参数。

## 六、参考依据

- [Spark on YARN](https://spark.apache.org/docs/latest/running-on-yarn.html)：说明cluster/client模式、AM、资源暂存和YARN Container语义。
- [Spark Cluster Mode Overview](https://spark.apache.org/docs/latest/cluster-overview.html)：说明Driver、Executor、Job、Stage和Task的职责与关系。
