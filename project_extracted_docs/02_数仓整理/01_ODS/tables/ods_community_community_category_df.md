# ods_community_community_category_df

## 所属分层

ODS

## 截图标题与数据量

- 截图标题：社区动态类目表
- 数据量说明：约 500 条数据，30 天分区

## 业务含义

社区动态类目源表，保存类目编码、类目名称、一级/二级/三级类目层级编码及名称，以及类目创建、修改信息。

该表是 `dim_com_trend_category_df` 的上游来源，用于将动态表中的 `level3_category_code` 补充为一级、二级、三级类目名称。

## 来源截图

- `数仓/ods/ods_community_community_category_df.png`

## 建表语句

见 SQL 文件：`project_extracted_docs/02_数仓整理/01_ODS/sql/ods_community_community_category_df.sql`

```sql
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
```

## 数据样例

当前仅收到建表截图，没有收到该表的数据样例截图，因此不虚构样例数据。

## 下游关系

```text
ods_community_community_category_df
    -> dim_com_trend_category_df
    -> DWM 输入宽表
```

`dim_com_trend_category_df` 中的字段映射为：

```text
category_code_lv1 -> level1_category_code
category_code_lv2 -> level2_category_code
category_code_lv3 -> level3_category_code
category_desc_lv1 -> level1_category_name
category_desc_lv2 -> level2_category_name
category_desc_lv3 -> level3_category_name
```
