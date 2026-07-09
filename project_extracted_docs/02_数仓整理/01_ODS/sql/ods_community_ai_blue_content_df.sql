-- 来源截图：
-- - 数仓/ods/ods_community_ai_blue_content_df(1).png
-- - 数仓/ods/ods_community_ai_blue_content_df(2).png
CREATE TABLE IF NOT EXISTS ods_community_ai_blue_content_df(
    id BIGINT COMMENT '自增id',
    ai_task_id BIGINT COMMENT 'ai智能内容任务ID',
    trend_id STRING COMMENT '内容唯一ID',
    content_title STRING COMMENT '内容名称',
    content_type BIGINT COMMENT '内容类型：0图文 1视频',
    content STRING COMMENT '原文字内容明细',
    new_content STRING COMMENT 'ai文字内容明细',
    image_url STRING COMMENT '原图片url',
    new_image_url STRING COMMENT 'ai文字图片url',
    video_url STRING COMMENT '原视频url',
    new_video_url STRING COMMENT 'ai视频url',
    similarity DOUBLE COMMENT 'ai相似度',
    resource_id BIGINT COMMENT '素材库素材id',
    cap_first_level_tag STRING COMMENT '内容一级类型',
    cap_second_level_tag STRING COMMENT '内容二级类型',
    user_id BIGINT COMMENT '用户ID',
    user_name STRING COMMENT '用户昵称',
    user_icon STRING COMMENT '用户头像',
    sample_attributes BIGINT COMMENT '样本属性：0-黑样本、1-白样本',
    difficulty_level BIGINT COMMENT '困难等级',
    request_id STRING COMMENT '请求id',
    create_time STRING COMMENT '创建时间',
    modify_time STRING COMMENT '修改时间'
)
COMMENT 'ods-电商社区系统-社区蓝军内容表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'table.creator'='764815144@qq.com', 'PARTITION_LIFECYCLE'='7d', 'SYNC_METASTORE'='on');
