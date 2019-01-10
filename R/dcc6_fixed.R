
#' @inheritParams dcc6
#' @param fixed_variable name of the variable for which you do not want to estimate the total
#' 
#' @rdname dcc6
#' @export
dcc6_fixed <- function(.data, .variables, .funs_list = list(n = ~dplyr::n()), 
                       .total = "Totale", order_type = extract_unique5, 
                       fixed_variable = NULL){
  
  if(is.null(fixed_variable)){
    cube <- dcc6(.data, .variables, .funs_list, .total, order_type, .all = TRUE)
  }
  
  stopifnot(fixed_variable %in% .variables)
  stopifnot(is.character(fixed_variable) & length(fixed_variable) == 1)
  
  .data[[fixed_variable]] <- as.character(.data[[fixed_variable]])
  fixed_values <- sort(unique(.data[[fixed_variable]]))
  fixed_values <- fixed_values[!is.na(fixed_values)]
  
  cube_list <- vector(mode = "list", length = length(fixed_values))
  
  for(i in seq_along(cube_list)){
    to_keep <- paste0(fixed_variable, " == '", fixed_values[i], "'")
    cube_list[[i]] <- .data %>%
      filter2_(.dots = to_keep) %>%
      dcc6(.variables[!.variables %in% fixed_variable], 
           .funs_list, .total, order_type, .all = TRUE)
    
    cube_list[[i]][[fixed_variable]] <- fixed_values[i]
  }
  
  cube <- dplyr::bind_rows(cube_list)
  
  cols <- colnames(cube)
  no_vars <- cols[!cols %in% .variables]
  cols <- c(.variables, no_vars)
  
  cube <- cube %>% select2_(cols)
  
  levels_fixed_variable <- .data[ , fixed_variable, drop = FALSE] %>%
    order_type() %>% unlist()
  cube[[fixed_variable]] <- factor(cube[[fixed_variable]], 
                                   levels = unique(levels_fixed_variable))
  
  cube <- cube %>%
    complete2_(.variables) %>% 
    arrange2_(.variables)
  
  attributes(cube)[[".variables"]] <- .variables
  attributes(cube)[["fixed_variable"]] <- fixed_variable
  
  cube
}