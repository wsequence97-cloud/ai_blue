# AI 蓝军核心 SQL、指标口径与数据质量风险

## 1. 阅读方式

本文分三层说明：

1. SQL 现在实际做了什么。
2. 这些字段在黑白样本业务中代表什么。
3. 当前截图 SQL 存在哪些需要确认的问题。

风险项只用于复盘和面试准备，不代表已经擅自修改生产 SQL。

## 2. DWD 核心加工逻辑

### 2.1 社区动态明细

`dwd_com_trend_detail_df`：

- 将 ODS `id` 转为字符串 `trend_id`。
- 将内容类型、展示状态、精选类型通过 `dim_code_desc` 映射为名称。
- 将阅读、点赞、回复、分享字段统一为 `_cnt` 命名。
- 将毫秒时间戳 `create_time/modify_time` 转为可读时间。
- 过滤 `is_del=0`。
- 保留当日分区全量快照。

它是 DWM 输入表的事实主表。

### 2.2 审核明细

`dwd_com_audit_detail_df`：

- 保留审核 ID、事件、业务 ID、发布人和发布内容。
- 统一人审处置为 `tag_result_code/name`。
- 统一机审处置为 `machine_tag_result_code/name`。
- 保留 `is_manual`，用于判断机审是否转人工。
- 通过 `event_code` 进行动态分区，便于按审核场景裁剪。

它同时服务两条链路：

- 生成前：给 Dify 提供机审、人审标签和处置上下文。
- 生成后：给蓝军效果宽表提供投放后的审核结果。

### 2.3 质检明细

`dwd_com_audit_quilty_check_detail_df`：

- 将质检 ID 转字符串。
- 映射审核结果和质检结果名称。
- 保留质检备注、业务 ID、审核 ID和事件。

### 2.4 蓝军用户人设

`dwd_com_audit_ai_blue_user_info_df`：

- 将业务账号 `user_id` 标准化为 `ai_blue_user_id`。
- 保留昵称、签名、头像、备注和人设文本。
- 将人设状态 1/2/3 映射为生产中/生产完成/生产失败。
- 保留 `user_style_request_id` 追踪人设生成请求。

### 2.5 蓝军生成内容

`dwd_com_audit_ai_blue_content_df`：

- 保留原始内容和 AI 改写内容。
- 保留原图/新图、原视频/新视频。
- 保留相似度、一级/二级标签、黑白样本属性和难度。
- 通过 `resource_id` 关联素材，通过 `ai_blue_user_id` 关联人设。
- 通过 `ai_blue_content_request_id` 关联 Dify 工作流运行。
- 通过 `trend_id` 关联审核结果。

### 2.6 蓝军素材

`dwd_com_audit_ai_blue_resource_df`：

- 以 ODS `id` 生成字符串 `resource_id`。
- 保留素材组、使用时间、是否使用过、创建修改信息。
- 过滤 `is_del=0`。
- 是 DWM 输出宽表的主表。

### 2.7 蓝军攻击关系

`dwd_com_audit_ai_blue_user_attack_df`：

- 表示“哪个实际账号使用哪个素材参加哪个攻击任务”。
- 保留 `user_id`、`resource_id`、`attack_task_id/name`。
- 过滤 `is_del=0`。

### 2.8 Dify 工作流运行

`dwd_ai_workflow_workflow_runs_detail_df`：

- 将 `id` 标准化为 `workflow_runs_id`。
- 保留 app、workflow、version、graph、inputs、outputs 和 status。
- 保留 elapsed、Token、step、error、exceptions。
- 对创建和结束时间加 28800 秒。
- 从源字段 `input` 的 `$.id` 提取 `biz_id`。

这张表用来追踪和评估模型调用，不负责实现模型。

## 3. 两张 DWM 为什么都需要

| 对比项 | DWM 输入 | DWM 输出 |
| --- | --- | --- |
| 表 | `dwm_com_audit_ai_blue_input_detail_di` | `dwm_com_audit_ai_blue_output_detail_df` |
| 时间位置 | Dify 生成前 | 生成、投放、审核后 |
| 主事实 | 社区帖子 | 蓝军素材 |
| 核心键 | `trend_id` | `resource_id` |
| 主要数据 | 帖子、作者、互动、类目、标签、审核、质检 | 素材、生成内容、人设、任务、工作流、审核结果 |
| 下游 | JSON/Kafka/Dify | ADS 指标和大盘 |
| 解决问题 | 模型需要什么优质参考数据 | 生成和攻击效果怎样 |

