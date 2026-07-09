-- 来源截图：
-- - 数仓/dwd/dwd_com_audit_ai_blue_user_info_df(1).png
-- - 数仓/dwd/dwd_com_audit_ai_blue_user_info_df(2).png
-- - 数仓/dwd/dwd_com_audit_ai_blue_user_info_df_代码.png

CREATE TABLE IF NOT EXISTS dwd_com_audit_ai_blue_user_info_df(
    ai_blue_user_id STRING COMMENT '蓝军用户id',
    ai_blue_user_name STRING COMMENT '蓝军用户昵称',
    ai_blue_user_sign STRING COMMENT '蓝军用户签名',
    ai_blue_user_icon STRING COMMENT '蓝军用户头像',
    remark STRING COMMENT '备注',
    create_time STRING COMMENT '系统时间',
    modify_time STRING COMMENT '修改时间',
    resource_id BIGINT COMMENT '素材库素材id',
    ai_blue_user_style STRING COMMENT '用户人设',
    ai_blue_user_style_code STRING COMMENT '人设生成状态code 1生成中 2生成完成 3生成失败',
    ai_blue_user_style_name STRING COMMENT '人设生成状态name 1生成中 2生成完成 3生成失败',
    user_style_request_id STRING COMMENT '人设生成请求id, workflow id'
)
COMMENT 'dwd-社区域-审核域-ai蓝军运营账号用户人设表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='7d', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dwd_com_audit_ai_blue_user_info_df PARTITION(pt='${bizdate}')
SELECT
    CAST(user_id AS STRING) AS ai_blue_user_id,
    user_name AS ai_blue_user_name,
    user_sign AS ai_blue_user_sign,
    user_icon AS ai_blue_user_icon,
    remark,
    create_time,
    modify_time,
    resource_id,
    user_style AS ai_blue_user_style,
    user_style_status AS ai_blue_user_style_code,
    t1.code_desc AS ai_blue_user_style_name,
    user_style_request_id AS ai_blue_user_style_request_id
FROM yshopping.ods_community_ai_blue_user_info_df t0
LEFT JOIN yshopping.dim_code_desc t1
    ON CAST(t0.user_style_status AS STRING)=t1.code
   AND t1.table_name='ods_community_ai_blue_user_info_df'
   AND t1.content_type='user_style_status'
WHERE t0.pt='${bizdate}';
