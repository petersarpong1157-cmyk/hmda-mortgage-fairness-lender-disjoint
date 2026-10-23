# Check locally archived HMDA DTI-excluded summary files without modifying them.
# Run: Rscript R/verify_sensitivity_outputs.R "C:/Users/peter/Downloads/HMDA_XAI_2025/DTI_Excluded_Sensitivity"
# Requires: data.table. Does NOT retrain models or recreate original data.

suppressPackageStartupMessages(library(data.table))
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 1L || !dir.exists(args[[1]]))
  stop("Pass the local DTI_Excluded_Sensitivity folder as the only argument")
root <- normalizePath(args[[1]], mustWork=TRUE)

needed <- c("dti_excluded_performance.csv",
            "dti_excluded_additional_seeds.csv",
            "Table_S4_DTI_Excluded_Three_Seed_Bootstrap.csv",
            "dti_excluded_test_predictions.csv",
            "dti_excluded_predictions_seed_202.csv",
            "dti_excluded_predictions_seed_303.csv")
p <- file.path(root, needed)
if (!all(file.exists(p))) stop("Missing inputs: ", paste(needed[!file.exists(p)], collapse=", "))

b <- fread(file.path(root,"Table_S4_DTI_Excluded_Three_Seed_Bootstrap.csv"))
stopifnot(all(c("Seed","Metric","Observed","CI_Lower","CI_Upper") %in% names(b)),
          nrow(b)==6L,
          setequal(b$Seed,c(101L,202L,303L)),
          all(is.finite(b$Observed)),
          all(b$CI_Lower<=b$CI_Upper))

expected <- data.table(
  Seed=rep(c(101L,202L,303L), each=2),
  Metric=rep(c("Gap_Reduction_pp","Brier_Change"),3),
  Expected=c(0.8595861387,0.0001802131,
             1.1308615482,0.0010559745,
             1.4446183523,0.0010907964))
check <- merge(b,expected,by=c("Seed","Metric"))
stopifnot(nrow(check)==6L,
          uniqueN(check,by=c("Seed","Metric"))==6L,
          max(abs(check$Observed-check$Expected))<1e-6)

for (s in c(101L,202L,303L)) {
  f <- if (s==101L) "dti_excluded_test_predictions.csv"
       else sprintf("dti_excluded_predictions_seed_%d.csv",s)
  x <- fread(file.path(root,f))
  stopifnot(nrow(x)==244463L,
            uniqueN(x$lei)==386L,
            all(x$denied %in% c(0,1)),
            !anyNA(x$lei), !anyNA(x$denied))
}

cat("PASS: Archived table structure, observed effects and saved prediction row/lender counts verified.\n")
cat("LIMIT: This is a local-file consistency check; it does not reproduce model training or audit individual application identities.\n")
