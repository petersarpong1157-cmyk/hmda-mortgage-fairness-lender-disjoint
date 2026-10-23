# Recorded local R environment (not a lockfile)

The author-provided `R_session_info(2).txt` recorded:

- R 4.5.2 (2025-10-31 ucrt), x86_64 Windows 11
- data.table 1.17.8
- Matrix 1.7-6
- torch 0.17.0
- xgboost 3.2.1.1
- pROC 1.19.1
- arrow 25.0.1
- ggplot2 4.0.3

These were the observed package versions in one saved local session,
**not a verified complete dependency lockfile**. They do not prove that
all original training was run under precisely these packages.

## Public-table verification

The workflow `.github/workflows/verify-public-results.yml` uses R 4.5.2
and runs `Rscript R/verify_public_results.R`. This script needs only base R,
reads the published CSV result tables, and verifies selected arithmetic and
confidence-interval indicator consistency. It cannot recreate bootstrap
samples, fit models, or regenerate unpublished record-level inputs.

To test locally after cloning:

```sh
Rscript R/verify_public_results.R
```

RStudio / Windows users can also run `source("R/verify_public_results.R")`
from the repository root. The script accepts the project root as an optional
command-line argument.

The original models require privately held and separately managed saved
protocol resources, model checkpoints, and HMDA research inputs. Do not
interpret CI success as end-to-end independent replication.