如果只建一张表，会混合生成前和生成后的两个生命周期，也难以同时维持帖子粒度和素材/攻击粒度。

## 4. 黑白样本审核结果真值表

假定 `init/pass` 表示待审核或通过，其他处置表示拦截/限制：

| 样本属性 | 审核结果 | 风控判断 | 蓝军视角 | ADS 字段命名方向 |
| --- | --- | --- | --- | --- |
| 黑样本 `0` | `init/pass` | 漏过 | 攻击发现漏洞 | `black_*_audit_fail` |
| 黑样本 `0` | 非 `init/pass` | 拦截 | 防守成功 | `black_*_audit_success` |
| 白样本 `1` | `init/pass` | 正常放过 | 防守成功 | `white_*_audit_success` |
| 白样本 `1` | 非 `init/pass` | 误伤 | 攻击发现误判 | `white_*_audit_fail` |

这里的 `success/fail` 主要站在审核防守角度，而 PRD 的“攻击成功率”可能站在蓝军发现问题的角度。面试时应直接说拦截、漏过、放过、误伤。

## 5. ADS 25 个物理字段的口径

`ads_operation_com_ovewview_target` 有 25 个 DDL 字段，其中两个是维度字段，23 个为数量或难度相关字段。

### 5.1 基础规模

| 字段 | SQL | 含义 |
| --- | --- | --- |
| `date_id` | `SUBSTR(ai_blue_resource_create_time,1,10)` | 素材创建日期，不是攻击日期 |
| `ai_blue_content_type_name` | 分组字段 | 图文/视频 |
| `ai_blue_resource_cnt_1d` | `COUNT(resource_id)` | 当日宽表行中的素材数量 |
| `ai_blue_attack_cnt_1d` | `COUNT(attack_task_id)` | 当日宽表行中的攻击任务数量 |
| `ai_blue_user_cnt_1d` | `COUNT(user_style_request_id)` | 有人设请求 ID 的行数 |
| `ai_blue_used_cnt_1d` | `SUM(is_used)` | 使用标志累计 |

注意：由于按素材创建日期分组，“最近 1 天攻击次数”实际可能是“当日创建素材关联的攻击次数”，不一定等于当天发生的攻击次数。

### 5.2 相似度和难度

| 字段组 | 当前 SQL 含义 |
| --- | --- |
| `similarity_person_audit_fail_cnt` | 相似度 `>=0.7` 且人审通过/待审时，累加该素材近 7 日攻击次数 |
| `similarity_cnt` | 相似度 `>=0.7` 时累加近 7 日攻击次数 |
| `person_audit_fail_difficulty_level` | 相似度 `<0.7` 且人审通过/待审时累加难度 |
| `similarity_difficulty_level` | 相似度 `>0.7` 时累加难度 |

当前 SQL 使用 `person_audit_result`，但 DWM 输出表提供的是 `tag_result_code`，字段无法直接对应，需要确认是否是截图遗漏或旧字段名。

### 5.3 二次投放

| 样本 | 分母 | 分子方向 |
| --- | --- | --- |
| 黑样本 | `sample_code=0 AND is_used=1` | 机审或人审出现非 pass/init 时计为二次投放拦截 |
| 白样本 | `sample_code=1 AND is_used=1` | 当前 SQL 使用“机审非 pass/init OR 人审 pass/init”，同时包含白样本误伤和正确放过，逻辑需确认 |

### 5.4 机审和人审结果

| 字段组 | 分子 |
| --- | --- |
| 黑样本机审漏过 | 黑样本且机审 `init/pass` |
| 黑样本机审拦截 | 黑样本且机审非 `init/pass` |
| 白样本机审误伤 | 白样本且机审非 `init/pass` |
| 白样本机审放过 | 白样本且机审 `init/pass` |
| 黑样本人审漏过 | 黑样本且人审 `init/pass` |
| 黑样本人审拦截 | 黑样本且人审非 `init/pass` |
| 白样本人审误伤 | 白样本且人审非 `init/pass` |
| 白样本人审放过 | 白样本且人审 `init/pass` |

