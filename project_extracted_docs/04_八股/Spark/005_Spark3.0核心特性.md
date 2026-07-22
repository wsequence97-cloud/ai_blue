# Spark 3.0核心特性

## 一、面试主答

Spark 3.0是3.x系列的首个大版本，升级重点集中在Spark SQL的执行优化和标准兼容性，面试中我主要从四点回答。

1. **AQE自适应查询执行。** Spark利用Shuffle后的真实运行时统计重新优化后续计划，可以合并过小的Shuffle分区、把SortMergeJoin动态调整为BroadcastHashJoin，并拆分倾斜的SortMergeJoin分区，减少小Task和长尾Task。
2. **DPP动态分区裁剪。** 查询大事实表关联维表时，Spark可先过滤维表得到Join Key，再把这些Key转换成事实表分区过滤条件，只扫描可能参与Join的分区。它要求Join Key能够对应事实表分区字段，否则不能减少事实表分区扫描。
3. **ANSI SQL兼容性增强。** 开启ANSI模式后，数值溢出、非法类型转换等问题会采用更严格的报错语义，有助于及早发现数据质量问题，但旧SQL升级时也可能暴露兼容性风险。
4. **生态和运行能力增强。** Spark 3.0还改进了Pandas UDF、Structured Streaming UI、Catalog插件API和加速器感知调度。总体方向是让执行计划更动态、SQL语义更规范、开发和监控能力更完整。

## 二、关键流程或代码

```text
AQE：生成初始物理计划
  → Shuffle完成并获得真实分区大小
  → 合并小分区 / 转换Join策略 / 拆分倾斜Join分区
  → 执行调整后的后续Stage

DPP：过滤维表
  → 得到符合条件的Join Key集合
  → 将Key集合下推为事实表分区过滤条件
  → 只扫描相关事实表分区
  → 执行Join
```

## 三、本次讨论后的复盘结论

- **我原来容易混淆的点：** 一是认为热点Key经过Hash分区后仍在同一个分区，所以AQE拆分倾斜分区可能无效；二是不理解只过滤维表为什么会影响事实表扫描。
- **修正后的理解：** 对倾斜SortMergeJoin，AQE可以按上游Shuffle Block把一个倾斜的逻辑分区拆成多个物理读取任务，并复制或拆分另一侧对应数据；如果一侧足够小，BroadcastHashJoin通常更直接，因为它可以取消大表按Join Key的Shuffle。DPP则通过Join Key建立联系：维表过滤得到的Key只有能对应事实表分区字段时，才能在扫描前裁剪事实表分区。
- **以后判断问题的标准：** 判断AQE倾斜优化时，先区分Join倾斜和最终聚合倾斜，再检查小表能否安全广播；判断DPP时，检查维表过滤字段能否得到Join Key，以及该Key是否对应事实表分区字段。
- **一句话记忆：** AQE根据运行时数据改计划，DPP根据维表结果少扫事实表分区。

## 四、高频追问

### 追问1：热点Key仍进入同一个分区，AQE为什么还能处理倾斜Join？

热点Key仍属于同一个逻辑Shuffle分区，但AQE可以根据不同Map Task写出的Shuffle Block，把这个倾斜分区拆成多个物理子分区交给多个Task读取，并让另一侧数据配合复制或拆分。它主要优化倾斜Join，不能普遍解决`groupByKey`等最终必须把同一Key汇总到一起的聚合倾斜；如果热点数据集中在单个巨大Shuffle Block中，拆分空间也会受限。

### 追问2：倾斜SortMergeJoin为什么不直接改成BroadcastHashJoin？

如果一侧足够小且Join类型支持，BroadcastHashJoin通常更优，因为小表广播到各Executor后，大表不必按Join Key进行Shuffle。若小表过大、广播可能导致内存压力或超时，Spark才需要保留Shuffle Join，并通过AQE拆分倾斜分区。AQE在运行中转换Join时，前面的部分Shuffle Write也可能已经发生，因此准确的表统计有助于更早选择广播。

### 追问3：维表过滤与事实表有什么关系，DPP什么时候失效？

DPP先过滤维表得到符合条件的Join Key，再用这些Key限制事实表分区。例如事实表按`region_id`分区，维表过滤得到`region_id={1,3}`，Spark就只读取这两个分区。如果事实表按`dt`分区，而维表只能得到`region_id`，Key无法推导日期分区，DPP就不能减少事实表扫描，只能在扫描后通过Join过滤记录。

## 五、项目或开发场景映射

- **通用开发场景：** 星型模型中，大订单事实表按日期分区并关联日期维表。过滤维表中的年份和月份后，DPP可得到具体日期并减少事实表分区扫描；Join执行期间，AQE再根据真实Shuffle数据量调整分区数量、Join策略或倾斜分区。
- **本项目可真实使用的表述：** AI蓝军仓库材料包含明细表、维表关联和聚合SQL，可以结合`EXPLAIN`分析如果由Spark SQL执行，哪些Join具备广播条件、哪些关联可能出现Shuffle，以及事实表分区字段是否满足DPP条件。
- **不能过度表述的部分：** 当前仓库不能证明项目实际使用Spark 3.0、启用AQE或触发DPP，也没有真实运行指标，因此不能声称具体Stage变化、扫描分区减少量或性能提升比例。

## 六、参考依据

- [Apache Spark 3.0.0 Release Notes](https://spark.apache.org/releases/spark-release-3-0-0.html)：列出AQE、DPP、ANSI SQL、Pandas UDF、Structured Streaming UI和加速器感知调度等3.0重点特性。
- [Spark SQL Performance Tuning](https://spark.apache.org/docs/latest/sql-performance-tuning.html)：说明AQE利用运行时统计合并Shuffle分区、转换Join策略和优化倾斜Join的机制；不同Spark版本的默认开关需按对应版本确认。
