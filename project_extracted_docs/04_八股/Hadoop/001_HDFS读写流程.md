# HDFS读写流程

## 一句话结论

HDFS读写都先由NameNode协调元数据，再由客户端直接与DataNode传输数据。读取选择一个较近的Block副本，写入则通过Pipeline将Block写到多个DataNode，文件数据本身不经过NameNode，从而避免集中式传输瓶颈，并提升集群横向扩展能力。

## 核心因果链

NameNode只管理元数据，客户端直连DataNode → 避免集中式传输瓶颈
读：查询Block位置 → 就近选择DataNode → Packet传输与校验
写：申请创建文件 → 获取DataNode组 → 建立Pipeline
Client → DN1 → DN2 → DN3逐级写入
DN3 → DN2 → DN1 → Client逐级返回ACK
当前Block完成 → 申请下一Block并循环

## 实际开发例子

将每日订单明细上传HDFS时，客户端先申请创建文件，再把各Block通过DataNode管道写成多个副本。后续Hive任务扫描该文件时，只从每个Block较近的一个副本获取数据；副本不可用时可改读其他副本。

## 易错点

- NameNode返回Block位置，不负责传输文件数据。
- 写入先申请创建文件，再申请当前Block位置。
- 正常读取一个副本，异常时才切换其他副本。

## 30秒面试回答

HDFS读取时，客户端先请求NameNode（名称节点），名称节点查询元数据并返回文件各Block（数据块）的DataNode（数据节点）位置。客户端按就近原则选一个副本，由数据节点以Packet（数据包）流式传输并校验，异常时切换其他副本。写入时，客户端先申请创建文件，再询问当前数据块应写到哪些数据节点。获得节点组后建立Pipeline（管道），数据依次传给各节点，ACK（确认）从末端逐级返回。一个数据块完成后继续申请下一个，直到文件写完；文件数据始终不经过名称节点。

## 高频追问

- 为什么数据不经过NameNode：流量分散、避免单机网络和处理能力限制集群吞吐。
- 为什么就近读取：副本内容相同，近端读取可降低延迟和跨机架开销。
- 为什么采用Pipeline：客户端一次发送，DataNode逐级复制多个副本。

## 官网依据

- [HDFS Users Guide](https://hadoop.apache.org/docs/current3/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html)：说明客户端向NameNode获取元数据，并直接与DataNode完成实际文件I/O。
- [HDFS Architecture](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html)：说明NameNode与DataNode的职责划分、Block副本管理及就近读取原则。
- [Replication Pipelining](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html#Replication_Pipelining)：说明写入多个副本时，各DataNode如何逐级接收、落盘和转发数据。
