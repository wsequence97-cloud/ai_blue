# dwd_com_audit_ai_blue_resource_df

## 所属分层

DWD

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 截图右侧被截断或无法确认的位置保留 `TODO`，未强行编造。

## SQL 文件

`project_extracted_docs/02_数仓整理/02_DWD/sql/dwd_com_audit_ai_blue_resource_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/dwd/dwd_com_audit_ai_blue_resource_df.png
-- - 数仓/dwd/dwd_com_audit_ai_blue_resource_df_代码.png

CREATE TABLE IF NOT EXISTS dwd_com_audit_ai_blue_resource_df(
    resource_id STRING COMMENT '素材id',
    ai_blue_group_id STRING COMMENT '素材组',
    ai_blue_group_name STRING COMMENT '素材组名称',
    use_time STRING COMMENT '素材使用时间',
    is_used BIGINT COMMENT '蓝军是否被之前使用过',
    creator_id STRING COMMENT '创建人员',
    create_time STRING COMMENT '系统时间',
    modifier_id STRING COMMENT '修改人员',
    modify_time STRING COMMENT '修改时间'
)
COMMENT 'dwd-社区域-审核域-社区蓝军素材表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'PARTITION_LIFECYCLE'='7d',
    'table.creator'='TODO: 截图右侧被截断，需人工确认'
);

INSERT OVERWRITE TABLE yshopping.dwd_com_audit_ai_blue_resource_df PARTITION(pt='${bizdate}')
SELECT
    CAST(id AS STRING) AS resource_id,
    group_id AS ai_blue_group_id,
    group_name AS ai_blue_group_name,
    use_time,
    is_used,
    CAST(creator_id AS STRING) AS creator_id,
    create_time,
    CAST(modifier_id AS STRING) AS modifier_id,
    modify_time
FROM yshopping.ods_community_ai_blue_resource_df t0
WHERE t0.pt='${bizdate}'
  AND t0.is_del=0;
```