最后一个字段的 SQL 条件是“白样本＋机审通过＋人审不通过”，但字段名包含 `black_sample`，中文注释又写白样本，属于命名与逻辑不一致。

## 6. PRD 17 类指标与现有 SQL 的映射

| 序号 | PRD 指标类别 | 当前资料中的承载 | 覆盖状态 |
| ---: | --- | --- | --- |
| 1 | 首页红蓝攻防状态 banner | 页面需求 | 当前 SQL 未体现 |
| 2 | 攻击时间日/周/月筛选 | `date_id`、分区和报表参数 | 部分覆盖；当前 ADS 以素材创建日聚合 |
| 3 | 累计攻击次数、样本库量级 | `attack_cnt_1d`、`resource_cnt_1d` | 部分覆盖；当前是日聚合，不是累计值 |
| 4 | 样本攻击次数、黑白样本攻击次数 | attack 及黑白样本数量字段 | 直接覆盖 |
| 5 | 一本多投成功率 | 二次投放分子/分母字段 | 可派生，但白样本条件需确认 |
| 6 | 黑样本攻击成功率 | 黑样本人审漏过/黑样本数 | 可派生 |
| 7 | 白样本攻击成功率 | 白样本人审误伤/白样本转人工量 | 部分字段可用，完整分母需确认 |
| 8 | 防御质量分 | 相似度、难度、标签、漏过数据 | 未看到完整 60% 内容分＋40% 难度分公式 |
| 9 | 难度等级分布 | DWM `ai_blue_difficulty_level` | 明细可支持，当前 ADS 未按难度分组 |
| 10 | 一级标签分布 | DWM 类目/审核标签 | 明细可支持，当前 ADS 未输出分布 |
| 11 | 机审直接处置率 | `is_manual`、机审结果 | 可派生，当前 ADS 没有直接率字段 |
| 12 | 机审直接处置错误率 | 黑漏过＋白误伤＋直接处置量 | 可派生，需明确 `is_manual=0` 过滤 |
| 13 | 普通素材 vs AI 素材、AI 可用率 | resource 和 is_used | 只覆盖 AI 素材侧，没有普通素材对照 |
| 14 | 普通攻击 vs AI 攻击次数 | attack_task | 只覆盖 AI 蓝军侧，没有普通攻击对照 |
| 15 | 仿真覆盖维度 | user style；PRD 还要求设备、IP、用户标签和轨迹 | 当前表仅部分支持 |
| 16 | 标签覆盖范围 | 输入表机审/人审标签 | 明细可支持，当前 ADS 未计算覆盖率 |
| 17 | 人设攻击次数 | user style＋attack_task | 明细可支持，当前 ADS 未按 12 种人设排名 |

因此简历“开发指标 17 个”应按业务指标类别解释。仅凭当前 ADS SQL，不能证明 17 类都在这一张表完整落地。

## 7. SQL 风险清单

### P0：可能直接导致建表/装载错误

1. **DWM 输出 DDL 重复字段**：`ai_blue_user_name` 和 `ai_blue_user_icon` 各出现两次。
2. **DWM 输出列位置错配**：SELECT 有 `t2.ai_blue_user_id`，DDL 没有第二个用户 ID；DDL 有 `user_id`，SELECT 没有 `t3.user_id`。第 32-42 列会错位。
3. **审核表普通字段与分区字段重复**：DDL 同时在字段列表和 `PARTITIONED BY` 中声明 `event_code`；需要按实际引擎语法确认。
4. **质检源字段不一致**：ODS DDL 是 `result_result`，DWD INSERT 使用 `check_result`。
5. **ADS 相似度公式引用不存在字段**：使用 `person_audit_result`，DWM 输出提供 `tag_result_code`。
6. **攻击 DWD 类型和别名不一致**：DDL 的 `user_id/creator_id/modifier_id` 是 BIGINT，SELECT 将其 CAST 为 STRING；SELECT 还使用 `ai_blue_user_id/ai_blue_attack_task_id` 等别名，而目标列仍按位置写入 `user_id/attack_task_id`。

### P1：可能导致指标错误

