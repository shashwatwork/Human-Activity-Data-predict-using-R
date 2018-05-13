cutoff.corr <- function(corrMatrix, cutoff) {
  result <- c()
  for (i in 1:(ncol(corrMatrix)-1)) {
    tempcol <- corrMatrix[,i]
    for (j in (i+1):nrow(corrMatrix)) {
      if (abs(corrMatrix[j,i])>cutoff) {
        if (!(j %in% result)) result <- c(result,j)
      }
    }
  
  }
  result
}