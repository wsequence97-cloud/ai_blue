# ods_community_audit_tag_df

## 所属分层

ODS

## 业务含义

社区审核标签全量表，保存标签编码、标签名称、标签负责人及创建更新时间。截图说明约 500 条数据，按 30 天分区。

## 整理说明

- 本表根据用户于 2026-07-10 补充的建表截图整理。
- 截图标题、表注释和实际上下游用途均指向 `ods_community_audit_tag_df`，但原 CREATE 第 1 行误写为 `ods_community_ecology_tag_df`；本文按目标表名修正。
- 当前补充截图只有 DDL，未提供 ODS 数据样例。

## 下游去向

```text
ods_community_audit_tag_df
→ dim_com_audit_tag_df
→ dwm_com_audit_ai_blue_input_detail_di
```

在 DWM input 宽表中：

- 机审标签编码 `machine_tag_code` 通过 `dim_com_audit_tag_df` 映射为 `machine_tag_name_list`。
- 人审标签编码 `tag_code` 通过 `dim_com_audit_tag_df` 映射为 `tag_name_list`。

## SQL 文件

`project_extracted_docs/02_数仓整理/01_ODS/sql/ods_community_audit_tag_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 用户于 2026-07-10 补充的 ods_community_audit_tag_df 建表截图
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
```

## 数据样例

当前补充截图未提供数据样例。
