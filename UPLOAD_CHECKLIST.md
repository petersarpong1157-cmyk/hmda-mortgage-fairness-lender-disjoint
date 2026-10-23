# Files required for a more complete research release

Already in repository: README, LICENSE (MIT), data-access and reproducibility notes, results summary.

**Manuscript policy:** The author will **not upload the manuscript** to this repository. This is intentional, not an outstanding upload task.

Still **not uploaded**:
- Original four R-produced PDF figures
- Original preprocessing and inference scripts, model architecture, cohort-building and manifest-audit scripts
- Frozen lender manifest and reviewed numeric result CSVs (if permissible to distribute)
- DTI-excluded training and bootstrap R scripts saved as durable files, rather than only RStudio session functions
- Six DTI-excluded model checkpoints and any other pretrained weights (publish only after auditing file sizes, licensing, and contents)
- A locked R package environment / `renv.lock`; clean-room run verification
- Verified official source HMDA snapshot/release metadata

Do not upload the massive raw HMDA LAR, application-level extracts, secrets, RStudio histories, or local personal paths. If distributing trained checkpoints, use appropriately documented versioned releases.

When files are deposited, update the README wording and rerun reproducibility checks. No DOI exists until a legitimate archival release is deposited and verified.
