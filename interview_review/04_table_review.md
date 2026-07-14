# AI 蓝军项目逐表审计

> 阶段：第二阶段项目技术复盘。  
> 口径：当前材料共覆盖 ODS 10 张、DWD 8 张、DIM 4 张、DWM 2 张、ADS 2 张。其中用户确认本人核心独立交付为 DWD 6、DWM 2、ADS 2。  
> 数据量：`pt='2026-07-11'` 的 100/200 条是本地复现数据；生产数据量目前未知。  
> 风险：表中风险来自当前截图整理/本地复现 SQL，不自动等同于生产事故或生产最终版本。

## 1. 表数量与个人交付口径

| 层级 | 当前材料表数 | 本人核心独立交付 | 说明 |
| --- | ---: | ---: | --- |
| ODS | 10 | 4 | 本人确认独立配置并上线人设、攻击、AI内容、AI素材4张ODS同步任务；其余为依赖/待确认范围 |
| DWD | 8 | 6 | 工作流1、审核1、蓝军业务4；动态和质检是生成前复用/依赖 |
| DIM | 4 | 待进一步确认 | 3张在主链路，生态标签维表为历史材料 |
| DWM | 2 | 2 | 生成前输入、生成后输出 |
| ADS | 2 | 2 | Kafka JSON供数、效果指标 |

## 2. ODS 层逐表审计

| 表 | 用途与粒度 | 主键/分区 | 上游 → 下游 | 本地量/生产量 | 重复、丢数与设计说明 | 面试追问 |
| --- | --- | --- | --- | --- | --- | --- |
| `ods_community_community_trend_df` | 一行一条原始社区动态；保留正文、作者、互动、类目和审核时间 | `id`；`pt` | 社区MySQL → `dwd_com_trend_detail_df` | 100；未知 | 全量快照便于追溯；`id`重复会放大后续链路，`is_del`不能在ODS提前抹掉；毫秒时间字段需确认 | 为什么ODS保留删除数据？`id`是否跨分区唯一？ |
| `ods_community_community_audit_result_df` | 一行一条审核记录，可能是同一业务对象的多次审核 | `id`；业务键 `biz_id+event_code`；`pt` | 审核系统 → `dwd_com_audit_detail_df` | 前置100+后置100=200；未知 | 前后置审核共表但不能共用同批`biz_id`；同一`biz_id`多审核是正常历史还是重复需区分；`is_del`需在DWD治理 | 如何取最终审核结果？为什么审核200而动态100？ |
| `ods_community_community_quilty_check_df` | 一行一条审核质检记录 | `id`/`audit_id`；`pt` | 质检系统 → 质检DWD | 本地口径未单列；未知 | 应优先通过`audit_id`或正确业务ID关联；当前DDL有尾逗号且字段版本不一致，可能导致装载/读取问题 | 质检如何关联审核而不是类目？ |
| `ods_community_audit_tag_df` | 一行一个审核标签 | `tag_code`；`pt` | 审核标签配置 → `dim_com_audit_tag_df` | 未知；未知 | 标签编码变更、复用或失效会影响标签匹配率；需要唯一性和生效状态 | 为什么不直接在DWD写CASE WHEN？ |
| `ods_community_community_category_df` | 一行一个类目节点/编码映射 | `category_code`；`pt` | 社区类目 → `dim_com_trend_category_df` | 截图约500；未知 | 三级编码体系必须与动态表一致；重复三级编码会放大动态 | 如何验证类目关联率？ |
| `ods_ai_workflow_workflow_runs_df` | 一行一次Dify工作流运行 | `id`；`pt` | Dify DB → workflow DWD | 内容生成100+人设生成100；未知 | 运行重试产生新ID；不能用`workflow_id`代替运行ID；inputs/outputs解析失败不能静默 | `id`、`workflow_id`、`request_id`区别？ |
| `ods_community_ai_blue_user_info_df` | 一行一个蓝军AI人设/用户记录 | `id`或`user_id`；`pt` | 蓝军MySQL → 人设DWD | 100；未知 | 同一用户多版本、人设重试、状态变化可能重复；需要明确全量快照取最新规则 | AI人设用户和实际投放账号区别？ |
| `ods_community_ai_blue_content_df` | 一行一条AI生成内容 | `id`/`ai_task_id`；`pt` | 蓝军MySQL → 内容DWD | 100；未知 | `resource_id`、`trend_id`、`request_id`分别连接素材、投放内容和工作流；重复生成与重试需识别 | 一条素材能否生成多条内容？ |
| `ods_community_ai_blue_resource_df` | 一行一条素材库记录 | `id`；`pt` | 蓝军MySQL → 素材DWD | 100；未知 | 全量表保留逻辑删除；`is_used`是状态不是天然的投放次数 | 为什么不能用`SUM(is_used)`代替复投次数？ |
| `ods_community_ai_blue_user_attack_df` | 一行一条账号-素材-攻击任务关系 | `id`；业务键候选`user_id+resource_id+attack_task_id`；`pt` | 蓝军MySQL → 攻击DWD | 100；未知 | 同一素材多任务属正常；重复同步会造成任务重复；删除关系需过滤 | 攻击次数按行数还是任务ID去重？ |

