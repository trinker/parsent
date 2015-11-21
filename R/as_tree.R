#' Convert a Parsed String to Tree
#'
#' Convert a parsed string to a tree structure.  A wrapper for
#' \code{\link[NLP]{Tree_parse}}.
#'
#' @param x A vector from \code{parser}.
#' @param \ldots ignored.
#' @return Returns a list of trees from \code{\link[NLP]{Tree_parse}}.
#' @keywords tree parse
#' @export
#' @seealso \code{\link[NLP]{Tree_parse}}
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
#' parse_ann <- parse_annotator()
#' x <- parser(txt, parse_ann)
#' as_tree(x)
#' }
as_tree <- function(x, ...){
    lapply(x, function(z){
        if(is.null(z)||is.na(z)) return(z)
        x <- NLP::Tree_parse(z)
        class(x) <- c("parsed_tree", class(x))
        attributes(x)[["parsed_character"]] <- z
        x
    })
}




