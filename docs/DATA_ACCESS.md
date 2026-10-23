# Data access and cohort

Source: 2025 public HMDA loan/application register (LAR), available from [FFIEC/CFPB HMDA data publications](https://ffiec.cfpb.gov/data-publication/). The exact official fixed release/snapshot corresponding to the local downloaded archive remains **unconfirmed**; do not assert a release date from the local ZIP timestamp.

The author's local ZIP MD5 was `561d641e884b1b1ef94e7118e3690b89`. The local source included 13,543,606 records; a restricted cohort of 2,034,914 records across 2,562 lenders was retained.

## Eligibility filters

- `loan_type == "1"` conventional
- `loan_purpose == "1"` purchase
- `lien_status == "1"` first lien
- `occupancy_type == "1"` principal residence
- `construction_method == "1"` site-built
- `total_units` in 1, 2, 3, 4
- `reverse_mortgage == "2"`, `open_end_line_of_credit == "2"`, `business_or_commercial_purpose == "2"`; **exclude `1111` exemption rather than treating it as No**
- `action_taken` in 1, 2, 3; labels: codes 1 and 2 non-denial; code 3 denial.

These restrictions create a more comparable pool of conventional home-purchase applications, limiting variation due to mortgage-product differences. They do not make the sample representative of all applicants or all lending decisions.

## Splitting

Frozen disjoint lenders: development training 1,530,103 applications/1,792 lenders; validation 260,348/384; held-out test 244,463/386.

## Data redistribution

The original 5+ GB extracted CSV, reconstructed row-level application records, and lender-level manifest are **not uploaded here**. Obtain HMDA data from the source above, observe source terms, and document the actual release before attempting reproduction. No proprietary or applicant-level redistribution rights are asserted here.