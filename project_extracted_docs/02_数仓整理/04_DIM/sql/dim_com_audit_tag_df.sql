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
