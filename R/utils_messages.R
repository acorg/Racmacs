
require_acmacs.r <- function(msg = "acmacs.r is required"){
  if(!require("acmacs.r")){
    stop(msg)
  }
}

strain_list_error <- function(error, strains){

  stop(paste0(error, "\n\n'",
              paste(strains, collapse = "'\n'"), "'\n"), call. = FALSE)

}

strain_list_warning <- function(warning, strains){

  warning(paste0(warning, "\n\n'",
                 paste(strains, collapse = "'\n'"), "'\n"), call. = FALSE)

}

vmessage <- function(verbose, ...){
  if(verbose) message(...)
}
