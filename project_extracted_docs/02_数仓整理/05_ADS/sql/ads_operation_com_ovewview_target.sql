-- 来源截图：
-- - 数仓/ads/ads_operation_com_ovewview_target(1).png
-- - 数仓/ads/ads_operation_com_ovewview_target(2).png
-- - 数仓/ads/ads_operation_com_ovewview_target_代码(1).png
-- - 数仓/ads/ads_operation_com_ovewview_target_代码(2).png
-- - 数仓/ads/ads_operation_com_ovewview_target_代码(3).png
-- - 数仓/ads/ads_operation_com_ovewview_target_具体计算公式(1-5).png
-- - 用户于 2026-07-10 补充的横向裁切代码截图（SELECT 第 2-30 行）
-- 注意：overview 在截图文件名和表名中写作 ovewview，本文保持截图原始拼写。
-- 用户确认：DDL 原第 5、6 行的 ai_blue_attack_cnt_1d 为重复字段，本文只保留一个。
-- 用户确认：原截图没有 INSERT OVERWRITE TABLE ... PARTITION(...)，以下按原图保留为独立 SELECT。
-- 注意：源 SQL 中相似度阈值与部分公式图的中文说明不完全一致，本文按代码截图原样整理。

CREATE TABLE `yshopping`.`ads_operation_com_ovewview_target` (
    date_id STRING COMMENT '业务日期',
    ai_blue_content_type_name STRING COMMENT '内容类型name：0图文 1视频',
    ai_blue_resource_cnt_1d BIGINT COMMENT '最近1天素材数',
    ai_blue_attack_cnt_1d BIGINT COMMENT '最近1天攻击次数',
    ai_blue_user_cnt_1d BIGINT COMMENT '最近1天生成蓝军用户数',
    ai_blue_used_cnt_1d BIGINT COMMENT '最近1天样本被使用过的次数',
    ai_blue_similarity_person_audit_fail_cnt_1d BIGINT COMMENT '最近1天样本相似度大于0.7近7日人审漏过数',
    ai_blue_similarity_cnt_1d BIGINT COMMENT '最近1天样本相似度大于0.7近7日人审量',
    ai_blue_similarity_person_audit_fail_difficulty_level_1d DOUBLE COMMENT '最近1天样本相似度小于0.7人审漏过难度',
    ai_blue_similarity_difficulty_level_1d DOUBLE COMMENT '最近1天样本相似度小于0.7人审通过难度',
    ai_blue_black_sample_second_audit_success_cnt_1d BIGINT COMMENT '最近1天黑样本二次投放拦截量',
    ai_blue_black_sample_second_cnt_1d BIGINT COMMENT '黑样本二次投放量',
    ai_blue_white_sample_second_audit_success_cnt_1d BIGINT COMMENT '最近1天黑样本二次投放拦截量',
    ai_blue_white_sample_second_cnt_1d BIGINT COMMENT '黑样本二次投放量',
    ai_blue_black_sample_machine_audit_fail_cnt_1d BIGINT COMMENT '机审黑样本漏过数',
    ai_blue_black_sample_machine_audit_success_cnt_1d BIGINT COMMENT '机审黑样本拦截数',
    ai_blue_black_sample_cnt_1d BIGINT COMMENT '黑样本数',
    ai_blue_white_sample_machine_audit_fail_cnt_1d BIGINT COMMENT '机审白样本误伤数',
    ai_blue_white_sample_machine_audit_success_cnt_1d BIGINT COMMENT '机审白样本放过数',
    ai_blue_white_sample_cnt_1d BIGINT COMMENT '白样本数',
    ai_blue_black_sample_person_audit_fail_cnt_1d BIGINT COMMENT '人审黑样本漏过数',
    ai_blue_black_sample_person_audit_success_cnt_1d BIGINT COMMENT '人审黑样本拦截数',
    ai_blue_white_sample_person_audit_fail_cnt_1d BIGINT COMMENT '人审白样本误伤数',
    ai_blue_white_sample_person_audit_success_cnt_1d BIGINT COMMENT '人审白样本放过数',
    ai_blue_black_sample_machine_success_person_audit_fail_cnt_1d BIGINT COMMENT '白样本机审通过人审不通过数'
)
COMMENT 'ads-运营域-社区域-ai社区蓝军大盘最近1天指标表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='365', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

