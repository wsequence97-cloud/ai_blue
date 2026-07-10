-- 来源截图：
-- - 数仓/dim/dim_com_ecology_tag_df.png
-- 用户于 2026-07-10 确认 ods_community_ecology_tag_df 不属于当前蓝军主链路；
-- 本 SQL 仅保留为历史截图还原，不纳入当前项目缺表清单或执行链路。

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
