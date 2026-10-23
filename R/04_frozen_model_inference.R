# Requires local checkpoints, recovered records and LOCKED_FINAL_PROTOCOL.rds; not distributed here.

library(data.table)
library(Matrix)
library(torch)
library(xgboost)

base_dir <- Sys.getenv("HMDA_BASE_DIR", unset = getwd())
script_dir <- file.path(base_dir, "R")
audit_dir <- file.path(base_dir, "raw_reconstruction_audit")

source(file.path(script_dir, "03_preprocessing.R"))
source(file.path(script_dir, "04a_original_dnn_architecture.R"))

# Load the archived test applications
test_path <- file.path(
  audit_dir, "recovered_hmda_test_applications.rds"
)

stopifnot(file.exists(test_path))

hmda_test <- readRDS(test_path)

stopifnot(
  nrow(hmda_test) == 244463L,
  data.table::uniqueN(hmda_test$lei) == 386L
)

# Reconstruct the common 88-column feature representation
X <- prepare_hmda_features(hmda_test)

stopifnot(
  inherits(X, "dgCMatrix"),
  identical(dim(X), c(244463L, 88L)),
  identical(colnames(X), pp$feature_names)
)

# Check the four frozen checkpoint files
models <- c(
  "xgboost_dti_only.json",
  "robust_dnn_seed_101_lambda_0.pt",
  "robust_dnn_seed_101_lambda_2.pt",
  "fair_dnn_lambda_10.pt"
)

model_paths <- file.path(base_dir, models)
stopifnot(all(file.exists(model_paths)))

# Predict with a frozen DNN, in batches
load_frozen_dnn <- function(filename) {
  net <- dnn(88)
  net$load_state_dict(
    torch_load(file.path(base_dir, filename))
  )
  net$eval()
  net
}

predict_frozen_dnn <- function(net, X, batch_size = 2048L) {

  result <- numeric(nrow(X))

  with_no_grad({
    for (start in seq.int(
      1L, nrow(X), by = batch_size
    )) {

      finish <- min(start + batch_size - 1L, nrow(X))
      idx <- start:finish

      dense_batch <- as.matrix(
        X[idx, , drop = FALSE]
      )

      tensor <- torch_tensor(
        dense_batch,
        dtype = torch_float()
      )

      result[idx] <- as.numeric(
        torch_sigmoid(net(tensor))$
          reshape(c(-1))$
          to(device = "cpu")
      )
    }
  })

  result
}

standard <- load_frozen_dnn(models[2])
fair2 <- load_frozen_dnn(models[3])
fair10 <- load_frozen_dnn(models[4])

p_standard <- predict_frozen_dnn(standard, X)
p_fair2 <- predict_frozen_dnn(fair2, X)
p_fair10 <- predict_frozen_dnn(fair10, X)

cat("PASS: Frozen DNN predictions regenerated.\n")

# XGBoost: restore unscaled numerical values
X_xgb <- X

numeric_vars <- c(
  "loan_amount", "income", "loan_term"
)

for (v in numeric_vars) {

  mu <- pp$numeric_scaling[
    Variable == v, Mean
  ]

  sigma <- pp$numeric_scaling[
    Variable == v, SD
  ]

  stopifnot(length(mu) == 1L, length(sigma) == 1L)

  X_xgb[, v] <- X_xgb[, v] * sigma + mu
}

xgb_model <- xgb.load(model_paths[1])

dtest <- xgb.DMatrix(
  data = X_xgb,
  missing = NA
)

# Frozen XGBoost checkpoint predicts approval,
# so convert probabilities to historical denial.
p_xgb <- 1 - predict(xgb_model, dtest)

cat("PASS: Frozen XGBoost predictions regenerated.\n")

result <- data.table(
  lei = as.character(hmda_test$lei),
  action_taken = as.character(hmda_test$action_taken),
  xgboost = p_xgb,
  standard_dnn = p_standard,
  fair_dnn_2 = p_fair2,
  fair_dnn_10 = p_fair10
)

stopifnot(
  nrow(result) == 244463L,
  all(vapply(
    result[, .(
      xgboost, standard_dnn,
      fair_dnn_2, fair_dnn_10
    )],
    function(p) {
      all(is.finite(p) & p >= 0 & p <= 1)
    },
    logical(1)
  ))
)

output_path <- file.path(
  audit_dir,
  "standalone_four_model_predictions.csv"
)

if (file.exists(output_path)) {
  stop("Output already exists; refusing to overwrite.")
}

fwrite(result, output_path)

cat("PASS: Four-model standalone inference completed.\n")
cat("Output:", output_path, "\n")
