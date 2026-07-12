-- 来源截图：
-- - 数仓/ods/ods_ai_workflow_workflow_runs_df.png
-- - 数仓/ods/ods_ai_workflow_workflow_runs_df(样例_1).png
-- - 数仓/ods/ods_ai_workflow_workflow_runs_df(样例_2).png

CREATE TABLE IF NOT EXISTS yshopping.ods_ai_workflow_workflow_runs_df(
    id STRING,
    tenant_id STRING COMMENT '租户id',
    app_id STRING COMMENT 'agent 应用id',
    sequence_number STRING COMMENT '序列号',
    workflow_id STRING COMMENT '工作流id',
    `type` STRING COMMENT '工作流类型',
    triggered_from STRING COMMENT '触发来源',
    `version` STRING COMMENT '版本',
    graph STRING COMMENT '图',
    inputs STRING COMMENT '传参',
    `status` STRING COMMENT '工作流运行状态',
    outputs STRING COMMENT '输出',
    error STRING COMMENT '报错',
    elapsed_dur DOUBLE COMMENT '耗时',
    total_tokens BIGINT COMMENT '总计tokens',
    total_steps BIGINT COMMENT '总计步数',
    create_user_role STRING COMMENT '创建者角色',
    create_user STRING COMMENT '创建者',
    create_time STRING COMMENT '创建时间',
    finish_time STRING COMMENT '完成时间',
    exceptions_cnt BIGINT COMMENT '异常数'
)
COMMENT 'ods-大模型-工作流执行-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'table.creator'='764815144@qq.com',
    'SYNC_METASTORE'='on',
    'PARTITION_LIFECYCLE'='7d'
);
