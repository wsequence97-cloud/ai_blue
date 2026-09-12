# Spark Web UI如何定位性能问题并治理

Spark Web UI排查可以固化为一条流程：

```text
找到慢Job
→ 找到拖慢Job的Stage
→ 比较Stage中Task的分位数
→ 判断问题发生在Shuffle前还是Shuffle后
→ 到Executors页验证内存、节点或Executor异常
→ 回到执行计划、SQL和数据分布确认根因
→ 针对性优化
→ 重跑并对比相同指标
```

核心原则是：**UI发现现象，Task指标确定位置，SQL和数据确认根因，最后按根因治理。**

## 一、先定位慢Job和慢Stage

### 1. 从Jobs或SQL页面开始

首先确认：

- 哪个Job耗时最长；
- 是一直都慢，还是最近突然变慢；
- SQL执行计划中有哪些Scan、Join、Aggregate、Window和Exchange；
- Job被划分成哪些Stage；
- 哪个Stage处于长尾状态。

不能一打开Web UI就直接看Executor。Executor异常可能只是结果，应该先定位问题发生在哪个Job和Stage。

### 2. 找到真正拖慢Job的Stage

重点关注：

- Stage整体Duration；
- 已完成、运行中、失败和重试的Task数量；
- 是否大部分Task已经完成，只剩少数Task长期运行；
- 当前Stage是读取源数据，还是Shuffle后的计算阶段；
- Stage是否发生Task重试、Fetch Failed或Executor丢失。

例如1000个Task中999个已经完成，只剩1个Task运行很久，通常说明存在长尾。长尾可能来自数据倾斜，也可能来自GC、节点、网络、磁盘或复杂计算，不能直接下结论。

## 二、怎么看Stage Summary Metrics

判断时主要比较：

```text
Median/P75：代表大部分Task的正常水平
Max：代表数据量最大或最慢的Task
```

不要只比较Min和Max。Min可能来自空分区或只处理极少数据的Task，参考价值较低。

可以使用如下判断思路：

```text
Max明显大于Median/P75
并且绝对数据量或耗时也确实很大
→ 可能存在数据分布不均或长尾问题
```

Spark AQE判断倾斜分区时同样使用“超过中位数若干倍，同时超过绝对大小阈值”的组合条件，而不是只比较最大值和最小值。

### 关键指标

| 指标 | 主要看什么 | 可能问题 |
| --- | --- | --- |
| Duration | Max是否远高于Median | 数据倾斜、GC、节点慢、复杂计算 |
| Input Size/Records | 个别Task读取量是否特别大 | 输入文件或源分区不均、Map端问题 |
| Shuffle Read Size/Records | 个别下游Task拉取量是否特别大 | Reduce端倾斜 |
| Shuffle Write Size/Records | 个别上游Task输出量是否特别大 | 输入不均、Join膨胀、热点数据 |
| GC Time | GC占Task运行时间的比例是否过高 | 分区过大、对象过多、内存压力 |
| Spill Memory/Disk | 是否大量溢写到磁盘 | 单Task数据过大、执行内存不足 |
| Fetch Wait Time | 是否长时间等待远程Shuffle数据 | 网络、远程拉取或上游Executor异常 |
| Scheduler Delay | Task计算很短但等待调度较长 | Task过多、资源不足、调度开销大 |

需要注意：

1. Duration异常只说明部分Task慢，不能单独证明数据倾斜。
2. GC Time高说明内存压力或对象创建频繁，但不代表只能通过增加内存解决。
3. Shuffle Write异常说明上游输出不均，是否形成Reduce倾斜还要查看下游Shuffle Read。
4. 一个Stage可能同时有Shuffle Read和Shuffle Write，需要结合DAG和SQL执行计划判断它在链路中的位置。
5. 如果数据量指标相近但Duration差异很大，应优先排查GC、CPU、UDF、外部IO和节点异常，而不是认定倾斜。

## 三、判断Map端问题

这里的Map端不是专指`map()`算子，而是指数据进入Shuffle之前的输入读取和上游计算阶段。

### 1. Web UI典型表现

```text
Duration：少数Task明显更慢
Input Size/Records：少数Task远高于Median/P75
Shuffle Write：对应Task可能也明显更大
Shuffle Read：源数据读取Stage通常没有或很少
```

例如：

```text
大部分Task读取128MB，执行1分钟
某个Task读取5GB，执行15分钟
```

这说明输入分区或文件本身不均衡。

### 2. 常见原因

