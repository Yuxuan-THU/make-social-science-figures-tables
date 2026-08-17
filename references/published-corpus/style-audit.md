# APSR/AJPS figure and table style audit

## Evidence boundary

This audit separates official requirements from recurring author/production choices. The local corpus contains 100 formally published main-text excerpts from 29 papers: 25 figures and 25 tables from each journal. The sample is mainly 2021–2026. Font inspection used embedded PDF font metadata; layout measurements were checked at publication-page scale. Exact font sizes and stroke widths sometimes vary by author and publisher conversion, so the numeric defaults below are implementation ranges rather than journal rules.

## Official AJPS rules (April 9, 2026)

- Figures: no background gridlines; all text black; no italics; words spelled out; sentence-style capitalization for panels, axes, values, and legends; portrait orientation; legends below or inside, never at the side or boxed; balanced equal-size panels.
- Tables: standard errors directly below coefficients; one decimal precision throughout; decimals aligned; no table panels or italics; explanatory note required; exact significance legend `†p < .10; *p < .05; **p < .01.` with no `***` tier.

## Official APSA/APSR rules

- `Table`/`Figure` plus an Arabic numeral and headline-style title, numbered in order of first mention.
- Figures and tables must stand alone, explain symbols/patterns, preserve black-and-white readability, and credit external sources.
- Table stubs/column heads use sentence-style capitalization; probability/significance notes follow substantive notes.
- APSR reproducibility packages must make every table and figure locatable in the code and output.

## Corpus-derived figure defaults

| Feature | APSR evidence/default | AJPS evidence/default |
|---|---|---|
| Typeface | Recent Cambridge production frequently embeds Noto Sans; author graphics also use Arial/Helvetica. Use portable `sans`. | Article text is Times/serif; figure labels frequently use Helvetica/Arial/sans. Use portable `sans`. |
| Label size | Usually visually equivalent to 8–10 pt at final width; never below 7 pt. | 8.5–9 pt is a reliable default; keep identical across figures. |
| Stroke | Axes/rules about 0.45–0.70 pt; CI strokes about 0.45–0.65 pt; reference lines visually distinct. | 0.45–0.60 pt axes and intervals; black zero/reference lines; use line type/shape redundancy. |
| Background | White or restrained light-gray major guides; author choice varies. | White with no grid, per official rule. |
| Color | Mostly black/gray plus one restrained accent; maps may use broader palettes. Always test grayscale. | Black text; data color may be used sparingly, with grayscale/shape redundancy. |
| Legend | Bottom or inside is the safest cross-sample choice. | Bottom or inside only; never side/boxed. |
| Panels | Short labels, balanced layout, aligned scales when comparison is intended. | `(a)`, `(b)` sentence-style labels centered over equal-size panels. |
| Size | Full width about 6.5 in; 4.4–5.2 in high for ordinary plots, taller for dense forests/maps. | Default 6.5 × 7.2 in portrait; reduce width before violating portrait orientation. |

## Corpus-derived table defaults

- Serif table typography at the manuscript font size, normally 8.5–10 pt after final placement.
- `booktabs` structure: top rule, header/body rule, bottom rule; no vertical rules; partial rules only for column groups.
- Coefficients above parenthesized standard errors; model information and observations separated by a midrule.
- Consistent hundredths or thousandths and decimal alignment with `siunitx`.
- General explanatory note first, then design/variance details and significance legend last.
- Use table width/label wrapping before font scaling. Split tables that cannot remain legible.

## Implemented profiles

The installed skill uses these ranges in `theme_apsr()`, `theme_ajps()`, `save_polisci_figure()`, `table_apsr()`, and `table_ajps()`. The original publication excerpts stay in this local corpus and are not included in the portable skill archive.
