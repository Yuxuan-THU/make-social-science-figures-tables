.require_namespace <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop("Package '", package, "' is required. Run scripts/install_dependencies.R.", call. = FALSE)
  }
}

theme_apsr <- function(base_size = 9, base_family = "sans") {
  .require_namespace("ggplot2")
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = "black"),
      plot.title = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.10), hjust = 0),
      plot.subtitle = ggplot2::element_text(size = ggplot2::rel(1.0), hjust = 0),
      axis.title = ggplot2::element_text(size = ggplot2::rel(1.0)),
      axis.text = ggplot2::element_text(colour = "black"),
      panel.grid.major = ggplot2::element_line(colour = "grey85", linewidth = 0.30),
      panel.grid.minor = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "plain"),
      legend.position = "bottom",
      legend.title = ggplot2::element_text(face = "plain"),
      legend.key = ggplot2::element_blank(),
      plot.caption = ggplot2::element_text(hjust = 0, size = ggplot2::rel(0.86)),
      plot.margin = ggplot2::margin(8, 10, 8, 8)
    )
}

theme_ajps <- function(base_size = 9, base_family = "sans") {
  .require_namespace("ggplot2")
  ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = "black", face = "plain"),
      plot.title = ggplot2::element_text(colour = "black", face = "plain", size = ggplot2::rel(1.05), hjust = 0),
      plot.subtitle = ggplot2::element_text(colour = "black", face = "plain", hjust = 0),
      axis.title = ggplot2::element_text(colour = "black", face = "plain", margin = ggplot2::margin(t = 8, r = 8)),
      axis.text = ggplot2::element_text(colour = "black", face = "plain"),
      panel.grid = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),
      axis.line = ggplot2::element_line(colour = "black", linewidth = 0.45),
      axis.ticks = ggplot2::element_line(colour = "black", linewidth = 0.40),
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(colour = "black", face = "plain"),
      legend.position = "bottom",
      legend.direction = "horizontal",
      legend.title = ggplot2::element_text(colour = "black", face = "plain"),
      legend.text = ggplot2::element_text(colour = "black", face = "plain"),
      legend.background = ggplot2::element_blank(),
      legend.box.background = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      plot.caption = ggplot2::element_text(colour = "black", face = "plain", hjust = 0, size = ggplot2::rel(0.86)),
      plot.margin = ggplot2::margin(8, 10, 8, 8)
    )
}

scale_colour_apsr <- function(...) {
  .require_namespace("ggplot2")
  ggplot2::scale_colour_manual(values = c("#000000", "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00"), ...)
}

scale_fill_apsr <- function(...) {
  .require_namespace("ggplot2")
  ggplot2::scale_fill_manual(values = c("#4D4D4D", "#56B4E9", "#E69F00", "#009E73", "#CC79A7", "#F0E442"), ...)
}

scale_colour_ajps <- function(...) {
  .require_namespace("ggplot2")
  ggplot2::scale_colour_manual(values = c("#000000", "#555555", "#999999", "#BBBBBB"), ...)
}

