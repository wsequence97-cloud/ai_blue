# ads_operation_com_ovewview_target

## 所属分层

ADS

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 截图右侧被截断或无法确认的位置保留 `TODO`，未强行编造。
- 用户于 2026-07-10 补充了 SELECT 第 2-30 行的横向裁切截图，已据此补齐全部指标表达式。
- 用户确认 DDL 原第 5、6 行的 `ai_blue_attack_cnt_1d` 是重复字段，本文只保留一个。
- 用户确认原截图没有 `INSERT OVERWRITE TABLE ... PARTITION(...)`，本文不补造写表语句，保留独立 SELECT。
- 本轮口径调整：删除二次投放指标；人审指标只计已转人工且结果已完成的记录；六个机审指标保持原条件。

## SQL 文件

`project_extracted_docs/02_数仓整理/05_ADS/sql/ads_operation_com_ovewview_target.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/ads/ads_operation_com_ovewview_target(1).png
-- - 数仓/ads/ads_operation_com_ovewview_target(2).png
-- - 数仓/ads/ads_operation_com_ovewview_target_代码(1).png
-- - 数仓/ads/ads_operation_com_ovewview_target_代码(2).png
-- - 数仓/ads/ads_operation_com_ovewview_target_代码(3).png
-- - 数仓/ads/ads_operation_com_ovewview_target_具体计算公式(1-5).png
-- - 用户于 2026-07-10 补充的横向裁切代码截图（SELECT 第 2-30 行）
-- 注意：overview 在截图文件名和表名中写作 ovewview，本文保持截图原始拼写。
-- 用户确认：DDL 原第 5、6 行的 ai_blue_attack_cnt_1d 为重复字段，本文只保留一个。
-- 用户确认：原截图没有 INSERT OVERWRITE TABLE ... PARTITION(...)，以下按原图保留为独立 SELECT。
-- 本轮口径调整：删除二次投放指标；人审指标只计已转人工且结果已完成的记录；六个机审指标保持原条件。

CREATE TABLE `yshopping`.`ads_operation_com_ovewview_target` (
    date_id STRING COMMENT '业务日期',
    ai_blue_content_type_name STRING COMMENT '内容类型name：0图文 1视频',
    ai_blue_resource_cnt_1d BIGINT COMMENT '最近1天素材数',
    ai_blue_attack_cnt_1d BIGINT COMMENT '最近1天攻击次数',
    ai_blue_user_cnt_1d BIGINT COMMENT '最近1天生成蓝军用户数',
    ai_blue_used_cnt_1d BIGINT COMMENT '最近1天样本被使用过的次数',
    ai_blue_similarity_person_audit_fail_cnt_1d BIGINT COMMENT '最近1天样本相似度大于0.7近7日人审漏过数',
    ai_blue_similarity_cnt_1d BIGINT COMMENT '最近1天样本相似度大于0.7近7日人审量',
    ai_blue_similarity_person_audit_fail_difficulty_level_1d DOUBLE COMMENT '最近1天样本相似度小于0.7人审漏过难度',
    ai_blue_similarity_difficulty_level_1d DOUBLE COMMENT '最近1天样本相似度小于0.7人审通过难度',
    ai_blue_black_sample_machine_audit_fail_cnt_1d BIGINT COMMENT '机审黑样本漏过数',
    ai_blue_black_sample_machine_audit_success_cnt_1d BIGINT COMMENT '机审黑样本拦截数',
    ai_blue_black_sample_cnt_1d BIGINT COMMENT '黑样本数',
    ai_blue_white_sample_machine_audit_fail_cnt_1d BIGINT COMMENT '机审白样本误伤数',
    ai_blue_white_sample_machine_audit_success_cnt_1d BIGINT COMMENT '机审白样本放过数',
    ai_blue_white_sample_cnt_1d BIGINT COMMENT '白样本数',
    ai_blue_black_sample_person_audit_fail_cnt_1d BIGINT COMMENT '人审黑样本漏过数',
    ai_blue_black_sample_person_audit_success_cnt_1d BIGINT COMMENT '人审黑样本拦截数',
    ai_blue_white_sample_person_audit_fail_cnt_1d BIGINT COMMENT '人审白样本误伤数',
    ai_blue_white_sample_person_audit_success_cnt_1d BIGINT COMMENT '人审白样本放过数',
    ai_blue_black_sample_machine_success_person_audit_fail_cnt_1d BIGINT COMMENT '白样本机审通过人审不通过数'
)
COMMENT 'ads-运营域-社区域-ai社区蓝军大盘最近1天指标表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='365', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

-- 原截图未提供 INSERT OVERWRITE，本段为独立指标查询。
SELECT
    SUBSTR(ai_blue_resource_create_time, 1, 10) AS date_id,
    ai_blue_content_type_name,
    COUNT(resource_id) AS ai_blue_resource_cnt_1d,
    COUNT(attack_task_id) AS ai_blue_attack_cnt_1d,
    COUNT(user_style_request_id) AS ai_blue_user_cnt_1d,
    SUM(is_used) AS ai_blue_used_cnt_1d,
    SUM(IF(ai_blue_similarity >= 0.7 AND person_audit_result IN ('init','pass'), attack_task_cnt_7d, 0)) AS ai_blue_similarity_person_audit_fail_cnt_1d,
    SUM(IF(ai_blue_similarity >= 0.7, attack_task_cnt_7d, 0)) AS ai_blue_similarity_cnt_1d,
    SUM(IF(ai_blue_similarity < 0.7 AND person_audit_result IN ('init','pass'), ai_blue_difficulty_level, 0)) AS ai_blue_similarity_person_audit_fail_difficulty_level_1d,
    SUM(IF(ai_blue_similarity > 0.7, ai_blue_difficulty_level, 0)) AS ai_blue_similarity_difficulty_level_1d,
    COUNT(IF(ai_blue_sample_code=0 AND machine_tag_result_code IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_black_sample_machine_audit_fail_cnt_1d,
    COUNT(IF(ai_blue_sample_code=0 AND machine_tag_result_code NOT IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_black_sample_machine_audit_success_cnt_1d,
    COUNT(IF(ai_blue_sample_code=0, attack_task_id, NULL)) AS ai_blue_black_sample_cnt_1d,
    COUNT(IF(ai_blue_sample_code=1 AND machine_tag_result_code NOT IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_white_sample_machine_audit_fail_cnt_1d,
    COUNT(IF(ai_blue_sample_code=1 AND machine_tag_result_code IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_white_sample_machine_audit_success_cnt_1d,
    COUNT(IF(ai_blue_sample_code=1, attack_task_id, NULL)) AS ai_blue_white_sample_cnt_1d,
    COUNT(IF(
        ai_blue_sample_code = 0
        AND is_manual = 1
        AND tag_result_code = 'pass',
        attack_task_id,
        NULL
    )) AS ai_blue_black_sample_person_audit_fail_cnt_1d,
    COUNT(IF(
        ai_blue_sample_code = 0
        AND is_manual = 1
        AND tag_result_code NOT IN ('init','pass'),
        attack_task_id,
        NULL
    )) AS ai_blue_black_sample_person_audit_success_cnt_1d,
    COUNT(IF(
        ai_blue_sample_code = 1
        AND is_manual = 1
        AND tag_result_code NOT IN ('init','pass'),
        attack_task_id,
        NULL
    )) AS ai_blue_white_sample_person_audit_fail_cnt_1d,
    COUNT(IF(
        ai_blue_sample_code = 1
        AND is_manual = 1
        AND tag_result_code = 'pass',
        attack_task_id,
        NULL
    )) AS ai_blue_white_sample_person_audit_success_cnt_1d,
    COUNT(IF(
        ai_blue_sample_code=1
        AND is_manual = 1
        AND tag_result_code IS NOT NULL
        AND tag_result_code <> 'init'
        AND tag_result_code NOT IN ('init','pass')
        AND machine_tag_result_code IN ('init','pass'),
        attack_task_id,
        NULL
    )) AS ai_blue_black_sample_machine_success_person_audit_fail_cnt_1d
FROM yshopping.dwm_com_audit_ai_blue_output_detail_df t0
LEFT JOIN (
    SELECT
        COUNT(attack_task_id) AS attack_task_cnt_7d,
        resource_id
    FROM yshopping.dwm_com_audit_ai_blue_output_detail_df
    WHERE pt='${bizdate}'
      AND DATEDIFF('${bizdate}', SUBSTR(attack_task_create_time,1,10)) <= 7
    GROUP BY resource_id
) t1
    ON t0.resource_id=t1.resource_id
WHERE t0.pt='${bizdate}'
GROUP BY ai_blue_content_type_name, SUBSTR(ai_blue_resource_create_time,1,10);
```

