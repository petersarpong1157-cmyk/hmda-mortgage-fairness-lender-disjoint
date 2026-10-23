# Lender-Disjoint Evaluation of Fairness-Aware Mortgage Prediction

**Peter Sarpong** — Independent Researcher, Gaithersburg, Maryland 20886, USA  
**Contact:** peter.sarpong1157@gmail.com

## Scope and status

A transparency and reproducibility repository supporting the manuscript **“Lender-Disjoint Evaluation of Fairness-Aware Mortgage Prediction: Cross-Demographic Calibration Trade-offs and Reproducibility Challenges.”**

**Important:** This is a *partial research archive*, not an independently reproduced end-to-end training pipeline. The original development-sampling seed/procedure has not been recovered, and original training has not been independently reproduced. No verified DOI exists as of this update. The manuscript should not claim otherwise.

## Study design

2025 U.S. HMDA historical mortgage-action classification (action codes 1 originated and 2 approved but not accepted = non-denial; action 3 denied = denial). The filtered sample comprises **2,034,914 applications and 2,562 lenders**. Lender-disjoint frozen partitions: development train **1,530,103** (1,792 lenders), validation **260,348** (384 lenders), held-out test **244,463** (386 lenders). Preserved model-development subsets: **306,013** training and **78,237** validation applications.

Eligibility: conventional home-purchase first-lien principal-residence site-built properties with 1–4 units. Reverse mortgage, open-end-credit and business-purpose flags must each equal explicit code `2`; exemption code `1111` is **not** treated as “No.”

The fairness penalty targets **signed mean prediction residual difference between Black and White categories**. Reducing this difference does not certify lawful or equitable mortgage decisions.

## Primary DTI-inclusive findings

| Model | AUROC | Brier | Absolute Black–White residual gap (pp) |
|---|---:|---:|---:|
| Standard DNN | 0.781178 | 0.04134097 | 4.700813 |
| Fair DNN (λ=2) | 0.778376 | 0.04154263 | 3.853615 |

Targeted gap reduction: **0.847198 pp**, 95% paired lender-cluster bootstrap CI **[0.698907, 1.044830]**. Brier change: **+0.000201658**, 95% CI **[0.000003780, 0.000422651]**.

## DTI-excluded sensitivity experiment

This experiment reuses preserved development and lender-disjoint test partitions, excluding DTI-derived features and **newly training** two models per seed. It is *not* an exact rerun of the original training protocol.

| Seed | Absolute B–W gap reduction (pp) | 95% lender-cluster CI (pp) | Brier change |
|---|---:|---|---:|
| 101 | 0.859586 | [0.637569, 1.097172] | +0.000180213 |
| 202 | 1.130862 | [0.906620, 1.369856] | +0.001055975 |
| 303 | 1.444618 | [1.091556, 1.820440] | +0.001090796 |

Each seed's targeted-gap confidence interval excludes zero. Brier-change CI includes zero for seed 101 but not for seeds 202 or 303. Intervals are pointwise and conditional on frozen checkpoints.

## Missingness and complete-case evaluation

In held-out test data, missingness: income **1.805%**, loan term **0.062%**, state **0.629%**, DTI **2.389%**. Missing income/DTI differs across reported racial categories. Using the *same seed-101 trained models*, gap reduction remained **0.8202 pp** for complete cases without DTI and **0.8174 pp** when DTI completeness was also required. These are sample-restriction evaluations, **not retraining**.

## Repository organization

- [Results](results/VERIFIED_RESULTS.md) — transcribed, numerically checked summaries
- [Uploaded aggregate results](results/) — published aggregate CSV tables, including bootstrap, performance, demographic calibration, missingness and complete-case sensitivity; **no application-level records**
- [Study figures](./) — four one-page PDF figures (Figure_1 through Figure_4) at repository root
- [Local experiment manifest](docs/DTI_Excluded_Artifact_Manifest.csv) — filenames and hashes for locally archived artifacts, not the underlying files
- [Reproducibility](docs/REPRODUCIBILITY.md) — verification status and limitations
- [Local protocol inspection utility](R/inspect_local_training_metadata.R) — inspects recorded settings without exposing mortgage records
- [Experimental DTI training reconstruction](R/reconstructed_dti_excluded_training.R) — newly written, untested, with explicitly assumed loss/optimizer; **not** the original training implementation
- [DTI code-recovery status](docs/DTI_CODE_RECOVERY.md) — archived bootstrap evidence, differing CIs, and original-source limitations
- [Local bootstrap-draw audit script](R/verify_archived_bootstrap.R) — newly documented post-hoc check (requires private local replicate CSV)
- [Recorded R environment](docs/R_ENVIRONMENT.md) — observed package versions, not a complete dependency lock
- [Automated public-results check](.github/workflows/verify-public-results.yml) — runs the base-R internal-consistency script on relevant changes
- [HMDA data access](docs/DATA_ACCESS.md) — source and filter documentation
- [R audit and frozen-model inference scripts](R/) — supporting scripts, some requiring external protocol/checkpoint files
- [Public aggregate verification](R/verify_public_results.R) — base-R consistency checks on four published tables; run `Rscript R/verify_public_results.R` from the repository root
- [DTI-excluded feature verification](R/verify_feature_inventory.R) — confirms the ordered 67-feature inventory; optionally compares against the privately held `experiment_protocol.rds`
- [Local checkpoint integrity manifest](docs/ARTIFACT_CHECKSUMS.md)
- [Upload checklist](UPLOAD_CHECKLIST.md)
- [MIT license](LICENSE) — applies to original repository code/documentation where copyrightable; not third-party HMDA records
- [Manuscript text access copy](manuscript/HMDA_V8_readable_text.txt) — working draft; formatted DOCX not deposited
- [Citation metadata](CITATION.cff) — repository citation details without an unverified DOI

**Manuscript availability:** An author-authorized [plain-text access copy of the research draft](manuscript/HMDA_V8_readable_text.txt) is published here. This text extraction is not a substitute for the formatted Word manuscript, which is not yet deposited in GitHub. The manuscript is a working draft, not peer-reviewed publication. Four original R-generated PDF figures are publicly available at the repository root. Model checkpoints, frozen manifest and the **complete end-to-end training/source-data pipeline** are not deposited. Six supporting R scripts for manifest checks, preprocessing, inference and prediction verification have been deposited, but depend on files not present in this repository. Do not infer their public availability from this README.

## Citation, funding and interests

Author: Peter Sarpong (Independent Researcher). Funding: none. Competing interests: none declared. No DOI has yet been verified. Please cite the manuscript with its title and author until a legitimate publication record exists.

## Caution

These retrospective predictions reproduce historical HMDA action codes, not applicant creditworthiness or causal discrimination. This repository does **not** authorize use of its models for automated lending decisions.
