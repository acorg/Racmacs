

# Check if code is being called as part of knitting
knitting <- function(){
  isTRUE(getOption('knitr.in.progress'))
}

#' @export
div <- function(...){

  if(knitting()){
    cat("<div class='parent'>")
    list(...)
    cat("</div>")
  } else {
    list(...)
  }

}

#' @export
out.plot <- function(code, fig_width=5, fig_height=7, out_height=NULL, out_width=NULL, inline=FALSE) {

  if(knitting()){
    g_deparsed <- paste0("function(){ ", deparse(substitute(code, env = parent.frame())), "}")

    if(is.null(out_height)) out_height <- "NULL"
    if(is.null(out_width))  out_width  <- "NULL"

    eval(expression(`.subChunkNum` <- `.subChunkNum` + 1), parent.frame())
    `.subChunkNum` <- parent.frame()$`.subChunkNum`
    sub_chunk <- paste0("
  `","``{r ", parent.frame()$`.chunk-label`, "_subchunk", `.subChunkNum`,
                        ", fig.height=", fig_height,
                        ", fig.width=",  fig_width,
                        ", out.height=", out_height,
                        ", out.width=",  out_width,
                        ", echo=FALSE, warning=FALSE, message=FALSE, error=FALSE}",
                        "\n(",
                        g_deparsed
                        , ")()",
                        "\n`","``
  ")

    if(inline){
      div <- "<div style='display:inline-block; vertical-align: top;'>"
    } else {
      div <- "<div>"
    }

    cat(div)
    cat(knitr::knit(text = knitr::knit_expand(text = sub_chunk)))
    cat("</div>")

  } else {
    print(code)
  }
}

#' @export
out <- function(...){

  if(knitting()){
    cat('<pre class="code-block code-output output-code"><code>')
    cat(..., sep = "")
    cat('</code></pre>')
  } else {
    cat(..., sep = "")
    cat("\n")
  }

}

#' @export
out.table <- function(x, scale = 1, escape = TRUE, ...){

  if(knitting()){
    if(escape){
      if(is.null(dim(x))) x <- gsub("*", "\\*", x, fixed = TRUE)
      else                x <- apply(x, 2, gsub, pattern = "*", replacement = "\\*", fixed = TRUE)
    }
    cat(sprintf("<div style='font-size:%s'>", paste0(scale*100, "%")))
    cat(knitr::kable(x, format = "html", escape = escape, ...))
    cat("</div>")
  } else {
    print(x)
  }
  invisible(NULL)

}

#' @export
out.collapsible <- function(label, x){

  if(knitting()){
    cat("<div class='collapsible-div' label='", label,"'>", sep = "")
    force(x)
    cat("</div>")
  } else {
    force(x)
  }
  invisible(NULL)

}

#' @export
out.tabset <- function(...){

  if(knitting()){
    cat("<div class='tabset-div'>")
    list(...)
    cat("</div>")
  } else {
    list(...)
  }
  invisible(NULL)

}

#' @export
out.tab <- function(label, x){

  if(knitting()){
    cat("<div class='tab-div' label='", label,"'>", sep = "")
    force(x)
    cat("</div>")
  } else {
    force(x)
  }
  invisible(NULL)

}

#' @export
out.div <- function(...){

  if(knitting()){
    cat("<div class='flex-row'>")
    list(...)
    cat("</div>")
  } else {
    list(...)
  }
  invisible(NULL)

}



# rootdir  <- "~/Dropbox/LabBook/packages/Racmacs/tests/testoutput/viewer/racmap/"
# testfile <- file.path(rootdir, "map_diagnostics.html")
#
# rmarkdown::render(
#   input = "~/Dropbox/LabBook/packages/Racmacs/inst/templates/diagnostics_page.Rmd",
#   output_format = rmarkdown::html_document(
#     theme          = NULL,
#     self_contained = FALSE,
#     lib_dir        = file.path(rootdir, ".lib")
#   ),
#   output_file = testfile,
#   quiet = TRUE,
#   knit_root_dir = getwd()
# )
#
# unlink(file.path(rootdir, ".lib/RacViewer-1.0.0"), recursive = T)
#
# plotdata <- readLines(testfile)
# plotdata <- gsub(
#   pattern     = ".lib/RacViewer-1.0.0/",
#   replacement = "../../../../inst/htmlwidgets/RacViewer/lib/",
#   x           = plotdata,
#   fixed       = TRUE
# )
# writeLines(plotdata, testfile)