## 当前指标口径与待确认事项

### 当前有效指标

本表当前为 **19 个指标字段**（DDL 含 2 个分组维度字段，另有 1 个分区字段 `pt`）：4 个相似度/难度指标、4 个基础指标、6 个机审指标、4 个人审指标和 1 个机审与人审差异指标。原有 4 个二次投放字段已删除，因为已确认每份 `resource_id` 素材只投放一次；不同攻击场景形成的不同素材具有不同 `resource_id`，不属于同一素材复投。

### 人审指标口径

人审效果统计要求实际转人工并且人审完成。`is_manual=1` 表示已转人工；`tag_result_code` 是实际人审结果；`init` 和 NULL 均不计入已完成人审。四项人审计算均继续以 `attack_task_id` 作为原有计数对象：黑样本 pass 计漏过，黑样本非 init/pass 计拦截；白样本非 init/pass 计误伤，白样本 pass 计放行。

机审 6 个指标的 SQL 条件本轮保持不变，包括黑样本 `machine_tag_result_code IN ('init','pass')` 仍按既定口径计为机审漏过。机审直接结束、未转人工的样本不进入人审指标；转人工但结果为 init 或 NULL 的样本也不计入人审效果。以上样本仍留在 DWM。

### 机审/人审差异指标命名待确认

