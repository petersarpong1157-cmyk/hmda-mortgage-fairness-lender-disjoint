# This verifies the frozen manifest; it does NOT recreate selection from raw HMDA.
library(data.table)

base_dir <- Sys.getenv("HMDA_BASE_DIR", unset = getwd())
manifest <- fread(file.path(base_dir, "lender_split_manifest_2025.csv"))

stopifnot(
  nrow(manifest) == 2562L,
  uniqueN(manifest$lei) == 2562L,
  sum(manifest$Total) == 2034914L
)

summary <- manifest[, .(
  Applications = sum(Total),
  Lenders = uniqueN(lei)
), by = split]

print(summary)
cat("PASS: Saved analytical-population manifest verified.\n")

# This audit does not reconstruct filtering from the raw HMDA file.