# Reproducibility statement

## What was verified locally

- Raw-to-eligible *lender counts* matched the frozen manifest for each of 2,562 lenders. This does not prove exact identity of every eligible row.
- Four primary frozen model checkpoints were independently evaluated, matching archived probability multisets within lender/action groups with float tolerance. Original test prediction ordering was **not** fully recovered at unique application level.
- The separate DTI-excluded analysis trained λ=0 and λ=2 models at seeds 101, 202, 303; each evaluated 244,463 applications from 386 held-out lenders.
- Seed-specific held-out results were checked and 2,000 paired lender-cluster bootstrap replicates generated per seed.
- Seed-101 DTI-excluded predictions aligned with recovered test rows on available keys, not unique application IDs.
- Locally archived 14 sensitivity files passed existence, size, and MD5 inventory checks. The actual binaries are **not** provided in this repository.

## What has NOT been verified

- Original development-sampling algorithm and seed, original end-to-end training, clean-room execution of a complete pipeline
- Exact official HMDA source release/snapshot corresponding to local source ZIP
- Unique row-level original-prediction pairing; ethnicity-specific missingness for the recovered test extract
- Public availability of all model checkpoints and the full frozen lender manifest (the four original R-generated figures **are published**)

The newly trained DTI-excluded experiments used a separately specified optimization protocol. Differences between the original primary models and new models **cannot be assigned causally to DTI exclusion alone**.

## Interpretation

These are retrospective prediction and audit experiments. Fairness optimization of historical denial codes does not establish prospective creditworthiness, causal discrimination, or legal compliance. Pointwise seed-specific cluster bootstrap intervals condition on checkpoints and do not incorporate retraining uncertainty.

This repository is a *partial documentary and result-verification archive*; a full executable release requires depositing the reviewed analysis scripts, permitted inputs, preprocessing resources, model artifacts and locked package environment and then verifying a clean run.
## Published supporting R scripts (October 2026)

The `R/` directory includes saved manifest audits, final preprocessing, architecture and frozen-checkpoint inference/verification scripts. They are not standalone: set `HMDA_BASE_DIR` to the local project directory and supply `LOCKED_FINAL_PROTOCOL.rds`, checkpoints, frozen manifest and recovered test application files from an authorized local environment. Previous preprocessing variants were intentionally omitted; `03_preprocessing.R` is the final version handling both actual missing values and categorical `NA` text. No complete raw-cohort reconstruction or original end-to-end training release is claimed.

## Independently executable public verification

The public-table check `R/verify_public_results.R` uses only base R and four published aggregate CSV files. GitHub Actions successfully executed it on 2026-10-23: [verification run 40031779315](https://github.com/petersarpong1157-cmyk/hmda-mortgage-fairness-lender-disjoint/actions/runs/40031779315). It checks reported point estimates, related fairness and Brier-score differences, and consistency of bootstrap confidence-interval flags. This verifies **internal mathematical consistency only**; it does not regenerate bootstraps or reproduce original training or inference.

The saved local R package versions are listed in [R_ENVIRONMENT.md](R_ENVIRONMENT.md). A lockfile representing an independently verified end-to-end environment has not been published.
