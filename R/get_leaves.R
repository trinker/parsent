#' Extract Tokens from a Phrase
#'
#' Extract the tokens from a phrase.
#'
#' @param x A list/vetor of phrases
#' @param regex A regular expression to extract tokens.  Default extracts tokens:
#' \code{"(?<=\\s)[A-Za-z'-]+(?=\\))"}.  Use \code{"(?<=\\s)[A-Za-z'-]+(?=\\))"}
#' to extract words.
#' @return Returns a list of vectors of extracted tokens.
#' @keywords leaves words tokens
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
#' parse_ann <- parse_annotator()
#' (x <- parser(txt, parse_ann))
#'
#' get_leaves(get_phrase_type_regex(x, "NP"))
#'
#' ## As a dplyr chain
#' library(dplyr)
#' x %>%
#'     get_phrase_type_regex("NP") %>%
#'     get_leaves()
#'
#' ## Just words (in this case no difference)
#' x %>%
#'     get_phrase_type_regex("NP") %>%
#'     get_leaves("@@words")
#' }
get_leaves <- function(x, regex = "@tokens"){
    if (grepl("^@", regex)) {
        regex <- switch(regex,
            `@tokens` = "(?<=\\s)[A-Za-z'.?!;:-]+(?=\\))",
            `@words` = "(?<=\\s)[A-Za-z'-]+(?=\\))",
            stop("Use a valid regex")
        )
    }
    lapply(x, function(y){
        unlist(qdapRegex::rm_default(y, pattern=regex, extract=TRUE))
    })
}



