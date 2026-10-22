# dwm_com_audit_ai_blue_output_detail_df

## 所属分层

DWM

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 截图右侧被截断或无法确认的位置保留 `TODO`，未强行编造。
- 用户确认：`t1` 内容表用户字段改为 `content_user_*`；`t2` 用户人设字段保留 `ai_blue_user_*`。
- 后置 DWM 以 `resource_id` 为明细粒度：每行表示一份针对具体攻击场景生成的独立仿真测试素材，包含素材基本信息、生成内容、攻击任务、蓝军用户、机审与人审结果。
- 一份素材对应一次攻击投放；`attack_task_id` 可关联多份素材，不是唯一键。DWM 不按审核结果筛选素材。

## SQL 文件

`project_extracted_docs/02_数仓整理/03_DWM/sql/dwm_com_audit_ai_blue_output_detail_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(1).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(2).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(3).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df_代码(1).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df_代码(2).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df_代码(3).png
-- - 用户于 2026-07-10 补充的建表截图（原代码第 30-44 行）
-- 注意：补充截图确认第 35-37 行为空行；第 38、40 行字段按截图原样补入。
-- 用户确认：后置 DWM 以 resource_id 为素材明细粒度；t1 内容表用户字段改为 content_user_*，t2 用户人设字段保留 ai_blue_user_*。

CREATE TABLE IF NOT EXISTS dwm_com_audit_ai_blue_output_detail_df(
    resource_id STRING COMMENT '素材id；后置明细粒度，一行表示一份独立仿真测试素材',
    ai_blue_group_id STRING COMMENT '素材组',
    ai_blue_group_name STRING COMMENT '素材组名称',
    use_time STRING COMMENT '素材使用时间',
    is_used BIGINT COMMENT '蓝军是否被之前使用过',
    ai_blue_resource_creator_id STRING COMMENT '素材创建人员',
    ai_blue_resource_create_time STRING COMMENT '素材系统时间',
    ai_blue_resource_modifier_id STRING COMMENT '素材修改人员',
    ai_blue_resource_modify_time STRING COMMENT '素材修改时间',
    ai_blue_content_task_id STRING COMMENT 'ai智能内容任务ID',
    trend_id STRING COMMENT '内容唯一ID',
    ai_blue_content_title STRING COMMENT '内容名称',
    ai_blue_content_type_code BIGINT COMMENT '内容类型code：0图文 1视频',
    ai_blue_content_type_name STRING COMMENT '内容类型name：0图文 1视频',
    ai_blue_content STRING COMMENT '原文字内容明细',
    ai_blue_content_new STRING COMMENT 'ai文字内容明细',
    ai_blue_image_url STRING COMMENT '原图片url',
    ai_blue_image_url_new STRING COMMENT 'ai文字图片url',
    ai_blue_video_url STRING COMMENT '原视频url',
    ai_blue_video_url_new STRING COMMENT 'ai视频url',
    ai_blue_similarity DOUBLE COMMENT 'ai相似度',
    level1_category_name STRING COMMENT '内容一级标签',
    level2_category_name STRING COMMENT '内容二级标签',
    content_user_id STRING COMMENT '内容记录中的用户ID',
    content_user_name STRING COMMENT '内容记录中的用户昵称',
    content_user_icon STRING COMMENT '内容记录中的用户头像',
    ai_blue_sample_code BIGINT COMMENT '样本属性code：0-黑样本、1-白样本',
    ai_blue_sample_name STRING COMMENT '样本属性name：0-黑样本、1-白样本',
    ai_blue_difficulty_level BIGINT COMMENT '困难等级',
    ai_blue_content_create_time STRING COMMENT '生成内容创建时间',
    ai_blue_content_modify_time STRING COMMENT '生成内容修改时间',
    ai_blue_user_id STRING COMMENT '蓝军用户ID',
    ai_blue_user_name STRING COMMENT '蓝军用户昵称',
    ai_blue_user_sign STRING COMMENT '蓝军用户签名',
    ai_blue_user_icon STRING COMMENT '蓝军用户头像',
    ai_blue_user_remark STRING COMMENT '备注',
    ai_blue_user_create_time STRING COMMENT '生成用户系统时间',
    ai_blue_user_modify_time STRING COMMENT '生成用户修改时间',
    ai_blue_user_style STRING COMMENT '用户人设',
    ai_blue_user_style_code STRING COMMENT '人设生成状态code 1生成中 2生成完成 3生成失败',
    ai_blue_user_style_name STRING COMMENT '人设生成状态name 1生成中 2生成完成 3生成失败',
    user_style_request_id STRING COMMENT '人设生成请求id, workflow id',
    user_id BIGINT COMMENT '蓝军攻击用户id（来自攻击关系表 user_id）',
    attack_task_id STRING COMMENT '攻击任务id',
    attack_task_name STRING COMMENT '攻击任务名称',
    attack_task_creator_id BIGINT COMMENT '攻击任务创建人员',
    attack_task_create_time STRING COMMENT '攻击任务创建时间',
    attack_task_modifier_id BIGINT COMMENT '攻击任务修改人员',
    attack_task_modify_time STRING COMMENT '攻击任务修改时间',
    workflow_runs_id STRING,
    app_id STRING COMMENT 'agent 应用id',
    workflow_id STRING COMMENT '工作流id',
    inputs STRING COMMENT '传参',
    outputs STRING COMMENT '输出',
    elapsed_dur DOUBLE COMMENT '耗时',
    total_tokens BIGINT COMMENT '总计tokens',
    audit_id STRING COMMENT '审核id',
    event_code STRING COMMENT '业务场景码code',
    event_name STRING COMMENT '业务场景码name',
    tag_result_code STRING COMMENT '实际人工审核结果code；init表示待审核、尚未完成人审',
    tag_result_name STRING COMMENT '处置结果name',
    tag_time STRING COMMENT '最新审核时间',
    tag_user_id STRING COMMENT '最新审核人ID',
    tag_user_name STRING COMMENT '最新审核人名称',
    is_manual BIGINT COMMENT '是否转人工：1表示转人工，不代表已完成人审',
    machine_audit_time STRING COMMENT '机审时间',
    machine_tag_result_code STRING COMMENT '实际机器审核结果code',
    machine_tag_result_name STRING COMMENT '机审打标结果name'
)
COMMENT '后置蓝军素材效果明细表；以resource_id为素材粒度，保留素材及其已有审核结果'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='7d', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dwm_com_audit_ai_blue_output_detail_df PARTITION(pt='${bizdate}')
SELECT
    t0.resource_id,
    t0.ai_blue_group_id,
    t0.ai_blue_group_name,
    t0.use_time,
    t0.is_used,
    t0.creator_id AS ai_blue_resource_creator_id,
    t0.create_time AS ai_blue_resource_create_time,
    t0.modifier_id AS ai_blue_resource_modifier_id,
    t0.modify_time AS ai_blue_resource_modify_time,
    t1.ai_blue_content_task_id,
    t1.trend_id,
    t1.ai_blue_content_title,
    t1.ai_blue_content_type_code,
    t1.ai_blue_content_type_name,
    t1.ai_blue_content,
    t1.ai_blue_content_new,
    t1.ai_blue_image_url,
    t1.ai_blue_image_url_new,
    t1.ai_blue_video_url,
    t1.ai_blue_video_url_new,
    t1.ai_blue_similarity,
    t1.level1_category_name,
    t1.level2_category_name,
    t1.ai_blue_user_id AS content_user_id,
    t1.ai_blue_user_name AS content_user_name,
    t1.ai_blue_user_icon AS content_user_icon,
    t1.ai_blue_sample_code,
    t1.ai_blue_sample_name,
    t1.ai_blue_difficulty_level,
    t1.create_time AS ai_blue_content_create_time,
    t1.modify_time AS ai_blue_content_modify_time,
    t2.ai_blue_user_id,
    t2.ai_blue_user_name,
    t2.ai_blue_user_sign,
    t2.ai_blue_user_icon,
    t2.remark AS ai_blue_user_remark,
    t2.create_time AS ai_blue_user_create_time,
    t2.modify_time AS ai_blue_user_modify_time,
    t2.ai_blue_user_style,
    t2.ai_blue_user_style_code,
    t2.ai_blue_user_style_name,
    t2.user_style_request_id,
    t3.user_id,
    t3.attack_task_id,
    t3.attack_task_name,
    t3.creator_id AS attack_task_creator_id,
    t3.create_time AS attack_task_create_time,
    t3.modifier_id AS attack_task_modifier_id,
    t3.modify_time AS attack_task_modify_time,
    t4.workflow_runs_id,
    t4.app_id,
    t4.workflow_id,
    t4.inputs,
    t4.outputs,
    t4.elapsed_dur,
    t4.total_tokens,
    t5.audit_id,
    t5.event_code,
    t5.event_name,
    t5.tag_result_code,
    t5.tag_result_name,
    t5.tag_time,
    t5.tag_user_id,
    t5.tag_user_name,
    t5.is_manual,
    t5.machine_audit_time,
    t5.machine_tag_result_code,
    t5.machine_tag_result_name
FROM yshopping.dwd_com_audit_ai_blue_resource_df t0
LEFT JOIN yshopping.dwd_com_audit_ai_blue_content_df t1
    ON t0.resource_id=t1.resource_id
   AND t1.pt='${bizdate}'
LEFT JOIN yshopping.dwd_com_audit_ai_blue_user_info_df t2
    ON t1.ai_blue_user_id=t2.ai_blue_user_id
   AND t2.pt='${bizdate}'
LEFT JOIN yshopping.dwd_com_audit_ai_blue_user_attack_df t3
    ON t0.resource_id=t3.resource_id
   AND t3.pt='${bizdate}'
LEFT JOIN yshopping.dwd_ai_workflow_workflow_runs_detail_df t4
    ON t1.ai_blue_content_request_id=t4.workflow_runs_id
   AND t4.pt='${bizdate}'
LEFT JOIN yshopping.dwd_com_audit_detail_df t5
    ON t1.trend_id=t5.biz_id
   AND t5.pt='${bizdate}'
WHERE t0.pt='${bizdate}';
```

