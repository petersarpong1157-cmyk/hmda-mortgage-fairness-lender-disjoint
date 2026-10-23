
library(data.table)
library(Matrix)

base_dir <- Sys.getenv("HMDA_BASE_DIR", unset = getwd())

protocol <- readRDS(file.path(
  base_dir, "LOCKED_FINAL_PROTOCOL.rds"
))

pp <- protocol$preprocessing

prepare_hmda_features <- function(df, sparse = TRUE) {

  d <- as.data.table(copy(df))

  numeric_vars <- c("loan_amount", "income", "loan_term")

  required <- c(
    numeric_vars,
    "applicant_age",
    "state_code",
    "debt_to_income_ratio"
  )

  stopifnot(all(required %in% names(d)))

  # Convert numerical variables
  for (v in numeric_vars) {
    d[, (v) := suppressWarnings(as.numeric(get(v)))]
  }

  # Apply original training medians
  for (v in numeric_vars) {

    med <- pp$numeric_imputation[
      Variable == v, Median
    ]

    stopifnot(length(med) == 1L)

    set(
      d,
      i = which(is.na(d[[v]])),
      j = v,
      value = med
    )
  }

  # Apply saved training means and standard deviations
  for (v in numeric_vars) {

    mu <- pp$numeric_scaling[
      Variable == v, Mean
    ]

    sigma <- pp$numeric_scaling[
      Variable == v, SD
    ]

    stopifnot(
      length(mu) == 1L,
      length(sigma) == 1L,
      is.finite(sigma),
      sigma > 0
    )

    d[, (v) := (get(v) - mu) / sigma]
  }

  # Restore original categorical factor levels
  for (v in names(pp$factor_levels)) {

    values <- as.character(d[[v]])

    # Reconstruct the saved Missing category
    values[
      is.na(values) |
      trimws(values) %in% c("", "NA")
    ] <- "Missing"

    d[, (v) := factor(
      values,
      levels = pp$factor_levels[[v]]
    )]
  }

  # Prevent silent loss of previously unseen categories
  for (v in names(pp$factor_levels)) {

    stopifnot(!anyNA(d[[v]]))
  }

  # Use the saved design formula and preserve sparsity
  X <- Matrix::sparse.model.matrix(
    pp$formula,
    data = as.data.frame(d),
    na.action = na.fail
  )

  stopifnot(
    nrow(X) == nrow(d),
    ncol(X) == length(pp$feature_names),
    identical(colnames(X), pp$feature_names),
    all(is.finite(X@x))
  )

  if (!sparse) {
    X <- as.matrix(X)
  }

  X
}

cat("PASS: Preprocessing function loaded.\n")
