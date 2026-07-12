-- 来源截图：
-- - 数仓/ods/ods_community_audit_tag_df.png
-- - 用户于 2026-07-12 新增的 ods_community_audit_tag_df 建表截图
-- 注意：截图标题、表注释及上下游用途均指向 ods_community_audit_tag_df，
--       但原 CREATE 第 1 行误写为 ods_community_ecology_tag_df；本文按目标表名修正。

CREATE TABLE `yshopping`.`ods_community_audit_tag_df` (
    tag_code STRING COMMENT '标签编码',
    tag_name STRING COMMENT '标签名称',
    event_owner_name STRING COMMENT '标签负责人',
    create_time STRING COMMENT '标签创建时间',
    modify_time STRING COMMENT '标签更新时间'
)
COMMENT 'ods-社区生态审系统-审核标签维表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='30d', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');
