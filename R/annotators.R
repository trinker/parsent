#' Annotators
#'
#' A wrapper for \code{\link[openNLP]{Parse_Annotator}} and
#' \code{\link[openNLP]{Maxent_Word_Token_Annotator}}.
#'
#' @return Returns an annotator for entities or words.
#' @seealso \code{\link[openNLP]{Parse_Annotator}},
#' \code{\link[openNLP]{Maxent_Word_Token_Annotator}}
#' @rdname annotators
#' @export
word_annotator <- function(){
    check_models_package()
    openNLP::Maxent_Word_Token_Annotator()
}

#' @rdname annotators
#' @export
parse_annotator <- function(){
    check_models_package()
    openNLP::Parse_Annotator()
}




check_models_package <- function(){
    outcome <- "openNLPmodels.en" %in% list.files(.libPaths())
    if (!outcome) {
        message(paste0("Well it appears `openNLPmodels.en` is not installed.\n",
            "This package is necessary in order to use the `entity` package.\n\nWould you like me to try and fetch it?"))
        ans <- utils::menu(c("Yes", "No"))
        if (ans == "2") {
            stop("Named entity extraction aborted.  Please install `openNLPmodels.en`")
        } else {
            message("Attempting to install `openNLPmodels.en`.")
            utils::install.packages(
                "http://datacube.wu.ac.at/src/contrib/openNLPmodels.en_1.5-1.tar.gz",
                repos=NULL,
                type="source"
            )
            outcome <- "openNLPmodels.en" %in% list.files(.libPaths())
            if (outcome) {
                return(TRUE)
            } else {
                stop("Failed to install `openNLPmodels.en`.  Please install `openNLPmodels.en` manually.")
            }
        }
    }
}
