# Verify the published DTI-excluded seed-101 feature-name inventory.
# Run from repo root: Rscript R/verify_feature_inventory.R
# Optional local comparison: Rscript R/verify_feature_inventory.R /path/to/experiment_protocol.rds
# No individual HMDA applications are read by this script.

args <- commandArgs(trailingOnly = TRUE)
p <- "docs/dti_excluded_seed101_feature_names.csv"
if (!file.exists(p)) stop("Run from repository root; missing ", p)
tab <- read.csv(p, stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(identical(names(tab), c("position", "feature_name")),
          nrow(tab) == 67L,
          identical(tab$position, seq_len(67L)),
          !anyNA(tab$feature_name),
          !anyDuplicated(tab$feature_name),
          identical(tab$feature_name[1:3], c("loan_amount", "income", "loan_term")),
          sum(startsWith(tab$feature_name, "applicant_age")) == 9L,
          sum(startsWith(tab$feature_name, "state_code")) == 55L,
          !any(grepl("debt_to_income|^dti", tab$feature_name,
                     ignore.case = TRUE)))
if (length(args) > 1L) stop("At most one protocol .rds argument expected")
if (length(args) == 1L) {
  protocol <- readRDS(args[[1]])
  stopifnot(identical(tab$feature_name, protocol$feature_names),
            identical(as.integer(protocol$seed), 101L),
            identical(as.numeric(protocol$lambda_values), c(0, 2)))
  cat("PASS: Public feature list exactly matches supplied local protocol.\n")
} else {
  cat("PASS: Public seed-101 67-feature inventory structural checks.\n")
}
cat("LIMIT: No model retraining, dataset preprocessing or feature-matrix equality test.\n")
