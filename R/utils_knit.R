
#
# # Check if code is being called as part of knitting
# knitting <- function(){
#   isTRUE(getOption('knitr.in.progress'))
# }
#
# #' @export
# div <- function(...){
#
#   if(knitting()){
#     cat("<div class='parent'>")
#     list(...)
#     cat("</div>")
#   } else {
#     list(...)
#   }
#
# }
#
# #' @export
# out.plot <- function(code, fig_width=5, fig_height=7, out_height=NULL, out_width=NULL, inline=FALSE) {
#
#   if(!is.null(out_width) && is.null(out_height)) out_height <- out_width*(fig_height/fig_width)
#   if(is.null(out_width) && !is.null(out_height)) out_width  <- out_height*(fig_width/fig_height)
#
#   if(knitting()){
#     g_deparsed <- paste0("function(){ ", deparse(substitute(code, env = parent.frame())), "}")
#
#     if(is.null(out_height)) out_height <- "NULL"
#     if(is.null(out_width))  out_width  <- "NULL"
#
#     sub_chunk <- paste0("```{r ", parent.frame()$`.chunk-label`, "_subchunk", sample(1:1000000000, 1),
#                         ", fig.height=", fig_height,
#                         ", fig.width=",  fig_width,
#                         ", out.height=", out_height,
#                         ", out.width=",  out_width,
#                         ", echo=FALSE, warning=FALSE, message=FALSE, error=FALSE, render=labpage_render}",
#                         "\n(",
#                         g_deparsed
#                         , ")()",
#                         "\n```
#         ")
#
#     if(inline){
#       div <- "<div style='display:inline-block; vertical-align: top;'>"
#     } else {
#       div <- "<div>"
#     }
#
#     out(paste0(
#       div,
#       gsub("\n", "", knitr::knit(text = knitr::knit_expand(text = sub_chunk)), fixed = T),
#       "</div>"
#     ))
#
#   } else {
#     print(code)
#   }
# }
#
# #' @export
# out <- function(...){
#
#   if(knitting()){
#     escape_output(...)
#   } else {
#     pink <- crayon::make_style("grey40")
#     cat(pink(paste(..., sep = "")))
#     cat("\n")
#   }
#
# }
#
# #' @export
# out.table <- function(x, scale = 1, escape = TRUE, ...){
#
#   if(knitting()){
#     if(escape){
#       if(is.null(dim(x))) x <- gsub("*", "\\*", x, fixed = TRUE)
#       else                x <- apply(x, 2, gsub, pattern = "*", replacement = "\\*", fixed = TRUE)
#     }
#     out(sprintf("<div style='font-size:%s'>", paste0(scale*100, "%")))
#     out(knitr::kable(x, format = "html", escape = escape, ...))
#     out("</div>")
#   } else {
#     print(x)
#   }
#   invisible(NULL)
#
# }
#
# #' @export
# out.collapsible <- function(label, x){
#
#   if(knitting()){
#     cat("<div class='collapsible-div' label='", label,"'>", sep = "")
#     force(x)
#     cat("</div>")
#   } else {
#     force(x)
#   }
#   invisible(NULL)
#
# }
#
# #' @export
# out.tabset <- function(...){
#
#   if(knitting()){
#     out("<div class='tabset-div'>")
#     list(...)
#     out("</div>")
#   } else {
#     list(...)
#   }
#   invisible(NULL)
#
# }
#
# #' @export
# out.tab <- function(label, x){
#
#   if(knitting()){
#     out("<div class='tab-div' label='", label,"'>", sep = "")
#     force(x)
#     out("</div>")
#   } else {
#     force(x)
#   }
#   invisible(NULL)
#
# }
#
# #' @export
# out.div <- function(...){
#
#   if(knitting()){
#     out("<div class='flex-row'>")
#     list(...)
#     out("</div>")
#   } else {
#     list(...)
#   }
#   invisible(NULL)
#
# }
#
#
# escape_start <- "[[[["
# escape_end   <- "]]]]"
#
# escape_output <- function(...){
#   cat(paste(c(escape_start, ..., escape_end), collapse = ""))
# }
#
#


