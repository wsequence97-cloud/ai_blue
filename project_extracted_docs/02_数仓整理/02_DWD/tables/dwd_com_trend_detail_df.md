# dwd_com_trend_detail_df

## 所属分层

DWD

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 截图右侧被截断或无法确认的位置保留 `TODO`，未强行编造。
- 用户于 2026-07-10 确认删除原截图中的 `t0.machine_tag_code`：`t0` 是动态 ODS，该字段属于审核结果链路，后续由 `dwd_com_audit_detail_df` 提供。

## SQL 文件

`project_extracted_docs/02_数仓整理/02_DWD/sql/dwd_com_trend_detail_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/dwd/dwd_com_trend_detail_df(1).png
-- - 数仓/dwd/dwd_com_trend_detail_df(2).png
-- - 数仓/dwd/dwd_com_trend_detail_df(3).png
-- - 数仓/dwd/dwd_com_trend_detail_df(4).png
-- - 数仓/dwd/dwd_com_trend_detail_df_代码1.png
-- - 数仓/dwd/dwd_com_trend_detail_df_代码2.png
-- 用户于 2026-07-10 确认删除原截图中的 t0.machine_tag_code：
-- t0 来源为动态 ODS，该字段属于审核结果链路，后续由 dwd_com_audit_detail_df 提供。

CREATE TABLE `yshopping`.`dwd_com_trend_detail_df` (
    trend_id STRING COMMENT '内容ID',
    content_type_code BIGINT COMMENT '内容类型code：0图文 1视频 2有图点评',
    content_type_name STRING COMMENT '内容类型name',
    content_title STRING COMMENT '内容名称',
    content STRING COMMENT '文字内容明细',
    content_word_cnt BIGINT COMMENT '内容字数',
    publish_user_id STRING COMMENT '发布用户ID',
    publish_user_name STRING COMMENT '发布动态昵称',
    publish_user_follows BIGINT COMMENT '发布用户关注数',
    publish_user_fans BIGINT COMMENT '发布用户粉丝数',
    publish_time STRING COMMENT '发布时间',
    edit_time STRING COMMENT '用户编辑时间',
    at_user_id_list STRING COMMENT '@用户列表',
    video_url STRING COMMENT '视频地址',
    video_dur_s BIGINT COMMENT '视频时长秒',
    gif_url STRING COMMENT '视频gif图',
    cover_url STRING COMMENT '封面图',
    image_cnt BIGINT COMMENT '图片数',
    is_activity BIGINT COMMENT '是否是活动',
    show_status_code BIGINT COMMENT '0未审核、1近自己可见、2仅粉丝可见 3 全部',
    show_status_name STRING COMMENT '0未审核、1近自己可见、2仅粉丝可见 3 全部',
    tag_id_list STRING COMMENT '关联话题id list',
    tag_name_list STRING COMMENT '关联话题名称 name',
    read_cnt BIGINT COMMENT '阅读数',
    favorite_cnt BIGINT COMMENT '点赞数',
    favorite_user_cnt BIGINT COMMENT '点赞用户数',
    reply_cnt BIGINT COMMENT '回复数',
    reply_user_cnt BIGINT COMMENT '回复用户数',
    share_cnt BIGINT COMMENT '分享数',
    share_user_cnt BIGINT COMMENT '分享用户数',
    is_selected BIGINT COMMENT '是否进精选池',
    selected_time STRING COMMENT '进入精选时间',
    selected_access_time STRING COMMENT '精选审核通过时间',
    selected_type_code BIGINT COMMENT '精选类型code 0.非精选 1.热点内容 2.爆款内容 3.扶持作者',
    selected_type_name STRING COMMENT '精选类型name 0.非精选 1.热点内容 2.爆款内容 3.扶持作者',
    interaction_score BIGINT COMMENT '互动分',
    spu_id_list STRING COMMENT '标注的商品ID',
    is_using_tool STRING COMMENT '是否使用创作工具-滤镜/贴纸/图片模板/视频模板/特效/配乐',
    filter_json STRING COMMENT '使用的滤镜json',
    sticker_json STRING COMMENT '使用的贴纸json',
    pict_template_json STRING COMMENT '使用的图片模板json',
    video_template_json STRING COMMENT '使用的视频模板json',
    magic_json STRING COMMENT '使用的特效json',
    music_json STRING COMMENT '使用的配乐json',
    level_category STRING COMMENT '分类打标id',
    level1_category_code STRING COMMENT '内容一级类别id',
    level2_category_code STRING COMMENT '内容二级类别id',
    level3_category_code STRING COMMENT '内容三级类别id',
    audit_time STRING COMMENT '进审时间',
    first_audit_tag_time STRING COMMENT '首次打标时间',
    final_audit_tag_time STRING COMMENT '最后一次打标时间',
    audit_tag_id STRING COMMENT '审核打标id',
    audit_tag_name STRING COMMENT '审核打标name',
    url STRING COMMENT 'url',
    create_time STRING COMMENT '创建时间',
    modify_time STRING COMMENT '修改时间'
)
COMMENT 'dwd-社区域-动态域-动态明细-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='365d', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dwd_com_trend_detail_df PARTITION(pt='${bizdate}')
SELECT
    CAST(t0.id AS STRING) AS trend_id,
    t0.content_type AS content_type_code,
    t1.code_desc AS content_type_name,
    t0.content_title,
    t0.content,
    t0.content_word_cnt,
    t0.publish_user_id,
    t0.publish_user_name,
    t0.publish_user_follows,
    t0.publish_user_fans,
    t0.publish_time,
    t0.edit_time,
    t0.atuserids AS at_user_id_list,
    t0.videourl AS video_url,
    t0.videoduration AS video_dur_s,
    t0.gifurl AS gif_url,
    t0.coverurl AS cover_url,
    t0.image_cnt,
    t0.is_activity,
    t0.show_status AS show_status_code,
    t2.code_desc AS show_status_name,
    t0.tag_ids AS tag_id_list,
    t0.tag_names AS tag_name_list,
    t0.readcount AS read_cnt,
    t0.favorite_cnt,
    t0.favorite_user_cnt,
    t0.replys AS reply_cnt,
    t0.reply_users AS reply_user_cnt,
    t0.shares AS share_cnt,
    t0.share_users AS share_user_cnt,
    t0.is_selected,
    t0.selected_time,
    t0.selected_access_time,
    t0.selected_type AS selected_type_code,
    t3.code_desc AS selected_type_name,
    t0.interaction_score,
    t0.productid AS spu_id_list,
    t0.is_using_tool,
    t0.filter AS filter_json,
    t0.sticker AS sticker_json,
    t0.pict_template AS pict_template_json,
    t0.video_template AS video_template_json,
    t0.magic AS magic_json,
    t0.music AS music_json,
    t0.level_category,
    t0.level1_category_code,
    t0.level2_category_code,
    t0.level3_category_code,
    t0.audit_time,
    t0.first_audit_tag_time,
    t0.final_audit_tag_time,
    t0.audit_tag_id,
    t0.audit_tag_name,
    t0.url,
    FROM_UNIXTIME(CAST(t0.create_time / 1000 AS BIGINT)) AS create_time,
    FROM_UNIXTIME(CAST(t0.modify_time / 1000 AS BIGINT)) AS modify_time
FROM yshopping.ods_community_community_trend_df t0
LEFT JOIN yshopping.dim_code_desc t1
    ON CAST(t0.content_type AS STRING)=t1.code
   AND t1.table_name='ods_community_community_trend_df'
   AND t1.content_type='content_type'
LEFT JOIN yshopping.dim_code_desc t2
    ON CAST(t0.show_status AS STRING)=t2.code
   AND t2.table_name='ods_community_community_trend_df'
   AND t2.fields_name='show_status'
LEFT JOIN yshopping.dim_code_desc t3
    ON CAST(t0.selected_type AS STRING)=t3.code
   AND t3.table_name='ods_community_community_trend_df'
   AND t3.fields_name='selected_type'
WHERE t0.pt='${bizdate}'
  AND t0.is_del=0;
```
