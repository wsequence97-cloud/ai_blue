-- 来源截图：
-- - 数仓/dwd/dwd_ai_workflow_workflow_detail_df.png
-- - 数仓/dwd/dwd_ai_workflow_workflow_detail_df_代码(1).png
-- - 数仓/dwd/dwd_ai_workflow_workflow_detail_df_代码(2).png

CREATE TABLE IF NOT EXISTS dwd_ai_workflow_workflow_detail_df(
    workflow_id STRING,
    tenant_id STRING COMMENT '租户id',
    app_id STRING COMMENT 'agent 应用id',
    workflow_type_code STRING COMMENT '工作流类型',
    `version` STRING COMMENT '版本',
    graph STRING COMMENT '图',
    features STRING COMMENT '构造',
    creator_id STRING COMMENT '创建人',
    create_time STRING COMMENT '创建时间',
    modifier_id STRING COMMENT '变更人',
    modify_time STRING COMMENT '变更时间',
    environment_variables STRING COMMENT '环境变量',
    conversation_variables STRING COMMENT '会话变量',
    marked_name STRING COMMENT '标记名称',
    marked_comment STRING COMMENT '标记描述',
    risk_event STRING COMMENT '风险事件',
    risk_event_id STRING COMMENT '风险事件id',
    risk_event_value STRING COMMENT '风险事件内容',
    risk_label STRING COMMENT '风险标签',
    risk_label_id STRING COMMENT '风险标签id',
    risk_label_value STRING COMMENT '风险标签内容',
    max_content_length STRING COMMENT '最大文本长度',
    max_content_length_id STRING COMMENT '最大文本长度id',
    max_content_length_value STRING COMMENT '最大文本长度值'
)
COMMENT 'dwd-大模型-工作流-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'table.creator'='764815144@qq.com',
    'SYNC_METASTORE'='on',
    'PARTITION_LIFECYCLE'='30d'
);

INSERT OVERWRITE TABLE yshopping.dwd_ai_workflow_workflow_detail_df PARTITION(pt='${bizdate}')
SELECT
    id AS workflow_id,
    tenant_id,
    app_id,
    `type` AS workflow_type_code,
    `version`,
    graph,
    features,
    create_user AS creator_id,
    create_time,
    update_user AS modifier_id,
    update_time AS modify_time,
    environment_variables,
    conversation_variables,
    marked_name,
    marked_comment,
    GET_JSON_OBJECT(environment_variables, '$.risk_event') AS risk_event,
    GET_JSON_OBJECT(environment_variables, '$.risk_event.id') AS risk_event_id,
    GET_JSON_OBJECT(environment_variables, '$.risk_event.value') AS risk_event_value,
    GET_JSON_OBJECT(environment_variables, '$.risk_label') AS risk_label,
    GET_JSON_OBJECT(environment_variables, '$.risk_label.id') AS risk_label_id,
    GET_JSON_OBJECT(environment_variables, '$.risk_label.value') AS risk_label_value,
    GET_JSON_OBJECT(environment_variables, '$.max_content_length') AS max_content_length,
    GET_JSON_OBJECT(environment_variables, '$.max_content_length.id') AS max_content_length_id,
    GET_JSON_OBJECT(environment_variables, '$.max_content_length.value') AS max_content_length_value
FROM yshopping.ods_ai_workflow_workflow_df
WHERE pt='${bizdate}';
