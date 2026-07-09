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
