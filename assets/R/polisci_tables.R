.latex_escape <- function(x) {
  x <- as.character(x)
  x <- gsub("\\", "@@POLISCI-BACKSLASH@@", x, fixed = TRUE)
  for (character in c("#", "$", "%", "&", "_", "{", "}")) {
    x <- gsub(character, paste0("\\", character), x, fixed = TRUE)
  }
  x <- gsub("~", "\\textasciitilde{}", x, fixed = TRUE)
  x <- gsub("^", "\\textasciicircum{}", x, fixed = TRUE)
  x <- gsub("@@POLISCI-BACKSLASH@@", "\\textbackslash{}", x, fixed = TRUE)
  x
}

.extract_estimates <- function(model) {
  if (requireNamespace("modelsummary", quietly = TRUE)) {
    out <- tryCatch(modelsummary::get_estimates(model), error = function(e) NULL)
    if (!is.null(out)) {
      names(out) <- tolower(names(out))
      p_name <- intersect(c("p.value", "p_value", "pvalue"), names(out))[1]
      se_name <- intersect(c("std.error", "std_error", "se"), names(out))[1]
      return(data.frame(term = out$term, estimate = out$estimate,
                        std.error = out[[se_name]], p.value = out[[p_name]], stringsAsFactors = FALSE))
    }
  }
  if (inherits(model, c("lm", "glm"))) {
    values <- summary(model)$coefficients
    return(data.frame(term = rownames(values), estimate = values[, 1], std.error = values[, 2], p.value = values[, 4], row.names = NULL))
  }
  if (inherits(model, "fixest")) {
    values <- fixest::coeftable(model)
    return(data.frame(term = rownames(values), estimate = values[, 1], std.error = values[, 2], p.value = values[, 4], row.names = NULL))
  }
  stop("Unsupported model. Install modelsummary or supply lm/glm/fixest models.", call. = FALSE)
}

.model_gof <- function(model) {
  n <- tryCatch(stats::nobs(model), error = function(e) NA_integer_)
  r2 <- if (inherits(model, "lm")) summary(model)$r.squared else if (inherits(model, "fixest")) tryCatch(as.numeric(fixest::fitstat(model, "r2")[[1]]), error = function(e) NA_real_) else NA_real_
  list(n = n, r2 = r2)
}

.stars <- function(p, journal) {
  if (is.na(p)) return("")
  if (journal == "ajps") {
    if (p < .01) "**" else if (p < .05) "*" else if (p < .10) "\\dagger" else ""
  } else {
    if (p < .001) "***" else if (p < .01) "**" else if (p < .05) "*" else ""
  }
}

.format_number <- function(x, digits) {
  if (is.na(x)) "" else formatC(x, format = "f", digits = digits)
}

