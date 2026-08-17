---
name: make-social-science-figures-tables
description: 使用 R 和 LaTeX 创建、重排、导出并审计符合 APSR 或 AJPS 风格的政治学图表。适用于系数/森林图、边际效应、事件研究、时间序列、分布图、散点/分箱散点图、柱形/构成图、地图、网络图、研究设计图、回归表、描述统计、平衡检验、处理效应表、稳健性/模型比较表、变量测量/编码表、列联表、定性证据表、形式理论/模拟表。输出可编辑 R 和 LaTeX 源码、PDF/SVG、PNG 预览、最小重绘数据切片和 QA 记录，同时保留用户指定的模型、样本、标准误和置信区间选择。
---

# APSR/AJPS 社会科学图表制作

## 目标

根据用户提供的数据、已拟合 R 模型或已有图表，制作符合 APSR 或 AJPS 风格的政治学论文图表。必须显式处理 `target_journal: apsr | ajps` 和 `artifact: figure | table`。把“统计分析”和“呈现排版”视为两个独立契约：只美化和导出用户提供的证据，不得静默改变模型、样本、缺失值规则、标准误、置信水平、参照组或类别顺序。

## 请求路由

1. 识别目标期刊、产物类型、图表类型、核心结论、变量标签和输出目录。
2. 只读取适用的期刊规范：[APSR profile](references/apsr-style.md) 或 [AJPS profile](references/ajps-style.md)。
3. 如果制作图，读取 [figure taxonomy](references/figure-taxonomy.md)。如果制作表，读取 [table taxonomy](references/table-taxonomy.md)。
4. 总是读取 [QA contract](references/qa-contract.md)。只有在解释或修订风格依据时，才读取 [evidence and scope](references/evidence.md)。
5. 需要比对已发表正文图表风格时，使用本机参考库 `references/published-corpus/`；其中 `figures/` 和 `tables/` 保存正式正文摘录，`manifest.csv` 和 `manifest.json` 保存 DOI、年份、图表编号、类型、页码和代码状态。
6. 使用 `assets/R/` 中的稳定助手函数。表格和可并入论文的 LaTeX 片段使用 `assets/latex/`。

如果用户省略了期刊或产物类型，但可以从上下文可靠推断，就在 QA 中写明假设并继续。只有当该选择会实质改变结果时才提问。

## 输入契约

可接受的输入包括：tidy 绘图数据、已经拟合好的 `lm`、`glm` 或 `fixest` 模型、`modelsummary` 可识别的模型列表、已经计算好不确定性的表格式结果，或需要重排风格的既有 R/LaTeX 图表。

语义上必须确认：图表要表达的核心结论、人类可读的变量标签、展示不确定性时使用的置信水平，以及输出目录。只有在用户提供明确模型公式或直接要求估计时，才执行估计。如果用户只提供结果，必须原样保留这些结果。

## 构建流程

### 1. 渲染前审计

记录输入行数、缺失情况、分组、因子水平及顺序、参照组、变量转换状态、置信区间定义，以及模型和方差估计器。禁止静默执行 listwise deletion。如果绘图或制表包自动丢行，必须在 QA 中暴露丢弃数量。

### 2. 制作图表

如果需要固定依赖环境，运行 `Rscript scripts/install_dependencies.R`；它默认按 `renv.lock` 恢复依赖。只有在明确测试更新版本兼容性时才使用 `--latest`，并在 QA 中记录该偏离。

制作图形时，先 source `assets/R/polisci_theme.R`，再应用 `theme_apsr()` 或 `theme_ajps()`。使用 `save_polisci_figure()` 同时导出 PDF、SVG 和 PNG，并生成 redraw data 与 QA。

制作模型表时，先 source `assets/R/polisci_tables.R`，再调用 `table_apsr()` 或 `table_ajps()`。这些助手函数会把标准误放在系数下方，并使用 `booktabs`、`threeparttable` 和 `siunitx` 约定。手工编排非模型表时，使用 `assets/latex/table-shell.tex`。

不得从四舍五入后的结果反推显著性。显著性符号必须来自拟合模型或结果对象中未四舍五入的 p 值。

### 3. 交付五件套

在一个自包含输出目录中生成：

1. 可编辑 `.R` 源码；表格还需生成 `.tex` 源码；
2. 矢量文件：图形为 `.pdf` 和 `.svg`，表格为 `.pdf`；
3. 高分辨率 `.png` 预览；
4. `redraw-data.csv`，只包含重绘该图表所需的变量和行；
5. `qa.json` 或 `qa.md`，记录来源、转换、缺失、尺寸、风格检查和警告。

不要把保密原始数据放进 redraw slice。如果来源数据受限，要求用户提供或创建明确标注的合成切片。

### 4. 视觉验证

按最终版面尺寸检查输出。至少检查裁切、重叠、最小字号、标签可读性、黑白打印、色觉可辨性、图例位置、小数位一致性、注释顺序，以及 PDF/SVG 字体嵌入。对 AJPS，侧边图例、背景网格、灰色文字、表格分面或 `***` 都视为验证失败。

## 稳定接口

```r
source("assets/R/polisci_theme.R")
source("assets/R/polisci_tables.R")

p <- ggplot2::ggplot(plot_data, ggplot2::aes(term, estimate)) +
  ggplot2::geom_pointrange(ggplot2::aes(ymin = conf_low, ymax = conf_high)) +
  theme_ajps()

save_polisci_figure(
  p, output_stem = "results/figure-1", target_journal = "ajps",
  data = plot_data, width = 6.5, height = 7.2,
  figure_type = "coefficient", confidence_level = 0.95,
  estimand = "supplied coefficient estimates",
  variance_estimator = "not supplied",
  source_files = "data/plot-data.csv",
  redraw_data_source = "data/plot-data.csv",
  visual_checks = list(
    clipping_checked = TRUE,
    overlap_checked = TRUE,
    font_embedding_checked = TRUE
  )
)

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

## 硬性边界

- 不得把重建 R 代码描述成作者原始源码。代码状态只能使用 `exact-source`、`adapted-source`、`reconstructed` 或 `not-found`。
- 翻译 Stata/R/LaTeX 复现逻辑时，保留原始代码，并把转换版本标为 `adapted-source`。
- 不得在未静态审查、未隔离目录、未限制资源、未排除 secrets 的条件下运行第三方复现代码。
- 不得把栅格图作为唯一投稿产物。
- 只有实际检查过最终尺寸产物后，才能把 `visual_checks` 字段设为 `TRUE`；未验证项目保持默认 `FALSE`。
- 本机 installed skill 可以保留 `references/published-corpus/` 作为风格参考；不得把该参考样本库复制进用户项目输出或可移植 skill 压缩包。
- 优先使用明确标签，避免缩写；不可避免的缩写必须在图注或表注中定义。
