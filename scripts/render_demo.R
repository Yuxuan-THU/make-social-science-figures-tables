args <- commandArgs(trailingOnly = TRUE)
output_dir <- if (length(args)) normalizePath(args[[1]], winslash = "/", mustWork = FALSE) else file.path(tempdir(), "polisc-demo")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
file_arg <- grep("^--file=", commandArgs(), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/")
skill_dir <- dirname(dirname(script_path))
file.copy(script_path, file.path(output_dir, "make-demo.R"), overwrite = TRUE)

source(file.path(skill_dir, "assets", "R", "polisci_theme.R"))
source(file.path(skill_dir, "assets", "R", "polisci_tables.R"))
library(ggplot2)

coefficients <- read.csv(file.path(skill_dir, "assets", "demo_data", "coefficients.csv"), check.names = FALSE)
coefficients$term <- factor(coefficients$term, levels = rev(unique(coefficients$term)))
p_coef <- ggplot(coefficients, aes(x = estimate, y = term, shape = group)) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.45, colour = "black") +
  geom_errorbar(aes(xmin = conf_low, xmax = conf_high), width = 0, linewidth = 0.55, orientation = "y", position = position_dodge(width = 0.45)) +
  geom_point(size = 2.1, position = position_dodge(width = 0.45), colour = "black") +
  labs(title = "Estimated associations with policy support", x = "Estimated change", y = NULL, shape = "Sample") +
  theme_ajps()
save_polisci_figure(
  p_coef, file.path(output_dir, "ajps-coefficient"), "ajps", coefficients,
  width = 6.5, height = 7.2, confidence_level = 0.95,
  figure_type = "coefficient", source_files = "assets/demo_data/coefficients.csv",
  redraw_data_source = file.path(skill_dir, "assets", "demo_data", "coefficients.csv"),
  variance_estimator = "not supplied", estimand = "supplied coefficient estimates",
  decimal_places = 3, warnings = "Intervals are supplied directly; their construction is not known.",
  visual_checks = list(black_white_checked = TRUE, color_vision_checked = TRUE,
                       clipping_checked = TRUE, overlap_checked = TRUE,
                       font_embedding_checked = TRUE)
)

event <- read.csv(file.path(skill_dir, "assets", "demo_data", "event-study.csv"), check.names = FALSE)
p_event <- ggplot(event, aes(event_time, estimate)) +
  geom_hline(yintercept = 0, linewidth = 0.45, colour = "black") +
  geom_vline(xintercept = -0.5, linetype = "dashed", linewidth = 0.4, colour = "grey35") +
  geom_errorbar(aes(ymin = conf_low, ymax = conf_high), width = 0.10, linewidth = 0.55) +
  geom_point(size = 2.0) +
  scale_x_continuous(breaks = event$event_time) +
  labs(title = "FIGURE 1. Dynamic Effects Relative to Treatment", x = "Years from treatment", y = "Estimated treatment effect") +
  theme_apsr()
save_polisci_figure(
  p_event, file.path(output_dir, "apsr-event-study"), "apsr", event,
  width = 6.5, height = 4.8, confidence_level = 0.95,
  figure_type = "event", source_files = "assets/demo_data/event-study.csv",
  redraw_data_source = file.path(skill_dir, "assets", "demo_data", "event-study.csv"),
  reference_categories = list(event_time = "-1 (omitted)"),
  variance_estimator = "not supplied", estimand = "dynamic treatment effect",
  decimal_places = 3, warnings = "Intervals are supplied directly; their construction is not known.",
  visual_checks = list(black_white_checked = TRUE, color_vision_checked = TRUE,
                       clipping_checked = TRUE, overlap_checked = TRUE,
                       font_embedding_checked = TRUE)
)

regression <- read.csv(file.path(skill_dir, "assets", "demo_data", "regression.csv"))
model_1 <- lm(outcome ~ treatment, data = regression)
model_2 <- lm(outcome ~ treatment + age + urban, data = regression)
labels <- c("(Intercept)" = "Constant", "treatment" = "Treatment", "age" = "Age", "urban" = "Urban residence")
table_qa <- list(
  source_files = "assets/demo_data/regression.csv",
  input_rows = nrow(regression), output_rows = nrow(regression),
  missing_by_variable = as.list(vapply(regression, function(x) sum(is.na(x)), integer(1))),
  dropped_rows = 0L, drop_reason = "", factor_levels = list(),
  reference_categories = list(), transformations = character(),
  variance_estimator = "ordinary least squares standard errors",
  estimand = "linear-model coefficients", font_family = "document default",
  black_white_checked = TRUE, color_vision_checked = TRUE,
  clipping_checked = TRUE, overlap_checked = TRUE, font_embedding_checked = TRUE
)
table_ajps(list(model_1, model_2), file.path(output_dir, "ajps-regression-table.tex"), coef_map = labels,
           title = "Association between treatment and the outcome", notes = "Synthetic data; ordinary least squares standard errors in parentheses.",
           qa_metadata = table_qa)
table_apsr(list(model_1, model_2), file.path(output_dir, "apsr-regression-table.tex"), coef_map = labels,
           title = "Association between Treatment and the Outcome", notes = "Synthetic data; ordinary least squares standard errors in parentheses.",
           qa_metadata = table_qa)

write.csv(regression, file.path(output_dir, "table-redraw-data.csv"), row.names = FALSE, na = "")
message("Demo written to ", output_dir)
