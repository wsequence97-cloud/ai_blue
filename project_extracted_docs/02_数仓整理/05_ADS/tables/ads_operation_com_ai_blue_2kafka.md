# ads_operation_com_ai_blue_2kafka

## 所属分层

ADS

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 用户于 2026-07-10 补充确认完整 `TBLPROPERTIES` 右侧属性。
- 用户确认原始资料本身没有提供 INSERT；本文不补造写表语句，保留独立 SELECT。

## SQL 文件

`project_extracted_docs/02_数仓整理/05_ADS/sql/ads_operation_com_ai_blue_2kafka.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/ads/ads_operation_com_ai_blue_2kafka.png
-- - 数仓/ads/ads_operation_com_ai_blue_2kafka_代码.png
-- - 数仓/ads/ads_operation_com_ai_blue_2kafka推数样式.png
-- 用户于 2026-07-10 补充确认完整 TBLPROPERTIES 右侧属性。
-- 用户确认原始资料本身没有提供 INSERT，本文件按截图保留独立 SELECT。

CREATE TABLE `yshopping`.`ads_operation_com_ai_blue_2kafka` (
    ai_blue_json STRING
)
COMMENT 'ads-运营域-社区域-ai蓝军数据推送kafka-增量'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'PARTITION_LIFECYCLE'='730',
    'table.creator'='764815144@qq.com',
    'SYNC_METASTORE'='on'
);

-- 原始资料未提供 INSERT，以下为独立 JSON 转换查询。
SELECT
    TO_JSON(
        MAP(
            'trendId', trend_id,
            'url', url,
            'data', data_json
        )
    ) AS ai_blue_json
FROM (
    SELECT
        trend_id,
        url,
        TO_JSON(
            MAP(
                'contentTitle', content_title,
                'content', content,
                'publishUserId', publish_user_id,
                'publishUserName', publish_user_name,
                'publishUserFans', publish_user_fans,
                'favoriteCnt', favorite_cnt,
                'replyCnt', reply_cnt,
                'shareCnt', share_cnt,
                'level1CategoryName', level1_category_name,
                'level2CategoryName', level2_category_name,
                'level3CategoryName', level3_category_name,
                'tagNameList', tag_name_list,
                'selectedTypeName', selected_type_name,
                'machineTagResultName', machine_tag_result_name,
                'tagResultName', tag_result_name,
                'TagNameList', tag_name_list,
                'machineTagNameList', machine_tag_name_list,
                'checkResultName', check_result_name
            )
        ) AS data_json
    FROM yshopping.dwm_com_audit_ai_blue_input_detail_di
    WHERE pt='${bizdate}'
) t;

-- 推送 JSON 样式
-- {
--   "trendId": "001",
--   "url": "xxxxx",
--   "data": {
--     "contentTitle": "xxx",
--     "content": "XXX",
--     "publishUserId": "XXX",
--     "publishUserName": "XXX",
--     "publishUserFans": "XXX",
--     "favoriteCnt": "20",
--     "replyCnt": "20",
--     "shareCnt": "30",
--     "level1CategoryName": "穿搭",
--     "level2CategoryName": "配饰",
--     "level3CategoryName": "帽子",
--     "tagNameList": "穿搭,adidas,ootd",
--     "selectedTypeName": "非精选",
--     "machineTagResultName": "通过",
--     "tagResultName": "隐藏",
--     "TagNameList": "色情低俗",
--     "machineTagNameList": "",
--     "checkResultName": "隐藏"
--   }
-- }
```
