# Make Social Science Figures & Tables

使用 R 和 LaTeX 制作符合 **APSR**（美国政治学评论）或 **AJPS**（美国政治学期刊）排版规范的政治学论文图表。本仓库是一个可直接安装的 Agent skill（Codex / DSH 通用 SKILL.md 格式），也可作为普通 R + LaTeX 项目使用。

**核心原则**：把“统计分析”与“呈现排版”视为两个独立契约——只美化与导出用户提供的证据，**不得静默改变**模型、样本、缺失值规则、标准误、置信水平、参照组或类别顺序。

## 功能特性

- **支持 APSR 与 AJPS 双期刊风格**，各自独立的排版规范（`references/apsr-style.md`、`references/ajps-style.md`）
- **图形类型**：系数/森林图、边际效应、事件研究、时间序列、分布图、散点/分箱散点图、柱形/构成图、地图、网络图、研究设计图
- **表格类型**：回归表、描述统计、平衡检验、处理效应表、稳健性/模型比较表、变量测量/编码表、列联表、定性证据表、形式理论/模拟表
- **可复现交付**：每个产物输出五件套——可编辑源码（.R / .tex）、矢量文件（PDF/SVG）、高分辨率 PNG 预览、最小重绘数据（redraw-data.csv）与 QA 记录（qa.json / qa.md）
- **依赖锁定**：通过 `renv.lock` 固定 R 依赖版本，保证可复现
- **已发表文献风格参考库**：内置 `references/published-corpus/`，收录 APSR / AJPS 已发表正文图表摘录（含 DOI、年份、图表编号、类型、页码与代码状态清单）
- **内置质量护栏**：渲染前审计（缺失、分组、因子水平、参照组、方差估计器）、拒绝从四舍五入结果反推显著性、逐项视觉验证清单

## 目录结构

```
make-social-science-figures-tables/
├── SKILL.md                    # skill 主指令（工作流、输入契约、硬性边界）
├── DESCRIPTION                 # R 包元数据（依赖清单）
├── manifest.yaml               # 版本 1.0.0，路由与稳定接口声明
├── renv.lock                   # R 依赖锁定文件
├── validation-report.json      # 结构完整性校验报告
├── agents/openai.yaml          # agent 配置
├── assets/
│   ├── R/polisci_theme.R       # theme_apsr() / theme_ajps() 绘图主题
│   ├── R/polisci_tables.R      # table_apsr() / table_ajps() 制表助手（booktabs + threeparttable + siunitx）
│   ├── latex/                  # preamble.tex、standalone.tex、table-shell.tex
│   └── demo_data/              # 演示数据（coefficients / event-study / regression）
├── references/
│   ├── apsr-style.md           # APSR 排版规范
│   ├── ajps-style.md           # AJPS 排版规范
│   ├── figure-taxonomy.md      # 图形类型学
│   ├── table-taxonomy.md       # 表格类型学
│   ├── qa-contract.md          # QA 契约（强制阅读）
│   ├── evidence.md             # 风格依据与适用范围
│   └── published-corpus/       # 已发表文献风格参考库（AJPS/APSR 图与表摘录、manifest、完整性报告）
└── scripts/
    ├── install_dependencies.R  # 按 renv.lock 恢复依赖（--latest 可选）
    ├── render_demo.R           # 演示：生成 AJPS 系数图、事件研究图等示例
    ├── render_type_suite.R     # 类型套件渲染
    ├── compile_tables.py       # 表格编译
    ├── validate_bundle.py      # 打包完整性校验
    └── forward_test_prompts.md # 前向测试提示词
```

## 快速开始

### 1. 安装为 Agent skill

将整个目录复制到你的 skills 目录（Codex：`~/.codex/skills/`；DeepSeek Harness：`~/.dsh/skills/`），保持目录名 `make-social-science-figures-tables`。之后即可在“制作 APSR/AJPS 风格图表”类任务中调用该 skill。

### 2. 安装 R 依赖

```r
Rscript scripts/install_dependencies.R          # 按 renv.lock 恢复固定版本
Rscript scripts/install_dependencies.R --latest # 仅当需要测试最新版本时
```

### 3. 运行演示

```r
Rscript scripts/render_demo.R <输出目录>
```

## 稳定接口（R）

```r
source("assets/R/polisci_theme.R")
source("assets/R/polisci_tables.R")

# 绘图：应用期刊主题并导出 PDF/SVG/PNG + redraw data + QA
p <- ggplot2::ggplot(plot_data, ggplot2::aes(term, estimate)) +
  ggplot2::geom_pointrange(ggplot2::aes(ymin = conf_low, ymax = conf_high)) +
  theme_ajps()  # 或 theme_apsr()

save_polisci_figure(
  p, output_stem = "results/figure-1", target_journal = "ajps",
  data = plot_data, width = 6.5, height = 7.2,
  figure_type = "coefficient", confidence_level = 0.95,
  estimand = "supplied coefficient estimates",
  variance_estimator = "not supplied",
  source_files = "data/plot-data.csv",
  redraw_data_source = "data/plot-data.csv",
  visual_checks = list(clipping_checked = TRUE, overlap_checked = TRUE,
                       font_embedding_checked = TRUE)
)

# 制表：生成符合期刊规范的 LaTeX 表格
table_apsr(models, output = "results/table-1.tex",
  coef_map = c(treatment = "Treatment"),
  notes = "Standard errors clustered by district.",
  qa_metadata = list(
    source_files = "data/analysis.csv",
    input_rows = 1250, output_rows = 1250,
    missing_by_variable = list(), dropped_rows = 0,
    variance_estimator = "district-clustered"
  ))
```

## 输入契约

可接受的输入包括：tidy 绘图数据、已拟合的 `lm` / `glm` / `fixest` 模型、`modelsummary` 可识别的模型列表、已计算好不确定性的表格式结果，或需要重排风格的既有 R/LaTeX 图表。

仅在用户提供明确模型公式或直接要求估计时才执行估计；只提供结果时必须原样保留。

## 硬性边界

- 不得把重建 R 代码描述成作者原始源码（代码状态仅允许 `exact-source` / `adapted-source` / `reconstructed` / `not-found`）
- 显著性符号必须来自未四舍五入的 p 值，不得从四舍五入结果反推
- 不得在未静态审查、未隔离目录、未限制资源、未排除 secrets 的条件下运行第三方复现代码
- 不得把栅格图作为唯一投稿产物
- `visual_checks` 字段只有实际检查过最终尺寸产物后才能设为 `TRUE`
- `published-corpus/` 仅供本机风格参考，不得复制进用户项目输出或可移植 skill 压缩包

## 许可证

按 `DESCRIPTION` 声明为 **MIT**。