## 粒度、审核字段与关联唯一性

- `resource_id` 是确认的明细粒度；一个攻击任务可以包含多份素材，因此不能用 `attack_task_id` 作为 DWM 唯一键。
- `machine_tag_result_code` 是实际机审结果；`tag_result_code` 是实际人审结果；`is_manual=1` 仅表示转人工，不代表审核完成；`tag_result_code='init'` 表示待审核。
- SQL 以素材表为主表并使用 LEFT JOIN，保留尚无生成内容、任务或审核结果的素材；不得按机审/人审状态过滤素材。
- 已修正 SELECT 漏选 `t3.user_id` 的位置错配，使攻击用户 ID、攻击任务 ID/名称及创建修改字段与 DDL 顺序对应。

仅凭当前 SQL **不能证明**每个 `resource_id` 最终只产生一行。以下关联均没有 SQL 层唯一性约束或确定性选行逻辑：内容表 `resource_id`、攻击关系表 `resource_id`、用户人设表 `ai_blue_user_id`、工作流表 `workflow_runs_id`、审核明细表 `biz_id`。审核明细尤其可能对同一 `trend_id` 有多条记录。不得用最终 DISTINCT 或任意 ROW_NUMBER/MAX 掩盖；须先用下方校验及源表规则确认。若源表确有多条且没有经业务确认的有效记录选择规则，需先确认规则再改 SQL。

