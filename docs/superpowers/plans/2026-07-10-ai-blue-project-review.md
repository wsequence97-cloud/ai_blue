# AI 蓝军项目完整复盘 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. 本线程禁止未获用户明确授权的子代理，因此采用当前会话内联执行。

**Goal:** 形成一套以简历第一个项目为验收标准、可用于面试完整讲解和追问应答的 AI 蓝军业务与离线数仓复盘材料。

**Architecture:** 以 PRD 业务闭环为顶层，以 ODS→DWD→DIM→DWM→ADS 为数据主线，以简历中的 DWD 6 张、DWM 2 张、ADS 2 张和 17 个指标为口径锚点。所有表级结论从现存 SQL 提取，区分核心自研表、复用依赖表、Dify/审核/蓝军系统边界和当前资料无法证明的内容。

**Tech Stack:** Markdown、Hive/Spark SQL、PowerShell 校验、PPTX Open XML 文本提取。

## Global Constraints

- 不修改用户原始简历 PPTX。
- 不把 Dify 工作流、审核策略、蓝军平台前后端描述成用户本人实现。
- 表名、字段、关联条件和指标公式以 `project_extracted_docs/02_数仓整理` 的现存 SQL 为准。
- PRD 历史名 `dwm_com_audit_ai_blue_detail_di` 按用户确认映射到当前 `dwm_com_audit_ai_blue_output_detail_df`。
- 对 SQL 截图中确认存在但尚未决定修法的问题，只记录风险，不擅自改写业务 SQL。

---

### Task 1: 简历项目承诺拆解

**Files:**
- Create: `project_extracted_docs/03_项目复盘/01_简历项目拆解与业务全景.md`

**Interfaces:**
- Consumes: 简历 PPTX 第 1 页、完整 PRD 流程文档。
- Produces: 项目背景、目标、个人职责、上下游边界、简历数字口径和端到端业务流程。

- [ ] 提取简历第一个项目的项目背景、项目梳理、项目价值和三段项目流程原文。
- [ ] 将简历承诺拆成可被 SQL 和 PRD 验证的责任项。
- [ ] 解释 DWD 6、DWM 2、ADS 2、指标 17 的面试口径。
- [ ] 标出简历中可能被面试官追问或表述不严谨的文字。

验证命令：

```powershell
rg -n "DWD 6|DWM 2|ADS 2|17|Dify|职责边界" project_extracted_docs/03_项目复盘/01_简历项目拆解与业务全景.md
```

预期：每个简历承诺均有独立解释。

### Task 2: 分层表清单与完整血缘

**Files:**
- Create: `project_extracted_docs/03_项目复盘/02_逐层表清单与完整血缘.md`

**Interfaces:**
- Consumes: `project_extracted_docs/02_数仓整理` 下全部 SQL 和表说明。
- Produces: 每层表的粒度、主键、来源、核心转换、下游、关联键和项目角色。

- [ ] 枚举全部 ODS、DWD、DIM、DWM、ADS 表及目录外依赖。
- [ ] 还原生成前供数链路和生成后评估链路。
- [ ] 写出 DWM 输入、DWM 输出的逐 JOIN 血缘与保留行影响。
- [ ] 写出核心 ID 在各表之间的传递路径。
- [ ] 区分简历核心 6 张 DWD 与复用/支撑 DWD 表。

验证命令：

```powershell
$doc = Get-Content project_extracted_docs/03_项目复盘/02_逐层表清单与完整血缘.md -Raw -Encoding UTF8
Get-ChildItem project_extracted_docs/02_数仓整理 -Recurse -Filter *.sql | ForEach-Object { if (-not $doc.Contains($_.BaseName)) { $_.BaseName } }
```

预期：没有输出，表示全部 SQL 表名均被覆盖。

### Task 3: 核心 SQL、字段口径与数据质量风险

**Files:**
- Create: `project_extracted_docs/03_项目复盘/03_核心SQL与指标口径.md`

**Interfaces:**
- Consumes: DWD、DWM、ADS SQL 和 PRD 指标需求。
- Produces: SQL 加工逻辑、指标计算、黑白样本语义、SQL 风险和面试解释。

- [ ] 解释各 DWD 的字段标准化、枚举映射、删除过滤和时间处理。
- [ ] 解释 DWM 两张宽表的事实粒度、维度退化和 JOIN 类型。
- [ ] 将 PRD 17 类业务指标映射到 ADS 字段或标记为未在当前 ADS SQL 中直接体现。
- [ ] 解释 17 个业务指标与 ADS 25 个物理字段的差异。
- [ ] 记录重复字段、列位置错配、字段名拼写、无 INSERT 和口径注释差异。

验证命令：

```powershell
rg -n "17 类|25 个|拦截|漏过|放过|误伤|重复字段|无 INSERT" project_extracted_docs/03_项目复盘/03_核心SQL与指标口径.md
```

预期：业务语义和技术风险均可检索。

### Task 4: 面试陈述与高频追问

**Files:**
- Create: `project_extracted_docs/03_项目复盘/04_面试陈述与高频问答.md`

**Interfaces:**
- Consumes: Task 1-3 的业务、血缘和口径结论。
- Produces: 30 秒、1 分钟、3 分钟陈述，以及业务、建模、SQL、性能、数据质量和项目协作问答。

- [ ] 写出不同长度的项目自述。
- [ ] 写出从“为什么建两张 DWM”到“如何保证口径一致”的高频问答。
- [ ] 为 Dify、Kafka、审核策略等非本人实现内容准备边界回答。
- [ ] 为简历量化结果准备不夸大、可追溯的回答。
- [ ] 添加面试前逐项自测清单。

验证命令：

```powershell
rg -n "30 秒|1 分钟|3 分钟|高频追问|不能说|自测" project_extracted_docs/03_项目复盘/04_面试陈述与高频问答.md
```

预期：至少覆盖六类追问和三种陈述长度。

### Task 5: 总入口与一致性校验

**Files:**
- Create: `project_extracted_docs/03_项目复盘/README.md`
- Modify: `project_extracted_docs/01_PRD/README.md`

**Interfaces:**
- Consumes: Task 1-4 的全部文档。
- Produces: 推荐阅读顺序、复盘导航和最终覆盖验证结果。

- [ ] 建立从业务到表血缘、指标、面试问答的阅读路径。
- [ ] 校验所有 Markdown 代码围栏闭合。
- [ ] 校验所有现存表说明和 SQL 表名均被复盘材料覆盖。
- [ ] 校验简历四个量化承诺均能定位到解释。

验证命令：

```powershell
rg -n "01_简历项目拆解|02_逐层表清单|03_核心SQL|04_面试陈述" project_extracted_docs/03_项目复盘/README.md
```

预期：四份复盘文档均有入口。
