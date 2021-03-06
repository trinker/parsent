#' Annotators
#'
#' \code{word_annotator} - A wrapper for \code{\link[openNLP]{Maxent_Word_Token_Annotator}}.
#'
#' @param n The number of generations to go back (see \code{\link[base]{parent.frame}}).
#' @return Returns an annotator for entities or words.
#' @seealso \code{\link[openNLP]{Parse_Annotator}},
#' \code{\link[openNLP]{Maxent_Word_Token_Annotator}}
#' @rdname annotators
#' @export
word_annotator <- function(){
    check_models_package()
    openNLP::Maxent_Word_Token_Annotator()
}

#' Annotators
#'
#' \code{parse_annotator} - A wrapper for \code{\link[openNLP]{Parse_Annotator}}.
#'
#' @rdname annotators
#' @export
parse_annotator <- function(){
    check_models_package()
    openNLP::Parse_Annotator()
}


#' Annotators
#'
#' \code{easy_parse_annotator} - A wrapper for \code{\link[openNLP]{Parse_Annotator}}
#' that checks for \code{.parse_ann} in the global environment.  If \code{.parse_ann}
#' is not found a copy is assigned to the global environment for future sourcing.
#' This is because the parse annotator often leds to a Java out of memory error
#' if multiple instances are assigned.
#'
#' @rdname annotators
#' @export
#' @return \code{easy_parse_annotator} - Assigns a parse annotator to \code{.parse_ann}
#' in the global nvironment if not found.
easy_parse_annotator <- function(n=2){
    if (!exists(".parse_ann", envir = parent.frame(n))) {
        .parse_ann <- parse_annotator()
        assign(".parse_ann", .parse_ann, envir = parent.frame(n))
    }
    get(".parse_ann", envir = parent.frame(n))
}

check_models_package <- function(version = NULL){

    root <- 'http://datacube.wu.ac.at/src/contrib'

    if (is.null(version)) {
        page <- try(readLines(root))
        version <- try({
            hit <- grep('openNLPmodels.en', page, value = TRUE)
            unlist(qdapRegex::ex_between(hit, 'openNLPmodels.en_', '.tar.gz'))[1]
        })
        if (inherits(version, 'try-catch')) version <- '1.5-1'

    }

    outcome <- "openNLPmodels.en" %in% list.files(.libPaths())

    if (!outcome) {

        message(paste0(
            "Well it appears `openNLPmodels.en` is not installed.\n",
            "This package is necessary in order to use the `parsent` package.\n\nWould you like me to try and fetch it?"
        ))

        ans <- utils::menu(c("Yes", "No"))

        if (ans == "2") {

            stop("Sentence parsing aborted.  Please install `openNLPmodels.en`")

        } else {

            message("Attempting to install `openNLPmodels.en`.")
            utils::install.packages(
                file.path(root, sprintf("openNLPmodels.en_%s.tar.gz", version)),
                repos=NULL,
                type="source"
            )

            outcome <- "openNLPmodels.en" %in% list.files(.libPaths())

            if (outcome) {
                return(TRUE)
            } else {
                stop(sprintf(
                    "Failed to install `openNLPmodels.en`.  Please install `openNLPmodels.en` manually.\n%s",
                    root
                ))
            }
        }
    }
}
