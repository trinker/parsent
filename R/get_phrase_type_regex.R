#' Regex Grab of Top Nest Phrases
#'
#' Uses a regex grab of phrases and corresponding sub-phrases and words.  For
#' example, \code{x <- "(NP, x)(NP, (VP a)(NP y))(VB z)"} will extract
#' \code{"(NP, x)"} & \code{"(NP, (VP a)(NP y))"} but not \code{(NP y)}
#' within the \code{"(NP, (VP a)(NP y))"}.  This function is useful over
#' \code{get_phrase_type} for certain parsing tasks in that is can be used at
#' any level of parse.
#'
#' @param x A parsed character string or list (see \code{parser}).
#' @param phrase A phrase type to extract phrases and corresponding words (see
#' \url{http://www.surdeanu.info/mihai/teaching/ista555-spring15/readings/PennTreebankConstituents.html}
#' for more on phrase types).
#' @return Returns a list of character vectors of extracted phrases.
#' @keywords phrase
#' @export
#' @author \href{http://stackoverflow.com/users/2206004/hwnd}{Jason Gray} and Tyler Rinker <tyler.rinker@@gmail.com>.
#' @references \url{http://stackoverflow.com/a/32899764/1000343}
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
#' get_phrase_type_regex(x, "VP")
#' get_phrase_type_regex(x, "NP")
#' get_phrase_type_regex(x, "VBZ")
#' get_phrase_type_regex(x, "V")
#'
#' ## get the words
#' get_leaves(get_phrase_type_regex(x, "NP"))
#'
#' ## As a dplyr chain
#' library(dplyr)
#' x %>%
#'     get_phrase_type_regex("NP") %>%
#'     get_leaves()
#'
#' ## With `get_phrase_type` as a dplyr chain
#' library(dplyr)
#' x %>%
#'     get_phrase_type("NP") %>%
#'     lapply(get_phrase_type_regex, "(PRP|NN)") %>%
#'     lapply(unlist)
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
get_phrase_type_regex <- function(x, phrase) {
    lapply(x, get_regex_phrase_helper, phrase = phrase)
}




get_regex_phrase_helper <- function(x, phrase) {
    if (is.na(x)) return(x)
    unlist(regmatches(x, gregexpr(build_regex_parse(phrase), x, perl=TRUE)))
}



build_regex_parse <- function(phrase){
    sprintf('(?x)
              (?=\\(%s)           # assert that subpattern precedes
                (                 # start of group 1
                \\(               # match open parenthesis
                    (?:           # start grouping construct
                        [^()]++   # one or more non-parenthesis (possessive)
                          |       # OR
                        (?1)      # found ( or ), recurse 1st subpattern
                    )*            # end grouping construct
                \\)               # match closing parenthesis
                )                 # end of group 1
         ',
         phrase
    )
}

