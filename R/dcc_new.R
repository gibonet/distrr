
# Data preparation, before the creation of the data cube
prepare_data <- function(.data, .variables, .total = "Totale", 
                         order_type = extract_unique4){
  l <- length(.variables)
  .other_vars <- setdiff(colnames(.data), .variables)
  
  # Estrazione dei valori unici (in ordine di apparizione nei dati)
  # in una lista di lunghezza l (l_lev)
  data_vars <- .data %>%
    select2_(.variables)
  
  l_lev <- data_vars %>%
    order_type()
  l_lev <- lapply(l_lev, function(x) x <- unique(c(.total, x)))
  
  # Trasformo le .variables in character
  data_vars <- data_vars %>% 
    dplyr::mutate_all(.funs = "as.character")
  
  data_others <- .data %>%
    select2_(.other_vars)
  
  data_new <- dplyr::bind_cols(data_vars, data_others)
  
  list(data_new = data_new, l_lev = l_lev, l = l)
}


# Last operations, after the creation of the cube.
# Reordering columns, creating factors, arranging rows, ...
finish_cube <- function(joint_all, .variables, l_lev, l){
  # Reorder columns
  dots_all <- colnames(joint_all)
  measures <- setdiff(dots_all, .variables)
  dots_all <- c(.variables, measures)
  joint_all <- joint_all %>% select2_(dots_all)
  
  # Completamento delle righe per le quali non esistono combinazioni di
  # variabili nei dati
  joint_all <- joint_all %>% 
    complete2_(.variables = .variables)

  # Trasformazione delle .variables in factor e assegnamento dei livelli
  # in base a l_lev
  options(drop = FALSE)
  joint_all[ , .variables] <- joint_all[ , .variables] %>%
    dplyr::mutate_all(.funs = "as.factor")
    
  for(i in 1:l){
    joint_all[[i]] <- factor(joint_all[[i]], levels = l_lev[[i]])  # funziona
  }
  
  # Ordinamento dei risultati in funzione dei livelli dei factor appena impostati
  # (.total per primo, ....)
  joint_all <- arrange2_(joint_all, .variables)
  
  return(joint_all)
}






###############################################################################
# Computations for the cube creation
joint_all_ <- function(.data, .variables, .fun = jointfun_, .total = "Totale",
                       .all = TRUE, ...){
  l <- length(.variables)
  m_comb <- combn_l(l)
  
  joint_all <- vector(mode = "list", length = l)
  for(i in 1:l){
    joint <- vector(mode = "list", length = ncol(m_comb[[i]]))
    
    for(j in seq_along(joint)){
      joint[[j]] <- .fun(.data, .variables[m_comb[[i]][ , j]], ...) # ...
    }
    joint_all[[i]] <- joint
  }
  
  # trasforma una nested list in una lista classica
  joint_all <- dplyr::combine(joint_all)
  
  # Aggiunge le colonne mancanti alle distribuzioni marginali e 
  # joint-conditionals (impostando il valore alla stringa .total). 
  for(k in seq_along(joint_all)){
    vars_missing <- setdiff(.variables, colnames(joint_all[[k]]))
    joint_all[[k]][ , vars_missing] <- .total
  }
  
  # Unisce i data frame della lista joint_all in uno solo (uno sotto l'altro)
  joint_all <- dplyr::bind_rows(joint_all) %>% dplyr::ungroup()
  
  if(.all){
    joint <- .data %>%
      summarise2_(n = ~n(), ...)
    joint[ , .variables] <- .total  
    
    joint_all <- dplyr::bind_rows(joint, joint_all) %>% dplyr::ungroup()
  }
  return(joint_all)
}
###############################################################################


remove_total <- function(.cube, .variables, .total = "Totale"){
  tmp <- paste0(.variables, " == '", .total, "'")
  dots <- paste(tmp, collapse = " & ")
  dots <- paste0("!(", dots, ")")
  .cube %>% filter2_(.dots = dots)
}

###############################################################################