.write_model_table <- function(models, output, journal, coef_map = NULL, notes = NULL,
                               digits = 3, title = "Model estimates", label = "tab:models",
                               model_names = NULL, code_status = "reconstructed",
                               table_width = "4.8in", qa_metadata = list()) {
  if (!is.list(models) || inherits(models, c("lm", "glm", "fixest"))) models <- list(models)
  if (is.null(model_names)) model_names <- paste("Model", seq_along(models))
  if (length(model_names) != length(models)) stop("model_names must match models.", call. = FALSE)
  if (!code_status %in% c("exact-source", "adapted-source", "reconstructed", "not-found")) stop("Invalid code_status.", call. = FALSE)
  if (!is.list(qa_metadata)) stop("qa_metadata must be a list.", call. = FALSE)
  estimates <- lapply(models, .extract_estimates)
  terms <- unique(unlist(lapply(estimates, function(x) x$term)))
  if (!is.null(coef_map)) {
    keep <- intersect(names(coef_map), terms)
    terms <- c(keep, setdiff(terms, names(coef_map)))
  }
  term_label <- function(term) if (!is.null(coef_map) && term %in% names(coef_map)) unname(coef_map[[term]]) else term
  k <- length(models)
  post_space <- if (journal == "ajps") "**" else "***"
  column_spec <- paste0("@{\\extracolsep{\\fill}} l ", paste(rep(sprintf("S[table-format=-1.%d,table-space-text-post={%s}]", digits, post_space), k), collapse = " "))
  lines <- c(
    "% Requires booktabs, threeparttable, siunitx, and caption.",
    "\\providecommand{\\sym}[1]{\\rlap{\\textsuperscript{#1}}}",
    "\\begin{table}[!htbp]", "\\centering", paste0("\\caption{", .latex_escape(title), "}"),
    paste0("\\label{", label, "}"), "\\begin{threeparttable}", paste0("\\begin{tabular*}{", table_width, "}{", column_spec, "}"),
    "\\toprule", paste0(" & ", paste(sprintf("{%s}", .latex_escape(model_names)), collapse = " & "), " \\\\"), "\\midrule"
  )
  for (term in terms) {
    values <- character(k)
    ses <- character(k)
    for (j in seq_len(k)) {
      row <- estimates[[j]][estimates[[j]]$term == term, , drop = FALSE]
      if (nrow(row)) {
        symbol <- .stars(row$p.value[1], journal)
        values[j] <- paste0(.format_number(row$estimate[1], digits), if (nzchar(symbol)) paste0("\\sym{", symbol, "}") else "")
        ses[j] <- paste0("{(", .format_number(row$std.error[1], digits), ")}")
      } else {
        values[j] <- "{}"; ses[j] <- "{}"
      }
    }
    lines <- c(lines,
      paste0(.latex_escape(term_label(term)), " & ", paste(values, collapse = " & "), " \\\\"),
      paste0(" & ", paste(ses, collapse = " & "), " \\\\[0.25em]"))
  }
  gof <- lapply(models, .model_gof)
  lines <- c(lines, "\\midrule",
    paste0("Observations & ", paste(vapply(gof, function(x) if (is.na(x$n)) "{}" else sprintf("{%s}", format(x$n, big.mark = ",", scientific = FALSE)), character(1)), collapse = " & "), " \\\\"))
  if (any(vapply(gof, function(x) !is.na(x$r2), logical(1)))) {
    lines <- c(lines, paste0("R-squared & ", paste(vapply(gof, function(x) if (is.na(x$r2)) "{}" else .format_number(x$r2, digits), character(1)), collapse = " & "), " \\\\"))
  }
  legend <- if (journal == "ajps") paste0(intToUtf8(0x2020), "p < .10; *p < .05; **p < .01.") else "*p < .05; **p < .01; ***p < .001."
  legend_tex <- if (journal == "ajps") "\\textdagger{}p < .10; *p < .05; **p < .01." else "*p < .05; **p < .01; ***p < .001."
  note_text <- paste(notes, collapse = " ")
  lines <- c(lines, "\\bottomrule", "\\end{tabular*}", "\\begin{tablenotes}[flushleft]", "\\footnotesize",
    paste0("\\item Note: ", .latex_escape(note_text), " ", legend_tex), "\\end{tablenotes}", "\\end{threeparttable}", "\\end{table}")
  directory <- dirname(output)
  if (!dir.exists(directory)) dir.create(directory, recursive = TRUE)
  writeLines(lines, output, useBytes = TRUE)
  standalone_path <- file.path(directory, paste0("standalone-", basename(output)))
  standalone <- c(
    "\\documentclass[10pt]{article}",
    "\\usepackage{booktabs}", "\\usepackage{threeparttable}", "\\usepackage{siunitx}",
    "\\usepackage{caption}", "\\usepackage[margin=0.75in]{geometry}",
    "\\sisetup{detect-all,table-number-alignment=center,group-separator={,},group-minimum-digits=4}",
    "\\newcommand{\\sym}[1]{\\rlap{\\textsuperscript{#1}}}",
    "\\captionsetup[table]{name=TABLE,labelsep=period,labelfont=bf,font=small,singlelinecheck=false,justification=raggedright}",
    "\\begin{document}", paste0("\\input{", basename(output), "}"), "\\end{document}"
  )
  writeLines(standalone, standalone_path, useBytes = TRUE)
  model_n <- vapply(models, function(x) tryCatch(as.integer(stats::nobs(x)), error = function(e) NA_integer_), integer(1))
  default_warnings <- character()
  if (!all(c("input_rows", "missing_by_variable", "dropped_rows") %in% names(qa_metadata))) {
    default_warnings <- "Pre-estimation input rows, missingness, or dropped rows are unavailable from fitted models unless supplied in qa_metadata."
  }
  qa_defaults <- list(
    target_journal = journal, artifact = "table", type = "regression",
    source_files = character(), input_rows = NA_integer_, output_rows = unname(model_n),
    missing_by_variable = list(), dropped_rows = NA_integer_, drop_reason = "",
    factor_levels = list(), reference_categories = list(), transformations = character(),
    model_classes = lapply(models, class),
    model_formula = lapply(models, function(x) tryCatch(paste(deparse(stats::formula(x)), collapse = " "), error = function(e) "")),
    variance_estimator = "preserved from supplied fitted model; method not independently verified",
    confidence_level = NA_real_, estimand = "model coefficients",
    dimensions_in = list(width = table_width, height = NA_real_), font_family = "document default",
    minimum_font_pt = 8, legend_position = "table notes", gridlines = "none",
    decimal_places = digits, significance_legend = legend, standard_errors_below = TRUE,
    black_white_checked = FALSE, color_vision_checked = FALSE, clipping_checked = FALSE,
    overlap_checked = FALSE, font_embedding_checked = FALSE,
    code_status = code_status, warnings = default_warnings, model_sample_size = unname(model_n)
  )
  qa <- utils::modifyList(qa_defaults, qa_metadata)
  qa$source_files <- as.list(unname(qa$source_files))
  qa$transformations <- as.list(unname(qa$transformations))
  qa$warnings <- as.list(unname(qa$warnings))
  qa_path <- sub("\\.tex$", "-qa.json", output, ignore.case = TRUE)
  if (requireNamespace("jsonlite", quietly = TRUE)) jsonlite::write_json(qa, qa_path, pretty = TRUE, auto_unbox = TRUE, na = "null")
  invisible(list(tex = output, standalone_tex = standalone_path, qa = qa_path))
}

