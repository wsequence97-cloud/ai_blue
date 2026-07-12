-- 来源截图：
-- - 数仓/ods/ods_community_community_category_df.png
-- 截图说明：约 500 条数据，30 天分区。
-- 注意：截图中 category_code_lv1/lv2/lv3 的 COMMENT 写为“类目名称”，
--       本文保留截图原注释；字段名本身表示一级/二级/三级类目编码。

CREATE TABLE `yshopping`.`ods_community_community_category_df` (
    category_code STRING COMMENT '类目编码',
    category_name STRING COMMENT '类目名称',
    category_code_lv1 STRING COMMENT '1级类目名称',
    category_code_lv2 STRING COMMENT '2级类目名称',
    category_code_lv3 STRING COMMENT '3级类目名称',
    category_desc_lv1 STRING COMMENT '1级类目名称',
    category_desc_lv2 STRING COMMENT '2级类目名称',
    category_desc_lv3 STRING COMMENT '3级类目名称',
    creator_id STRING COMMENT '类目创建人',
    modifier_id STRING COMMENT '类目修改人',
    create_time STRING COMMENT '类目创建时间',
    modify_time STRING COMMENT '类目更新时间'
)
COMMENT 'ods-社区生态系统-审核类目维表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'PARTITION_LIFECYCLE'='30d',
    'table.creator'='764815144@qq.com',
    'SYNC_METASTORE'='on'
);
