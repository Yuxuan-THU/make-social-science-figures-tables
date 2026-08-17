# Table taxonomy and construction rules

| Family | Required content |
|---|---|
| regression | estimand/variables, coefficient, SE below, model identifiers, observations, variance estimator, FE/controls |
| descriptive/sample | units, sample definition, N, missingness, scale/range, consistent summaries |
| balance/randomization | treatment arms, standardized differences or tests, assignment unit, multiplicity rule if used |
| treatment effects | estimand, comparison, effect scale, uncertainty, sample and clustering/randomization rule |
| model comparison/robustness | baseline, changed assumption per column, common outcome/sample or differences flagged |
| measurement/coding | construct, operational definition, values, source, direction and missing-code treatment |
| crosstab/classification | row/column denominators, counts vs percentages, totals, exclusivity or overlap |
| case/qualitative evidence | case-selection rule, source/date, quotation/paraphrase status, evidence anchor |
| formal theory/simulation | parameters, values/ranges, equilibrium/solution concept, repetitions/seed where applicable |

## Statistical neutrality

Do not select, reorder, or suppress coefficients because of significance. Do not change precision, SE type, fixed effects, weights, or sample. If columns use different samples, surface each N and explain the difference.

## LaTeX baseline

Use `booktabs`, `threeparttable`, and `siunitx`; never vertical rules. Set a real width and wrap labels before shrinking type. Prefer `\small` to scaling a bitmap. Decimal alignment belongs in `S` columns. If the table cannot fit legibly, split it and retain stable column numbering.
