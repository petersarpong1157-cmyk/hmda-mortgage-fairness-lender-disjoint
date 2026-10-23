# Post-hoc verification of archived seed-101 DTI-excluded bootstrap draws.
# This is newly documented verification code, NOT the original bootstrap generator.
# Usage: Rscript R/verify_archived_bootstrap.R /path/to/DTI_Excluded_Sensitivity
# Requires only base R. Original replicate draws are intentionally kept local.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L || !dir.exists(args[[1]]))
  stop("Supply the existing local DTI_Excluded_Sensitivity directory")
root <- normalizePath(args[[1]], mustWork = TRUE)
replicates <- read.csv(file.path(root, "dti_excluded_bootstrap_replicates.csv"))
summary <- read.csv(file.path(root, "dti_excluded_lender_bootstrap.csv"))
required <- c("Gap_Reduction_pp", "Brier_Change")
stopifnot(nrow(replicates) == 2000L,
          identical(names(replicates), required),
          all(is.finite(as.matrix(replicates))),
          all(c("Metric", "Observed", "CI_Lower", "CI_Upper",
                "CI_Excludes_Zero") %in% names(summary)),
          setequal(summary$Metric, required))
for (metric in required) {
  q <- as.numeric(quantile(replicates[[metric]], probs = c(.025, .975),
                           names = FALSE, type = 7))
  line <- summary[summary$Metric == metric, , drop = FALSE]
  stopifnot(nrow(line) == 1L,
            max(abs(q - c(line$CI_Lower, line$CI_Upper))) < 1e-9)
  excludes_zero <- q[1] > 0 || q[2] < 0
  stopifnot(identical(as.logical(line$CI_Excludes_Zero),
                      excludes_zero))
  cat(metric, ": archived percentile CI = [",
      format(q[1], digits = 9), ", ", format(q[2], digits = 9),
      "], verified\n", sep = "")
}
cat("PASS: Saved 2,000 seed-101 bootstrap draws reproduce the local")
cat(" lender-bootstrap summary by type-7 percentiles.\n")
cat("LIMIT: This does not reconstruct sampling, refit models, or explain")
cat(" differences from separately archived Table_S4 intervals.\n")
