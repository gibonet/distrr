#' Estimate and manage empirical distributions
#' 
#' Tools to estimate and manage empirical distributions,
#' which should work with survey data. One of the main features is the 
#' possibility to create data cubes of estimated statistics, that include
#' all the combinations of the variables of interest (see for example functions
#' dcc5() and dcc6()).
#' 
#' @docType package
#' @name distrr
#' 
#' @import rlang
#' @import dplyr
#' @importFrom utils combn
#' @importFrom stats na.omit setNames quantile
#' @importFrom tidyr expand expand_ complete_
NULL

# Sostituisco
# #' @importFrom dplyr group_by_ summarise_ mutate_ filter_ arrange_ select_ mutate_all bind_cols bind_rows combine ungroup n
# con (per il momento)
# #' @import dplyr


#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`

