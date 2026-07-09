-- 来源截图：
-- - 数仓/ads/ads_operation_com_ai_blue_2kafka.png
-- - 数仓/ads/ads_operation_com_ai_blue_2kafka_代码.png
-- - 数仓/ads/ads_operation_com_ai_blue_2kafka推数样式.png

CREATE TABLE `yshopping`.`ads_operation_com_ai_blue_2kafka` (
    ai_blue_json STRING
)
COMMENT 'ads-运营域-社区域-ai蓝军数据推送kafka-增量'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES (
    'table.source'='自定义',
    'PARTITION_LIFECYCLE'='730',
    'table.creator'='TODO: 截图右侧被截断，需人工确认'
);

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
