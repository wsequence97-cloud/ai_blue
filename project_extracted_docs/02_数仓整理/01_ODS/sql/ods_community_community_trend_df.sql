-- 来源截图：
-- - 数仓/ods/ods_community_community_trend_df.png
-- - 数仓/ods/ods_community_community_trend_df(2).png
-- 用户于 2026-07-10 补充确认 TBLPROPERTIES 右侧属性。
CREATE TABLE `yshopping`.`ods_community_community_trend_df` (
    id STRING COMMENT '内容ID',
    content_type BIGINT COMMENT '内容类型：0图文 1视频 2有图点评',
    content_title STRING COMMENT '内容名称',
    content STRING COMMENT '文字内容明细',
    content_word_cnt BIGINT COMMENT '内容字数',
    publish_user_id STRING COMMENT '发布用户ID',
    publish_user_name STRING COMMENT '发布动态昵称',
    publish_user_follows BIGINT COMMENT '发布用户关注数',
    publish_user_fans BIGINT COMMENT '发布用户粉丝数',
    publish_time STRING COMMENT '发布时间',
    edit_time STRING COMMENT '用户编辑时间',
    atuserids STRING COMMENT '@用户列表',
    videourl STRING COMMENT '视频地址',
    videoduration BIGINT COMMENT '视频时长秒',
    gifurl STRING COMMENT '视频gif图',
    coverurl STRING COMMENT '封面图',
    image_cnt BIGINT COMMENT '图片数',
    is_activity BIGINT COMMENT '是否是活动',
    show_status BIGINT COMMENT '0未审核、1近自己可见、2仅粉丝可见 3 全部',
    is_del BIGINT COMMENT '是否删除 0.正常 1.已删除',
    tag_ids STRING COMMENT '关联话题id list',
    tag_names STRING COMMENT '关联话题名称 name',
    readcount BIGINT COMMENT '阅读数',
    favorite_cnt BIGINT COMMENT '点赞数',
    favorite_user_cnt BIGINT COMMENT '点赞用户数',
    replys BIGINT COMMENT '回复数',
    reply_users BIGINT COMMENT '回复用户数',
    shares BIGINT COMMENT '分享数',
    share_users BIGINT COMMENT '分享用户数',
    is_selected BIGINT COMMENT '是否进精选池',
    selected_time STRING COMMENT '进入精选时间',
    selected_access_time STRING COMMENT '精选审核通过时间',
    selected_type BIGINT COMMENT '精选类型 0.非精选 1.热点内容 2.爆款内容 3.扶持作者',
    interaction_score BIGINT COMMENT '互动分',
    productid STRING COMMENT '标注的商品ID',
    is_using_tool STRING COMMENT '是否使用创作工具-滤镜/贴纸/图片模板/视频模板/特效/配乐',
    filter STRING COMMENT '使用的滤镜json',
    sticker STRING COMMENT '使用的贴纸json',
    pict_template STRING COMMENT '使用的图片模板json',
    video_template STRING COMMENT '使用的视频模板json',
    magic STRING COMMENT '使用的特效json',
    music STRING COMMENT '使用的配乐json',
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
    create_time BIGINT COMMENT '创建时间',
    modify_time BIGINT COMMENT '修改时间'
)
COMMENT 'ods-电商社区系统-动态主表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'PARTITION_LIFECYCLE'='365d',
    'table.creator'='764815144@qq.com',
    'SYNC_METASTORE'='on'
);
