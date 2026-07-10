# dim_com_trend_category_df

## 所属分层

DIM

## 业务含义

社区动态类目维表，维护一级、二级、三级内容类目的编码和名称。当前蓝军链路通过动态明细表的 `level3_category_code` 关联该表，取得三级类目及其上级类目名称。

截图说明：约 500 条数据，按 30 天分区。

## 整理说明

- 本表根据用户于 2026-07-10 补充的 DDL、INSERT 和三级类目映射截图整理。
- 原 INSERT 截图第 9 行把 `category_desc_lv3` 的别名写成了 `level1_category_name`；根据目标 DDL 字段顺序修正为 `level3_category_name`。
- `PARTITION_LIFECYCLE` 按截图原值保留为 `30`。

## 上游来源

- `yshopping.ods_community_community_category_df`

## 下游去向

- `yshopping.dwm_com_audit_ai_blue_input_detail_di`

关联方式：

```sql
t0.level3_category_code = t1.level3_category_code
AND t1.pt='${bizdate}'
```

## SQL 文件

`project_extracted_docs/02_数仓整理/04_DIM/sql/dim_com_trend_category_df.sql`

## 可复制 SQL

```sql
-- 来源截图：
-- - 用户于 2026-07-10 补充的 dim_com_trend_category_df 建表截图
-- - 用户于 2026-07-10 补充的 dim_com_trend_category_df INSERT 截图
-- 注意：原 INSERT 截图第 9 行将 category_desc_lv3 别名写为 level1_category_name；
--       根据目标 DDL 的三级类目字段顺序，本文修正为 level3_category_name。

CREATE TABLE `yshopping`.`dim_com_trend_category_df` (
    category_code STRING COMMENT '类目编码',
    category_name STRING COMMENT '类目名称',
    level1_category_code STRING COMMENT '内容一级类别id',
    level2_category_code STRING COMMENT '内容二级类别id',
    level3_category_code STRING COMMENT '内容三级类别id',
    level1_category_name STRING COMMENT '内容一级类别name',
    level2_category_name STRING COMMENT '内容二级类别name',
    level3_category_name STRING COMMENT '内容三级类别name',
    creator_id STRING COMMENT '类目创建人',
    modifier_id STRING COMMENT '类目负责人',
    create_time STRING COMMENT '类目创建时间',
    modify_time STRING COMMENT '类目更新时间'
)
COMMENT 'dim-社区域-动态域-审核类目维表-全量表'
PARTITIONED BY (`pt` STRING COMMENT '业务日期')
STORED AS PARQUET
TBLPROPERTIES ('table.source'='自定义', 'PARTITION_LIFECYCLE'='30', 'table.creator'='764815144@qq.com', 'SYNC_METASTORE'='on');

INSERT OVERWRITE TABLE yshopping.dim_com_trend_category_df PARTITION(pt='${bizdate}')
SELECT
    category_code,
    category_name,
    category_code_lv1 AS level1_category_code,
    category_code_lv2 AS level2_category_code,
    category_code_lv3 AS level3_category_code,
    category_desc_lv1 AS level1_category_name,
    category_desc_lv2 AS level2_category_name,
    category_desc_lv3 AS level3_category_name,
    creator_id,
    modifier_id,
    create_time,
    modify_time
FROM yshopping.ods_community_community_category_df
WHERE pt='${bizdate}';
```

## 截图可见三级类目映射示例

| 一级类目 | 二级类目 | 三级类目 |
|---|---|---|
| 颜值 | 自拍 | 自拍 |
| 数码 | 数码产品 | 电脑及外设 |
| 潮物 | 潮玩 | 盲盒扭蛋 |
| 男士理容 | 男士理容 | 男士发型 |
| 数码 | 手机平板 | 手机平板 |
| 知识教育 | 泛知识科普 | 能力提升 |
| 情感 | 情感记录 | 情感日常 |
| 运动健身 | 竞技运动 | 其他运动 |
| 穿搭 | 配饰 | 帽子 |
| 情感 | 情感素材 | 情感素材 |
| 美妆个护 | 美妆其他 | 美妆其他 |
| 鞋靴 | 鞋类晒物 | 鞋类衍生品 |
| 知识教育 | 校园教育 | 中等教育 |
| 穿搭 | 穿搭其他 | 穿搭其他 |
| 出行 | 户外运动 | 滑板 |
| 数码 | 数码产品 | 摄影设备 |
| 数码 | 数码产品 | 平板电脑 |
| 数码 | 智能产品 | 智能产品 |
| 鞋靴 | 鞋类晒物 | 鞋类商品展示 |
| 其他 | 其他 | 其他 |
| 出行 | 城市出行 | 出行攻略 |
| 运动健身 | 竞技运动 | 篮球 |
| 美妆个护 | 彩妆护肤发型 | 发型 |
| 素材 | 搞笑 | 段子 |
| 生活旅行 | 旅行 | 旅行 |
| 游戏 | 游戏其他 | 游戏其他 |
| 情感 | 情感教学 | 情感教学 |
| 数码 | 数码其他 | 资讯新闻 |
| 穿搭 | 配饰 | 手表 |
| 数码 | 耳机 | 耳机 |
| 知识教育 | 校园教育 | 高等教育 |
| 家居家装 | 家居 | 家居日用 |
| 书影音 | 影视 | 影视 |
