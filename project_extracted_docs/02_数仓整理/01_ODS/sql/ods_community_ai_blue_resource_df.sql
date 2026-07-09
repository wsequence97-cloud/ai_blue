-- 来源截图：
-- - 数仓/ods/ods_community_ai_blue_resource_df(1).png
-- - 数仓/ods/ods_community_ai_blue_resource_df(2).png
CREATE TABLE IF NOT EXISTS ods_community_ai_blue_resource_df(
    id BIGINT COMMENT '自增id',
    group_id STRING COMMENT '素材组',
    group_name STRING COMMENT '素材组名称',
    use_time STRING COMMENT '素材使用时间',
    is_used BIGINT COMMENT '蓝军是否被之前使用过',
    creator_id BIGINT COMMENT '创建人员',
    create_time STRING COMMENT '系统时间',
    modifier_id BIGINT COMMENT '修改人员',
    modify_time STRING COMMENT '修改时间',
    is_del BIGINT COMMENT '素材是否删除：0-未删除、1-已删除'
)
COMMENT 'ods-电商社区系统-社区蓝军内容表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'table.creator'='764815144@qq.com', 'PARTITION_LIFECYCLE'='7d', 'SYNC_METASTORE'='on');