现有字段 `ai_blue_black_sample_machine_success_person_audit_fail_cnt_1d` 的 SQL 实际筛选 `ai_blue_sample_code=1`，即白样本；说明文字也描述白样本机审通过、人审不通过。因此字段名中的 `black` 与计算条件不一致。建议字段名为 `ai_blue_white_sample_machine_success_person_audit_fail_cnt_1d`（旧字段 → 建议新字段），但下游是否引用尚未核实，本轮保留旧字段名，仅在 SQL 增加已完成人审条件。需确认下游依赖后再决定是否改名。

### TODO：相似度指标待业务口径核定

本轮保留以下 4 个相似度字段和 SQL 表达式，不表示其口径或可执行性已确认：

- `ai_blue_similarity_person_audit_fail_cnt_1d`
- `ai_blue_similarity_cnt_1d`
- `ai_blue_similarity_person_audit_fail_difficulty_level_1d`
- `ai_blue_similarity_difficulty_level_1d`

待核定事项：

1. 相似度取值范围是 0～1 还是 0～100。
2. 原 SQL 引用当前 DWM 不存在的 `person_audit_result`，DWM 当前字段为 `tag_result_code`；本轮不替换该引用。
3. 原 SQL 的近 7 日攻击次数计算与“一份素材一次投放”规则不一致，需重新核定。
4. 难度指标的聚合方式、高低相似度过滤条件需重新确认。

**相似度模块本轮不保证 SQL 可执行；不能因其他指标完成调整，就把整张 ADS SQL 标记为全部修复完成。**

### TODO：基础指标日期与计数对象

以下基础指标维持原实现：`ai_blue_resource_cnt_1d`、`ai_blue_attack_cnt_1d`、`ai_blue_user_cnt_1d`、`ai_blue_used_cnt_1d`。后续需确认用户数是否按用户 ID 去重、`is_used` 表示状态还是累计使用次数，以及素材创建日、攻击发生日、人工审核日分别对应何种报表统计口径。本轮不修改这些逻辑。

## 人审口径用例核对（静态预期，未连接运行环境执行）

| 样本 | `is_manual` | `tag_result_code` | 预期人审效果指标 |
| --- | ---: | --- | --- |
| 黑样本 | 1 | `pass` | 黑样本人审漏过 |
| 黑样本 | 1 | 非 `init/pass` 且非 NULL | 黑样本人审拦截 |
| 白样本 | 1 | 非 `init/pass` 且非 NULL | 白样本人审误伤 |
| 白样本 | 1 | `pass` | 白样本人审放行 |
| 任意样本 | 0 或 NULL | 任意 | 不计入人审效果 |
| 任意样本 | 1 | `init` 或 NULL | 不计入已完成人审 |
| 任意样本 | 任意 | 任意，但 `attack_task_id` 为 NULL | 不计入上述攻击效果计数 |

## 可执行前的静态检查建议（待 Spark 环境执行）

```sql
-- 按相同过滤条件独立计算四项已完成人审指标，核对 ADS 输出。
SELECT
    COUNT(IF(ai_blue_sample_code=0 AND is_manual=1 AND tag_result_code='pass', attack_task_id, NULL)) AS black_manual_leak_cnt,
    COUNT(IF(ai_blue_sample_code=0 AND is_manual=1 AND tag_result_code NOT IN ('init','pass'), attack_task_id, NULL)) AS black_manual_block_cnt,
    COUNT(IF(ai_blue_sample_code=1 AND is_manual=1 AND tag_result_code NOT IN ('init','pass'), attack_task_id, NULL)) AS white_manual_false_positive_cnt,
    COUNT(IF(ai_blue_sample_code=1 AND is_manual=1 AND tag_result_code='pass', attack_task_id, NULL)) AS white_manual_pass_cnt
FROM yshopping.dwm_com_audit_ai_blue_output_detail_df
WHERE pt='${bizdate}';
```

此查询只是待执行校验示例。生产分区数据、指标结果、下游看板及 DQC/SLA 均未在本轮环境中实际运行验证。
