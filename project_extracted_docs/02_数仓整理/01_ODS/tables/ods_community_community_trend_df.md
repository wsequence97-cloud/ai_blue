# ods_community_community_trend_df

## 所属分层

ODS

## 截图标题与数据量

- 截图标题：动态表
- 数据量说明：4 亿数据量，日增 30 万

## 来源截图

- `数仓/ods/ods_community_community_trend_df.png`
- `数仓/ods/ods_community_community_trend_df(2).png`
- `数仓/ods/ods_community_community_trend_df(样例_1).png`
- `数仓/ods/ods_community_community_trend_df(样例_2).png`
- `数仓/ods/ods_community_community_trend_df(样例_3).png`
- `数仓/ods/ods_community_community_trend_df(样例_4).png`

## 建表语句

见 SQL 文件：`project_extracted_docs/02_数仓整理/01_ODS/sql/ods_community_community_trend_df.sql`

```sql
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
STORED AS PARQUET;
```

## 数据样例

样例截图为横向滚动表格，以下整理截图可见字段。

| id | content_type | content_title | content | content_word_cnt | publish_user_id | publish_user_name | publish_user_follows | publish_user_fans | publish_time | edit_time | atuserids | videourl | videoduration | gifurl | coverurl | image_cnt | show_status | tag_ids | tag_names | readcount | favorite_cnt | shares | is_selected | selected_type | interaction_score | productid | level_category | level1_category_code | level2_category_code | level3_category_code | audit_time | first_audit_tag_time | final_audit_tag_time | audit_tag_id | audit_tag_name |
|---:|---:|---|---|---:|---:|---|---:|---:|---|---|---|---|---:|---|---|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---:|---|
| 342657341 | 0 | 时尚简约长裤，轻松驾驭任何风格👖 | 时尚简约长裤，轻松驾驭任何风格👖。优质面料，裁剪利落，无论是搭配牛仔裤还是衬衫，都不失格调，让你从人群中脱颖而出 | 56 | 2145994100 | 夏威夷番茄 | 126 | 56 | 2024-11-16 13:17:18 | 2024-11-16 13:17:18 | [134577,7422235] | xxxxx | 0 | xxx | xxxx | 4 | 3 | 2134556,1232145 | 简约长裤,牛仔裤 | 1031 | 12 | 5 | 0 | 0 | 0 | 4657681 | 946 | 16 | 212 | 946 | 2024-11-16 13:17:42 | 2024-11-16 13:17:56 | 2024-11-16 13:17:56 | 1 | 通过 |
| 342654745 | 0 | 44.5码 nike lebron 20 ep 詹姆斯20 时尚舒适 | 44.5码 nike lebron 20 ep 詹姆斯20 时尚舒适，非常好看，穿起来舒服，质量也非常好。 | 33 | 2154351231 | 我是危危呀 | 24 | 12 | 2024-11-16 17:20:11 | 2024-11-16 17:28:43 | [] | xxxxx | 0 | xxx | xxxxx | 9 | 3 | 54688,11871 | nike lebron 20,时尚 | 591 | 20 | 6 | 1 | 2 | 17 | 2144546 | 487 | 28 | 132 | 487 | 2024-11-16 17:20:39 | 2024-11-16 17:21:32 | 2024-11-16 17:29:17 | 1 | 通过 |

## 待确认

- 建表截图右侧被截断，`TBLPROPERTIES` 末尾需人工确认。
- 样例截图为横向滚动截图，部分字段如 `replys`、`reply_users` 未在可见样例中完整出现，未强行补齐。
