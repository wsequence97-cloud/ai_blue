-- 来源截图：
-- - 数仓/ods/ods_community_community_quilty_check_df(1).png
-- - 数仓/ods/ods_community_community_quilty_check_df(2).png
CREATE TABLE IF NOT EXISTS ods_community_community_quilty_check_df(
    id BIGINT,
    audit_id STRING COMMENT '审核id',
    event_code STRING COMMENT '业务场景码code',
    event_name STRING COMMENT '业务场景码name',
    biz_id STRING COMMENT 'id rood_id/treand_id',
    audit_result STRING COMMENT '审核结果',
    check_content STRING COMMENT '质检备注',
    result_result STRING COMMENT '质检结果',
    create_time STRING COMMENT '创建时间',
    modify_time STRING COMMENT '更新时间'
)
COMMENT 'ods-电商社区系统-质检表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'table.creator'='764815144@qq.com', 'PARTITION_LIFECYCLE'='365d', 'SYNC_METASTORE'='on');
