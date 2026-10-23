# Standalone consistency audit of PUBLIC aggregate results (base R only).
# Run from repository root: Rscript R/verify_public_results.R
# This does NOT retrain models or independently reproduce raw HMDA analysis.

locate_root <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args)) return(normalizePath(args[[1]], mustWork = TRUE))
  normalizePath(".", mustWork = TRUE)
}
root <- locate_root()
read_result <- function(filename) {
  p <- file.path(root, "results", filename)
  if (!file.exists(p)) stop("Missing public result: ", p)
  read.csv(p, stringsAsFactors = FALSE, check.names = FALSE)
}
close_to <- function(x, y, tol = 1e-7) {
  stopifnot(length(x) == length(y), all(is.finite(x)),
            all(abs(x - y) < tol))
}

perf <- read_result("performance_metrics_audit.csv")
gaps <- read_result("corrected_black_white_gaps.csv")
boot <- read_result("final_lender_cluster_bootstrap.csv")
sensitivity <- read_result("Table_S4_DTI_Excluded_Three_Seed_Bootstrap.csv")

stopifnot(nrow(perf) == 4, nrow(gaps) == 4,
          setequal(perf$Model, gaps$Model),
          all(perf$AUROC >= 0 & perf$AUROC <= 1),
          all(perf$Brier >= 0 & perf$Brier <= 1),
          all(gaps$Absolute_Gap_pp >= 0))
close_to(gaps$Absolute_Gap_pp, abs(gaps$Black_White_Gap_pp))

gap <- setNames(gaps$Absolute_Gap_pp, gaps$Model)
brier <- setNames(perf$Brier, perf$Model)
observed_reduction <- unname(gap["standard_dnn"] - gap["fair_dnn_2"])
observed_brier <- unname(brier["fair_dnn_2"] - brier["standard_dnn"])
i_gap <- which(boot$Metric == "Reduction in absolute B-W gap (pp)")
i_brier <- which(boot$Metric == "Fair DNN minus standard Brier")
stopifnot(length(i_gap) == 1L, length(i_brier) == 1L)
close_to(observed_reduction, boot$Observed[i_gap])
close_to(observed_brier, boot$Observed[i_brier])
stopifnot(all(boot$CI_Lower <= boot$Observed &
              boot$Observed <= boot$CI_Upper))

stopifnot(nrow(sensitivity) == 6L,
          setequal(sensitivity$Seed, c(101L, 202L, 303L)),
          setequal(sensitivity$Metric, c("Gap_Reduction_pp", "Brier_Change")),
          all(sensitivity$CI_Lower <= sensitivity$Observed),
          all(sensitivity$Observed <= sensitivity$CI_Upper))
ci_excludes_zero <- sensitivity$CI_Lower > 0 | sensitivity$CI_Upper < 0
stopifnot(identical(as.logical(sensitivity$CI_Excludes_Zero),
                    as.logical(ci_excludes_zero)))

cat("PASS: Public aggregate-table internal consistency checks.\n")
cat("LIMITATION: Checks do not independently rerun statistical analyses,\n",
    "reconstruct individual applications, or reproduce model training.\n", sep = "")
