# dwd_com_audit_detail_df

## 所属分层

DWD

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 截图右侧被截断或无法确认的位置保留 `TODO`，未强行编造。

## SQL 文件

`project_extracted_docs/02_数仓整理/02_DWD/sql/dwd_com_audit_detail_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/dwd/dwd_com_audit_detail_df(1).png
-- - 数仓/dwd/dwd_com_audit_detail_df(2).png
-- - 数仓/dwd/dwd_com_audit_detail_df(3).png
-- - 数仓/dwd/dwd_com_audit_detail_df_代码1.png
-- - 数仓/dwd/dwd_com_audit_detail_df_代码2.png

CREATE TABLE `yshopping`.`dwd_com_audit_detail_df` (
    audit_id STRING COMMENT '审核id',
    event_code STRING COMMENT '业务场景码code',
    event_name STRING COMMENT '业务场景码name',
    biz_id STRING COMMENT '业务ID',
    publish_user_id STRING COMMENT '发布人ID',
    publish_time STRING COMMENT '发布时间',
    publish_content STRING COMMENT '发布内容',
    tag_code BIGINT COMMENT '人审打标code',
    tag_result_code STRING COMMENT '处置结果code：init-待审核, pass-通过, hide-隐藏, lock-封禁, remove-删除, only_fans-仅粉丝可见, anti_spam-反垃圾, show-显示, recover-恢复, unlock-解禁, ignore-忽略, reset-重...',
    tag_result_name STRING COMMENT '处置结果name',
    tag_time STRING COMMENT '最新审核时间',
    tag_user_id STRING COMMENT '最新审核人ID',
    tag_user_name STRING COMMENT '最新审核人名称',
    content_type_code STRING COMMENT '内容类型code',
    content_type_name STRING COMMENT '内容类型name',
    is_manual BIGINT COMMENT '机审是否转人工',
    machine_audit_time STRING COMMENT '机审时间',
    machine_tag_code BIGINT COMMENT '机审打标code',
    machine_tag_result_code STRING COMMENT '机审打标结果code',
    machine_tag_result_name STRING COMMENT '机审打标结果name',
    create_time STRING COMMENT '创建时间',
    modify_time STRING COMMENT '最新修改时间'
)
COMMENT 'dwd-社区域-审核域-审核明细-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期', event_code STRING COMMENT '业务场景码code')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='365d', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dwd_com_audit_detail_df PARTITION (pt='${bizdate}', event_code)
SELECT
    CAST(t0.id AS STRING) AS audit_id,
    t0.event_code,
    t1.code_desc AS event_name,
    t0.biz_id,
    CAST(t0.publish_user_id AS STRING) AS publish_user_id,
    t0.publish_time,
    t0.publish_content,
    t0.tag_code,
    t0.tag_result AS tag_result_code,
    t2.code_desc AS tag_result_name,
    t0.tag_time,
    CAST(t0.tag_user_id AS STRING) AS tag_user_id,
    t0.tag_user_name,
    t0.content_type AS content_type_code,
    t3.code_desc AS content_type_name,
    t0.is_manual,
    t0.machine_audit_time,
    t0.machine_tag_code,
    t0.machine_tag_result AS machine_tag_result_code,
    t4.code_desc AS machine_tag_result_name,
    t0.create_time,
    t0.modify_time,
    t0.event_code
FROM yshopping.ods_community_community_audit_result_df t0
LEFT JOIN yshopping.dim_code_desc t1
    ON CAST(t0.event_code AS STRING)=t1.code
   AND t1.table_name='ods_community_community_audit_result_df'
   AND t1.fields_name='event_code'
LEFT JOIN yshopping.dim_code_desc t2
    ON CAST(t0.tag_result AS STRING)=t2.code
   AND t2.table_name='ods_community_community_audit_result_df'
   AND t2.fields_name='tag_result'
LEFT JOIN yshopping.dim_code_desc t3
    ON CAST(t0.content_type AS STRING)=t3.code
   AND t3.table_name='ods_community_community_audit_result_df'
   AND t3.fields_name='content_type'
LEFT JOIN yshopping.dim_code_desc t4
    ON CAST(t0.machine_tag_result AS STRING)=t4.code
   AND t4.table_name='ods_community_community_audit_result_df'
   AND t4.fields_name='machine_tag_result'
WHERE t0.pt='${bizdate}';
```