## 3. DWD 层逐表审计

### 3.1 本人核心独立交付6张

| 表 | 用途与目标粒度 | 主键/分区 | 上游 → 下游 | 本地量/生产量 | 重复、丢数与关键设计 | 面试追问 |
| --- | --- | --- | --- | --- | --- | --- |
| `dwd_ai_workflow_workflow_runs_detail_df` | 一行一次工作流运行；标准化运行、耗时、Token和异常 | `workflow_runs_id`；`pt` | workflow ODS → DWM output | 200；未知 | 从inputs提取`biz_id`，时间加8小时需确认源时区；JSON解析失败会丢业务键 | 为什么加28800？如何验证时区？ |
| `dwd_com_audit_detail_df` | 一行一条审核记录，而非一行一个业务对象 | `audit_id`；`pt+event_code` | audit ODS + `dim_code_desc` → 两张DWM | 200；未知 | `event_code`不能同时作为普通列和分区列；应过滤删除记录；同`biz_id`多行需在下游选取 | 为什么按event_code二级分区？如何防小分区？ |
| `dwd_com_audit_ai_blue_user_info_df` | 一行一个标准化AI人设记录 | `ai_blue_user_id`或源记录ID；`pt` | user_info ODS + enum DIM → DWM output | 100；未知 | 如果同一用户多版本，单用user_id不唯一；人设状态映射未匹配会为空 | 如何处理人设更新和生成失败？ |
| `dwd_com_audit_ai_blue_content_df` | 一行一条AI生成内容/任务结果 | `ai_blue_content_task_id`；`pt` | content ODS + enum DIM → DWM output | 100；未知 | `resource_id`/`trend_id`/request ID均需非空率监控；样本属性映射必须使用`sample_attributes`而非content_type | 黑白样本属性如何验证没有映射反？ |
| `dwd_com_audit_ai_blue_resource_df` | 一行一条有效素材 | `resource_id`；`pt` | resource ODS → DWM output主表 | 100；未知 | `is_del=0`会产生ODS-DWD合理差异；全量快照重跑用overwrite保证幂等 | 为什么选素材做输出宽表主表？ |
| `dwd_com_audit_ai_blue_user_attack_df` | 一行一条有效攻击关系 | 源`id`更稳；业务键候选`attack_task_id+resource_id+user_id`；`pt` | attack ODS → DWM output | 100；未知 | 当前整理版DDL和SELECT类型/别名有错位风险；同素材多任务不能误判为重复 | 如何定义攻击任务唯一性？ |

### 3.2 生成前复用/依赖2张