table_apsr <- function(models, output, coef_map = NULL, notes = NULL, digits = 3,
                       title = "Model estimates", label = "tab:models", model_names = NULL,
                       code_status = "reconstructed", table_width = "4.8in", qa_metadata = list()) {
  .write_model_table(models, output, "apsr", coef_map, notes, digits, title, label, model_names,
                     code_status, table_width, qa_metadata)
}

table_ajps <- function(models, output, coef_map = NULL, notes = NULL, digits = 3,
                       title = "Model estimates", label = "tab:models", model_names = NULL,
                       code_status = "reconstructed", table_width = "4.8in", qa_metadata = list()) {
  .write_model_table(models, output, "ajps", coef_map, notes, digits, title, label, model_names,
                     code_status, table_width, qa_metadata)
}

write_polisci_data_table <- function(data, output, journal = c("apsr", "ajps"),
                                     title = "Summary", label = "tab:summary",
                                     notes = "Entries are synthetic demonstration values.", digits = 3) {
  journal <- match.arg(tolower(journal), c("apsr", "ajps"))
  if (!is.data.frame(data) || ncol(data) < 2) stop("data must have at least two columns.", call. = FALSE)
  numeric <- vapply(data, is.numeric, logical(1))
  specs <- ifelse(numeric, sprintf("S[table-format=-1.%d]", digits), "l")
  header <- paste(sprintf("{%s}", .latex_escape(names(data))), collapse = " & ")
  body <- apply(data, 1, function(row) {
    cells <- mapply(function(value, is_num) {
      if (is_num) .format_number(as.numeric(value), digits) else .latex_escape(value)
    }, row, numeric, SIMPLIFY = TRUE, USE.NAMES = FALSE)
    paste0(paste(cells, collapse = " & "), " \\\\")
  })
  lines <- c("\\begin{table}[!htbp]", "\\centering", paste0("\\caption{", .latex_escape(title), "}"),
             paste0("\\label{", label, "}"), "\\begin{threeparttable}",
             paste0("\\begin{tabular}{", paste(specs, collapse = " "), "}"), "\\toprule",
             paste0(header, " \\\\"), "\\midrule", body, "\\bottomrule", "\\end{tabular}",
             "\\begin{tablenotes}[flushleft]", "\\footnotesize", paste0("\\item Note: ", .latex_escape(notes)),
             "\\end{tablenotes}", "\\end{threeparttable}", "\\end{table}")
  dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
  writeLines(lines, output, useBytes = TRUE)
  invisible(output)
}
