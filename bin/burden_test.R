#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)
cases <- args[1]
controls <- args[2]
model <- args[3]
tested_file <- args[4] 

# Read and join cases and controls
d <- dplyr::left_join(
  readr::read_tsv(cases),
  readr::read_tsv(controls)
)

# Function
burden_test <- function(dat, model = 'DOM') {
  # Add a column for the model
  dat <- dplyr::mutate(dat, model = model)

  # Get the 2 x2 cells based on the model
  # Fixed cohort size
  # 0 if count in controls is NA
  dat <- dplyr::mutate(
    dat,
    a = ifelse(model == 'DOM', CASE_COUNT_DOM, CASE_COUNT_REC),
    c = ifelse(model == 'DOM', CONTROL_COUNT_DOM, CONTROL_COUNT_REC),
    c = ifelse(is.na(c), 0, c),
    b = na.omit(unique(dat$CASE_SIZE)),
    d = na.omit(unique(dat$CONTROL_SIZE))
  )
  
  # Remove rows with 0 in a
  dat <- dplyr::filter(dat, a > 0)
  
  # Perform Fisher's exact test, by gene
  dat <- dplyr::group_split(dat, gene)
  res <- purrr::map_df(
    dat,
    ~{
        # Create a 2 x 2 table
        mat <- with(
          .x,
          rbind(
          c(a, b - a),
          c(c, d - c)
        )
        )

        # Apply test
        df <- broom::tidy(
          fisher.test(
            mat
          )
        )
        dplyr::bind_cols(.x, df)
      }
  )

  # Adjust for multiple testing
  res <- dplyr::mutate(res, p.adj = stats::p.adjust(p.value, method = 'BH'))
  
  return(res)
}

# Call burden_test
res <- burden_test(
  d,
  model = model
)

# Write output
readr::write_tsv(res, tested_file) 