| 表 | 用途与目标粒度 | 主键/分区 | 上游 → 下游 | 本地量/生产量 | 重复、丢数与关键设计 | 面试追问 |
| --- | --- | --- | --- | --- | --- | --- |
| `dwd_com_trend_detail_df` | 一行一条有效社区动态，统一字段、枚举和时间 | `trend_id`；`pt` | trend ODS + enum DIM → DWM input | 100；未知 | 过滤`is_del=0`；时间戳除1000；枚举维表重复会放大；修改时间字段需与ODS一致 | 为什么它不计入核心DWD 6张？ |
| `dwd_com_audit_quilty_check_detail_df` | 一行一条质检记录 | `check_id`；`pt` | quality ODS + enum DIM → DWM input | 未单列；未知 | 文件名quality、对象名quilty；`check_result`字段和枚举映射需统一；不能用类目编码关联业务ID | 质检结果怎样进入DWM且不放大？ |

## 4. DIM 层逐表审计

| 表 | 用途与粒度 | 主键/分区 | 上游 → 下游 | 本地量/生产量 | 重复、丢数与设计说明 | 面试追问 |
| --- | --- | --- | --- | --- | --- | --- |
| `dim_code_desc` | 一行一个“来源表+字段+code”的中文映射 | `table_name+fields_name+code`；无pt | 手工维护 → 多张DWD | 未知；未知 | 复合键必须唯一；`only`与`only_fans`不一致会导致未匹配；集中维护优于散落CASE WHEN | 手工维表如何发布、审计和监控？ |
| `dim_com_audit_tag_df` | 一行一个审核标签 | `tag_code`；`pt` | audit_tag ODS → DWM input标签聚合 | 未知；未知 | 标签重复会造成EXPLODE后再次放大；需监控无法映射标签 | 标签多值为什么先拆再聚合？ |
| `dim_com_trend_category_df` | 一行一个三级类目映射及其父级名称 | `level3_category_code`；`pt` | category ODS → DWM input | 约500；未知 | 动态与维表编码体系若不同会整列为空；三级码必须唯一 | 为什么按三级码关联？ |
| `dim_com_ecology_tag_df` | 历史生态标签维表，一行一个标签 | `tag_code`；`pt` | ecology ODS → 当前主链路无下游 | 未知；未知 | 已确认不属于当前蓝军主链路；面试中不计入核心交付 | 为什么材料里有表但血缘不用？ |

## 5. DWM 层逐表审计（本人独立交付）

| 表 | 用途与目标粒度 | 主键/分区 | 上游 → 下游 | 本地量/生产量 | 重复、丢数与关键设计 | 面试追问 |
| --- | --- | --- | --- | --- | --- | --- |
| `dwm_com_audit_ai_blue_input_detail_di` | 生成前输入宽表；一行一条当日动态及审核上下文 | 候选`pt+trend_id`；`pt` | trend/audit/quality DWD + tag/category DIM → ADS JSON | 目标约100，实际受JOIN过滤影响；未知 | 人审标签INNER JOIN可能丢整批；审核一对多会放大；质检关联可疑；BIGINT标签却SPLIT会报错/异常 | 为什么用INNER JOIN？DWM没数据如何定位？ |
| `dwm_com_audit_ai_blue_output_detail_df` | 生成后全链路宽表；目标可定义为素材任务级 | 建议`pt+resource_id+attack_task_id`，若保留审核再加`audit_id`；`pt` | 6张核心DWD → 效果ADS | 以素材100为起点，JOIN后不应直接假定100；未知 | 内容、任务、审核三个一对多可能相乘；当前整理版DDL/SELECT列错位；LEFT JOIN保证素材不因缺下游结果被丢弃 | 你最终把一行定义成什么？如何治理一对多？ |

## 6. ADS 层逐表审计（本人独立交付）

