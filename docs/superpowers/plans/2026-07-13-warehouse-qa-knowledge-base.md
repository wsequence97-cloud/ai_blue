# 数仓问答知识库 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. 当前任务未授权子代理，采用当前会话内联执行。

**Goal:** 创建按数仓实践路线分类的一题一文件 Markdown 知识库，并归档首题“如何保证离线数仓链路的数据质量”。

**Architecture:** 在 `project_extracted_docs/04_数仓问答知识库/` 建立 11 个数仓建设主题、技术组件区和 AI 蓝军项目区。每个问题只有一个正文文件，通过 YAML 元数据和三个索引提供分类、技术组件及面试场景等交叉入口。

**Tech Stack:** Markdown、YAML Front Matter、PowerShell、ripgrep、Git。

## Global Constraints

- 每个问题独立保存为一个 Markdown 文件，并且只有一个主分类和一份正文。
- 前 11 个主题必须与 `数仓建设实践路线.xmind` 的主体结构对应。
- 单题文件使用 `NNN_问题核心关键词.md`，编号在所属目录内从 `001` 递增。
- 官方依据优先使用 Apache、产品官方文档或正式标准，并说明链接支撑的结论。
- 必须区分 AI 蓝军项目已实现内容、当前材料无法证明的内容和生产环境建议。
- 不修改现有 PRD、数仓 SQL 和项目复盘正文。
- 不覆盖或提交用户当前未提交的 `codex_project_screenshot_extraction_prompt.md` 和 `数仓建设实践路线.xmind`。

---

### Task 1: 创建知识库目录与总入口

**Files:**
- Create: `project_extracted_docs/04_数仓问答知识库/README.md`
- Create: `project_extracted_docs/04_数仓问答知识库/00_索引/全部问题索引.md`
- Create: `project_extracted_docs/04_数仓问答知识库/00_索引/按技术组件索引.md`
- Create: `project_extracted_docs/04_数仓问答知识库/00_索引/按面试场景索引.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-13-warehouse-qa-knowledge-base-design.md` 的目录、分类、命名和索引规则。
- Produces: 知识库入口及三个可供首题注册的索引文件。

- [ ] **Step 1: 验证知识库尚未存在**

Run:

```powershell
Test-Path 'project_extracted_docs/04_数仓问答知识库'
```

Expected: `False`。如果已经存在，先只读检查现有文件并在不覆盖内容的前提下补齐缺失结构。

- [ ] **Step 2: 创建 README 和索引文件**

使用 `apply_patch` 创建四个 Markdown 文件。`README.md` 必须包含：知识库定位、目录导航、分类规则、一题一文件规则、统一模板、推荐复盘方式和维护流程。

三个索引文件的表头分别固定为：

```markdown
| 编号 | 问题 | 主分类 | 题型 | 难度 | 项目相关 | 链接 |
| --- | --- | --- | --- | --- | --- | --- |
```

```markdown
| 技术组件 | 问题 | 主分类 | 题型 | 链接 |
| --- | --- | --- | --- | --- |
```

```markdown
| 面试场景 | 问题 | 难度 | 项目相关 | 链接 |
| --- | --- | --- | --- | --- |
```

- [ ] **Step 3: 建立空主题目录的可追踪入口**

Git 不追踪空目录，因此各主题不预先创建占位文件。`README.md` 列出完整目录蓝图；实际主题目录在首个问题归档时创建。首题会自然创建 `05_数据质量/`，后续题目按需创建其他目录，避免无意义占位文件。

- [ ] **Step 4: 验证入口结构**

Run:

```powershell
rg -n "认识业务与规划架构|数仓标准制定|数据质量|技术基础与计算引擎|AI蓝军项目实战|一题一文件|统一模板" 'project_extracted_docs/04_数仓问答知识库/README.md'
Get-ChildItem 'project_extracted_docs/04_数仓问答知识库/00_索引' -File | Select-Object -ExpandProperty Name
```

Expected: README 命中全部核心主题和维护规则；索引目录输出三个索引文件名。

- [ ] **Step 5: 提交知识库骨架**

```powershell
git add -- 'project_extracted_docs/04_数仓问答知识库/README.md' 'project_extracted_docs/04_数仓问答知识库/00_索引'
git commit -m "docs: scaffold warehouse qa knowledge base"
```

### Task 2: 归档首题数据质量问答

**Files:**
- Create: `project_extracted_docs/04_数仓问答知识库/05_数据质量/001_如何保证离线数仓链路的数据质量.md`

**Interfaces:**
- Consumes: 当前会话中“如何保证这条链路的数据质量”的完整回答、当前仓库 ODS/DWD/DWM/ADS SQL、Apache Hive DML 文档和 Apache Spark SQL 文档。
- Produces: 符合统一模板的首篇问答正文，供三个索引引用。

- [ ] **Step 1: 写入完整 YAML 元数据**

文件头必须使用以下字段和值：

```yaml
---
title: 如何保证离线数仓链路的数据质量
category: 数据质量
question_type: 场景题
difficulty: 中等
project_related: true
technologies:
  - Hive
  - Spark SQL
tags:
  - DQC
  - 数据对账
  - JOIN放大
  - 幂等重跑
  - 指标口径
created: 2026-07-13
updated: 2026-07-13
---
```

- [ ] **Step 2: 写入模板规定的 11 个正文部分**

正文必须依次包含：原问题、核心结论、完整解释、结合 AI 蓝军项目、SQL 或代码示例、官方文档依据、项目现状与生产方案、面试回答、高频追问、易错点、复盘检查清单。

完整解释至少覆盖：

