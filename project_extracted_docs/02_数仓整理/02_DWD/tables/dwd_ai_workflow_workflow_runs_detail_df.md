# dwd_ai_workflow_workflow_runs_detail_df

## 所属分层

DWD

## 业务含义

大模型底层工作流执行明细全量表，记录每次工作流运行的输入、输出、状态、耗时、token、步骤数及业务 ID。该表用于关联 AI 蓝军内容请求与对应的工作流执行结果。

## 整理说明

- 用户于 2026-07-10 确认旧表 `dwd_ai_workflow_workflow_detail_df` 不属于当前项目链路，已从结构化 DWD 目录删除。
- 用户于 2026-07-10 确认 `ods_ai_workflow_workflow_df` 不属于当前项目链路；本表实际使用的上游是 `ods_ai_workflow_workflow_runs_df`。
- 本表根据用户补充的建表和 INSERT 截图整理。
- 用户于 2026-07-10 补充确认完整表属性为 `'PARTITION_LIFECYCLE'='30d', 'SYNC_METASTORE'='on'`。
- 原图 `total_steps` 字段缺少 `COMMENT` 关键字，本文按相邻字段格式补全，以形成可执行 DDL。

## 上游来源

- `yshopping.ods_ai_workflow_workflow_runs_df`

## 下游去向

- `yshopping.dwm_com_audit_ai_blue_output_detail_df`

关联条件：蓝军内容请求 ID `ai_blue_content_request_id` 对应工作流执行 ID `workflow_runs_id`。

## SQL 文件

`project_extracted_docs/02_数仓整理/02_DWD/sql/dwd_ai_workflow_workflow_runs_detail_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 用户于 2026-07-10 补充的 dwd_ai_workflow_workflow_runs_detail_df 建表截图
-- - 用户于 2026-07-10 补充的 dwd_ai_workflow_workflow_runs_detail_df INSERT 截图
-- 用户于 2026-07-10 补充确认：PARTITION_LIFECYCLE='30d'，SYNC_METASTORE='on'。
-- 注意：原图 total_steps 字段缺少 COMMENT 关键字，本文按相邻字段格式补为 COMMENT，以形成可执行 DDL。

CREATE TABLE IF NOT EXISTS yshopping.dwd_ai_workflow_workflow_runs_detail_df(
    workflow_runs_id STRING,
    tenant_id STRING COMMENT '租户id',
    app_id STRING COMMENT 'agent 应用id',
    sequence_id STRING COMMENT '序列号',
    workflow_id STRING COMMENT '工作流id',
    workflow_runs_type_code STRING COMMENT '工作流运行类型',
    workflow_runs_triggered_from_code STRING COMMENT '触发来源',
    `version` STRING COMMENT '版本',
    graph STRING COMMENT '图',
    inputs STRING COMMENT '传参',
    workflow_runs_status_code STRING COMMENT '工作流运行状态',
    outputs STRING COMMENT '输出',
    error STRING COMMENT '报错',
    elapsed_dur DOUBLE COMMENT '耗时',
    total_tokens BIGINT COMMENT '总计tokens',
    total_steps BIGINT COMMENT '总计步数',
    create_user_role STRING COMMENT '创建者角色',
    creator_id STRING COMMENT '创建者',
    create_time STRING COMMENT '创建时间',
    finish_time STRING COMMENT '完成时间',
    exceptions_cnt BIGINT COMMENT '异常数',
    biz_id STRING COMMENT '业务id'
)
COMMENT 'dwd-大模型-工作流执行-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'table.creator'='764815144@qq.com', 'PARTITION_LIFECYCLE'='30d', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dwd_ai_workflow_workflow_runs_detail_df PARTITION(pt='${bizdate}')
SELECT
    id AS workflow_runs_id,
    tenant_id,
    app_id,
    sequence_number AS sequence_id,
    workflow_id,
    `type` AS workflow_runs_type_code,
    triggered_from AS workflow_runs_triggered_from_code,
    `version`,
    graph,
    inputs,
    `status` AS workflow_runs_status_code,
    outputs,
    error,
    elapsed_dur,
    total_tokens,
    total_steps,
    create_user_role,
    create_user AS creator_id,
    FROM_UNIXTIME(UNIX_TIMESTAMP(create_time) + 28800) AS create_time,
    FROM_UNIXTIME(UNIX_TIMESTAMP(finish_time) + 28800) AS finish_time,
    exceptions_cnt,
    GET_JSON_OBJECT(inputs, '$.id') AS biz_id
FROM yshopping.ods_ai_workflow_workflow_runs_df
WHERE pt='${bizdate}';
```
