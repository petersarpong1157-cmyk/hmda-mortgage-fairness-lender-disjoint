# Files required for a more complete research release

Already in repository: README, LICENSE (MIT), data-access and reproducibility notes, four original PDF figures at repository root, aggregate results tables in `results/`, and the local artifact checksum manifest in `docs/`. The application-level prediction files are intentionally excluded.

**Manuscript policy:** The author will **not upload the manuscript** to this repository. This is intentional, not an outstanding upload task.

Still **not uploaded**:
- Full executable **raw cohort construction and split-generation code** (the uploaded 01 and 02 scripts only verify an existing manifest). Preprocessing, recovered DNN architecture, frozen inference and prediction verification scripts **are now uploaded**.
- Frozen lender manifest (not published); additional reviewed numeric results only if necessary and appropriate to distribute
- DTI-excluded training and bootstrap R scripts saved as durable files, rather than only RStudio session functions
- Six DTI-excluded model checkpoints and any other pretrained weights (publish only after auditing file sizes, licensing, and contents)
- A locked R package environment / `renv.lock`; clean-room run verification
- Verified official source HMDA snapshot/release metadata

Do not upload the massive raw HMDA LAR, application-level extracts, secrets, RStudio histories, or local personal paths. If distributing trained checkpoints, use appropriately documented versioned releases.

When files are deposited, update the README wording and rerun reproducibility checks. No DOI exists until a legitimate archival release is deposited and verified.