#' @inheritParams dcc2
#' @param .total character string with the name to give to the subset of data
#'  that includes all the observations of a variable (default: \code{"Totale"}).
#' @param .all logical, indicating if functions' have to be evaluated on the 
#'   complete dataset.
#'  
#' @examples 
#' # dcc5 works like dcc2, but has an additional optional argument, .total,
#' # that can be added to give a name to the groups that include all the 
#' # observations of a variable.
#' tmp5 <- dcc5(.data = invented_wages, 
#'             .variables = c("gender", "education"),
#'             .fun = jointfun_,
#'             .total = "TOTAL",
#'             order_type = extract_unique2)
#' tmp5
#' 
#' @rdname dcc
#' @export
dcc5 <- function(.data, .variables, .fun = jointfun_, .total = "Totale", 
                 order_type = extract_unique4, .all = TRUE, ...){
  # Data preparation, before the computations for the cube creation
  d <- prepare_data(.data = .data, .variables = .variables, .total = .total, 
                    order_type = order_type)
  
  # Computations for the cube creation
  l <- d[["l"]]; data_new <- d[["data_new"]]; l_lev <- d[["l_lev"]]
  
  joint_all <- joint_all_(data_new, .variables = .variables, .fun = .fun, 
                          .total = .total, .all = .all, ...)

  # Last operations, after the creation of the cube.
  # Reordering columns, creating factors, arranging rows, ...
  joint_all_final <- finish_cube(joint_all = joint_all, .variables = .variables,
                                 l_lev = l_lev, l = l)
  
  attributes(joint_all_final)[[".variables"]] <- .variables
  
  if(!.all){
    joint_all_final <- remove_total(joint_all_final, .variables = .variables,
                                    .total = .total)
  }
  
  return(joint_all_final)
}
###############################################################################






###############################################################################
# Argument .fun is replaced by argument .funs_list, which is a list in the form 
# list(n = ~n()). In addition, argument "..." is removed. 
# The .funs_list argument will contain all the statistics to be estimated in 
# the data cube.
# For example, 
# .funs_list = list(
#   n = ~n(), 
#   p50 = ~wq(wage, sample_weights, probs = 0.5), 
#   p25 = ~wq(wage, sample_weights, probs = 0.25))
###############################################################################
# Computations for the cube creation
joint_all_funs_ <- function(.data, .variables, .funs_list = list(n = ~dplyr::n()), 
                            .total = "Totale", .all = TRUE){
  l <- length(.variables)
  m_comb <- combn_l(l)
  
  joint_all <- vector(mode = "list", length = l)
  for(i in 1:l){
    joint <- vector(mode = "list", length = ncol(m_comb[[i]]))
    
    for(j in seq_along(joint)){
      joint[[j]] <- .data %>%
        gby_(.variables[m_comb[[i]][ , j]]) %>%
        summarise2_dots_(.funs_list) %>%
        stats::na.omit()
    }
    joint_all[[i]] <- joint
  }

  # trasforma una nested list in una lista classica  
  joint_all <- dplyr::combine(joint_all)
  
  # Aggiunge le colonne mancanti alle distribuzioni marginali e joint-conditionals
  # (impostando il valore a "Totale"). 
  for(k in seq_along(joint_all)){
    vars_missing <- setdiff(.variables, colnames(joint_all[[k]]))
    joint_all[[k]][ , vars_missing] <- .total
  }
  
  # Unisce i data frame della lista joint_all in uno solo (uno sotto l'altro ...)
  joint_all <- dplyr::bind_rows(joint_all) %>% dplyr::ungroup()
  
  if(.all){
    joint <- .data %>%
      summarise2_dots_(.funs_list)
    
    joint[ , .variables] <- .total
    joint_all <- dplyr::bind_rows(joint, joint_all) %>% dplyr::ungroup()
  }
  return(joint_all)
}
###############################################################################



###############################################################################

#' Data cube creation
#' 
#' @param .data data frame to be processed.
#' @param .variables variables to split data frame by, as a character vector 
#'     (\code{c("var1", "var2")}).
#' @param .funs_list a list of function calls in the form of right-hand formula.
#' @param .total character string with the name to give to the subset of data
#'  that includes all the observations of a variable (default: \code{"Totale"}).
#' @param order_type a function like \code{\link{extract_unique}} or 
#'    \code{\link{extract_unique2}}.
#' @param .all logical, indicating if functions' have to be evaluated on the 
#'   complete dataset.
#'   
#' @examples 
#' dcc6(invented_wages,
#'      .variables = c("gender", "sector"), 
#'      .funs_list = list(n = ~dplyr::n()),
#'      .all = TRUE)
#'      
#' dcc6(invented_wages,
#'      .variables = c("gender", "sector"), 
#'      .funs_list = list(n = ~dplyr::n()),
#'      .all = FALSE)
#' 
#' @export
dcc6 <- function(.data, .variables, .funs_list = list(n = ~dplyr::n()), .total = "Totale", 
                 order_type = extract_unique4, .all = TRUE){
  # Data preparation, before the computations for the cube creation
  d <- prepare_data(.data = .data, .variables = .variables, .total = .total, 
                    order_type = order_type)
  
  # Computations for the cube creation
  l <- d[["l"]]; data_new <- d[["data_new"]]; l_lev <- d[["l_lev"]]
  
  joint_all <- joint_all_funs_(data_new, .variables = .variables, 
                               .funs_list = .funs_list, .total = .total, .all = .all)
  
  # Last operations, after the creation of the cube.
  # Reordering columns, creating factors, arranging rows, ...
  joint_all_final <- finish_cube(joint_all = joint_all, .variables = .variables,
                                 l_lev = l_lev, l = l)
  
  attributes(joint_all_final)[[".variables"]] <- .variables
  
  if(!.all){
    joint_all_final <- remove_total(joint_all_final, .variables = .variables,
                                    .total = .total)
  }
  
  return(joint_all_final)
}
###############################################################################