1. **样本属性映射 JOIN 键**：DWD 内容表给样本属性取名称时，当前 SQL 用 `t0.content_type=t2.code`，更可能应使用 `sample_attributes`。
2. **DWM 输入质检 JOIN**：当前条件是 `level3_category_code=quality.biz_id`，类目编码与质检业务 ID 的语义需要确认。
3. **DWM 多个一对多 JOIN 放大**：内容、任务、审核可能形成乘积，导致 COUNT 和 SUM 膨胀。
4. **审核删除数据未过滤**：ODS 审核有 `is_del`，DWD 审核 SQL没有 `is_del=0` 条件。
5. **标签字段类型**：审核 DDL 将 `tag_code`、`machine_tag_code` 定义为 BIGINT，DWM 却按逗号字符串 `SPLIT`。
6. **白样本二次投放 OR 条件**：同时包含误伤和放过，分子含义不单一。
7. **最后一个交叉指标命名**：字段名写黑样本，逻辑和注释是白样本。
8. **日指标按素材创建时间分组**：不一定等于攻击发生日或审核完成日。
9. **通用枚举配置字段名需对齐**：审核 DWD 使用 `event_code` 查维表，但当前手工维表截图示例使用 `scene_code`；质检 DWD 使用 `handle_result`，当前示例主要展示 `tag_result/machine_tag_result`，需要确认维表中是否存在完整配置。

### P2：需要口径或实现边界确认

1. 两张 ADS 均没有 INSERT，无法从当前资料证明实际落表方式。
2. `ads_operation_com_ai_blue_2kafka` 只生成 JSON，Kafka 写入由谁完成未见代码。
3. 外层 JSON 的 `data` 来源是已序列化字符串，需确认下游是否得到嵌套对象还是转义字符串。
4. JSON 同时出现 `tagNameList` 和 `TagNameList`，且当前都取同一字段，需确认大小写字段的真实语义。
5. 工作流时间统一加 8 小时，需要确认源时间是否为 UTC，避免重复偏移。
6. `NOT IN` 遇到 NULL 时不会进入成功或失败分支，需要单独定义未审核/缺失结果口径。

## 8. 数据质量保障应该怎样回答

若面试官问“怎么保证这条链路准确”，可以从以下检查回答。只有实际做过的部分才能使用完成时；其他应说“生产设计上需要”。

### 8.1 ODS→DWD

- 分区行数对账：ODS 和 DWD 总量、过滤删除量。
- 主键重复检查：`trend_id`、`resource_id`、`workflow_runs_id`。
- 枚举覆盖率：code 无法匹配 `dim_code_desc` 的比例。
- 时间合法性：时间戳转换前后范围、时区和未来时间。
- 逻辑删除：核对 `is_del=0` 后的保留量。

### 8.2 DWD→DWM

- JOIN 前后行数和放大倍数。
- 关键外键空值率：内容找不到素材、人设、工作流或审核的比例。
- 一对多关系基数：每个素材对应内容数、任务数、审核数。
- 标签拆分前后数量和无法匹配标签比例。
- 明确宽表唯一键并进行重复检查。

### 8.3 DWM→ADS

- 用少量样本手工验证黑拦截、黑漏过、白放过、白误伤。
- 分子不得大于分母。
- 按日指标与任务明细、审核明细交叉核对。
- 校验首投、复投和近 7 日窗口边界。
- 统一空值、待审核和删除数据处理。

## 9. 面试中的 SQL 深挖点

### 为什么人审标签使用 INNER JOIN？

当前 SQL 会过滤没有人审标签或标签无法映射的帖子。可以解释为模型训练/生成输入只保留有人审语义的高质量样本，但需要承认这会降低覆盖率，并应由产品确认是否符合供数目标。

### 为什么其他表使用 LEFT JOIN？

输出宽表以素材为主，即使内容生成、攻击、工作流或审核尚未完成，也要保留素材用于观察链路完成状态。LEFT JOIN 可避免未完成记录直接消失。

### 如何处理一对多放大？

先确定最终粒度。若目标是每个任务一行，可使用 `resource_id+attack_task_id`；审核取最新结果时先对 `biz_id` 按审核时间 `ROW_NUMBER`；指标用唯一业务 ID 去重，而不是直接 COUNT 宽表行。

### 为什么需要 DIM？

避免在每张 DWD 中硬编码枚举 CASE WHEN，使标签、内容类型和状态有统一中文名称，也便于枚举变化时集中维护。但需要监控维度重复和未匹配率，保证 JOIN 不放大事实表。
