args <- commandArgs(trailingOnly = TRUE)
output_dir <- if (length(args)) normalizePath(args[[1]], winslash = "/", mustWork = FALSE) else file.path(tempdir(), "polisc-type-suite")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
file_arg <- grep("^--file=", commandArgs(), value = TRUE)
skill_dir <- dirname(dirname(normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/")))
source(file.path(skill_dir, "assets", "R", "polisci_theme.R"))
source(file.path(skill_dir, "assets", "R", "polisci_tables.R"))
library(ggplot2)
set.seed(20260817)

save_demo <- function(name, plot, data, journal = "apsr") {
  save_polisci_figure(plot, file.path(output_dir, "figures", name), journal, data,
                      width = 6.5, height = if (journal == "ajps") 7.2 else 4.8)
}

coef <- data.frame(term = factor(LETTERS[1:5], levels = rev(LETTERS[1:5])), estimate = c(-.12, .03, .18, .07, -.04), low = c(-.21, -.04, .08, -.01, -.13), high = c(-.03, .10, .28, .15, .05))
save_demo("01-coefficient", ggplot(coef, aes(estimate, term)) + geom_vline(xintercept = 0, linetype = 2) + geom_errorbar(aes(xmin = low, xmax = high), width = 0, orientation = "y") + geom_point() + labs(x = "Estimate", y = NULL) + theme_ajps(), coef, "ajps")

margin <- expand.grid(x = seq(0, 1, length.out = 25), group = c("Comparison", "Treatment")); margin$fit <- .2 + .45 * margin$x + ifelse(margin$group == "Treatment", .12 * margin$x, 0)
save_demo("02-marginal", ggplot(margin, aes(x, fit, linetype = group)) + geom_line() + labs(x = "Moderator", y = "Predicted probability", linetype = "Group") + theme_ajps(), margin, "ajps")

event <- read.csv(file.path(skill_dir, "assets", "demo_data", "event-study.csv"))
save_demo("03-event-study", ggplot(event, aes(event_time, estimate)) + geom_hline(yintercept = 0) + geom_errorbar(aes(ymin = conf_low, ymax = conf_high), width = .1) + geom_point() + theme_apsr(), event)

series <- data.frame(year = 2000:2024, value = cumsum(rnorm(25, .15, .3)))
save_demo("04-time-series", ggplot(series, aes(year, value)) + geom_line() + geom_point(size = 1) + labs(x = "Year", y = "Index") + theme_ajps(), series, "ajps")

dist <- data.frame(value = c(rnorm(300), rnorm(300, .7)), group = rep(c("Comparison", "Treatment"), each = 300))
save_demo("05-distribution", ggplot(dist, aes(value, linetype = group)) + geom_density(fill = NA) + labs(x = "Outcome", y = "Density", linetype = "Group") + theme_ajps(), dist, "ajps")

scatter <- data.frame(x = runif(160)); scatter$y <- .3 + .5 * scatter$x + rnorm(160, 0, .18)
save_demo("06-scatter", ggplot(scatter, aes(x, y)) + geom_point(shape = 1, alpha = .6) + geom_smooth(method = "lm", formula = y ~ x, se = TRUE, colour = "black", fill = "grey80") + labs(x = "Exposure", y = "Outcome") + theme_apsr(), scatter)

bars <- data.frame(category = LETTERS[1:4], share = c(.18, .27, .31, .24))
save_demo("07-bar", ggplot(bars, aes(category, share)) + geom_col(fill = "grey45") + scale_y_continuous(limits = c(0, .4)) + labs(x = "Category", y = "Share") + theme_ajps(), bars, "ajps")

map <- expand.grid(x = 1:8, y = 1:6); map$value <- seq_len(nrow(map)) %% 7
save_demo("08-map", ggplot(map, aes(x, y, fill = value)) + geom_tile(colour = "white") + coord_equal() + scale_fill_gradient(low = "white", high = "black") + labs(x = NULL, y = NULL, fill = "Value") + theme_apsr() + theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank()), map)

nodes <- data.frame(id = 1:8, x = cos(seq(0, 2*pi, length.out = 9)[-9]), y = sin(seq(0, 2*pi, length.out = 9)[-9])); edges <- data.frame(from = 1:8, to = c(2:8, 1)); edges <- merge(edges, nodes, by.x = "from", by.y = "id"); edges <- merge(edges, nodes, by.x = "to", by.y = "id"); names(edges)[3:6] <- c("x", "y", "xend", "yend")
save_demo("09-network", ggplot() + geom_segment(data = edges, aes(x, y, xend = xend, yend = yend), arrow = arrow(length = grid::unit(0.10, "in"))) + geom_point(data = nodes, aes(x, y), size = 3) + coord_equal() + theme_void(), nodes)

design <- data.frame(x = 1:4, y = 1, label = c("Assignment", "Treatment", "Measurement", "Outcome"))
save_demo("10-design", ggplot(design, aes(x, y, label = label)) + geom_segment(aes(x = x, xend = x + .75, yend = y), data = design[1:3, ], arrow = arrow(length = grid::unit(.1, "in"))) + geom_label() + xlim(.5, 4.5) + theme_void(), design)

table_examples <- list(
  "01-regression" = data.frame(Variable = c("Treatment", "Standard error", "Observations"), `Model 1` = c(.125, .051, 1250), check.names = FALSE),
  "02-descriptive" = data.frame(Measure = c("Age", "Income"), Mean = c(42.3, 55.8), `Standard deviation` = c(12.1, 18.7), check.names = FALSE),
  "03-balance" = data.frame(Measure = c("Age", "Urban residence"), Treatment = c(41.8, .62), Comparison = c(42.0, .60)),
  "04-treatment-effects" = data.frame(Outcome = c("Support", "Turnout"), Effect = c(.08, .04), `Standard error` = c(.03, .02), check.names = FALSE),
  "05-model-comparison" = data.frame(Specification = c("Baseline", "Covariates", "Fixed effects"), Estimate = c(.12, .11, .10)),
  "06-measurement" = data.frame(Construct = c("Trust", "Participation"), Coding = c("0 to 10", "Any activity"), Source = c("Survey", "Survey")),
  "07-crosstab" = data.frame(Category = c("A", "B", "C"), Treatment = c(31, 44, 25), Comparison = c(28, 46, 26)),
  "08-case-evidence" = data.frame(Case = c("North", "South"), Evidence = c("Archive A", "Interview B"), Date = c("1924", "1978")),
  "09-formal-simulation" = data.frame(Parameter = c("Cost", "Precision", "Iterations"), Value = c(.25, .80, 1000))
)
for (name in names(table_examples)) write_polisci_data_table(table_examples[[name]], file.path(output_dir, "tables", paste0(name, ".tex")), "ajps", title = gsub("-", " ", sub("^[0-9]+-", "", name)))
message("Type suite written to ", output_dir)
