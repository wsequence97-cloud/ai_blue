# ods_ai_workflow_workflow_runs_df

## 所属分层

ODS

## 业务含义

大模型底层工作流运行明细全量表，记录 Dify/Agent 每次工作流执行的运行 ID、应用、工作流、输入输出、运行状态、耗时、Token、步骤数和异常数。

截图说明日增约 10 万条数据。

## 来源截图

- `数仓/ods/ods_ai_workflow_workflow_runs_df.png`
- `数仓/ods/ods_ai_workflow_workflow_runs_df(样例_1).png`
- `数仓/ods/ods_ai_workflow_workflow_runs_df(样例_2).png`

## 建表语句

见 SQL 文件：`project_extracted_docs/02_数仓整理/01_ODS/sql/ods_ai_workflow_workflow_runs_df.sql`

```sql
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
```

## 样例整理

样例截图为横向滚动表格，以下保留截图中可确认的代表性字段和 JSON 内容。

| 字段 | 样例值 |
| --- | --- |
| `id` | `a22b518d-f3ed-4024-a7c7-c4629c0faa92` |
| `tenant_id` | `a2205f3d-688-478f-ab48-5987da38bf7c` |
| `app_id` | `102` |
| `sequence_number` | `135316` |
| `workflow_id` | `3ee3aad1-2899-491b-9ca-4d715248624a` |
| `type` | `workflow` |
| `triggered_from` | `app-run` |
| `version` | `2025-06-14 13:45:29` |
| `elapsed_dur` | `0.7344` |
| `total_tokens` | `25087` |
| `total_steps` | `7` |
| `create_user_role` | `end_user` |
| `create_user` | `yx129` |
| `exceptions_cnt` | `0` |

### inputs 示例

```json
{
  "image_urls": ["http://.jpg"],
  "content": "谁能帮忙在y shopping 支付一下订单",
  "scene": "y/_07",
  "model_code": "ocr_cv",
  "sys.files": [],
  "sys.user_id": "y_risk_intelligence",
  "sys.app_id": "102",
  "sys.workflow_id": "3ee3aad1-2899-491b-9ca-4d715248624a",
  "sys.workflow_runs_id": "63302761-63ad-4823-8ca1-52d26aefa45",
  "id": "124d41sx35122xa"
}
```

### outputs 示例

```json
{
  "result": [
    {
      "url": "http://xxxxx.jpg",
      "content": "用户表达在电商平台消费情况，无任何风险提示"
    },
    {
      "url": "http://xxxxx.jpg",
      "content": "无具体风险要素，仅为消费行为表述"
    }
  ]
}
```

## 下游关系

该 ODS 表被 `dwd_ai_workflow_workflow_runs_detail_df` 使用：

```text
ods_ai_workflow_workflow_runs_df
    -> dwd_ai_workflow_workflow_runs_detail_df
    -> dwm_com_audit_ai_blue_output_detail_df
```

DWD 将 `id` 标准化为 `workflow_runs_id`，并从输入 JSON 的 `$.id` 提取辅助业务 ID；DWM 再通过蓝军内容的 `ai_blue_content_request_id = workflow_runs_id` 关联工作流运行结果。
