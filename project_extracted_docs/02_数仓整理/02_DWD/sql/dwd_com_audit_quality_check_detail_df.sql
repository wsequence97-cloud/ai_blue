-- 来源截图：
-- - 数仓/dwd/dwd_com_audit_quilty_check_detail_df(1).png
-- - 数仓/dwd/dwd_com_audit_quilty_check_detail_df(2).png
-- - 用户于 2026-07-10 补充的 INSERT SQL 截图
-- 注意：截图、DDL、INSERT 及下游 DWM 均使用 quilty；只有当前整理文件名使用了 quality。
-- 注意：补充的 INSERT 使用 t0.check_result，而现有 ODS 建表截图整理出的字段为 result_result，本文按新截图原样保留，执行前需确认 ODS 实际字段名。

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

INSERT OVERWRITE TABLE yshopping.dwd_com_audit_quilty_check_detail_df PARTITION(pt='${bizdate}')
SELECT
    CAST(id AS STRING) AS check_id,
    audit_id,
    event_code,
    event_name,
    biz_id,
    audit_result AS audit_result_code,
    t1.code_desc AS audit_result_name,
    check_content,
    check_result AS check_result_code,
    t2.code_desc AS check_result_name,
    create_time,
    modify_time
FROM yshopping.ods_community_community_quilty_check_df t0
LEFT JOIN yshopping.dim_code_desc t1
    ON CAST(t0.audit_result AS STRING)=t1.code
   AND t1.table_name='ods_community_community_audit_result_df'
   AND t1.content_type='handle_result'
LEFT JOIN yshopping.dim_code_desc t2
    ON CAST(t0.check_result AS STRING)=t2.code
   AND t2.table_name='ods_community_community_audit_result_df'
   AND t2.content_type='handle_result'
WHERE t0.pt='${bizdate}';
