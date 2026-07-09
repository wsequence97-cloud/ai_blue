# raw_transcripts 已废弃

旧版 `raw_transcripts` 是自动 OCR 原始稿，存在中文/SQL 混乱、截图行号混入、分段 SQL 未拼接等问题。

已改为按表/主题输出清洗后的 Markdown 和 SQL：

| 分层 | Markdown | SQL |
|---|---|---|
| ODS | `project_extracted_docs/02_数仓整理/01_ODS/tables/` | `project_extracted_docs/02_数仓整理/01_ODS/sql/` |
| DWD | `project_extracted_docs/02_数仓整理/02_DWD/tables/` | `project_extracted_docs/02_数仓整理/02_DWD/sql/` |
| DWM | `project_extracted_docs/02_数仓整理/03_DWM/tables/` | `project_extracted_docs/02_数仓整理/03_DWM/sql/` |
| DIM | `project_extracted_docs/02_数仓整理/04_DIM/tables/` | `project_extracted_docs/02_数仓整理/04_DIM/sql/` |
| ADS | `project_extracted_docs/02_数仓整理/05_ADS/tables/` | `project_extracted_docs/02_数仓整理/05_ADS/sql/` |

说明：PRD 截图尚未在本次修正中完整清洗，后续应按同样原则重新整理，不能直接使用旧 OCR。
