# dwd_com_audit_quality_check_detail_df

## 所属分层

DWD

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 截图右侧被截断或无法确认的位置保留 `TODO`，未强行编造。

## SQL 文件

`project_extracted_docs/02_数仓整理/02_DWD/sql/dwd_com_audit_quality_check_detail_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/dwd/dwd_com_audit_quilty_check_detail_df(1).png
-- - 数仓/dwd/dwd_com_audit_quilty_check_detail_df(2).png
-- 注意：原截图文件名与表名中均出现 quilty/quality 拼写不一致风险，本文件名采用 quality，表名按截图采用 quilty。

CREATE TABLE IF NOT EXISTS dwd_com_audit_quilty_check_detail_df(
    check_id STRING COMMENT '质检id',
    audit_id STRING COMMENT '审核id',
    event_code STRING COMMENT '业务场景码code',
    event_name STRING COMMENT '业务场景码name',
    biz_id STRING COMMENT '封禁id rood_id/treand_id',
    audit_result_code STRING COMMENT '审核结果code',
    audit_result_name STRING COMMENT '审核结果name',
    check_content STRING COMMENT '质检备注',
    check_result_code STRING COMMENT '质检结果code',
    check_result_name STRING COMMENT '质检结果name',
    create_time STRING COMMENT '创建时间',
    modify_time STRING COMMENT '更新时间'
)
COMMENT 'dwd-社区域-审核域-质检表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='7d', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');
```
