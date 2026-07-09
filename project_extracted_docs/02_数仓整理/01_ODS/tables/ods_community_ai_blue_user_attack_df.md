# ods_community_ai_blue_user_attack_df

## 所属分层

ODS

## 截图标题与数据量

- 截图标题：社区蓝军用户攻击表
- 数据量说明：每日新增 5000+ 条，总体 300w+ 数据量

## 来源截图

- `数仓/ods/ods_community_ai_blue_user_attack_df(1).png`
- `数仓/ods/ods_community_ai_blue_user_attack_df(2).png`
- `数仓/ods/ods_community_ai_blue_user_attack_df(样例).png`

## 建表语句

见 SQL 文件：`project_extracted_docs/02_数仓整理/01_ODS/sql/ods_community_ai_blue_user_attack_df.sql`

```sql
CREATE TABLE IF NOT EXISTS ods_community_ai_blue_user_attack_df(
    id BIGINT COMMENT '自增id',
    user_id BIGINT COMMENT '蓝军攻击用户id',
    attack_task_id STRING COMMENT '攻击任务id',
    attack_task_name STRING COMMENT '攻击任务名称',
    resource_id STRING COMMENT '样本id',
    creator_id BIGINT COMMENT '创建人员',
    create_time STRING COMMENT '系统时间',
    modifier_id BIGINT COMMENT '修改人员',
    modify_time STRING COMMENT '修改时间',
    is_del BIGINT COMMENT '攻击是否删除：0-未删除、1-已删除'
)
COMMENT 'ods-电商社区系统-社区蓝军用户攻击表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'table.creator'='764815144@qq.com', 'PARTITION_LIFECYCLE'='7d', 'SYNC_METASTORE'='on');
```

## 数据样例

| id | user_id | attack_task_id | attack_task_name | resource_id | creator_id | create_time | modifier_id | modify_time | is_del |
|---:|---:|---:|---|---:|---|---|---|---|---:|
| 1325512 | 3245994100 | 144 | 宗教血腥黑样本任务 | 69204 | xxx | 2025-08-23 11:11:41 | xxx | 2025-08-20 17:12:14 | 0 |