1. 上游Hive分区数据量不均；
2. 单个HDFS文件特别大；
3. 压缩文件不可切分；
4. SQL遗漏`pt`等分区条件；
5. 列裁剪或谓词下推没有生效；
6. 某个业务分区包含大量历史数据；
7. JSON解析或UDF使部分记录处理特别慢；
8. 上游Join已经发生数据膨胀；
9. 输入文件大小差异很大，导致Task承担的数据量不同。

遗漏分区条件通常表现为所有Task扫描量都增加，属于读取范围过大；只有少数Task读取量特别大，才更符合输入侧不均。列裁剪能够减少读取的列和字节数，但不一定改变分区之间的数据分布。

### 3. 对应治理方法

#### 先减少输入范围

- 补充正确的分区过滤条件；
- 只选择真正需要的字段；
- 将过滤条件尽量提前；
- 检查执行计划中的Partition Filters和Pushed Filters；
- 避免读取无关历史分区；
- 对全量表评估是否可以改成增量读取。

#### 再解决输入分区不均

- 拆分异常大的文件；
- 对数据重新分区；
- 调整输入分区大小；
- 优化上游表的分区和文件布局；
- 对不可切分的压缩格式进行改造；
- 对长期失衡的业务分区调整存储设计。

#### 如果是计算逻辑慢

- 减少重复JSON解析；
- 避免低效UDF；
- 将公共计算提前沉淀；
- 检查是否重复执行相同表达式；
- 对比Executor CPU Time和Run Time，判断是CPU计算还是等待问题。

## 四、判断Reduce端问题

Reduce端问题发生在Shuffle之后。下游Task要从所有上游Task中拉取属于自己分区的数据，相同Key通常会进入同一个目标分区。

### 1. Web UI典型表现

```text
Duration：少数Task形成明显长尾
Shuffle Read：Max远高于Median/P75
Records Read：少数Task记录数异常多
Spill和GC：倾斜Task可能明显更高
Input Size：不一定异常
```

例如：

```text
大部分Task的Shuffle Read为300MB
某个Task的Shuffle Read为20GB
```

这说明大量数据被分配到同一个下游分区。

### 2. 常见原因

1. `GROUP BY`字段存在热点Key；
2. 大量`NULL`、空字符串或默认值集中到同一个Key；
3. Join Key分布不均；
4. 一对多或多对多Join造成行数膨胀；
5. 窗口函数的分组字段倾斜；
6. 全局排序导致数据集中；
7. Shuffle分区数量过少；
8. 上游某些Task输出了异常多的数据。

### 3. 回到SQL定位具体Key

不能一看到Shuffle Read大就直接加盐。应该先检查热点Key、空值以及Join两侧的基数：

```sql
SELECT
    join_key,
    COUNT(*) AS cnt
FROM source_table
WHERE pt='${bizdate}'
GROUP BY join_key
ORDER BY cnt DESC
LIMIT 20;
```

同时检查：

- `NULL`和空字符串数量；
- `0`、`unknown`等默认值数量；
- Join前后总行数；
- Join前后业务主键基数；
- 每个Key在Join两侧分别有多少行；
- 是否存在两张一对多表直接关联。

假设左表某个Key有1000行，右表同一个Key有500行，直接Join理论上可能得到50万行。这属于多对多Join膨胀，可能进一步形成Shuffle大分区，但根因是粒度和Join基数，而不是Spark参数。

### 4. 根据根因选择方案

#### 热点Key聚合

可以使用加盐和二次聚合：

```text
第一次：原Key + 随机盐，拆成多个Key做局部聚合
第二次：去掉盐，再按照原Key汇总
```

适合单个Key数据量特别大的聚合场景。

#### 大表Join小表

如果一侧数据量足够小，可以使用Broadcast Join，将小表发送到各Executor，避免大表两侧都进行Shuffle。

#### 空值或默认值集中

- 业务无意义的数据提前过滤；
- 必须保留但不需要匹配的数据单独处理，再`UNION ALL`；
- 必须参与关联的热点值根据业务规则拆分处理；
- 不能为了性能随意改变空值的业务语义。

#### Join膨胀

- 先确认两张表的粒度和目标输出粒度；
- 按时间取最新记录；
- 标签等一对多数据先聚合成集合；
- 对重复数据先去重；
- 避免两个一对多关系直接相乘；
- 检查Join前后的行数和业务主键放大倍数。

#### 整体分区偏大，但没有单一热点Key

可以合理增加Shuffle分区数，使每个Task处理的数据减少。

