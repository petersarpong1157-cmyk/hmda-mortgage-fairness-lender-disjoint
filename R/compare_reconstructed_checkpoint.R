# Compare an EXPERIMENTAL reconstructed fit with a saved DTI-excluded checkpoint.
# This is a new diagnostic, NOT reproduction of the historic training process.
# Run from repository root after preparing local 67-column inputs:
# source("R/compare_reconstructed_checkpoint.R")
# compare_reconstructed_checkpoint(reconstructed_fit, saved_model, X)
# reconstructed_fit: result from train_reconstructed_dti()
# saved_model: a loaded, eval-mode torch model with a compatible architecture
# X: same synthetic or locally permitted 67-column numeric design matrix
# Checkpoint weights and row-level predictions are NEVER written by this utility.

suppressPackageStartupMessages(library(torch))

predict_dti_tensor_model <- function(net, X, batch_size = 1024L) {
  stopifnot(is.matrix(X),is.numeric(X),ncol(X)==67L,
            nrow(X)>0L,all(is.finite(X)),batch_size>0L)
  net$eval()
  p <- numeric(nrow(X))
  with_no_grad({
    for (start in seq.int(1L,nrow(X),by=batch_size)) {
      rows <- start:min(start+batch_size-1L,nrow(X))
      xx <- torch_tensor(X[rows,,drop=FALSE],dtype=torch_float())
      p[rows] <- as.numeric(torch_sigmoid(net(xx))$reshape(c(-1)))
    }
  })
  stopifnot(all(is.finite(p) & p>=0 & p<=1))
  p
}

compare_reconstructed_checkpoint <- function(reconstructed_fit, saved_model, X) {
  stopifnot(is.list(reconstructed_fit),!is.null(reconstructed_fit$model))
  p_new <- predict_dti_tensor_model(reconstructed_fit$model,X)
  p_saved <- predict_dti_tensor_model(saved_model,X)
  difference <- p_new-p_saved
  # Aggregate diagnostics only; do not write row-level predictions.
  data.frame(
    N=length(difference),
    Mean_Absolute_Difference=mean(abs(difference)),
    Root_Mean_Square_Difference=sqrt(mean(difference^2)),
    Maximum_Absolute_Difference=max(abs(difference)),
    Correlation=if(sd(p_new)>0 && sd(p_saved)>0) cor(p_new,p_saved) else NA_real_
  )
}
