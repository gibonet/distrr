
#' Weighted empirical cumulative distribution function (ecdf), conditional on one or more variables
#' 
#' @param .data a data frame
#' @param .variables a character vector with one or more column names
#' @param x character vector of length one, with the name of the numeric column whose conditional ecdf has to be estimated
#' @param weights character vector of length one, indicating the name of the positive numeric column of weights, which will be used in the estimation of the conditional ecdf
#' @return a data frame, with the variables used to condition, the x variable, and columns wsum (aggregated sum of weights, based on unique values of x) and Fhat (the estimated conditional Fhat). In addition to data frame, the object will be of classes grouped_df, tbl_df and tbl (from package dplyr) 
#' @examples 
#' Fhat_conditional_(mtcars,
#'                  .variables = c("vs", "am"),
#'                  x = "mpg",
#'                  weights = "cyl")
#' @export              
Fhat_conditional_ <- function(.data, .variables, x, weights){
  group_all <- c(.variables, x)
  .data |>
    gby_(group_all) |>
    sumx_(weights) |>
    stats::na.omit() |>
    gby_(.variables) |>
    mutcumx_("wsum")
}

# Sembra funzionare

#' Weighted empirical cumulative distribution function (data frame version)
#' 
#' @param .data a data frame
#' @param x name of the numeric column (as character)
#' @param weights name of the weight column (as character)
#' @return a data frame with columns: x, wcum and Fhat
#' @examples 
#' data(invented_wages)
#' Fhat_df_(invented_wages, "wage", "sample_weights")
#' @export
Fhat_df_ <- function(.data, x, weights){
  .data |>
    gby_(x) |>
    sumx_(weights) |>
    dplyr::ungroup() |>
    stats::na.omit() |>
    mutcumx_("wsum")
}
