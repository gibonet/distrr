# Partendo da un numero intero, k, genera una lista i cui elementi saranno 
# delle matrici con degli indici in riga e ogni colonna che rappresenta una
# combinazione. Le combinazioni k - (k-i) vengono generate per `i` che va da
# 1 a k (combn(3, 1), combn(3, 2), combn(3, 3))
combn_l <- function(k) lapply(1:k, function(x) combn(k, m = k - x + 1))
# combn_l(3)

# Riprendo combn_char dal pacchetto cuber

#' Generate all combinations of the elements of a character vector
#' 
#' @param x a character vector
#' 
#' @return a nested list. A list whose elements are lists containing the 
#' character vectors with the combinations of their elements.
#' 
#' @examples 
#' combn_char(c("gender", "sector"))
#' combn_char(c("gender", "sector", "education"))
#' @export
combn_char <- function(x) {
  l <- length(x)
  comb_vars <- combn_l(l)
  
  list_comb <- vector(mode = "list", length = l)
  
  for (i in seq_along(comb_vars)) {
    list_comb_i <- vector(mode = "list", length = ncol(comb_vars[[i]]))
    
    for (j in seq_along(list_comb_i)) {
      k <- comb_vars[[i]][ , j]
      list_comb_i[[j]] <- x[k]
    }
    
    list_comb[[i]] <- list_comb_i
  }
  
  return(list_comb)
}

# vars <- c("gender", "sector", "education")
# list_vars <- combn_char(vars)




find_factor <- function(.data) {
  lapply(.data, is.factor)
}
# find_factor(x)

# http://adv-r.had.co.nz/Functionals.html#functionals-fp
where <- function(f, x) {
  vapply(x, f, logical(1))
}
# where(is.factor, x)


# Se factor: estrarre i livelli (e memorizzarli)
# Trasformare i factor in character
# Aggiungere "Totale"
# Ri-creare i factors, aggiungendo "Totale" ai levels salvati in precedenza

# Se factor, estrae i livelli (in una lista?)
extract_levels <- function(df) {
  are_fact <- where(is.factor, df)  # Vettore di TRUE/FALSE
  
  l_lev <- lapply(df[, are_fact], levels)
  
  return(l_lev)
}
# extract_levels(d)


# Input: df un data frame
# Output: una lista, i cui elementi sono dei vettori character 
#         con i valori unici di ogni colonna del data frame df

#' Functions to be used in conjunction with 'dcc' family
#' 
#' @param df a data frame
#' 
#' @return a list whose elements are character vectors of the 
#'     unique values of each column
#' 
#' @examples 
#' data("invented_wages")
#' tmp <- extract_unique(df = invented_wages[, c("gender", "sector")])
#' tmp
#' str(tmp)
#' @export
extract_unique <- function(df) {
  res <- lapply(df, function(x) unique(as.character((x))))
  # unique da solo manterrebbe eventuali factor 
  # (può comunque tornare utile in caso di altri modi di ordinare...)
  return(res)
}
# extract_unique(d[1:3])
# str(extract_unique(d[1:3]))



# Versione di extract_unique alternativa:
# Se factor, estrae i livelli esistenti
# Se no, estrae i valori unici (in ordine di apparizione)

#' @rdname extract_unique
#' @export
extract_unique2 <- function(df) {
  are_factors <- where(is.factor, df)
  res <- vector(mode = "list", length = length(are_factors))
  
  for (i in seq_along(df)) {
    if (are_factors[i]) {
      res[[i]] <- levels(df[[i]]) 
    } else {
      res[[i]] <- unique(as.character(df[[i]]))
    }
  }
  
  return(res)
}
# extract_unique2(d[1:3])
# str(extract_unique2(d[1:3]))


# ordine "alfabetico" (crescente)

#' @rdname extract_unique
#' @export
extract_unique3 <- function(df) {
  res <- lapply(df, function(x) sort(unique(as.character((x)))))
  return(res)
}



#' @rdname extract_unique
#' @export
extract_unique4 <- function(df) {
  are_factors <- where(is.factor, df)
  res <- vector(mode = "list", length = length(are_factors))
  
  for (i in seq_along(df)) {
    if (are_factors[i]) {
      res[[i]] <- levels(df[[i]]) 
    } else {
      res[[i]] <- sort(unique(as.character(df[[i]])))
    }
  }
  
  return(res)
}


#' @rdname extract_unique
#' @export
extract_unique5 <- function(df) {
  are_factors <- where(is.factor, df)
  res <- vector(mode = "list", length = length(are_factors))
  
  for (i in seq_along(df)) {
    
    if (are_factors[i]) {
      res[[i]] <- levels(df[[i]])
      res[[i]] <- res[[i]][res[[i]] %in% unique(as.character(df[[i]]))]
    } else {
      res[[i]] <- sort(unique(as.character(df[[i]])))
    }
    
  }
  
  return(res)
}

