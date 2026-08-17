# QA contract

Create a machine-readable QA record with these keys.

```yaml
target_journal:
artifact:
type:
source_files: []
input_rows:
output_rows:
missing_by_variable: {}
dropped_rows: 0
drop_reason:
factor_levels: {}
reference_categories: {}
transformations: []
model_formula:
variance_estimator:
confidence_level:
estimand:
dimensions_in: {width: null, height: null}
font_family:
minimum_font_pt:
legend_position:
gridlines:
decimal_places:
significance_legend:
black_white_checked: false
color_vision_checked: false
clipping_checked: false
overlap_checked: false
font_embedding_checked: false
code_status: reconstructed
warnings: []
```

## Invariants

- `input_rows - dropped_rows = output_rows` unless aggregation changes row meaning; then document it.
- Missing values, filters, joins, weights, transforms, and category reordering must be explicit.
- Confidence level and interval method must be identified.
- A model object may be formatted but not re-estimated unless authorized.
- `exact-source` is original author/publisher source. A translation is `adapted-source`; a new implementation from an image is `reconstructed`.
- A redraw slice must preserve values, row order, category order, labels, and missingness. If the input CSV is already the minimal slice and byte-for-byte preservation matters, pass it as `redraw_data_source`; otherwise document serialization-only changes such as quoting or printed precision.

## Visual checks

Render at final dimensions and inspect it. Check page/plot edges, long labels, panel balance, note wrapping, line visibility at 100%, grayscale separation, and minimum 7 pt text. Verify SVG/PDF are vector where possible and fonts are embedded or mapped to portable generic families.
