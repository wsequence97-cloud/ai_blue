# dim_com_audit_tag_df

## 所属分层

DIM

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 截图右侧被截断或无法确认的位置保留 `TODO`，未强行编造。
- 上游 `ods_community_audit_tag_df` 的 DDL 已由用户于 2026-07-10 补充并纳入 ODS 目录。

## 上下游与关联用途

- 上游：`ods_community_audit_tag_df`。
- 本表通过直接 SELECT 将审核标签编码和名称加工为 `dim_com_audit_tag_df`。
- 下游：`dwm_com_audit_ai_blue_input_detail_di`。
- 下游第一次关联用于把 `machine_tag_code` 映射为 `machine_tag_name_list`；第二次关联用于把 `tag_code` 映射为 `tag_name_list`。

因此，`ods_community_audit_tag_df` 是蓝军 input 宽表中机审、人审标签名称的间接上游，需要保留。

## SQL 文件

`project_extracted_docs/02_数仓整理/04_DIM/sql/dim_com_audit_tag_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/dim/dim_com_audit_df.png
-- - 数仓/dim/dim_com_audit_df_具体映射.png

CREATE TABLE `yshopping`.`dim_com_audit_tag_df` (
    tag_code STRING COMMENT '标签编码',
    tag_name STRING COMMENT '标签名称',
    event_owner_name STRING COMMENT '标签负责人',
    create_time STRING COMMENT '标签创建时间',
    modify_time STRING COMMENT '标签更新时间'
)
COMMENT 'dim-社区生态审-标签维表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='30d', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dim_com_audit_tag_df PARTITION(pt='${bizdate}')
SELECT
    tag_code,
    tag_name,
    event_owner_name,
    create_time,
    modify_time
FROM yshopping.ods_community_audit_tag_df
WHERE pt='${bizdate}';

-- 截图可见样例映射：
-- 706 人社矛盾
-- 782 套路营销
-- 102 引人不适
-- 185 互关互赞
-- 97 竞品信息
-- 76 负面价值观
-- 75 色情低俗
-- 40 伪科学
-- 33 宗教
-- 6 血腥暴力
```
