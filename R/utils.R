
collate <- function(x){
  if(is.null(x)) return(NULL)
  sapply(x, function(x){
    if(is.null(x)) return(NA)
    else           return(x)
  })
}
