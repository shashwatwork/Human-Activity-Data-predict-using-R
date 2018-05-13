mcErrorRate <- function(predicted, actual) {
  mytable <- table(actual,predicted)
  sum(mytable[row(mytable) != col(mytable)]) / sum(mytable)
}