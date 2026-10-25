# Figure 5 — Geographic variation in mortgage denial rates (2025 HMDA)

This figure describes **unadjusted historical mortgage-action denial rates** in the eligible 2025 HMDA study cohort. It is **not** an evaluation of the fairness-aware DNN checkpoints, an estimate of causal discrimination, or a nationally representative estimate for all 2025 applications.

## Verified denominators

| Population | Eligible applications | Denials | Denial rate |
|---|---:|---:|---:|
| 50 states and Washington, DC | 2,024,489 | 143,268 | 7.08% |
| Full eligible study cohort | 2,034,914 | 148,538 | 7.30% |

The state-and-DC subset differs from the full eligible cohort because the latter includes records not assigned to the 50 states or DC. The subset rate is computed from pooled counts rather than the simple mean of state percentages.

## Selected observed state-level rates

- Florida: 11.5%
- Hawaii: 10.1%
- Mississippi: 10.0%
- Texas: 8.7%
- New York: 8.6%
- North Dakota: 3.5%

These are rounded descriptive values from the source state-summary CSV. In the original R session, the author checked that the aggregate rate equaled `100 * sum(denied) / sum(applications)` and that each state-level rate agreed with `100 * denied / applications` within numerical tolerance.

## Caption

**Figure 5.** Geographic variation in mortgage denial rates across the United States using 2,034,914 eligible applications from the 2025 HMDA study cohort. State-level rates are unadjusted, with an aggregate denial rate of 7.08% across the 50 states and Washington, DC, compared with 7.30% in the full eligible sample. Geographic differences should not be interpreted as evidence of causal discrimination.

## Availability and reproducibility

The anonymized PNG is named `Figure_5_Anonymous_JPENTAI.png` in the author's local R output folder `HMDA_State_Maps`; the accompanying state-level aggregate CSV is `HMDA_2025_State_Denial_Rates.csv`. These local files are **not uploaded by this documentation commit**. The publicly available repository cannot yet reproduce this figure from its archived materials alone. No borrower-level HMDA records should be uploaded.

The figure excludes the author's name and DOI for double-blind manuscript review; authorship and research-materials DOI belong in the repository metadata and separate editorial correspondence, not the reviewer-facing image.