save_polisci_figure <- function(plot, output_stem, target_journal = c("apsr", "ajps"),
                                data = NULL, width = NULL, height = NULL, dpi = 320,
                                confidence_level = NULL, code_status = "reconstructed",
                                warnings = character(), figure_type = NULL,
                                source_files = character(), redraw_data_source = NULL,
                                reference_categories = list(),
                                transformations = character(), model_formula = NULL,
                                variance_estimator = NULL, estimand = NULL,
                                decimal_places = NULL, font_family = "sans",
                                minimum_font_pt = 7, legend_position = NULL,
                                dropped_rows = 0L, drop_reason = "",
                                visual_checks = list(
                                  black_white_checked = FALSE,
                                  color_vision_checked = FALSE,
                                  clipping_checked = FALSE,
                                  overlap_checked = FALSE,
                                  font_embedding_checked = FALSE
                                )) {
  .require_namespace("ggplot2")
  target_journal <- match.arg(tolower(target_journal), c("apsr", "ajps"))
  if (!inherits(plot, "ggplot")) stop("'plot' must be a ggplot object.", call. = FALSE)
  if (!code_status %in% c("exact-source", "adapted-source", "reconstructed", "not-found")) {
    stop("Invalid code_status.", call. = FALSE)
  }
  if (is.null(width)) width <- 6.5
  if (is.null(height)) height <- if (target_journal == "ajps") 7.2 else 4.8
  if (target_journal == "ajps" && width > height) {
    warnings <- c(warnings, "AJPS requires portrait orientation; supplied width exceeds height.")
  }
  stem <- sub("\\.(pdf|svg|png)$", "", output_stem, ignore.case = TRUE)
  directory <- dirname(stem)
  if (!dir.exists(directory)) dir.create(directory, recursive = TRUE)
  paths <- c(pdf = paste0(stem, ".pdf"), svg = paste0(stem, ".svg"), png = paste0(stem, ".png"))

  ggplot2::ggsave(paths[["pdf"]], plot = plot, width = width, height = height,
                  units = "in", device = grDevices::cairo_pdf, bg = "white")
  if (requireNamespace("svglite", quietly = TRUE)) {
    ggplot2::ggsave(paths[["svg"]], plot = plot, width = width, height = height,
                    units = "in", device = svglite::svglite, bg = "white")
  } else {
    stop("Package 'svglite' is required for the vector bundle.", call. = FALSE)
  }
  if (requireNamespace("ragg", quietly = TRUE)) {
    ggplot2::ggsave(paths[["png"]], plot = plot, width = width, height = height,
                    units = "in", dpi = dpi, device = ragg::agg_png, background = "white")
  } else {
    ggplot2::ggsave(paths[["png"]], plot = plot, width = width, height = height,
                    units = "in", dpi = dpi, bg = "white")
  }

  data_path <- paste0(stem, "-redraw-data.csv")
  if (!is.null(redraw_data_source)) {
    if (!file.exists(redraw_data_source)) stop("redraw_data_source does not exist.", call. = FALSE)
    source_path <- normalizePath(redraw_data_source, winslash = "/", mustWork = TRUE)
    target_path <- normalizePath(data_path, winslash = "/", mustWork = FALSE)
    if (!identical(source_path, target_path) && !file.copy(source_path, data_path, overwrite = TRUE)) {
      stop("Could not copy redraw_data_source.", call. = FALSE)
    }
  } else if (!is.null(data)) {
    utils::write.csv(data, data_path, row.names = FALSE, na = "")
  }
  missing_by_variable <- if (is.null(data)) list() else as.list(vapply(data, function(x) sum(is.na(x)), integer(1)))
  factor_levels <- if (is.null(data)) list() else lapply(data[vapply(data, is.factor, logical(1))], levels)
  default_checks <- list(black_white_checked = FALSE, color_vision_checked = FALSE,
                         clipping_checked = FALSE, overlap_checked = FALSE,
                         font_embedding_checked = FALSE)
  visual_checks <- utils::modifyList(default_checks, visual_checks)
  if (is.null(legend_position)) legend_position <- "bottom_or_inside"
  qa <- list(
    target_journal = target_journal, artifact = "figure", type = figure_type,
    source_files = as.list(unname(source_files)),
    input_rows = if (is.null(data)) NA_integer_ else nrow(data) + as.integer(dropped_rows),
    output_rows = if (is.null(data)) NA_integer_ else nrow(data),
    missing_by_variable = missing_by_variable, dropped_rows = as.integer(dropped_rows),
    drop_reason = drop_reason, factor_levels = factor_levels,
    reference_categories = reference_categories, transformations = as.list(unname(transformations)),
    model_formula = model_formula, variance_estimator = variance_estimator,
    confidence_level = confidence_level, estimand = estimand,
    dimensions_in = list(width = width, height = height), font_family = font_family,
    minimum_font_pt = minimum_font_pt, legend_position = legend_position,
    gridlines = if (target_journal == "ajps") "none" else "restrained_major",
    decimal_places = decimal_places,
    black_white_checked = isTRUE(visual_checks$black_white_checked),
    color_vision_checked = isTRUE(visual_checks$color_vision_checked),
    clipping_checked = isTRUE(visual_checks$clipping_checked),
    overlap_checked = isTRUE(visual_checks$overlap_checked),
    font_embedding_checked = isTRUE(visual_checks$font_embedding_checked),
    code_status = code_status, warnings = as.list(unname(warnings))
  )
  qa_path <- paste0(stem, "-qa.json")
  if (requireNamespace("jsonlite", quietly = TRUE)) {
    jsonlite::write_json(qa, qa_path, pretty = TRUE, auto_unbox = TRUE, na = "null")
  } else {
    dput(qa, file = sub("\\.json$", ".R", qa_path))
    warnings <- c(warnings, "jsonlite unavailable; QA written as an R object.")
  }
  invisible(list(files = paths, redraw_data = if (file.exists(data_path)) data_path else NULL, qa = qa_path, warnings = warnings))
}
