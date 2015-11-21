#' Take Elements From a Vector
#'
#' Take elements from a vector.  Useful for extracting an index from branches
#' in a parse tree, particularly, in a \pkg{magrittr} chain.
#'
#' @param x A vector of elements to select from.
#' @param indices The indices to select.
#' @return Returns a subset of the original set of elements.
#' @export
#' @examples
#' take(list(1:4, LETTERS, rnorm(10)))
#' take(list(1:4, LETTERS, rnorm(10)), 2)
#' take(list(1:4, LETTERS, rnorm(10)), 1:3)
#'
#' \dontrun{
#' ## Parse example
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
#' parse_ann <- parse_annotator()
#' (x <- parser(txt, parse_ann))
#'
#' get_phrase_type(x, "NP") %>%
#'     take() %>%
#'     get_leaves()
#' }
take <- function(x, indices = 1){
    lapply(x, function(x){
        if (max(indices) > length(x)) return(character(0))
        x[indices]
    })
}