-- 原截图未提供 INSERT OVERWRITE，本段为独立指标查询。
SELECT
    SUBSTR(ai_blue_resource_create_time, 1, 10) AS date_id,
    ai_blue_content_type_name,
    COUNT(resource_id) AS ai_blue_resource_cnt_1d,
    COUNT(attack_task_id) AS ai_blue_attack_cnt_1d,
    COUNT(user_style_request_id) AS ai_blue_user_cnt_1d,
    SUM(is_used) AS ai_blue_used_cnt_1d,
    SUM(IF(ai_blue_similarity >= 0.7 AND person_audit_result IN ('init','pass'), attack_task_cnt_7d, 0)) AS ai_blue_similarity_person_audit_fail_cnt_1d,
    SUM(IF(ai_blue_similarity >= 0.7, attack_task_cnt_7d, 0)) AS ai_blue_similarity_cnt_1d,
    SUM(IF(ai_blue_similarity < 0.7 AND person_audit_result IN ('init','pass'), ai_blue_difficulty_level, 0)) AS ai_blue_similarity_person_audit_fail_difficulty_level_1d,
    SUM(IF(ai_blue_similarity > 0.7, ai_blue_difficulty_level, 0)) AS ai_blue_similarity_difficulty_level_1d,
    COUNT(IF(
        ai_blue_sample_code=0
        AND (machine_tag_result_code NOT IN ('init','pass') OR tag_result_code NOT IN ('init','pass'))
        AND is_used=1,
        attack_task_id,
        NULL
    )) AS ai_blue_black_sample_second_audit_success_cnt_1d,
    COUNT(IF(ai_blue_sample_code=0 AND is_used=1, attack_task_id, NULL)) AS ai_blue_black_sample_second_cnt_1d,
    COUNT(IF(
        ai_blue_sample_code=1
        AND (machine_tag_result_code NOT IN ('init','pass') OR tag_result_code IN ('init','pass'))
        AND is_used=1,
        attack_task_id,
        NULL
    )) AS ai_blue_white_sample_second_audit_success_cnt_1d,
    COUNT(IF(ai_blue_sample_code=1 AND is_used=1, attack_task_id, NULL)) AS ai_blue_white_sample_second_cnt_1d,
    COUNT(IF(ai_blue_sample_code=0 AND machine_tag_result_code IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_black_sample_machine_audit_fail_cnt_1d,
    COUNT(IF(ai_blue_sample_code=0 AND machine_tag_result_code NOT IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_black_sample_machine_audit_success_cnt_1d,
    COUNT(IF(ai_blue_sample_code=0, attack_task_id, NULL)) AS ai_blue_black_sample_cnt_1d,
    COUNT(IF(ai_blue_sample_code=1 AND machine_tag_result_code NOT IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_white_sample_machine_audit_fail_cnt_1d,
    COUNT(IF(ai_blue_sample_code=1 AND machine_tag_result_code IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_white_sample_machine_audit_success_cnt_1d,
    COUNT(IF(ai_blue_sample_code=1, attack_task_id, NULL)) AS ai_blue_white_sample_cnt_1d,
    COUNT(IF(ai_blue_sample_code=0 AND tag_result_code IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_black_sample_person_audit_fail_cnt_1d,
    COUNT(IF(ai_blue_sample_code=0 AND tag_result_code NOT IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_black_sample_person_audit_success_cnt_1d,
    COUNT(IF(ai_blue_sample_code=1 AND tag_result_code NOT IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_white_sample_person_audit_fail_cnt_1d,
    COUNT(IF(ai_blue_sample_code=1 AND tag_result_code IN ('init','pass'), attack_task_id, NULL)) AS ai_blue_white_sample_person_audit_success_cnt_1d,
    COUNT(IF(
        ai_blue_sample_code=1
        AND tag_result_code NOT IN ('init','pass')
        AND machine_tag_result_code IN ('init','pass'),
        attack_task_id,
        NULL
    )) AS ai_blue_black_sample_machine_success_person_audit_fail_cnt_1d
FROM yshopping.dwm_com_audit_ai_blue_output_detail_df t0
LEFT JOIN (
    SELECT
        COUNT(attack_task_id) AS attack_task_cnt_7d,
        resource_id
    FROM yshopping.dwm_com_audit_ai_blue_output_detail_df
    WHERE pt='${bizdate}'
      AND DATEDIFF('${bizdate}', SUBSTR(attack_task_create_time,1,10)) <= 7
    GROUP BY resource_id
) t1
    ON t0.resource_id=t1.resource_id
WHERE t0.pt='${bizdate}'
GROUP BY ai_blue_content_type_name, SUBSTR(ai_blue_resource_create_time,1,10);
