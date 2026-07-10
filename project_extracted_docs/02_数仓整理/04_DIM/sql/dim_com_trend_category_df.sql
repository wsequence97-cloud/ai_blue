-- 来源截图：
-- - 用户于 2026-07-10 补充的 dim_com_trend_category_df 建表截图
-- - 用户于 2026-07-10 补充的 dim_com_trend_category_df INSERT 截图
-- 注意：原 INSERT 截图第 9 行将 category_desc_lv3 别名写为 level1_category_name；
--       根据目标 DDL 的三级类目字段顺序，本文修正为 level3_category_name。

CREATE TABLE `yshopping`.`dim_com_trend_category_df` (
    category_code STRING COMMENT '类目编码',
    category_name STRING COMMENT '类目名称',
    level1_category_code STRING COMMENT '内容一级类别id',
    level2_category_code STRING COMMENT '内容二级类别id',
    level3_category_code STRING COMMENT '内容三级类别id',
    level1_category_name STRING COMMENT '内容一级类别name',
    level2_category_name STRING COMMENT '内容二级类别name',
    level3_category_name STRING COMMENT '内容三级类别name',
    creator_id STRING COMMENT '类目创建人',
    modifier_id STRING COMMENT '类目负责人',
    create_time STRING COMMENT '类目创建时间',
    modify_time STRING COMMENT '类目更新时间'
)
COMMENT 'dim-社区域-动态域-审核类目维表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='30', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dim_com_trend_category_df PARTITION(pt='${bizdate}')
SELECT
    category_code,
    category_name,
    category_code_lv1 AS level1_category_code,
    category_code_lv2 AS level2_category_code,
    category_code_lv3 AS level3_category_code,
    category_desc_lv1 AS level1_category_name,
    category_desc_lv2 AS level2_category_name,
    category_desc_lv3 AS level3_category_name,
    creator_id,
    modifier_id,
    create_time,
    modify_time
FROM yshopping.ods_community_community_category_df
WHERE pt='${bizdate}';
