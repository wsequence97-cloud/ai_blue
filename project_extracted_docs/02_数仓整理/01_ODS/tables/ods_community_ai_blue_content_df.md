# ods_community_ai_blue_content_df

## 所属分层

ODS

## 截图标题与数据量

- 截图标题：社区蓝军内容表
- 数据量说明：每日新增 1.8w+ 条，总体 1300w+ 数据量

## 来源截图

- `数仓/ods/ods_community_ai_blue_content_df(1).png`
- `数仓/ods/ods_community_ai_blue_content_df(2).png`
- `数仓/ods/ods_community_ai_blue_content_df(样例1).png`
- `数仓/ods/ods_community_ai_blue_content_df(样例2).png`

## 建表语句

见 SQL 文件：`project_extracted_docs/02_数仓整理/01_ODS/sql/ods_community_ai_blue_content_df.sql`

```sql
CREATE TABLE IF NOT EXISTS ods_community_ai_blue_content_df(
    id BIGINT COMMENT '自增id',
    ai_task_id BIGINT COMMENT 'ai智能内容任务ID',
    trend_id STRING COMMENT '内容唯一ID',
    content_title STRING COMMENT '内容名称',
    content_type BIGINT COMMENT '内容类型：0图文 1视频',
    content STRING COMMENT '原文字内容明细',
    new_content STRING COMMENT 'ai文字内容明细',
    image_url STRING COMMENT '原图片url',
    new_image_url STRING COMMENT 'ai文字图片url',
    video_url STRING COMMENT '原视频url',
    new_video_url STRING COMMENT 'ai视频url',
    similarity DOUBLE COMMENT 'ai相似度',
    resource_id BIGINT COMMENT '素材库素材id',
    cap_first_level_tag STRING COMMENT '内容一级类型',
    cap_second_level_tag STRING COMMENT '内容二级类型',
    user_id BIGINT COMMENT '用户ID',
    user_name STRING COMMENT '用户昵称',
    user_icon STRING COMMENT '用户头像',
    sample_attributes BIGINT COMMENT '样本属性：0-黑样本、1-白样本',
    difficulty_level BIGINT COMMENT '困难等级',
    request_id STRING COMMENT '请求id',
    create_time STRING COMMENT '创建时间',
    modify_time STRING COMMENT '修改时间'
)
COMMENT 'ods-电商社区系统-社区蓝军内容表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'table.creator'='764815144@qq.com', 'PARTITION_LIFECYCLE'='7d', 'SYNC_METASTORE'='on');
```

## 数据样例

样例截图为横向滚动表格，以下仅整理截图可见字段。

| id | ai_task_id | trend_id | content_title | content_type | content | new_content | image_url | new_image_url | similarity | resource_id | cap_first_level_tag | cap_second_level_tag | user_id | user_name | sample_attributes | difficulty_level | create_time | modify_time |
|---|---:|---:|---|---:|---|---|---|---|---:|---:|---:|---:|---:|---|---|---:|---|---|
| 69204 | 23561 | 62462353 | 索多玛的景象 | 0 | xxx | xxxxx | 2025-08-20 17:12:14 | xxxxxxxx | 80.2 | 69204 | 19 | 33 | 3245994100 | 巴尔的眼睛 | 0.8 | 2 | 2025-08-23 07:12:53 | 2025-08-23 07:12:53 |

## 待确认

- 样例截图横向滚动且有重叠，`resource_id` 附近的列对齐需要人工复核。
- `new_image_url` 的中文注释按截图整理为“ai文字图片url”，后续可结合业务口径确认是否为“ai文案图片url”。
