-- 来源截图：
-- - 数仓/dwd/dwd_com_audit_ai_blue_content_df.png
-- - 数仓/dwd/dwd_com_audit_ai_blue_content_df_代码1.png
-- - 数仓/dwd/dwd_com_audit_ai_blue_content_df_代码2.png

CREATE TABLE IF NOT EXISTS dwd_com_audit_ai_blue_content_df(
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
    resource_id STRING COMMENT '素材库素材id',
    level1_category_name STRING COMMENT '内容一级标签',
    level2_category_name STRING COMMENT '内容二级标签',
    ai_blue_user_id STRING COMMENT '用户ID',
    ai_blue_user_name STRING COMMENT '用户昵称',
    ai_blue_user_icon STRING COMMENT '用户头像',
    ai_blue_sample_code BIGINT COMMENT '样本属性code：0-黑样本、1-白样本',
    ai_blue_sample_name STRING COMMENT '样本属性name：0-黑样本、1-白样本',
    ai_blue_difficulty_level BIGINT COMMENT '困难等级',
    ai_blue_content_request_id STRING COMMENT '大模型请求id，等同于workflow_runs_id',
    create_time STRING COMMENT '创建时间',
    modify_time STRING COMMENT '修改时间'
)
COMMENT 'dwd-社区域-审核域-社区蓝军内容表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'PARTITION_LIFECYCLE'='7d',
    'table.creator'='TODO: 截图右侧被截断，需人工确认'
);

INSERT OVERWRITE TABLE yshopping.dwd_com_audit_ai_blue_content_df PARTITION(pt='${bizdate}')
SELECT
    CAST(ai_task_id AS STRING) AS ai_blue_content_task_id,
    trend_id,
    content_title AS ai_blue_content_title,
    content_type AS ai_blue_content_type_code,
    t1.code_desc AS ai_blue_content_type_name,
    content AS ai_blue_content,
    new_content AS ai_blue_content_new,
    image_url AS ai_blue_image_url,
    new_image_url AS ai_blue_image_url_new,
    video_url AS ai_blue_video_url,
    new_video_url AS ai_blue_video_url_new,
    similarity AS ai_blue_similarity,
    CAST(resource_id AS STRING) AS resource_id,
    cap_first_level_tag AS level1_category_name,
    cap_second_level_tag AS level2_category_name,
    CAST(user_id AS STRING) AS ai_blue_user_id,
    user_name AS ai_blue_user_name,
    user_icon AS ai_blue_user_icon,
    sample_attributes AS ai_blue_sample_code,
    t2.code_desc AS ai_blue_sample_name,
    difficulty_level AS ai_blue_difficulty_level,
    request_id AS ai_blue_content_request_id,
    create_time,
    modify_time
FROM yshopping.ods_community_ai_blue_content_df t0
LEFT JOIN yshopping.dim_code_desc t1
    ON CAST(t0.content_type AS STRING)=t1.code
   AND t1.table_name='ods_community_community_trend_df'
   AND t1.content_type='content_type'
LEFT JOIN yshopping.dim_code_desc t2
    ON CAST(t0.content_type AS STRING)=t2.code
   AND t2.table_name='ods_community_ai_blue_content_df'
   AND t2.content_type='sample_attributes'
WHERE t0.pt='${bizdate}';
