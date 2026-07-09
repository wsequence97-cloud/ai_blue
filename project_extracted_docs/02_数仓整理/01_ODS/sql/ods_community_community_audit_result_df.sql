-- 来源截图：
-- - 数仓/ods/ods_community_community_audit_result_df.png
-- 注意：截图右侧被截断，TBLPROPERTIES 末尾未完全拍到。
CREATE TABLE `yshopping`.`ods_community_community_audit_result_df` (
    id BIGINT COMMENT '自增id',
    event_code STRING COMMENT '业务场景码',
    biz_id STRING COMMENT '业务ID',
    publish_user_id BIGINT COMMENT '发布人ID',
    publish_time STRING COMMENT '发布时间',
    publish_content STRING COMMENT '发布内容',
    tag_code BIGINT COMMENT '人审打标code',
    tag_result STRING COMMENT '处置结果：init-待审核, pass-通过, hide-隐藏, lock-封禁, remove-TODO截图右侧截断',
    tag_time STRING COMMENT '最新审核时间',
    tag_user_id BIGINT COMMENT '最新审核人ID',
    tag_user_name STRING COMMENT '最新审核人名称',
    content_type STRING COMMENT '内容类型',
    is_manual BIGINT COMMENT '机审是否转人工',
    machine_audit_time STRING COMMENT '机审时间',
    machine_tag_code BIGINT COMMENT '机审打标code',
    machine_tag_result STRING COMMENT '机审标签',
    is_del BIGINT COMMENT '是否删除：0-未删除、1-已删除',
    create_time STRING COMMENT '创建时间',
    modify_time STRING COMMENT '最新修改时间'
)
COMMENT 'ods-电商社区系统-审核结果表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'PARTITION_LIFECYCLE'='30d',
    'table.creator'='TODO: 截图右侧被截断，需人工确认'
);
