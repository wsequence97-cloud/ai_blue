# ods_community_community_audit_result_df

## 所属分层

ODS

## 截图标题与数据量

- 截图标题：审核结果表
- 来源说明：来源 mysql
- 业务说明：审核结果表非常特殊，由于审核的内容有周期（长视频等），同时发布内容失败用户后续还会走申诉审核，因此这里特地做成 df 表。
- 数据量说明：4 亿数据量，日增 30 万

## 来源截图

- `数仓/ods/ods_community_community_audit_result_df.png`
- `数仓/ods/ods_community_community_audit_result_df(样例1).png`
- `数仓/ods/ods_community_community_audit_result_df(样例2).png`
- 用户于 2026-07-10 补充确认 `tag_result` 枚举和完整 `TBLPROPERTIES`。

## 建表语句

见 SQL 文件：`project_extracted_docs/02_数仓整理/01_ODS/sql/ods_community_community_audit_result_df.sql`

```sql
CREATE TABLE `yshopping`.`ods_community_community_audit_result_df` (
    id BIGINT COMMENT '自增id',
    event_code STRING COMMENT '业务场景码',
    biz_id STRING COMMENT '业务ID',
    publish_user_id BIGINT COMMENT '发布人ID',
    publish_time STRING COMMENT '发布时间',
    publish_content STRING COMMENT '发布内容',
    tag_code BIGINT COMMENT '人审打标code',
    tag_result STRING COMMENT '处置结果：init-待审核, pass-通过, hide-隐藏, lock-封禁, remove-删除, only_fans-仅粉丝可见, anti_spam-反垃圾, show-显示, recover-恢复, unlock-解禁, ignore-忽略, reset-重...',
    tag_time STRING COMMENT '最新审核时间',
    tag_user_id BIGINT COMMENT '最新审核人ID',
    tag_user_name STRING COMMENT '最新审核人名称',
    content_type STRING COMMENT '内容类型',
    is_manual BIGINT COMMENT '机审是否转人工',
    machine_audit_time STRING COMMENT '机审时间',
    machine_tag_code BIGINT COMMENT '机审打标code',
    machine_tag_result STRING COMMENT '机审标签',
    is_del BIGINT COMMENT '是否删除：0-未删除、1-已删除',
    create_time STRING COMMENT '创建时间',
    modify_time STRING COMMENT '最新修改时间'
)
COMMENT 'ods-电商社区系统-审核结果表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'PARTITION_LIFECYCLE'='30d',
    'table.creator'='764815144@qq.com',
    'SYNC_METASTORE'='on'
);
```

## 数据样例

样例截图为横向滚动表格，以下整理截图可见字段。

| id | event_code | biz_id | publish_user_id | publish_time | publish_content | tag_result | tag_time | tag_user_id | tag_user_name | content_type | is_manual | machine_audit_time | machine_tag_result | is_del | create_time | modify_time |
|---:|---|---:|---:|---|---|---|---|---|---|---|---:|---|---|---:|---|---|
| 352637442 | y101 | 342657341 | 2145994100 | 2024-11-16 13:17:18 | 时尚简约长裤，轻松驾驭任何风格👖。优质面料，裁剪利落，无论是搭配牛仔裤还是衬衫，都不失格调，让你从人群中脱颖而出 | pass | 2024-11-16 13:17:56 | yx320 | yx320 | 图文 | 0 | 2024-11-16 13:17:20 | pass | 0 | 2024-11-16 13:17:18 | 2024-11-16 13:17:56 |

## 补充确认

- `tag_result` 截断部分和 `TBLPROPERTIES` 已由用户于 2026-07-10 补齐，不再作为待确认项。
