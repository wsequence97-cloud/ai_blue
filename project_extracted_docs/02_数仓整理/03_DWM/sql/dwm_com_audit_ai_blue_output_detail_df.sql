-- 来源截图：
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(1).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(2).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(3).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df_代码(1).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df_代码(2).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df_代码(3).png
-- - 用户于 2026-07-10 补充的建表截图（原代码第 30-44 行）
-- 注意：补充截图确认第 35-37 行为空行；第 38、40 行字段按截图原样补入。
-- 注意：补入后 ai_blue_user_name、ai_blue_user_icon 与前文存在同名字段。
-- SELECT 还同时输出 t1/t2 两组 ai_blue_user_id/name/icon，但 DDL 只声明一个 ai_blue_user_id，且 DDL 的 user_id 没有对应的 t3.user_id；执行前需确认字段命名和列顺序。

CREATE TABLE IF NOT EXISTS dwm_com_audit_ai_blue_output_detail_df(
    resource_id STRING COMMENT '素材id',
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
    ai_blue_user_id STRING COMMENT '用户ID',
    ai_blue_user_name STRING COMMENT '用户昵称',
    ai_blue_user_icon STRING COMMENT '用户头像',
    ai_blue_sample_code BIGINT COMMENT '样本属性code：0-黑样本、1-白样本',
    ai_blue_sample_name STRING COMMENT '样本属性name：0-黑样本、1-白样本',
    ai_blue_difficulty_level BIGINT COMMENT '困难等级',
    ai_blue_content_create_time STRING COMMENT '生成内容创建时间',
    ai_blue_content_modify_time STRING COMMENT '生成内容修改时间',
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
    user_id BIGINT COMMENT '蓝军攻击用户id',
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
    tag_result_code STRING COMMENT '处置结果code：init-待审核, pass-通过, hide-隐藏, lock-封禁, remove-删除, only_fans-仅粉丝可见, anti_spam-反垃圾, show-显示, recover-恢复, unlock-解禁, ignore-忽略, reset-重...',
    tag_result_name STRING COMMENT '处置结果name',
    tag_time STRING COMMENT '最新审核时间',
    tag_user_id STRING COMMENT '最新审核人ID',
    tag_user_name STRING COMMENT '最新审核人名称',
    is_manual BIGINT COMMENT '机审是否转人工',
    machine_audit_time STRING COMMENT '机审时间',
    machine_tag_result_code STRING COMMENT '机审打标结果code',
    machine_tag_result_name STRING COMMENT '机审打标结果name'
)
COMMENT 'dwd-社区域-审核域-ai智能蓝军输出表-全量表'
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
    t1.ai_blue_user_id,
    t1.ai_blue_user_name,
    t1.ai_blue_user_icon,
    t1.ai_blue_sample_code,
    t1.ai_blue_sample_name,
    t1.ai_blue_difficulty_level,
    t1.create_time AS ai_blue_content_create_time,
    t1.modify_time AS ai_blue_content_modify_time,
    t2.ai_blue_user_id,
    t2.ai_blue_user_name,
    t2.ai_blue_user_sign,
    t2.ai_blue_user_icon,
    t2.ai_blue_user_remark,
    t2.create_time AS ai_blue_user_create_time,
    t2.modify_time AS ai_blue_user_modify_time,
    t2.ai_blue_user_style,
    t2.ai_blue_user_style_code,
    t2.ai_blue_user_style_name,
    t2.user_style_request_id,
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
