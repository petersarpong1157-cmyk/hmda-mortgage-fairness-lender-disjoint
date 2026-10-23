# Inspect locally saved DTI-excluded training metadata without publishing records.
# Run: Rscript R/inspect_local_training_metadata.R /path/to/experiment_protocol.rds
# Base R only. This is a metadata audit, not original training code.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L || !file.exists(args[[1]]))
  stop("Supply the local experiment_protocol.rds path as one argument")
protocol <- readRDS(args[[1]])
if (!is.list(protocol)) stop("Expected a list in the protocol RDS")
cat("Protocol field names:\n")
print(names(protocol))
expected <- c("experiment","seed","batch_size","learning_rate",
              "maximum_epochs","patience","selection_metric","feature_names",
              "lambda_values","standard_best_epoch","fair_best_epoch",
              "original_sampling_reused")
cat("Expected fields present: ", all(expected %in% names(protocol)), "\n", sep="")
if (all(expected %in% names(protocol))) {
  cat("Experiment: ", protocol$experiment, "\n", sep="")
  cat("Seed: ", protocol$seed, "\n", sep="")
  cat("Features: ", length(protocol$feature_names), "\n", sep="")
  cat("Lambdas: ", paste(protocol$lambda_values, collapse=", "), "\n", sep="")
  cat("Training metadata fields supplied: ", length(names(protocol)), "\n", sep="")
}
cat("\nFields NOT established by this inventory may include optimizer type,\n",
    "weight decay, loss/fairness formula, batching order, initialization,\n",
    "and exact preprocessing execution details. Do not assume values.\n", sep="")
cat("No individual HMDA records, model weights, or local paths were exported.\n")
