# utility functions

# function calculating CK from a table of obs x pred
cohens_kappa = function(acc_table){
  p <- apply(acc_table,1,sum) / sum(acc_table)
  q <- apply(acc_table,2,sum) / sum(acc_table)
  p0 <- sum(diag(acc_table)) / sum(acc_table)
  
  kappa <- (p0 - sum(p * q)) / (1 - sum(p * q))
  
  return(kappa)
}
