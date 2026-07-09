# 阶段 1 图片资产清单

生成时间：2026-07-09

阶段边界：
- 本文件仅完成图片递归扫描、目录统计、分层初步分类和内容类型初判。
- 未执行 OCR / 视觉转写。
- 未生成 PRD、SQL、血缘、指标口径或最终项目总结。
- “初步判断内容”仅依据原始目录结构与文件名关键词判断，后续阶段需要逐图核对。

## 1. 扫描结果概览

| 指标 | 数量 |
|---|---:|
| 图片总数 | 88 |
| 已按 PRD / ODS / DWD / DWM / DIM / ADS 初步分类 | 88 |
| 未分类图片 | 0 |

## 2. 各目录图片数量

| 目录 | 初步所属模块 | 图片数量 |
|---|---|---:|
| 大模型社区智能蓝军PRD | PRD | 10 |
| 数仓/ods | ODS | 24 |
| 数仓/dwd | DWD | 26 |
| 数仓/dwm | DWM | 10 |
| 数仓/dim | DIM | 5 |
| 数仓/ads | ADS | 13 |

## 3. 初步识别到的内容类型

| 初步内容类型 | 数量 | 判断依据 |
|---|---:|---|
| PRD 截图/页面内容 | 10 | 位于 `大模型社区智能蓝军PRD/`，文件名为页码 |
| 建表/表结构截图 | 37 | 文件名为表名或表名分片，未带“代码/样例/公式/映射”等关键词 |
| 数据样例截图 | 11 | 文件名包含“样例” |
| SQL/加工代码截图 | 20 | 文件名包含“代码” |
| 指标计算公式截图 | 5 | 文件名包含“具体计算公式” |
| SQL 转 JSON / Kafka 推数相关截图 | 2 | 文件名包含“2kafka”或“推数样式” |
| 手工维护维表截图 | 2 | 文件名包含“手工维护” |
| 字段/编码映射截图 | 1 | 文件名包含“具体映射” |

## 4. 图片明细清单

