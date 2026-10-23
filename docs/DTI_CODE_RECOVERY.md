# DTI-excluded code recovery and bootstrap evidence

## What is recoverable

The locally archived `dti_excluded_bootstrap_replicates.csv` has **2,000 rows**
and columns `Gap_Reduction_pp`, `Brier_Change`. Its R type-7 2.5% and
97.5% quantiles reproduce the separate
`dti_excluded_lender_bootstrap.csv` summary for seed 101:

| Metric | Lower | Upper |
|---|---:|---:|
| Gap reduction (percentage points) | 0.644236 | 1.096519 |
| Brier change | -0.000030 | 0.000432 |

The seed-101 confidence intervals in the separately archived
`Table_S4_DTI_Excluded_Three_Seed_Bootstrap.csv` are **not identical**
([0.637569, 1.097172] and [-0.0000287, 0.0004422], respectively).
The available aggregate files do not establish why the estimates differ
(e.g., alternative bootstrap run/seed). They should **not** be conflated.

Run `Rscript R/verify_archived_bootstrap.R /path/to/DTI_Excluded_Sensitivity`
locally to verify the archived replicate summary. The replicate file is
not published here and the script is **new post-hoc verification code**,
not the original bootstrap-generation function.

## Training-code recovery status

The six archived DTI-excluded `.pt` weights, training history, and
`experiment_protocol.rds` are preserved locally. They are **not**
original training source code. The exact training and resampling source
was not deposited in this repository. We do not infer implementation
details from checkpoint names, and we do not label an invented retraining
pipeline as the historical analysis.

The protocol is an R-specific binary RDS file. It must be inspected
with `readRDS()` on a trusted machine before any new training
implementation can be mapped to its fields. Avoid publishing individual
applications, lender IDs, or other record-level predictions.

For publication, report sensitivity confidence intervals from the
pre-specified verified analysis output and transparently document any
separately archived local bootstrap experiments.

## Seed-101 saved experiment protocol (author-inspected RDS)

The author inspected `experiment_protocol.rds` in R using
`str(protocol, max.level = 3)` and reported these recorded settings:

| Field | Recorded value |
|---|---|
| Experiment | DTI-excluded sensitivity |
| Seed | 101 |
| Batch size | 1,024 |
| Learning rate | 0.001 |
| Maximum epochs | 25 |
| Early-stopping patience | 5 |
| Model selection metric | Validation Brier |
| Feature vector length | 67 |
| Fairness penalty lambdas | 0 and 2 |
| Selected best epoch (standard, lambda 0) | 14 |
| Selected best epoch (fair, lambda 2) | 19 |
| Original development sampling reused | TRUE |

The author subsequently supplied the complete ordered list of 67 names, now archived in [dti_excluded_seed101_feature_names.csv](dti_excluded_seed101_feature_names.csv). It contains three numerical terms, nine age indicator terms and 55 state-code indicator terms. This records the **feature names and their order**, but does not independently establish factor-reference levels, scaling values, or encoded matrix equivalence.
This is a verified **protocol inventory**, not a recovered training script.
The RDS extract does not specify all choices necessary to reproduce the
historical fit, including optimizer configuration beyond the learning rate,
loss/fairness implementation, initialization and batching order. Do not
attribute those details to the protocol without further evidence.

To compare the public feature list with the local protocol:

```r
published <- read.csv("docs/dti_excluded_seed101_feature_names.csv", check.names = FALSE)
stopifnot(identical(published$feature_name, protocol$feature_names))
```

Keep the original RDS local until its metadata and suitability for public
release have been reviewed.

## Local feature-list cross-check

On 2026-10-23, the author downloaded the published feature CSV from this repository directly into RStudio and ran `identical(published$feature_name, protocol$feature_names)` against the locally loaded `experiment_protocol.rds`. The comparison passed for all 67 features in the saved order. This is author-reported local verification, **not** an independent replication of feature engineering or training.

## Experimental training reconstruction (not historical source)

`R/reconstructed_dti_excluded_training.R` is a **new hypothetical
implementation**, provided as a starting point for a separate reproducibility
experiment. The original optimization code was not found in saved R scripts,
the project `.Rhistory`, or the home-directory R history. The author-confirmed
seed-101 protocol records batch size 1024, learning rate 0.001, up to 25 epochs,
patience 5, validation Brier selection, lambda values 0/2 and 67 features.

**Unverified implementation choices:** Adam optimization; binary
cross-entropy with logits; squared Black-minus-White mean prediction
residual difference as the penalty; epoch-wise random shuffling;
mini-batch rather than full-dataset penalty; initialization and the
precise early-stopping tolerance. The 64/32 hidden-layer layout mirrors
a previously recovered DNN architecture, but matching the historic
DTI-excluded network is not independently established.

The script is **untested end-to-end**, requires locally prepared
67-column design matrices and aligned binary outcomes and race labels,
and must not be used to regenerate published statistics unless
its outputs and assumptions have been independently validated.
Published seed-101 weights and results were **not** produced with this
newly written code. No manuscript or application-level inputs are
distributed. It is research-only, not a lending-decision system.

## Author-run synthetic smoke test (October 23, 2026)

The author executed the newly written `R/reconstructed_dti_excluded_training.R` with synthetic inputs (2,000 training observations, 500 validation observations, 67 numeric columns, binary artificial outcomes and randomly assigned Black/White category labels). Lambda was 2, seed 101, mini-batch size 1,024, learning rate 0.001, and the test was limited to three epochs. The author reported:

| Epoch | Training loss | Validation Brier |
|---|---:|---:|
| 1 | 0.6953884 | 0.2508667 |
| 2 | 0.6970546 | 0.2507178 |
| 3 | 0.6964214 | 0.2504913 |

Best selected epoch: 3; best validation Brier: 0.2504913. This is **author-reported functional execution evidence**, not a controlled independent rerun. It does not verify fairness-penalty correctness, reproducibility across systems, or equivalence to original HMDA training. No synthetic or application-level input records were uploaded.

## Additional reconstruction smoke-test script

`R/test_reconstructed_training.R` exercises the new hypothetical training implementation on synthetic inputs, checks rejection of incorrectly sized feature matrices, verifies basic bounds for early-stopping outputs, and tests that a sample squared residual-gap penalty has a finite gradient. Run locally from the cloned repository root with R `torch` and libtorch available:

```sh
Rscript R/test_reconstructed_training.R
```

This script was **published but not executed independently at the time it was added**. Its explicit penalty-gradient check is a limited numerical smoke test, not a proof that the original fairness-loss implementation was recovered or that training is statistically equivalent to the archived models.
