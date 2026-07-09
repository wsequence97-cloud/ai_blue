# ods_community_ai_blue_user_info_df

## 所属分层

ODS

## 截图标题与数据量

- 截图标题：社区蓝军运营账号用户人设表
- 数据量说明：每日新增 400+ 条，总体 20w+ 数据量

## 来源截图

- `数仓/ods/ods_community_ai_blue_user_info_df(1).png`
- `数仓/ods/ods_community_ai_blue_user_info_df(2).png`
- `数仓/ods/ods_community_ai_blue_user_info_df(样例).png`

## 建表语句

见 SQL 文件：`project_extracted_docs/02_数仓整理/01_ODS/sql/ods_community_ai_blue_user_info_df.sql`

```sql
CREATE TABLE IF NOT EXISTS ods_community_ai_blue_user_info_df(
    id BIGINT,
    user_id BIGINT COMMENT '蓝军用户id',
    user_name STRING COMMENT '蓝军用户昵称',
    user_sign STRING COMMENT '蓝军用户签名',
    user_icon STRING COMMENT '蓝军用户头像',
    remark STRING COMMENT '备注',
    create_time STRING COMMENT '系统时间',
    modify_time STRING COMMENT '修改时间',
    resource_id BIGINT COMMENT '素材库素材id',
    user_style STRING COMMENT '用户人设',
    user_style_status STRING COMMENT '人设生成状态code 1生成中 2生成完成 3生成失败',
    user_style_request_id STRING COMMENT '人设生成请求id, workflow id'
)
COMMENT 'ods-电商社区系统-社区运营账号用户人设表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'table.creator'='764815144@qq.com', 'PARTITION_LIFECYCLE'='7d', 'SYNC_METASTORE'='on');
```

## 数据样例

| id | user_id | user_name | user_sign | user_icon | remark | create_time | modify_time | user_style | user_style_status | user_style_request_id |
|---:|---:|---|---|---|---|---|---|---|---:|---:|
| 1723 | 3245994100 | 巴尔的眼睛 | 图像与眼睛 | xxxxx | xxx | 2025-08-20 04:12:14 | 2025-08-20 04:12:14 | 神秘学/宗教/血腥 | 2 | 2312567 |