| 序号 | 图片路径 | 所属模块 | 所在目录 | 初步判断内容 | 备注 |
|---:|---|---|---|---|---|
| 1 | 大模型社区智能蓝军PRD/1.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 2 | 大模型社区智能蓝军PRD/2.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 3 | 大模型社区智能蓝军PRD/3.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 4 | 大模型社区智能蓝军PRD/4.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 5 | 大模型社区智能蓝军PRD/5.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 6 | 大模型社区智能蓝军PRD/6.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 7 | 大模型社区智能蓝军PRD/7.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 8 | 大模型社区智能蓝军PRD/8.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 9 | 大模型社区智能蓝军PRD/9.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 10 | 大模型社区智能蓝军PRD/10.png | PRD | 大模型社区智能蓝军PRD | PRD 截图/页面内容 | 具体章节待阶段 2 识别 |
| 11 | 数仓/ods/ods_community_ai_blue_content_df(1).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_ai_blue_content_df |
| 12 | 数仓/ods/ods_community_ai_blue_content_df(2).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_ai_blue_content_df |
| 13 | 数仓/ods/ods_community_ai_blue_content_df(样例1).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_ai_blue_content_df |
| 14 | 数仓/ods/ods_community_ai_blue_content_df(样例2).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_ai_blue_content_df |
| 15 | 数仓/ods/ods_community_ai_blue_resource_df(1).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_ai_blue_resource_df |
| 16 | 数仓/ods/ods_community_ai_blue_resource_df(2).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_ai_blue_resource_df |
| 17 | 数仓/ods/ods_community_ai_blue_resource_df(样例).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_ai_blue_resource_df |
| 18 | 数仓/ods/ods_community_ai_blue_user_attack_df(1).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_ai_blue_user_attack_df |
| 19 | 数仓/ods/ods_community_ai_blue_user_attack_df(2).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_ai_blue_user_attack_df |
| 20 | 数仓/ods/ods_community_ai_blue_user_attack_df(样例).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_ai_blue_user_attack_df |
| 21 | 数仓/ods/ods_community_ai_blue_user_info_df(1).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_ai_blue_user_info_df |
| 22 | 数仓/ods/ods_community_ai_blue_user_info_df(2).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_ai_blue_user_info_df |
| 23 | 数仓/ods/ods_community_ai_blue_user_info_df(样例).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_ai_blue_user_info_df |
| 24 | 数仓/ods/ods_community_community_audit_result_df.png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_community_audit_result_df |
| 25 | 数仓/ods/ods_community_community_audit_result_df(样例1).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_community_audit_result_df |
| 26 | 数仓/ods/ods_community_community_audit_result_df(样例2).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_community_audit_result_df |
| 27 | 数仓/ods/ods_community_community_quilty_check_df(1).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_community_quilty_check_df |
| 28 | 数仓/ods/ods_community_community_quilty_check_df(2).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_community_quilty_check_df |
| 29 | 数仓/ods/ods_community_community_trend_df.png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_community_trend_df |
| 30 | 数仓/ods/ods_community_community_trend_df(2).png | ODS | 数仓/ods | 建表/表结构截图 | 初步归属表：ods_community_community_trend_df |
| 31 | 数仓/ods/ods_community_community_trend_df(样例_1).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_community_trend_df |
| 32 | 数仓/ods/ods_community_community_trend_df(样例_2).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_community_trend_df |
| 33 | 数仓/ods/ods_community_community_trend_df(样例_3).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_community_trend_df |
| 34 | 数仓/ods/ods_community_community_trend_df(样例_4).png | ODS | 数仓/ods | 数据样例截图 | 初步归属表：ods_community_community_trend_df |
| 35 | 数仓/dwd/dwd_ai_workflow_workflow_detail_df.png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_ai_workflow_workflow_detail_df |
| 36 | 数仓/dwd/dwd_ai_workflow_workflow_detail_df_代码(1).png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_ai_workflow_workflow_detail_df |
| 37 | 数仓/dwd/dwd_ai_workflow_workflow_detail_df_代码(2).png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_ai_workflow_workflow_detail_df |
| 38 | 数仓/dwd/dwd_com_audit_ai_blue_content_df.png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_ai_blue_content_df |
| 39 | 数仓/dwd/dwd_com_audit_ai_blue_content_df_代码1.png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_com_audit_ai_blue_content_df |
| 40 | 数仓/dwd/dwd_com_audit_ai_blue_content_df_代码2.png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_com_audit_ai_blue_content_df |
| 41 | 数仓/dwd/dwd_com_audit_ai_blue_resource_df.png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_ai_blue_resource_df |
| 42 | 数仓/dwd/dwd_com_audit_ai_blue_resource_df_代码.png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_com_audit_ai_blue_resource_df |
| 43 | 数仓/dwd/dwd_com_audit_ai_blue_user_attack_df.png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_ai_blue_user_attack_df |
| 44 | 数仓/dwd/dwd_com_audit_ai_blue_user_attack_df_代码.png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_com_audit_ai_blue_user_attack_df |
| 45 | 数仓/dwd/dwd_com_audit_ai_blue_user_info_df(1).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_ai_blue_user_info_df |
| 46 | 数仓/dwd/dwd_com_audit_ai_blue_user_info_df(2).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_ai_blue_user_info_df |
| 47 | 数仓/dwd/dwd_com_audit_ai_blue_user_info_df_代码.png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_com_audit_ai_blue_user_info_df |
| 48 | 数仓/dwd/dwd_com_audit_detail_df(1).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_detail_df |
| 49 | 数仓/dwd/dwd_com_audit_detail_df(2).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_detail_df |
| 50 | 数仓/dwd/dwd_com_audit_detail_df(3).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_detail_df |
| 51 | 数仓/dwd/dwd_com_audit_detail_df_代码1.png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_com_audit_detail_df |
| 52 | 数仓/dwd/dwd_com_audit_detail_df_代码2.png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_com_audit_detail_df |
| 53 | 数仓/dwd/dwd_com_audit_quilty_check_detail_df(1).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_quilty_check_detail_df |
| 54 | 数仓/dwd/dwd_com_audit_quilty_check_detail_df(2).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_audit_quilty_check_detail_df |
| 55 | 数仓/dwd/dwd_com_trend_detail_df(1).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_trend_detail_df |
| 56 | 数仓/dwd/dwd_com_trend_detail_df(2).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_trend_detail_df |
| 57 | 数仓/dwd/dwd_com_trend_detail_df(3).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_trend_detail_df |
| 58 | 数仓/dwd/dwd_com_trend_detail_df(4).png | DWD | 数仓/dwd | 建表/表结构截图 | 初步归属表：dwd_com_trend_detail_df |
| 59 | 数仓/dwd/dwd_com_trend_detail_df_代码1.png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_com_trend_detail_df |
| 60 | 数仓/dwd/dwd_com_trend_detail_df_代码2.png | DWD | 数仓/dwd | SQL/加工代码截图 | 初步归属表：dwd_com_trend_detail_df |
| 61 | 数仓/dwm/dwm_com_audit_ai_blue_input_detail_di.png | DWM | 数仓/dwm | 建表/表结构截图 | 初步归属表：dwm_com_audit_ai_blue_input_detail_di |
| 62 | 数仓/dwm/dwm_com_audit_ai_blue_input_detail_di_代码(1).png | DWM | 数仓/dwm | SQL/加工代码截图 | 初步归属表：dwm_com_audit_ai_blue_input_detail_di |
| 63 | 数仓/dwm/dwm_com_audit_ai_blue_input_detail_di_代码(2).png | DWM | 数仓/dwm | SQL/加工代码截图 | 初步归属表：dwm_com_audit_ai_blue_input_detail_di |
| 64 | 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(1).png | DWM | 数仓/dwm | 建表/表结构截图 | 初步归属表：dwm_com_audit_ai_blue_output_detail_df |
| 65 | 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(2).png | DWM | 数仓/dwm | 建表/表结构截图 | 初步归属表：dwm_com_audit_ai_blue_output_detail_df |
| 66 | 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(3).png | DWM | 数仓/dwm | 建表/表结构截图 | 初步归属表：dwm_com_audit_ai_blue_output_detail_df |
| 67 | 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df(4).png | DWM | 数仓/dwm | 建表/表结构截图 | 初步归属表：dwm_com_audit_ai_blue_output_detail_df |
| 68 | 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df_代码(1).png | DWM | 数仓/dwm | SQL/加工代码截图 | 初步归属表：dwm_com_audit_ai_blue_output_detail_df |
| 69 | 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df_代码(2).png | DWM | 数仓/dwm | SQL/加工代码截图 | 初步归属表：dwm_com_audit_ai_blue_output_detail_df |
| 70 | 数仓/dwm/dwm_com_audit_ai_blue_output_detail_df_代码(3).png | DWM | 数仓/dwm | SQL/加工代码截图 | 初步归属表：dwm_com_audit_ai_blue_output_detail_df |
| 71 | 数仓/dim/dim_code_desc(手工维护1).png | DIM | 数仓/dim | 手工维护维表截图 | 初步归属表：dim_code_desc |
| 72 | 数仓/dim/dim_code_desc(手工维护2).png | DIM | 数仓/dim | 手工维护维表截图 | 初步归属表：dim_code_desc |
| 73 | 数仓/dim/dim_com_audit_df.png | DIM | 数仓/dim | 建表/表结构截图 | 初步归属表：dim_com_audit_df |
| 74 | 数仓/dim/dim_com_audit_df_具体映射.png | DIM | 数仓/dim | 字段/编码映射截图 | 初步归属表：dim_com_audit_df |
| 75 | 数仓/dim/dim_com_ecology_tag_df.png | DIM | 数仓/dim | 建表/表结构截图 | 初步归属表：dim_com_ecology_tag_df |
| 76 | 数仓/ads/ads_operation_com_ai_blue_2kafka.png | ADS | 数仓/ads | SQL 转 JSON / Kafka 推数相关截图 | 初步归属表/主题：ads_operation_com_ai_blue_2kafka |
| 77 | 数仓/ads/ads_operation_com_ai_blue_2kafka_代码.png | ADS | 数仓/ads | SQL/加工代码截图 | 初步归属表/主题：ads_operation_com_ai_blue_2kafka |
| 78 | 数仓/ads/ads_operation_com_ai_blue_2kafka推数样式.png | ADS | 数仓/ads | SQL 转 JSON / Kafka 推数相关截图 | 初步归属表/主题：ads_operation_com_ai_blue_2kafka |
| 79 | 数仓/ads/ads_operation_com_ovewview_target(1).png | ADS | 数仓/ads | 建表/表结构截图 | 初步归属表：ads_operation_com_ovewview_target |
| 80 | 数仓/ads/ads_operation_com_ovewview_target(2).png | ADS | 数仓/ads | 建表/表结构截图 | 初步归属表：ads_operation_com_ovewview_target |
| 81 | 数仓/ads/ads_operation_com_ovewview_target_代码(1).png | ADS | 数仓/ads | SQL/加工代码截图 | 初步归属表：ads_operation_com_ovewview_target |
| 82 | 数仓/ads/ads_operation_com_ovewview_target_代码(2).png | ADS | 数仓/ads | SQL/加工代码截图 | 初步归属表：ads_operation_com_ovewview_target |
| 83 | 数仓/ads/ads_operation_com_ovewview_target_代码(3).png | ADS | 数仓/ads | SQL/加工代码截图 | 初步归属表：ads_operation_com_ovewview_target |
| 84 | 数仓/ads/ads_operation_com_ovewview_target_具体计算公式(1).png | ADS | 数仓/ads | 指标计算公式截图 | 初步归属主题：ads_operation_com_ovewview_target 指标口径 |
| 85 | 数仓/ads/ads_operation_com_ovewview_target_具体计算公式(2).png | ADS | 数仓/ads | 指标计算公式截图 | 初步归属主题：ads_operation_com_ovewview_target 指标口径 |
| 86 | 数仓/ads/ads_operation_com_ovewview_target_具体计算公式(3).png | ADS | 数仓/ads | 指标计算公式截图 | 初步归属主题：ads_operation_com_ovewview_target 指标口径 |
| 87 | 数仓/ads/ads_operation_com_ovewview_target_具体计算公式(4).png | ADS | 数仓/ads | 指标计算公式截图 | 初步归属主题：ads_operation_com_ovewview_target 指标口径 |
| 88 | 数仓/ads/ads_operation_com_ovewview_target_具体计算公式(5).png | ADS | 数仓/ads | 指标计算公式截图 | 初步归属主题：ads_operation_com_ovewview_target 指标口径 |

## 5. 阶段 1 待确认点

- PRD 目录中的 10 张截图目前只能按目录归为 PRD，具体哪些是项目背景、功能模块、流程图、数据链路图，需要阶段 2 逐图识别。
- `数仓/ads/ads_operation_com_ovewview_target*` 文件名保留原始拼写 `ovewview`，后续如需改为 `overview`，应在确认表名后再统一处理。
- `SQL 转 JSON / Kafka 推数相关截图` 目前仅依据 `2kafka`、`推数样式` 文件名判断，实际是否属于 SQL 转 JSON、Kafka 推送格式或两者组合，需要阶段 2 识别截图内容确认。
- 本阶段未判断截图是否清晰、SQL 是否截断、字段是否完整，这些属于阶段 2 及之后的核对范围。
