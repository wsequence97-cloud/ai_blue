# dwm_com_audit_ai_blue_input_detail_di

## 所属分层

DWM

## 整理说明

- 本文件由截图内容整理为可复制 SQL/Markdown，不再保留截图左侧行号。
- 多张分段截图已按同一张表/同一段 SQL 进行拼接。
- 截图右侧被截断或无法确认的位置保留 `TODO`，未强行编造。

## SQL 文件

`project_extracted_docs/02_数仓整理/03_DWM/sql/dwm_com_audit_ai_blue_input_detail_di.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 数仓/dwm/dwm_com_audit_ai_blue_input_detail_di.png
-- - 数仓/dwm/dwm_com_audit_ai_blue_input_detail_di_代码(1).png
-- - 数仓/dwm/dwm_com_audit_ai_blue_input_detail_di_代码(2).png

CREATE TABLE `yshopping`.`dwm_com_audit_ai_blue_input_detail_di` (
    trend_id STRING COMMENT '内容ID',
    content_title STRING COMMENT '内容名称',
    content STRING COMMENT '文字内容明细',
    publish_user_id STRING COMMENT '发布用户ID',
    publish_user_name STRING COMMENT '发布动态昵称',
    publish_user_fans BIGINT COMMENT '发布用户粉丝数',
    favorite_cnt BIGINT COMMENT '点赞数',
    reply_cnt BIGINT COMMENT '回复数',
    share_cnt BIGINT COMMENT '分享数',
    level1_category_name STRING COMMENT '内容一级类别name',
    level2_category_name STRING COMMENT '内容二级类别name',
    level3_category_name STRING COMMENT '内容三级类别name',
    url STRING COMMENT 'url',
    selected_type_name STRING COMMENT '精选类型name 0.非精选 1.热点内容 2.爆款内容 3.扶持作者',
    machine_tag_result_name STRING COMMENT '机审标签name',
    tag_result_name STRING COMMENT '人审处置结果name',
    tag_name_list STRING COMMENT '人审打标code',
    machine_tag_name_list STRING COMMENT '机审打标code',
    check_result_name STRING COMMENT '质检结果name',
    publish_time STRING COMMENT '发布时间'
)
COMMENT 'dwd-社区域-审核域-ai智能蓝军输入表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='730d', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dwm_com_audit_ai_blue_input_detail_di PARTITION(pt='${bizdate}')
SELECT
    t0.trend_id,
    t0.content_title,
    t0.content,
    t0.publish_user_id,
    t0.publish_user_name,
    t0.publish_user_fans,
    t0.favorite_cnt,
    t0.reply_cnt,
    t0.share_cnt,
    t1.level1_category_name,
    t1.level2_category_name,
    t1.level3_category_name,
    t0.url,
    t0.selected_type_name,
    t2.machine_tag_result_name,
    t2.tag_result_name,
    CONCAT_WS(',', t5.tag_name_list) AS tag_name_list,
    CONCAT_WS(',', t4.machine_tag_name_list) AS machine_tag_name_list,
    t3.check_result_name,
    t0.publish_time
FROM yshopping.dwd_com_trend_detail_df t0
LEFT JOIN yshopping.dim_com_trend_category_df t1
    ON t0.level3_category_code=t1.level3_category_code
   AND t1.pt='${bizdate}'
LEFT JOIN yshopping.dwd_com_audit_detail_df t2
    ON t0.trend_id=t2.biz_id
   AND t2.pt='${bizdate}'
LEFT JOIN yshopping.dwd_com_audit_quilty_check_detail_df t3
    ON t0.level3_category_code=t3.biz_id
   AND t3.pt='${bizdate}'
LEFT JOIN (
    SELECT
        biz_id,
        COLLECT_LIST(tag_name) AS machine_tag_name_list
    FROM (
        SELECT
            biz_id,
            machine_tag_code2
        FROM yshopping.dwd_com_audit_detail_df
        LATERAL VIEW EXPLODE(SPLIT(machine_tag_code, ',')) t AS machine_tag_code2
        WHERE pt='${bizdate}'
    ) t4_1
    LEFT JOIN yshopping.dim_com_audit_tag_df t4_2
        ON t4_1.machine_tag_code2=t4_2.tag_code
       AND t4_2.pt='${bizdate}'
    GROUP BY biz_id
) t4
    ON t0.trend_id=t4.biz_id
JOIN (
    -- 这里一定要用 join：需要同时参考人审数据，过滤掉机审筛掉但人审通过的数据。
    SELECT
        biz_id,
        COLLECT_LIST(tag_name) AS tag_name_list
    FROM (
        SELECT
            biz_id,
            tag_code2
        FROM yshopping.dwd_com_audit_detail_df
        LATERAL VIEW EXPLODE(SPLIT(tag_code, ',')) t AS tag_code2
        WHERE pt='${bizdate}'
    ) t5_1
    JOIN yshopping.dim_com_audit_tag_df t5_2
        ON t5_1.tag_code2=t5_2.tag_code
       AND t5_2.pt='${bizdate}'
    GROUP BY biz_id
) t5
    ON t0.trend_id=t5.biz_id
WHERE t0.pt='${bizdate}'
  AND SUBSTR(t0.publish_time,1,10)='${bizdate}';
```
