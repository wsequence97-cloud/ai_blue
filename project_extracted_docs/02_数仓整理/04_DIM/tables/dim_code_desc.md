# dim_code_desc

## 所属分层

DIM

## 来源截图

- `数仓/dim/dim_code_desc(手工维护1).png`
- `数仓/dim/dim_code_desc(手工维护2).png`

## 说明

该截图为手工维护的 code 到中文含义映射，用于 DWD 层把枚举值转换为 name。

## SQL 文件

可执行建表与插入脚本：`project_extracted_docs/02_数仓整理/04_DIM/sql/dim_code_desc.sql`

脚本按截图使用 `fields_name` 作为映射字段名。

当前资料没有提供 `handle_result` 的具体 code/code_desc 映射，因此脚本未自行补充该类数据。

## 截图可见映射

| table_name | fields_name | code | code_desc |
|---|---|---|---|
| ods_community_community_audit_result_df | machine_tag_result | remove | 删除 |
| ods_community_community_audit_result_df | machine_tag_result | lock | 封禁 |
| ods_community_community_audit_result_df | machine_tag_result | hide | 隐藏 |
| ods_community_community_audit_result_df | machine_tag_result | pass | 通过 |
| ods_community_community_audit_result_df | machine_tag_result | init | 待审核 |
| ods_community_community_audit_result_df | content_type | 2 | 有图点评 |
| ods_community_community_audit_result_df | content_type | 1 | 视频 |
| ods_community_community_audit_result_df | content_type | 0 | 图文 |
| ods_community_community_audit_result_df | tag_result | only | 仅粉丝可见 |
| ods_community_community_audit_result_df | tag_result | remove | 删除 |
| ods_community_community_audit_result_df | tag_result | lock | 封禁 |
| ods_community_community_audit_result_df | tag_result | hide | 隐藏 |
| ods_community_community_audit_result_df | tag_result | pass | 通过 |
| ods_community_community_audit_result_df | tag_result | init | 待审核 |
| ods_community_community_audit_result_df | event_code | y104 | 评论 |
| ods_community_community_audit_result_df | event_code | y103 | 私信 |
| ods_community_community_audit_result_df | event_code | y102 | 直播 |
| ods_community_community_audit_result_df | event_code | y101 | 动态 |
| ods_community_community_trend_df | selected_type | 3 | 扶持作者 |
| ods_community_community_trend_df | selected_type | 2 | 爆款内容 |
| ods_community_community_trend_df | selected_type | 1 | 热点内容 |
| ods_community_community_trend_df | selected_type | 0 | 非精选 |
| ods_community_community_trend_df | show_status | 3 | 全部 |
| ods_community_community_trend_df | show_status | 2 | 仅粉丝可见 |
| ods_community_community_trend_df | show_status | 1 | 近自己可见 |
| ods_community_community_trend_df | show_status | 0 | 未审核 |
| ods_community_community_trend_df | content_type | 2 | 有图点评 |
| ods_community_community_trend_df | content_type | 1 | 视频 |
| ods_community_community_trend_df | content_type | 0 | 图文 |
| ods_community_ai_blue_content_df | sample_attributes | 0 | 黑样本 |
| ods_community_ai_blue_content_df | sample_attributes | 1 | 白样本 |
| ods_community_ai_blue_user_info_df | user_style_status | 1 | 生产中 |
| ods_community_ai_blue_user_info_df | user_style_status | 2 | 生产完成 |
| ods_community_ai_blue_user_info_df | user_style_status | 3 | 生产失败 |
