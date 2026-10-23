# Synthetic unit/smoke tests for the EXPERIMENTAL reconstruction.
# Run from repo root: Rscript R/test_reconstructed_training.R
# Requires R torch and a working libtorch installation; no HMDA records.
source("R/reconstructed_dti_excluded_training.R")
set.seed(101L)
make_data <- function(n) {
  list(X = matrix(rnorm(n*67L), nrow=n, ncol=67L),
       y = sample(c(0,1), n, replace=TRUE),
       race = rep(c("White","Black or African American"), length.out=n))
}
tr <- make_data(120L)
va <- make_data(64L)
# Check invalid input is rejected.
bad <- tr
bad$X <- bad$X[, -67L, drop=FALSE]
stopifnot(inherits(try(check_reconstruction_data(bad,"bad"),silent=TRUE),"try-error"))
# Miniature model run checks early-stopping bounds and output integrity.
fit <- train_reconstructed_dti(
  tr, va, lambda=2, seed=101L, batch_size=32L,
  lr=0.001, max_epochs=5L, patience=2L
)
h <- fit$history
stopifnot(nrow(h)>=1L,nrow(h)<=5L,
          all(is.finite(h$train_loss)),
          all(is.finite(h$validation_brier)),
          all(h$validation_brier>=0 & h$validation_brier<=1),
          fit$best_epoch %in% h$epoch,
          abs(fit$best_validation_brier-min(h$validation_brier))<1e-9)
# Separately confirm penalty direction and differentiability on tensor examples.
logits <- torch::torch_tensor(matrix(c(0.2,-0.4,0.3,-0.1),ncol=1),
                              dtype=torch::torch_float(),requires_grad=TRUE)
y <- torch::torch_tensor(matrix(c(1,0,1,0),ncol=1),dtype=torch::torch_float())
resid <- torch::torch_sigmoid(logits)-y
gap <- resid[c(1,3),]$mean()-resid[c(2,4),]$mean()
penalty <- gap$pow(2)
stopifnot(is.finite(as.numeric(penalty$item())),
          as.numeric(penalty$item())>=0)
penalty$backward()
stopifnot(all(is.finite(as.numeric(logits$grad))))
cat("PASS: Synthetic training, bounds and penalty-gradient smoke checks.\n")
cat("LIMIT: No check of historic fairness formula or exact retraining.\n")
