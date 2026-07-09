# ods_community_ai_blue_resource_df

## 所属分层

ODS

## 截图标题与数据量

- 截图标题：社区蓝军素材表
- 数据量说明：每日新增 1.8w+ 条，总体 1300w+ 数据量，数据量是蓝军 + 内容的总和

## 来源截图

- `数仓/ods/ods_community_ai_blue_resource_df(1).png`
- `数仓/ods/ods_community_ai_blue_resource_df(2).png`
- `数仓/ods/ods_community_ai_blue_resource_df(样例).png`

## 建表语句

见 SQL 文件：`project_extracted_docs/02_数仓整理/01_ODS/sql/ods_community_ai_blue_resource_df.sql`

```sql
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
```

## 数据样例

| id | group_id | group_name | use_time | is_used | creator_id | create_time | modifier_id | modify_time | is_del |
|---:|---:|---|---|---:|---|---|---|---|---:|
| 69204 | 2 | 宗教 | 2025-08-23 11:11:41 | 0 | xxx | 2025-08-23 07:12:53 | xxx | 2025-08-23 07:12:53 | 0 |