需要注意：**增加Shuffle分区数只能降低平均分区大小，不能解决一个热点Key必须进入同一分区的问题。**

#### Spark 3 AQE

Spark SQL开启AQE倾斜Join优化后，可以根据运行时统计识别过大的Sort-Merge Join分区，并将倾斜分区拆成更小的分区执行。但AQE主要是执行层的缓解措施，仍然要检查热点Key、Join基数和业务粒度是否正确。

## 五、判断小文件问题

小文件严格来说不一定属于数据倾斜，但会造成大量Task、文件枚举和调度开销，也可能形成长尾，因此通常与倾斜一起排查。

### 1. Web UI典型表现

```text
Stage的Task数量特别多
每个Task的Input Size很小
单个Task计算时间很短
总输入数据量不一定大
Stage整体却耗时较长
Shuffle Read通常不是主要问题
```

例如：

```text
总数据只有10GB
却启动了几万个Task
大部分Task只读取几百KB或几MB
```

这说明大量时间花在文件枚举、Task创建、资源申请、任务调度和文件打开关闭上，而不是真正的业务计算。

### 2. HDFS侧的影响

- NameNode需要维护大量文件和Block元数据；
- 计算引擎需要频繁获取文件与Block位置；
- 文件打开、关闭和远程读取次数增加；
- 可能生成大量很短的读取Task；
- 下游如果继续按过多分区写出，还会产生更多小文件。

Spark UI不能直接完整展示NameNode压力，因此还要结合HDFS目录中的文件数量、平均文件大小和Block分布判断。

### 3. 治理输入小文件

- 对历史小文件进行合并；
- 控制上游表的分区粒度；
- 避免使用高基数字段作为存储分区；
- 调整Spark文件扫描分区策略，让多个小文件组合成一个读取Task；
- 从上游写出逻辑治理文件数量，而不是长期依赖读取参数补救。

### 4. 治理输出小文件

- 合理设置Shuffle和输出分区数；
- 输出前使用`coalesce`或`repartition`；
- 根据业务分区使用`DISTRIBUTE BY`；
- 使用AQE合并过小的Shuffle分区；
- 避免每个动态分区同时启动过多写Task；
- 写出后检查文件数、平均文件大小和最大最小文件差异。

不能简单使用`coalesce(1)`。这可能把全部数据集中到一个Task，导致单Task瓶颈、单文件过大或任务失败。

## 六、Executors页面怎么辅助验证

Stage页面用于判断“哪类Task异常”，Executors页面用于验证“是否存在内存、节点或Executor层面的问题”。

### 1. 重点查看

- 每个Executor完成的Task数量；
- Active、Failed和Completed Tasks；
- Total Duration；
- Total GC Time；
- Input；
- Shuffle Read和Shuffle Write；
- 是否存在Dead或被排除的Executor；
- 某个Executor是否长期只能完成少量Task；
- Executor日志中的OOM、Fetch Failed、容器被杀和心跳超时。

### 2. 所有Executor的GC都高

可能原因包括：

- Executor内存配置不合理；
- 单Task分区普遍过大；
- 每个Executor并发Task过多；
- UDF或业务代码创建大量对象；
- 缓存占用较多；
- Shuffle聚合产生较大的内存结构。

处理时应同时检查分区大小、并发度、缓存、对象创建和内存配置，不能只盲目增加Executor Memory。

### 3. 只有一个Executor明显异常

可能原因包括：

- 该Executor分配到了倾斜Task；
- 所在节点磁盘或网络异常；
- Executor频繁失败或重试；
- 节点存在资源争抢；
- 个别Task访问外部系统较慢。

需要继续对照该Executor上运行的Task和Executor日志，不能仅凭Executor汇总值认定数据倾斜。

### 4. Shuffle集中在少数Executor

这可能说明少数Executor承载了倾斜分区，但Executor汇总结果也会受到Task调度位置影响，最终仍然要回到Stage的Task粒度确认。

### 5. Storage Memory的含义

Executors页中的Storage Memory主要反映缓存数据占用，并不等于Executor所有可用于计算的JVM堆内存。不能看到Storage Memory接近上限，就直接判断任务发生OOM。

## 七、完整判断矩阵

