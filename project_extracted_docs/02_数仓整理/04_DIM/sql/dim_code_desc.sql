-- 维度表：枚举编码与中文名称映射
-- 来源：数仓/dim/dim_code_desc(手工维护1).png、数仓/dim/dim_code_desc(手工维护2).png
-- 说明：按截图结构使用 fields_name 作为映射字段名。

CREATE TABLE IF NOT EXISTS yshopping.dim_code_desc (
    table_name STRING COMMENT '来源表名',
    fields_name STRING COMMENT '映射字段名',
    code STRING COMMENT '枚举编码',
    code_desc STRING COMMENT '枚举中文名称'
)
COMMENT 'DIM-通用编码与中文描述映射表-手工维护'
STORED AS PARQUET;

INSERT OVERWRITE TABLE yshopping.dim_code_desc
VALUES
    ('ods_community_community_audit_result_df', 'machine_tag_result', 'remove', '删除'),
    ('ods_community_community_audit_result_df', 'machine_tag_result', 'lock', '封禁'),
    ('ods_community_community_audit_result_df', 'machine_tag_result', 'hide', '隐藏'),
    ('ods_community_community_audit_result_df', 'machine_tag_result', 'pass', '通过'),
    ('ods_community_community_audit_result_df', 'machine_tag_result', 'init', '待审核'),

    ('ods_community_community_audit_result_df', 'content_type', '2', '有图点评'),
    ('ods_community_community_audit_result_df', 'content_type', '1', '视频'),
    ('ods_community_community_audit_result_df', 'content_type', '0', '图文'),

    ('ods_community_community_audit_result_df', 'tag_result', 'only', '仅粉丝可见'),
    ('ods_community_community_audit_result_df', 'tag_result', 'remove', '删除'),
    ('ods_community_community_audit_result_df', 'tag_result', 'lock', '封禁'),
    ('ods_community_community_audit_result_df', 'tag_result', 'hide', '隐藏'),
    ('ods_community_community_audit_result_df', 'tag_result', 'pass', '通过'),
    ('ods_community_community_audit_result_df', 'tag_result', 'init', '待审核'),

    ('ods_community_community_audit_result_df', 'event_code', 'y104', '评论'),
    ('ods_community_community_audit_result_df', 'event_code', 'y103', '私信'),
    ('ods_community_community_audit_result_df', 'event_code', 'y102', '直播'),
    ('ods_community_community_audit_result_df', 'event_code', 'y101', '动态'),

    ('ods_community_community_trend_df', 'selected_type', '3', '扶持作者'),
    ('ods_community_community_trend_df', 'selected_type', '2', '爆款内容'),
    ('ods_community_community_trend_df', 'selected_type', '1', '热点内容'),
    ('ods_community_community_trend_df', 'selected_type', '0', '非精选'),

    ('ods_community_community_trend_df', 'show_status', '3', '全部'),
    ('ods_community_community_trend_df', 'show_status', '2', '仅粉丝可见'),
    ('ods_community_community_trend_df', 'show_status', '1', '近自己可见'),
    ('ods_community_community_trend_df', 'show_status', '0', '未审核'),

    ('ods_community_community_trend_df', 'content_type', '2', '有图点评'),
    ('ods_community_community_trend_df', 'content_type', '1', '视频'),
    ('ods_community_community_trend_df', 'content_type', '0', '图文'),

    ('ods_community_ai_blue_content_df', 'sample_attributes', '0', '黑样本'),
    ('ods_community_ai_blue_content_df', 'sample_attributes', '1', '白样本'),

    ('ods_community_ai_blue_user_info_df', 'user_style_status', '1', '生产中'),
    ('ods_community_ai_blue_user_info_df', 'user_style_status', '2', '生产完成'),
    ('ods_community_ai_blue_user_info_df', 'user_style_status', '3', '生产失败');

-- 待确认：dwd_com_audit_quality_check_detail_df.sql 使用 fields_name='handle_result'，
-- 但当前截图清单没有提供 handle_result 的 code/code_desc 映射，暂不凭空补充。
