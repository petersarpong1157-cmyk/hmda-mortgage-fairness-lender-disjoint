
library(data.table)

base_dir <- Sys.getenv("HMDA_BASE_DIR", unset = getwd())

reproduced_path <- file.path(
  base_dir,
  "raw_reconstruction_audit",
  "standalone_four_model_predictions.csv"
)

saved_path <- file.path(
  base_dir,
  "final_test",
  "corrected_test_predictions_2025.csv"
)

stopifnot(
  file.exists(reproduced_path),
  file.exists(saved_path)
)

reproduced <- fread(reproduced_path)
saved <- fread(saved_path)

stopifnot(
  nrow(reproduced) == 244463L,
  nrow(saved) == 244463L
)

saved[, action_taken := as.character(action_taken)]
reproduced[, action_taken := as.character(action_taken)]

model_columns <- c(
  "xgboost",
  "standard_dnn",
  "fair_dnn_2",
  "fair_dnn_10"
)

compare_model <- function(model_name) {

  a <- saved[, .(
    lei,
    action_taken,
    probability = get(model_name)
  )]

  b <- reproduced[, .(
    lei,
    action_taken,
    probability = get(model_name)
  )]

  setorder(a, lei, action_taken, probability)
  setorder(b, lei, action_taken, probability)

  stopifnot(
    identical(a$lei, b$lei),
    identical(a$action_taken, b$action_taken)
  )

  differences <- abs(a$probability - b$probability)

  data.table(
    Model = model_name,
    Maximum_Difference = max(differences),
    Mean_Difference = mean(differences),
    Passed = all(is.finite(differences)) &&
      max(differences) <= 1e-5
  )
}

verification <- rbindlist(
  lapply(model_columns, compare_model)
)

print(verification)

output_path <- file.path(
  base_dir,
  "HMDA_Manuscript_Reproducibility",
  "standalone_inference_verification.csv"
)

fwrite(verification, output_path)

stopifnot(
  nrow(verification) == 4L,
  !anyNA(verification$Passed),
  all(verification$Passed)
)

cat("PASS: All four frozen model inference results verified.\n")
