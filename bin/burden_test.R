#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)
cases <- args[1]
controls <- args[2]
model <- args[3]
tested_file <- args[4] 
not_tested_file <- args[5] 

# Read and join cases and controls
d <- dplyr::left_join(
  readr::read_tsv(cases),
  readr::read_tsv(controls)
)
# Add a column for the model
d <- dplyr::mutate(d, model = model)

# Missing in controls
if ( model == 'DOM') {
  not_tested <- dplyr::filter(d,  CONTROL_COUNT_DOM == 0 | is.na(CONTROL_COUNT_DOM))
  d <- dplyr::filter(d,  CONTROL_COUNT_DOM > 0 & !is.na(CONTROL_COUNT_DOM))
} else if ( model == 'REC') {
  not_tested <- dplyr::filter(d,  CONTROL_COUNT_REC == 0 | is.na(CONTROL_COUNT_REC))
  d <- dplyr::filter(d,  CONTROL_COUNT_REC> 0 & !is.na(CONTROL_COUNT_REC))
} else {
  stop('Model must be DOM or REC')
}

# Write output
readr::write_tsv(not_tested, not_tested_file) 

# Function
burden_test <- function(d, model = 'DOM') {
  # Get the a and c cells based on the model
  d <- dplyr::mutate(
    d,
    a = ifelse(model == 'DOM', CASE_COUNT_DOM, CASE_COUNT_REC),
    c = ifelse(model == 'DOM', CONTROL_COUNT_DOM, CONTROL_COUNT_REC)
  )

  # Filter out genes with no variants in both cases and controls
  d <- dplyr::filter(d, a > 0 & c > 0)

  # Perform Fisher's exact test, by gene
  d <- dplyr::group_split(d, gene)
  res <- purrr::map_df(
    d,
    ~{
        # Create a 2 x 2 table
        mat <- rbind(
          c(.x$a, .x$CASE_SIZE - .x$a),
          c(.x$c, .x$CONTROL_SIZE - .x$c)
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
