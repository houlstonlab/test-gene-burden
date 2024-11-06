#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)
cases <- args[1]
controls <- args[2]
model <- args[3]
output_file <- args[4] 

# Function
burden_test <- function(cases, controls, model = 'DOM') {
  # Read and join cases and controls
  d <- dplyr::inner_join(
    readr::read_tsv(cases),
    readr::read_tsv(controls)
  )
  
  # Add a column for the model
  d <- dplyr::mutate(d, model = model)

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
  cases,
  controls,
  model = model
)

# Write output
readr::write_tsv(res, output_file) 