## DWM 唯一性校验（待 Spark 环境执行）

```sql
-- 行数与非空 resource_id 去重数应相等，且空 resource_id 为 0。
SELECT
    COUNT(*) AS row_cnt,
    COUNT(resource_id) AS non_null_resource_id_cnt,
    COUNT(DISTINCT resource_id) AS distinct_resource_id_cnt,
    SUM(CASE WHEN resource_id IS NULL THEN 1 ELSE 0 END) AS null_resource_id_cnt,
    CASE WHEN COUNT(*) = COUNT(DISTINCT resource_id) THEN 'PASS' ELSE 'FAIL' END AS unique_and_non_null_check
FROM yshopping.dwm_com_audit_ai_blue_output_detail_df
WHERE pt='${bizdate}';

-- 查找重复素材键。
SELECT resource_id, COUNT(*) AS row_cnt
FROM yshopping.dwm_com_audit_ai_blue_output_detail_df
WHERE pt='${bizdate}'
GROUP BY resource_id
HAVING resource_id IS NULL OR COUNT(*) > 1;

-- 查看重复 resource_id 对应的具体明细与可能的放大关联。
SELECT *
FROM yshopping.dwm_com_audit_ai_blue_output_detail_df
WHERE pt='${bizdate}'
  AND (resource_id IN (
      SELECT resource_id
      FROM yshopping.dwm_com_audit_ai_blue_output_detail_df
      WHERE pt='${bizdate}'
      GROUP BY resource_id
      HAVING COUNT(*) > 1
  )
  OR resource_id IS NULL);
```

将重复归因到某个 JOIN 前，先检查各来源表在当前分区的关联键基数。以下诊断语句尚未在实际数据环境执行：

```sql
SELECT resource_id, COUNT(*) AS row_cnt FROM yshopping.dwd_com_audit_ai_blue_resource_df WHERE pt='${bizdate}' GROUP BY resource_id HAVING COUNT(*) > 1;
SELECT resource_id, COUNT(*) AS row_cnt FROM yshopping.dwd_com_audit_ai_blue_content_df WHERE pt='${bizdate}' GROUP BY resource_id HAVING COUNT(*) > 1;
SELECT resource_id, COUNT(*) AS row_cnt FROM yshopping.dwd_com_audit_ai_blue_user_attack_df WHERE pt='${bizdate}' GROUP BY resource_id HAVING COUNT(*) > 1;
SELECT ai_blue_user_id, COUNT(*) AS row_cnt FROM yshopping.dwd_com_audit_ai_blue_user_info_df WHERE pt='${bizdate}' GROUP BY ai_blue_user_id HAVING COUNT(*) > 1;
SELECT workflow_runs_id, COUNT(*) AS row_cnt FROM yshopping.dwd_ai_workflow_workflow_runs_detail_df WHERE pt='${bizdate}' GROUP BY workflow_runs_id HAVING COUNT(*) > 1;
SELECT biz_id, COUNT(*) AS row_cnt FROM yshopping.dwd_com_audit_detail_df WHERE pt='${bizdate}' GROUP BY biz_id HAVING COUNT(*) > 1;
```

以上仅为待执行校验语句，不代表已连接 Spark/EasyData 或生产验证通过。
