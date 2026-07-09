-- 来源截图：
-- - 数仓/ods/ods_community_ai_blue_user_info_df(1).png
-- - 数仓/ods/ods_community_ai_blue_user_info_df(2).png
CREATE TABLE IF NOT EXISTS ods_community_ai_blue_user_info_df(
    id BIGINT,
    user_id BIGINT COMMENT '蓝军用户id',
    user_name STRING COMMENT '蓝军用户昵称',
    user_sign STRING COMMENT '蓝军用户签名',
    user_icon STRING COMMENT '蓝军用户头像',
    remark STRING COMMENT '备注',
    create_time STRING COMMENT '系统时间',
    modify_time STRING COMMENT '修改时间',
    resource_id BIGINT COMMENT '素材库素材id',
    user_style STRING COMMENT '用户人设',
    user_style_status STRING COMMENT '人设生成状态code 1生成中 2生成完成 3生成失败',
    user_style_request_id STRING COMMENT '人设生成请求id, workflow id'
)
COMMENT 'ods-电商社区系统-社区运营账号用户人设表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'table.creator'='764815144@qq.com', 'PARTITION_LIFECYCLE'='7d', 'SYNC_METASTORE'='on');
