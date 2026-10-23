# EXPERIMENTAL RECONSTRUCTION — NOT recovered original training code.
# Requires local prepared training/validation features, labels, race categories.
# Explicit assumptions: Adam optimizer, BCEWithLogits, squared signed
# Black-White residual gap penalty. Original loss/optimizer not recovered.
# Usage after defining train and valid lists in R:
# source("R/reconstructed_dti_excluded_training.R")
# fit <- train_reconstructed_dti(train, valid, lambda=2, seed=101)
# Each list must contain X (numeric 67-col matrix), y (0/1 denial),
# race (Black or African American, White, or other).
# This code is not to be used for automated lending decisions.

suppressPackageStartupMessages(library(torch))

reconstructed_dnn <- nn_module(
  "ReconstructedDTIExcludedDNN",
  initialize = function(n_features) {
    self$network <- nn_sequential(
      nn_linear(n_features, 64), nn_relu(), nn_dropout(0.2),
      nn_linear(64, 32), nn_relu(), nn_dropout(0.1),
      nn_linear(32, 1)
    )
  },
  forward = function(x) self$network(x)
)

check_reconstruction_data <- function(d, label) {
  stopifnot(is.list(d), all(c("X", "y", "race") %in% names(d)),
            is.matrix(d$X), is.numeric(d$X), ncol(d$X) == 67L,
            all(is.finite(d$X)), length(d$y) == nrow(d$X),
            all(d$y %in% c(0, 1)), length(d$race) == nrow(d$X))
  if (anyNA(d$race)) stop(label, " contains missing race labels")
}

train_reconstructed_dti <- function(train, valid, lambda = 2,
                                     seed = 101L, batch_size = 1024L,
                                     lr = 0.001, max_epochs = 25L,
                                     patience = 5L) {
  # Explicit reconstructed choices—not evidenced in original source code.
  check_reconstruction_data(train, "train")
  check_reconstruction_data(valid, "valid")
  stopifnot(lambda %in% c(0, 2), batch_size > 0, lr > 0,
            max_epochs > 0, patience > 0)
  torch_manual_seed(as.integer(seed))
  set.seed(as.integer(seed))
  net <- reconstructed_dnn(67L)
  optimizer <- optim_adam(net$parameters, lr = lr)
  best_brier <- Inf
  best_state <- NULL
  best_epoch <- NA_integer_
  stale <- 0L
  history <- data.frame(epoch=integer(), train_loss=double(),
                        validation_brier=double())
  # CPU implementation intentionally uses mini-batch fairness regularization.
  # This may differ from the historical global/fixed-batch penalty.
  for (epoch in seq_len(max_epochs)) {
    net$train()
    order <- sample.int(nrow(train$X))
    batch_losses <- numeric()
    for (start in seq.int(1L, length(order), by=batch_size)) {
      idx <- order[start:min(start+batch_size-1L,length(order))]
      x <- torch_tensor(train$X[idx,,drop=FALSE], dtype=torch_float())
      y <- torch_tensor(matrix(train$y[idx], ncol=1L),dtype=torch_float())
      optimizer$zero_grad()
      logits <- net(x)
      bce <- nnf_binary_cross_entropy_with_logits(logits,y)
      penalty <- torch_zeros(1L)
      if (lambda > 0) {
        b <- which(train$race[idx] == "Black or African American")
        w <- which(train$race[idx] == "White")
        if (length(b) && length(w)) {
          residual <- torch_sigmoid(logits) - y
          gap <- residual[b,]$mean() - residual[w,]$mean()
          penalty <- gap$pow(2)
        }
      }
      loss <- bce + lambda * penalty
      loss$backward()
      optimizer$step()
      batch_losses <- c(batch_losses, loss$item())
    }
    net$eval()
    with_no_grad({
      pred <- numeric(nrow(valid$X))
      for (start in seq.int(1L,nrow(valid$X),by=batch_size)) {
        idx <- start:min(start+batch_size-1L,nrow(valid$X))
        x <- torch_tensor(valid$X[idx,,drop=FALSE],dtype=torch_float())
        pred[idx] <- as.numeric(torch_sigmoid(net(x))$reshape(c(-1)))
      }
      score <- mean((pred-valid$y)^2)
    })
    history <- rbind(history,data.frame(epoch=epoch,
      train_loss=mean(batch_losses),validation_brier=score))
    if (score < best_brier - 1e-12) {
      best_brier <- score
      best_epoch <- epoch
      best_state <- lapply(net$state_dict(),function(z) z$detach()$clone())
      stale <- 0L
    } else {
      stale <- stale + 1L
      if (stale >= patience) break
    }
  }
  net$load_state_dict(best_state)
  net$eval()
  list(model=net,history=history,best_epoch=best_epoch,
       best_validation_brier=best_brier,
       assumptions=c("Adam optimizer","BCE-with-logits",
         "squared mini-batch mean-residual gap penalty",
         "random reshuffle each epoch"))
}