| 表 | 用途与目标粒度 | 主键/分区 | 上游 → 下游 | 本地量/生产量 | 重复、丢数与关键设计 | 面试追问 |
| --- | --- | --- | --- | --- | --- | --- |
| `ads_operation_com_ai_blue_2kafka` | 一行一个待推送的内容JSON | 建议`pt+trend_id`；`pt` | DWM input → Kafka → 研发/Dify | 最多约100，取决于DWM保留量；未知 | 当前材料只有SELECT；生产实现需说明落表/直推方式；JSON转义、重复发送和消费幂等是核心 | 你用什么方式推Kafka？如何避免重复？ |
| `ads_operation_com_ovewview_target` | 按日期和内容类型聚合蓝军效果指标 | `pt+date_id+content_type`；`pt` | DWM output → 指标平台/大盘 | 聚合后少量行；未知 | 当前截图按素材创建日而非攻击日聚合；一对多会放大；NULL不会进入`NOT IN`；17类需求并非全部由当前25字段覆盖 | 17类指标和25字段为何不同？时间口径是什么？ |

## 7. 本地测试量守恒关系

| 对象 | 本地测试量 | 应如何解释 |
| --- | ---: | --- |
| 原始社区动态 | 100 | 生成前输入候选，不等于最终DWM一定100 |
| 前置审核 | 100 | 应与原始动态ID匹配 |
| AI生成内容 | 100 | 生成后内容记录 |
| 后置审核 | 100 | 应与投放后新`trend_id`匹配 |
| 审核表合计 | 200 | 前后置共表，但`biz_id`集合必须分离 |
| 素材/人设/攻击任务 | 各100 | 仅为本地等量造数，不代表关系必然一对一 |
| 工作流运行 | 内容100+人设100 | 不同工作流/请求类型，应通过ID和类型区分 |

最重要的本地DQC：

```text
前置审核.biz_id ∩ 后置审核.biz_id = 空集
```

## 8. 重复、丢数与分区通用检查

### 重复

- ODS检查源主键是否重复；全量快照跨分区重复不等于分区内重复。
- DWD检查转换和维表JOIN是否放大。
- DWM检查每个JOIN键的1:1、1:N、N:M基数和JOIN前后倍数。
- ADS数量指标优先使用明确业务ID去重，而非直接数宽表行。

### 丢数

- WHERE过滤、`is_del=0`、发布日期过滤和INNER JOIN分别记录减少量。
- LEFT JOIN后的关键外键空值率应单独监控，不能用INNER JOIN静默丢弃。
- 枚举无法映射、JSON解析失败、NULL审核结果应进入异常分类。

### 分区

- 本项目当前均按业务日期`pt`裁剪；审核可能再按`event_code`分区。
- `INSERT OVERWRITE`适合分区幂等重跑，但必须确认只覆盖目标分区。
- 动态分区字段必须位于SELECT末尾并开启正确配置。
- 是否增加`event_code`二级分区取决于数据量、查询过滤比例和小文件数量，不能仅因字段常用就机械分区。

## 9. 生产量与性能结论

- 用户确认核心10张表真实上线并稳定调度，但没有提供生产数据量。
- 本阶段不得声称日均十万、千万、亿级或TB级，也不得把本地100条写成生产规模。
- 因此当前只能回答表结构、粒度、关联、质量和通用优化方法；真实资源配置、Shuffle量、任务耗时、SLA和性能收益仍需生产证据。

## 10. A级职责的技术自证清单

后续模拟面试前，本人应能对核心10张表逐张回答：

1. 需求从谁提出，解决什么问题。
2. 为什么选择该粒度，唯一键是什么。
3. 上游源表、核心字段和下游消费者是谁。
4. 为什么采用当前分区和写入方式。
5. SQL最关键的JOIN、过滤、枚举或聚合逻辑。
6. 实际遇到的一个问题，如何定位和修复。
7. 做过哪些行数、唯一性、空值、关联率和指标对账。
8. 如何完成下游验收，验收失败怎样回溯。

若只能读出表名而不能回答以上细节，A 级表述在严格面试中仍存在较高风险。