- 建模前明确业务粒度和唯一键。
- ODS 到 DWD 的分区、主键、空值、逻辑删除、枚举和时间校验。
- DWD 到 DWM 的关联基数、外键缺失、标签映射和 JOIN 放大检查。
- DWM 到 ADS 的黑拦截、黑漏过、白放过、白误伤真值表和指标恒等式。
- 强弱 DQC、调度依赖、SLA、告警、隔离和按业务分区覆盖重跑。

- [ ] **Step 3: 写入项目当前风险**

项目现状至少记录以下当前 SQL 风险：

- 质检 ODS DDL 尾随逗号，且下游读取未在源 DDL 中定义的 `modify_time`。
- 审核 DWD 的 `event_code` 同时出现在普通列和分区列。
- DWM 输出 DDL 有攻击用户 `user_id`，但 SELECT 未输出 `t3.user_id`。
- ADS 引用不存在的 `person_audit_result`。
- DWM 输入的质检关联键和标签字段类型需要确认。
- 多个一对多 JOIN 可能造成指标膨胀。
- 两张 ADS 缺少实际落表 INSERT，不能证明完整发布实现。

- [ ] **Step 4: 写入官方依据**

至少引用并解释：

- Apache Hive LanguageManual DML：`https://hive.apache.org/docs/latest/language/languagemanual-dml/`，支撑 `INSERT OVERWRITE` 分区覆盖与动态分区顺序规则。
- Apache Spark SQL Built-in Functions：`https://spark.apache.org/docs/latest/api/sql/index.html`，支撑 `row_number()` 按业务键取最新记录。
- Apache Spark SQL Performance Tuning：`https://spark.apache.org/docs/latest/sql-performance-tuning`，说明 AQE 可改善 JOIN 和数据倾斜性能，但不能修复错误业务粒度。

- [ ] **Step 5: 验证首题结构与内容**

Run:

```powershell
$f='project_extracted_docs/04_数仓问答知识库/05_数据质量/001_如何保证离线数仓链路的数据质量.md'
rg -n "^## (1|2|3|4|5|6|7|8|9|10|11)\." $f
rg -n "INSERT OVERWRITE|ROW_NUMBER|JOIN放大|黑样本|白样本|person_audit_result|Apache Hive|Apache Spark" $f
```

Expected: 第一个命令依次命中 11 个章节；第二个命令命中所有关键质量主题和官方依据。

- [ ] **Step 6: 提交首题正文**

```powershell
git add -- 'project_extracted_docs/04_数仓问答知识库/05_数据质量/001_如何保证离线数仓链路的数据质量.md'
git commit -m "docs: archive data quality qa"
```

### Task 3: 注册索引并完成一致性验证

**Files:**
- Modify: `project_extracted_docs/04_数仓问答知识库/00_索引/全部问题索引.md`
- Modify: `project_extracted_docs/04_数仓问答知识库/00_索引/按技术组件索引.md`
- Modify: `project_extracted_docs/04_数仓问答知识库/00_索引/按面试场景索引.md`

**Interfaces:**
- Consumes: Task 2 生成的首题正文路径和 YAML 元数据。
- Produces: 三个能正确导航到首题的交叉索引以及最终验证结果。

- [ ] **Step 1: 更新全部问题索引**

加入以下记录：

```markdown
| 001 | 如何保证离线数仓链路的数据质量 | 数据质量 | 场景题 | 中等 | 是 | [查看](../05_数据质量/001_如何保证离线数仓链路的数据质量.md) |
```

- [ ] **Step 2: 更新技术组件索引**

分别为 Hive、Spark SQL 和 DQC 添加首题入口；三条记录都链接到同一正文，不能复制正文文件。

- [ ] **Step 3: 更新面试场景索引**

将首题登记到“方案设计”和“项目追问”两个场景，两条记录链接到同一正文。

- [ ] **Step 4: 验证相对链接和唯一正文**

Run:

```powershell
$root=Resolve-Path 'project_extracted_docs/04_数仓问答知识库'
$files=Get-ChildItem $root -Recurse -Filter '*.md'
$broken=@()
foreach($file in $files){
    $text=Get-Content -Raw -Encoding UTF8 $file.FullName
    foreach($m in [regex]::Matches($text,'\[[^\]]+\]\((?!https?://)([^)#]+)(?:#[^)]+)?\)')){
        $target=Join-Path $file.DirectoryName ([uri]::UnescapeDataString($m.Groups[1].Value))
        if(-not (Test-Path -LiteralPath $target)){ $broken += "$($file.FullName) -> $target" }
    }
}
$broken
(Get-ChildItem $root -Recurse -Filter '001_如何保证离线数仓链路的数据质量.md').Count
```

Expected: `$broken` 没有输出；正文文件数量输出 `1`。

- [ ] **Step 5: 验证 Markdown 和工作树范围**

Run:

```powershell
rg -n "未完成|占位内容|待补充|待完善" 'project_extracted_docs/04_数仓问答知识库'
git diff --check
git status --short
```

Expected: 知识库没有占位文本；`git diff --check` 无输出；工作树只保留用户原有未提交改动和本任务待提交的索引修改。

- [ ] **Step 6: 提交索引更新**

```powershell
git add -- 'project_extracted_docs/04_数仓问答知识库/00_索引'
git commit -m "docs: index warehouse qa knowledge base"
```

- [ ] **Step 7: 最终验收**

Run:

```powershell
git log -4 --oneline
git status --short
```

Expected: 最近提交依次包含设计规格、知识库骨架、首题正文和索引更新；用户原有未提交文件仍保持未提交且未被改写。
