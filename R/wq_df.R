
wq_df <- function(.data, x, weights, probs = c(0.5)){
  Fhat_ <- .data %>% Fhat_df_(x = x, weights = weights)
  
  # First indices greater or equal to desired quantile levels
  k <- lapply(probs, function(y) which(Fhat_[["Fhat"]] >= y)[1:2])
  # k <- unlist(k)
  
  # Extract 'empirical' quantile levels and corresponding x-values
  values <- lapply(k, function(i) Fhat_[i , c("Fhat", x), drop = FALSE])
  
  # Weighted quantiles
  res <- vector(mode = "list", length = length(values))
  for(i in seq_along(values)){
    if(abs(values[[i]][["Fhat"]][1] - probs[i]) < 1e-10){
      res[[i]] <- mean(values[[i]][[x]])
    }else{
      res[[i]] <- values[[i]][[x]][1]
    }
  }

  res
}
# wq_df(invented_wages, x = "wage", weights = "sample_weights", 
#       probs = c(0.5, 0.9))


# Versione che parte dall'output di Fhat_df_
wq_Fhat <- function(.Fhat, probs = c(0.5)){
  x <- colnames(.Fhat)[1]
  
  # First indices greater or equal to desired quantile levels
  k <- lapply(probs, function(y) which(.Fhat[["Fhat"]] >= y)[1:2])
  # k <- unlist(k)
  
  # Extract 'empirical' quantile levels and corresponding x-values
  values <- lapply(k, function(i) .Fhat[i , c("Fhat", x), drop = FALSE])
  
  # Weighted quantiles
  res <- vector(mode = "list", length = length(values))
  for(i in seq_along(values)){
    if(abs(values[[i]][["Fhat"]][1] - probs[i]) < 1e-10){
      res[[i]] <- mean(values[[i]][[x]])
    }else{
      res[[i]] <- values[[i]][[x]][1]
    }
  }
  
  res
}