| 现象 | 初步判断 | 下一步检查 |
| --- | --- | --- |
| Input Size的Max远高于Median | Map输入不均 | HDFS文件、上游分区、分区过滤 |
| Shuffle Read的Max远高于Median | Reduce倾斜 | 热点Key、空值、Join膨胀 |
| Shuffle Write少数Task特别大 | 上游输出不均 | 输入分布、Join和数据扩张 |
| Task特别多且Input都很小 | 小文件 | 文件数、平均大小、输出分区 |
| 数据量均衡但Duration差异大 | 非数据倾斜 | GC、CPU、UDF、节点、外部IO |
| GC和Spill普遍很高 | 内存压力或分区过大 | 分区数、内存、并发、对象创建 |
| 只有某个Executor异常 | 节点或个别Task | Executor日志、失败记录、Task分布 |
| Fetch Wait Time很高 | Shuffle拉取等待 | 网络、远程Executor、Shuffle文件 |
| 大多数Shuffle Task都很大 | 分区数可能不足 | 总Shuffle量、分区数、单分区大小 |
| 一个Shuffle Task极大 | 单Key或单分区倾斜 | Top Key、NULL、默认值、Join基数 |

## 八、容易说错的地方

1. **Duration Max远高于Median不等于一定倾斜。** 它只能证明有长尾，还要看Input、Shuffle、GC、Spill和Fetch Wait。
2. **增加Shuffle分区数不一定解决热点Key。** 同一个热点Key仍然会进入同一个目标分区。
3. **`DISTRIBUTE BY`不是通用答案。** 如果选择的字段本身是热点Key，重新分布后仍然倾斜。
4. **二级存储分区主要解决扫描问题。** 它通过分区裁剪减少输入范围，不会自动解决Shuffle中的热点Key。
5. **GC高不等于数据倾斜。** GC高更直接说明内存压力或对象创建过多。
6. **小文件不是一个文件启动一个JVM。** Executor JVM会复用；小文件主要增加文件枚举、元数据访问、Task调度和文件打开成本。
7. **`ROW_NUMBER()`不能随意替换为聚合。** 只有业务语义等价时，才能使用取最大值或最新值等聚合逻辑代替窗口。
8. **`LEFT JOIN`右表过滤条件放在`WHERE`可能改变语义。** 是否放入`ON`首先取决于业务是否需要保留未匹配的左表记录。
9. **参数优化应放在根因分析之后。** AQE可以辅助处理倾斜Join，但不能修复错误粒度、多对多Join和无意义的默认Key。
10. **优化必须同时验证结果。** 运行变快但数据行数、去重主键或指标口径发生变化，不能算有效优化。

## 九、完整面试流程话术

> 我排查Spark任务时，会按照Job、Stage、Task和Executor四层逐步定位。首先在Jobs或SQL页面找到耗时最长的Job，再根据DAG和Stage耗时找到真正的瓶颈Stage。如果大部分Task已经完成，只剩少数Task长期运行，说明存在长尾，但这时还不能直接认定为数据倾斜。
>
> 进入Stage详情后，我主要比较Task指标的Max和Median或P75，而不是只看Min。先看Duration确认长尾，再根据数据发生的位置分类：如果少数Task的Input Size特别大，说明问题主要在Shuffle前，通常是输入文件、源分区或分区裁剪问题；如果少数Task的Shuffle Read特别大，说明问题发生在Shuffle后，需要排查热点Key、空值集中、Join膨胀和Shuffle分区数；如果Task数量特别多但每个Task读取量很小，则通常是小文件和调度开销。如果数据量比较均衡但Duration仍然相差很大，我会继续看GC、Spill、Fetch Wait和Executor日志，排查内存、网络、节点或UDF问题。
>
> 接着我会到Executors页面查看各Executor的GC、Shuffle、失败Task和存活状态。如果所有Executor的GC都高，可能是分区普遍过大、并发过高或对象创建较多；如果只有一个Executor异常，则还要排查它承载的具体Task和所在节点。
>
> 定位问题位置后，我会回到SQL和数据验证根因。Map端问题通过分区裁剪、列裁剪、拆分大文件和重新组织输入分区解决；Reduce端则根据具体原因选择热点Key加盐、两阶段聚合、Broadcast Join、处理空值、一对多去重、预聚合、增加分区或AQE；小文件问题从输入文件合并和控制输出分区数两端治理。最后使用相同业务日期重跑，对比Stage耗时、Max与Median差距、Input、Shuffle、GC、Spill和文件数量，同时核对行数、主键和指标口径，确认优化真正有效。

一句话记忆：

> **Input Size看Map输入，Shuffle Read看Reduce分区，Task数量和单Task大小看小文件，GC与失败情况再到Executor验证。**
