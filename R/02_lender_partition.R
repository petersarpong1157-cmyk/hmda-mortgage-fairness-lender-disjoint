# This verifies an existing lender manifest; it does NOT regenerate the split.
library(data.table)

base_dir <- Sys.getenv("HMDA_BASE_DIR", unset = getwd())
manifest <- fread(file.path(base_dir, "lender_split_manifest_2025.csv"))

stopifnot(
  setequal(unique(manifest$split), c("train", "validation", "test")),
  !anyDuplicated(manifest$lei),
  manifest[split == 'train', sum(Total)] == 1530103L,
  manifest[split == 'validation', sum(Total)] == 260348L,
  manifest[split == 'test', sum(Total)] == 244463L,
  manifest[split == 'train', .N] == 1792L,
  manifest[split == 'validation', .N] == 384L,
  manifest[split == 'test', .N] == 386L
)

cat("PASS: Saved lender partitions are mutually exclusive.\n")