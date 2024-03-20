
## #' @inheritParams dcc6


#' @param fixed_variable name of the variable for which you do not want to estimate the total
#' 
#' @rdname dcc6
#' @export
dcc6_fixed <- function(.data, 
                       .variables, 
                       .funs_list = list(n = ~dplyr::n()), 
                       .total = "Totale", 
                       order_type = extract_unique5, 
                       .all = TRUE, 
                       fixed_variable = NULL) {
  
  
  if (is.null(fixed_variable)) {
    cube <- dcc6(.data, .variables, .funs_list, .total, order_type, .all = .all)
  } else {
    # Some checks
    stopifnot(fixed_variable %in% .variables)
    stopifnot(is.character(fixed_variable) & length(fixed_variable) == 1)
    
    if (!is.factor(.data[[fixed_variable]])) {
      .data[[fixed_variable]] <- as.character(.data[[fixed_variable]])
      fixed_values <- sort(unique(.data[[fixed_variable]]))
    } else {
      fixed_values <- levels(.data[[fixed_variable]])
    }
    
    fixed_values <- fixed_values[!is.na(fixed_values)]
    
    # Data preparation, before the computations for the cube creation
    d <- prepare_data(
      .data = .data, 
      .variables = .variables, 
      .total = .total,
      order_type = order_type
    )
    
    # Computations for the cube creation
    l <- d[["l"]]; data_new <- d[["data_new"]]; l_lev <- d[["l_lev"]]
    
    cube_list <- vector(mode = "list", length = length(fixed_values))
    
    for (i in seq_along(cube_list)) {
      to_keep <- paste0(fixed_variable, " == '", fixed_values[i], "'")
      
      cube_list[[i]] <- data_new |>
        filter2_(.dots = to_keep) |>
        joint_all_funs_(
          .variables = .variables[!.variables %in% fixed_variable], 
          .funs_list = .funs_list, 
          .total = .total, 
          .all = .all
        )
      
      cube_list[[i]][[fixed_variable]] <- fixed_values[i]
    }
    
    cube <- dplyr::bind_rows(cube_list)
    
    cols <- colnames(cube)
    no_vars <- cols[!cols %in% .variables]
    cols <- c(.variables, no_vars)
    
    cube <- cube |> select2_(cols)
    
    # Last operations, after the creation of the data cube.
    # Reordering columns, creating factors, arranging rows, ...
    cube <- finish_cube(
      joint_all = cube, 
      .variables = .variables,
      l_lev = l_lev, 
      l = l
    )
    
    cube[[fixed_variable]] <- droplevels(cube[[fixed_variable]])
    
    
    attributes(cube)[[".variables"]] <- .variables
    attributes(cube)[["fixed_variable"]] <- fixed_variable
    
    if (!.all) {
      cube <- remove_total(
        cube, 
        .variables = .variables,
        .total = .total
      )
    }
    
  }
  
  cube
}



