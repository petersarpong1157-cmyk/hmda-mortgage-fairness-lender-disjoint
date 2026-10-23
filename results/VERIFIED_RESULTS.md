# Verified numerical results (transcribed from executed R output)

No application-level records or unverifiable inference claims are included.

## Cohort and held-out models

- Eligible cohort: 2,034,914 HMDA applications, 2,562 lenders.
- Held-out lender-disjoint test: 244,463 applications, 386 lenders.
- Primary model evaluation:

| Model | AUROC | Average precision (non-interpolated tie-grouped) | Brier | Signed B–W residual gap, pp | Absolute B–W gap, pp |
|---|---:|---:|---:|---:|---:|
| XGBoost DTI | 0.7946865 | 0.4801342 | 0.04155145 | -4.833122 | 4.833122 |
| Standard DNN | 0.7811777 | 0.4805096 | 0.04134097 | -4.700813 | 4.700813 |
| Fair DNN λ=2 | 0.7783757 | 0.4790210 | 0.04154263 | -3.853615 | 3.853615 |
| Fair DNN λ=10 | 0.7706760 | 0.4655044 | 0.04304716 | -2.266283 | 2.266283 |

Primary λ=2 minus standard: absolute gap reduction **0.8471981631 percentage points** (95% lender-cluster bootstrap CI **[0.6989072, 1.0448299769]**); Brier change **+0.0002016577** (CI **[0.000003780076, 0.0004226513]**); 1,000 paired lender-level replicates.

## Simultaneous subgroup inference

Among 14 selected demographic group comparisons, only the Black or African American group's improvement remained positive under the simultaneous 95% CI: **+0.95760428 pp**, simultaneous CI **[0.2393432, 1.6758654]**. The other 13 simultaneous intervals included zero. Pointwise intervals shown in Figure 4, if present in a manuscript, must not be misinterpreted as simultaneous.

## DTI-excluded three-seed sensitivity

Newly trained standard (λ=0) and fairness (λ=2) DNNs, with separate explicitly documented training protocol and the same preserved lender-disjoint test partition. 2,000 paired lender-cluster bootstrap replicates per seed, pointwise intervals.

| Seed | Standard Brier | Fair Brier | B–W gap reduction, pp | 95% gap CI, pp | Brier change | 95% Brier CI |
|---|---:|---:|---:|---|---:|---|
| 101 | 0.05338661 | 0.05356683 | 0.8595861387 | [0.6375689, 1.0971719752] | +0.0001802131 | [-0.00002874272, 0.0004421921] |
| 202 | 0.05280460 | 0.05386057 | 1.1308615482 | [0.9066199, 1.3698558971] | +0.0010559745 | [0.0007428423, 0.0014743260] |
| 303 | 0.05290528 | 0.05399608 | 1.4446183523 | [1.091556, 1.8204395918] | +0.0010907964 | [0.0008276742, 0.0014138237] |

Seed 101 best validation epochs: standard 14 (Brier 0.06554644), fair 19 (0.06595842). Seeds 202: standard 23, fair 17. Seeds 303: standard 17, fair 12.

## Missingness

Held-out sample N=244,463:

| Predictor | Missing | Percent |
|---|---:|---:|
| Loan amount | 0 | 0 |
| Income | 4,412 | 1.80477209 |
| Loan term | 152 | 0.06217710 |
| Applicant age | 0 | 0 |
| State | 1,537 | 0.62872500 |
| DTI | 5,839 | 2.38850051 |

Under the seed-101 **saved models without retraining**, N=238,459 complete non-DTI predictor cases: B–W gap reduction **0.8201520 pp**, Brier change **+0.0002634459**. Requiring DTI completeness too, N=235,185: reduction **0.8174329 pp**, Brier change **+0.0002612460**.

Selected descriptive race-specific missingness: Asian N=24,794 income 3.944503%, DTI 4.694684%; White N=168,348 income 1.575902%, DTI 2.023784%; Black/African American N=10,685 income 1.506785%, DTI 2.442677%. These differences are not evidence of causal discrimination.

## Inference limits

Intervals are conditional on trained checkpoints and lender-cluster resampling. The 3 training seeds are not a population-level training-uncertainty confidence interval. Original training pipeline and exact official HMDA release remain incompletely reconstructed. The study predicts historical decision labels, not mortgage creditworthiness or legal compliance.
