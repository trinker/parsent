#' Extract the Phrases from Parsed Sentence
#'
#' Extract highest level phrases from a sentence (see
#' \url{http://www.surdeanu.info/mihai/teaching/ista555-spring15/readings/PennTreebankConstituents.html}
#' for more on phrase types).
#'
#' @param x A parsed character string or list (see \code{parser}).
#' @return Returns a list of character vectors of highest level phrases.
#' @keywords phrases
#' @export
#' @examples
#' \dontrun{
#' txt <- c(
#'     "Really, I like chocolate because it is good. It smells great.",
#'     "Robots are rather evil and most are devoid of decency.",
#'     "He is my friend.",
#'     "Clifford the big red dog ate my lunch.",
#'     "Professor Johns can not teach",
#'     "",
#'     NA
#' )
#'
#' if(!exists('parse_ann')) {
#'     parse_ann <- parse_annotator()
#' }
#' (x <- parser(txt, parse_ann))
#' get_phrases(x)
#'
#' lapply(get_phrases(x), get_leaves)
#' }
get_phrases <- function(x){
    lapply(x, gp)
}

gp <- function(x){

    if (is.na(x)) return(x)

    fun <- switch(class(x)[1],
        character = unlister,
        parsed_character = unlister,
        Tree = unlister2,
        parsed_tree = unlister2,
        stop("Not a `parsed_tree`/`Tree` or `parsed_character`/`character` object.")
    )

    y <- fun(x)
    inds <- detect_sent(y)
    sents <- any(inds)

    y[!inds] <- lapply(y[!inds], utils::capture.output)
    while(any(sents)) {
        inds <- detect_sent(y)
        recursed <- lapply(y[inds], unlister2)
        recursed <- lapply(recursed, function(x) {
            x[!detect_sent(x)] <- lapply(x[!detect_sent(x)], utils::capture.output)
            x
        })
        sents <- unlist(lapply(recursed, detect_sent))
        y[inds] <- recursed
    }
    collapser(unlist(y))
}


unlister <- function(x) as_tree(x)[[1]][[2]][[1]][[2]]
unlister2 <- function(x) x[[2]]
detect_sent <- function(x) sapply(x, function(y) y[[1]][[1]] == "S") #grepl("\\(S ", x)

collapser <- function(x){
    unlist(lapply(textshape::split_index(gsub("^ +", "", x), grep("^[^ ]", x)), paste, collapse = ""))
}

## extracts next level phrases
# lapply(get_phrases(x), function(x){
#
#     if (is.na(x) || stringi::stri_count_regex(x, "\\(") == 1) return(x)
#     sapply(as_tree(x)[[1]][[2]], utils::capture.output)
# })
