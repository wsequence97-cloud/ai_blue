# dim_com_ecology_tag_df

## 所属分层

DIM

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 截图右侧被截断或无法确认的位置保留 `TODO`，未强行编造。

## SQL 文件

`project_extracted_docs/02_数仓整理/04_DIM/sql/dim_com_ecology_tag_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/dim/dim_com_ecology_tag_df.png

CREATE TABLE `yshopping`.`dim_com_ecology_tag_df` (
    tag_code STRING COMMENT '标签编码',
    tag_name STRING COMMENT '标签名称',
    dept_name STRING COMMENT '标签所属部门',
    event_owner_name STRING COMMENT '标签负责人'
)
COMMENT 'dim-社区生态审-标签维表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='30d', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dim_com_ecology_tag_df PARTITION(pt='${bizdate}')
SELECT
    tag_code,
    tag_name,
    dept_name,
    event_owner_name
FROM yshopping.ods_community_ecology_tag_df
WHERE pt='${bizdate}';
```
