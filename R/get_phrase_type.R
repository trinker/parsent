#' Grab of Highest Level Phrases
#'
#' Grab the highest level phrases and corresponding sub-phrases and words.  This
#' parse uses a tree/list approach that is less prone to surprises than the
#' \code{get_phrase_type_regex} regex approach.
#'
#' @param x A parsed character string or list (see \code{parser}).
#' @param phrase A phrase type to extract phrases and corresponding words (see
#' \url{http://www.surdeanu.info/mihai/teaching/ista555-spring15/readings/PennTreebankConstituents.html}
#' for more on phrase types).
#' @return Returns a list of character vectors of extracted phrases.
#' @keywords phrase
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
#' get_phrase_type(x, "VP")
#' get_phrase_type(x, "NP")
#' get_phrase_type(x, "V")
#'
#' ## With `get_phrase_type_regex` as a dplyr chain
#' library(dplyr)
#' x %>%
#'     get_phrase_type("NP") %>%
#'     lapply(get_phrase_type_regex, "(PRP|NN)") %>%
#'     lapply(unlist)
#'
#' ## get the words
#' get_leaves(get_phrase_type(x, "NP"))
#'
#' ## As a dplyr chain
#' library(dplyr)
#' x %>%
#'     get_phrase_type("NP") %>%
#'     get_leaves()
#'
#' ## Subject
#' get_phrase_type(x, "NP") %>%
#'     take() %>%
#'     get_leaves()
#'
#' ## Predicate Verb
#' get_phrase_type_regex(x, "VP") %>%
#'     take() %>%
#'     get_phrase_type_regex("(VB|MD)") %>%
#'     take() %>%
#'     get_leaves()
#'
#' ## Direct Object
#' get_phrase_type_regex(x, "VP") %>%
#'     take() %>%
#'     get_phrase_type_regex("NP") %>%
#'     take() %>%
#'     get_leaves()
#' }
get_phrase_type <- function(x, phrase){
    y <- get_phrases(x)
    lapply(y, gpt, phrase)
}


gpt <- function(m, type){
    if (length(m) == 1 && is.na(m)) return(NA)
    m[grepl(paste0("^[(]", type), m, perl=TRUE)]
}

