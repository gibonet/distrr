#' Empirical weighted quantile
#' 
#' @param x A numeric vector
#' @param weights A vector of (positive) sample weights
#' @param probs a numeric vector with the desired quantile levels (default 0.5, the median)
#' @return The weighted quantile (a numeric vector)
#' @references Ferrez, J., Graf, M. (2007). Enquète suisse sur la structure des
#'  salaires. Programmes R pour l'intervalle de confiance de la médiane. 
#'  (Rapport de méthodes No. 338-0045). Neuchâtel: Office fédéral de statistique.
#'  
#' @examples
#' wq(x = rnorm(100), weights = runif(100))
#' @export
wq <- function(x, weights, probs = c(0.5)){
  if(missing(weights)) {
    weights <- rep(1L, length(x))
  }

  ord <- order(x)
  cum.w <- cumsum(weights[ord])[!is.na(x)]/sum(weights[!is.na(x)])
  tmpS <- data.frame(matrix(rep(NA, 2 * length(probs)), nrow = 2))
  tmpO <- data.frame(matrix(rep(NA, 2 * length(probs)), nrow = 2))
  res <- c(rep(NA, length(probs)))
  for (i in 1:length(probs)) {
    tmpS[i] <- cum.w[cum.w >= probs[i]][1:2]
    tmpO[i] <- ord[cum.w >= probs[i]][1:2]
    res[i] <- (ifelse(abs(tmpS[1, i] - probs[i]) < 1e-10, 
                      mean(x[tmpO[, i]]), x[tmpO[1, i]]))
  }
  return(res)
}



#' Data cube creation (dcc)
#' 
#' @param .data data frame to be processed
#' @param .variables variables to split data frame by, as a character vector 
#'     (\code{c("var1", "var2")}).
#' @param .fun function to apply to each piece (default: \code{\link{jointfun_}})
#' @param ... additional functions passed to \code{.fun}.
#' @return a data cube, with a column for each cateogorical variable used, and a row for each combination of all the categorical variables' modalities. In addition to all the modalities, each variable will also have a "Total" possibility, which includes all the others. The data cube will contain marginal, conditional and joint empirical distributions...
#' @examples
#' data("invented_wages")
#' str(invented_wages)
#' tmp <- dcc(.data = invented_wages, 
#'            .variables = c("gender", "sector"), .fun = jointfun_)
#' tmp
#' str(tmp)
#' @export
dcc <- function(.data, .variables, .fun = jointfun_, ...){
  dcc5(.data, .variables, .fun = .fun, .total = "Totale", order_type = extract_unique2,
       .all = TRUE, ...)
}




#' @inheritParams dcc
#' @param order_type a function like \code{\link{extract_unique}} or 
#'    \code{\link{extract_unique2}}.
#' 
#' @examples
#' tmp2 <- dcc2(.data = invented_wages, 
#'             .variables = c("gender", "education"), 
#'             .fun = jointfun_, 
#'             order_type = extract_unique2)
#' tmp2
#' str(tmp2)
#' 
#' @rdname dcc
#' @export
dcc2 <- function(.data, .variables, .fun = jointfun_, order_type = extract_unique2, ...){
  dcc5(.data, .variables, .fun = .fun, .total = "Totale", order_type = order_type,
       .all = TRUE, ...)
}



#' Keeps only joint distribution (removes '.total').
#' 
#' Removes all the rows where variables have value \code{.total}.
#' 
#' @param .cube a datacube with 'Totale' modalities
#' @param  .total modality to eliminate (filter out) (default: "Totale")
#' @param .variables a character vector with the names of the categorical variables
#' @return a subset of the data cube with only the combinations of all variables modalities, without the "margins".
#' 
#' @examples 
#' data(invented_wages)
#' str(invented_wages)
#' 
#' vars <- c("gender", "education")
#' tmp <- dcc2(.data = invented_wages, 
#'             .variables = vars, 
#'             .fun = jointfun_, 
#'             order_type = extract_unique2)
#' tmp
#' str(tmp)
#' only_joint(tmp, .variables = vars)
#' 
#' # Compare dimensions (number of groups)
#' dim(tmp)
#' dim(only_joint(tmp, .variables = vars))
#' @export
only_joint <- function(.cube, 
                       .total = "Totale", 
                       .variables = NULL){
  if(is.null(.variables)){
    .variables <- attributes(.cube)[[".variables"]]
  }
  
  tmp <- paste0(.variables, " != '", .total, "'")
  dots <- paste(tmp, collapse = " & ")
  
  
  .cube %>%
    filter2_(.dots = dots)
}





