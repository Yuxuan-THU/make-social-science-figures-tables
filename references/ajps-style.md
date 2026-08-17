# AJPS profile

This profile implements AJPS *Guidelines for Figures and Tables in Final Drafts*, updated April 9, 2026. These rules override older author-specific choices seen in published samples.

## Figures — hard requirements

- Use a short, descriptive, meaningful title that does not state a conclusion.
- Do not use background gridlines.
- Spell out words in titles, axes, values, and legends; define unavoidable acronyms in the note.
- Capitalize only the first word of panel labels, axis labels, value labels, and legend labels.
- Use black text, never gray, and do not use italics.
- Use portrait orientation and about one text line between tick labels and an axis title.
- Use one consistent font family and size across all figures.
- Put legends below the whole figure or inside it, never at the side; do not draw a legend box.
- Multi-panel labels are short and descriptive, preceded by `(a)`, `(b)`, etc., and centered over the plotting region. Panels are equal size and balanced.
- Use one shared legend when possible. Put panel-specific legends inside or directly below their panels.

Default implementation: white background, black axes/text, no grids, 8.5–9 pt sans-serif labels, 0.55 pt axes, 0.45–0.65 pt intervals, and shape/line-type redundancy. These numeric values are corpus-derived defaults, not textual mandates.

## Tables — hard requirements

- Use a meaningful title that does not state a conclusion.
- Spell out labels and headers; define unavoidable acronyms in the note.
- Significance legend must be exactly `†p < .10; *p < .05; **p < .01.` Do not mark smaller thresholds or use `***`.
- Use the same decimal precision throughout, normally hundredths or thousandths, including terminal zeros.
- Put standard errors immediately beneath coefficients.
- Capitalize only the first word of column headers and row labels.
- Include an explanatory note so the table stands alone.
- Do not use panels inside a table; split them into separate tables.
- Do not use italics.
- Left-align headings above text, center headings above numeric entries, left-align text, center whole numbers, and align decimals.
- Separate heading levels with space and center broad headings over subheadings.

## QA failures

Fail validation for any gridline, gray text, side legend, boxed legend, italics, table panels, inconsistent decimals, SEs not directly below estimates, unexplained abbreviation, or significance legend other than the prescribed three symbols.
