# Figure taxonomy and construction rules

Select the family from the evidentiary task, not from decoration.

| Family | Use | Required checks |
|---|---|---|
| coefficient/forest | many estimates on a common scale | zero/reference line; ordered labels; interval level stated |
| marginal effects/predictions | model-implied outcome across a moderator | observed support; scale and estimand stated; rug/distribution if useful |
| event study | dynamic leads/lags around treatment | omitted period explicit; event time ordered; pre/post distinction; CI definition |
| time series | change through calendar time | interval and aggregation unit; intervention markers; no unlabeled interpolation |
| distribution | density, histogram, ECDF, ridgeline, violin | bin/bandwidth recorded; sample sizes; common comparison scale |
| scatter/binned scatter | association of continuous variables | binning/residualization documented; raw support or counts; fit uncertainty distinguished |
| bar/composition | discrete quantities or shares | zero baseline for magnitude; denominator and uncertainty; avoid for dense estimates |
| map/spatial | geographic pattern or assignment | projection, boundaries, missing regions, legend, source and date |
| network/flow | relational structure or movement | node/edge meaning, layout, weights/direction, isolates and filtering |
| timeline/design/theory | sequence, assignment, DAG, formal logic | reading order, symbol key, treatment/measurement timing, arrow meaning |

## Defaults

- Prefer point plus interval over bars for estimates.
- Order categories substantively; record reordering in QA.
- Use direct labels when they reduce legend lookup without collision.
- Keep uncertainty visually subordinate but legible.
- Share panel scales only when comparisons are meaningful; document free scales.
- Avoid dual axes unless units are a deterministic transform and the transform is explicit.
