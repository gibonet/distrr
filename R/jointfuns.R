
#' A minimal function which counts the number of observations by groups in a data frame
#' 
#' 
#' @param .data data frame to be processed
#' @param .variables variables to split data frame by, as a character vector (\code{c("var1", "var2")}).
#' @param ... additional function calls to be applied on the .data
#' @return a data frame, with a column for each cateogrical variable used, and a row for each combination of all the categorical variables' modalities. 
#' @examples
#' data("invented_wages")
#' tmp <- jointfun_(.data = invented_wages, .variables = c("gender", "sector"))
#' tmp
#' str(tmp)
#' @export
jointfun_ <- function(.data, .variables, ...){
  .data %>%
    gby_(.variables) %>%
    summarise2_(n = ~n(), ...) %>%
    stats::na.omit()
}


