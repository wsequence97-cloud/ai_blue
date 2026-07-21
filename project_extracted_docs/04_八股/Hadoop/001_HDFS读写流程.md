# HDFS读写流程

## 一、面试主答

1. HDFS读写的核心是NameNode只负责文件路径、Block位置等元数据，客户端直接和DataNode传输文件数据。这样大流量不会集中经过NameNode，避免它成为数据传输瓶颈。
2. 读取时，客户端先向NameNode查询文件及Block位置，再按网络拓扑选择较近且可用的一个副本，随后从DataNode流式读取并校验；当前副本异常时可切换其他副本。
3. 写入时，客户端先申请创建文件，再获取当前Block对应的DataNode组并建立Pipeline。数据以Packet依次传给DN1、DN2、DN3，确认从末端逐级返回；Block完成后继续写下一块。
4. NameNode仍会承受元数据请求和命名空间管理压力，但不是文件内容的网络流量与磁盘读写压力。面试时要把“协调元数据”和“传输数据”分开表达。

## 二、关键流程或代码

```text
读：Client → NameNode查询Block位置 → 就近选择一个DataNode副本 → 流式读取
写：Client → NameNode申请文件和Block位置
    Client → DN1 → DN2 → DN3
    Client ← DN1 ← DN2 ← DN3（ACK逐级返回）
```

## 三、本次讨论后的复盘结论

- **我原来容易混淆的点：** 曾认为文件数据读写都经过NameNode，所以会直接压到它的网络和磁盘；也把读取过程理解成每读完一个Block都必须重新请求一次NameNode。
- **修正后的理解：** NameNode提供元数据和Block位置，文件内容由客户端与DataNode直接传输。客户端可先获得一批位置，必要时再补充查询，不必机械地每块请求一次。
- **以后判断问题的标准：** 先区分控制面和数据面：谁决定数据在哪，谁真正搬运数据。
- **一句话记忆：** NameNode指路，DataNode传数据。

## 四、高频追问

### 追问1：NameNode具体承受什么压力？

主要是客户端元数据RPC、目录和文件操作、Block位置管理等请求压力，而不是文件内容的传输流量。可以表达为“元数据访问和命名空间管理压力”，不要笼统说所有读写都压在NameNode磁盘上。

### 追问2：为什么读取只选一个副本？

同一Block的各副本内容相同，正常读取一个可用副本即可。客户端优先选择网络距离较近的副本以减少延迟和跨机架流量，失败时再切换其他副本。

### 追问3：为什么写副本要使用Pipeline？

客户端不需要分别把同一份数据发送多次，而是发送给第一个DataNode，再由各DataNode逐级转发。这样能分散客户端网络开销，并通过逐级ACK确认整条管道的写入状态。

## 五、项目或开发场景映射

- **通用开发场景：** Hive任务扫描HDFS上的订单文件时，先获取Block位置，再由多个计算任务并行读取对应DataNode；写结果时通过Pipeline生成多个副本。
- **本项目可真实使用的表述：** 仓库能确认ODS、DWD表和分区加工SQL，但没有直接展示HDFS客户端读写代码或集群部署细节。
- **不能过度表述的部分：** 不能声称本人处理过NameNode瓶颈、DataNode故障或具体吞吐指标，也不能把底层HDFS流程包装成项目中亲手实现的逻辑。

## 六、参考依据

- [HDFS Architecture](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html)：说明NameNode、DataNode职责、Block副本选择和复制管道。
- [HDFS Users Guide](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html)：说明HDFS客户端访问与文件系统使用方式。