###############################################################################
# Computations for the cube creation
# With the choice of combinations of variables
joint_all_funs2_ <- function(.data, .list_variables, .funs_list = list(n = ~n()), 
                            .total = "Totale", .all = TRUE){
  l <- length(.list_variables)
  # m_comb <- combn_l(l)
  
  joint_all <- vector(mode = "list", length = l)
  for(i in 1:l){
      joint_all[[i]] <- .data %>%
        gby_(.list_variables[[i]]) %>%
        summarise2_dots_(.funs_list) %>%
        stats::na.omit()
  }
  
  # trasforma una nested list in una lista classica  
  # joint_all <- dplyr::combine(joint_all)
  
  # Aggiunge le colonne mancanti alle distribuzioni marginali e joint-conditionals
  # (impostando il valore a "Totale"). 
  .variables <- unique(Reduce(c, .list_variables))
  for(k in seq_along(joint_all)){
    vars_missing <- setdiff(.variables, colnames(joint_all[[k]]))  ######################
    joint_all[[k]][ , vars_missing] <- .total
  }
  
  # Unisce i data frame della lista joint_all in uno solo (uno sotto l'altro ...)
  joint_all <- dplyr::bind_rows(joint_all)
  
  if(.all){
    joint <- .data %>%
      summarise2_dots_(.funs_list)
    
    joint[ , .variables] <- .total
    joint_all <- dplyr::bind_rows(joint, joint_all)
  }
  return(joint_all)
}


# Last operations, after the creation of the cube.
# Reordering columns, creating factors, arranging rows, ...
finish_cube2 <- function(joint_all, .variables, l_lev, l){
  # Reorder columns
  dots_all <- colnames(joint_all)
  measures <- setdiff(dots_all, .variables)
  dots_all <- c(.variables, measures)
  joint_all <- joint_all %>% select2_(dots_all)
  
  # Completamento delle righe per le quali non esistono combinazioni di
  # variabili nei dati
  # joint_all <- joint_all %>% 
  #   tidyr::complete_(cols = .variables, fill = as.list(rep(NA, l)))
  
  # Trasformazione delle .variables in factor e assegnamento dei livelli
  # in base a l_lev
  options(drop = FALSE)
  joint_all[ , .variables] <- joint_all[ , .variables] %>%
    dplyr::mutate_all(.funs = "as.factor")
  
  for(i in 1:l){
    joint_all[[i]] <- factor(joint_all[[i]], levels = l_lev[[i]])  # funziona
  }
  
  # Ordinamento dei risultati in funzione dei livelli dei factor appena impostati
  # (.total per primo, ....)
  joint_all <- arrange2_(joint_all, .variables)
  
  return(joint_all)
}


dcc7 <- function(.data, .list_variables, .funs_list = list(n = ~n()), .total = "Totale", 
                 order_type = extract_unique4, .all = TRUE){
  # Data preparation, before the computations for the cube creation
  .variables <- unique(Reduce(c, .list_variables))
  d <- prepare_data(.data = .data, .variables = .variables, .total = .total, 
                    order_type = order_type)
  
  # Computations for the cube creation
  l <- d[["l"]]; data_new <- d[["data_new"]]; l_lev <- d[["l_lev"]]
  
  joint_all <- joint_all_funs2_(data_new, .list_variables = .list_variables, 
                               .funs_list = .funs_list, .total = .total, .all = .all)
  
  # Last operations, after the creation of the cube.
  # Reordering columns, creating factors, arranging rows, ...
  joint_all_final <- finish_cube2(joint_all = joint_all, .variables = .variables,
                                 l_lev = l_lev, l = l)
  
  return(joint_all_final)
}
###############################################################################












