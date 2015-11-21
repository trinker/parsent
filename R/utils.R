m_gsub <- function (pattern, replacement, text.var, leadspace = FALSE,
    trailspace = FALSE, fixed = TRUE, trim = TRUE, order.pattern = fixed,
    ...) {

    if (leadspace | trailspace) replacement <- spaste(replacement, trailing = trailspace, leading = leadspace)

    if (fixed && order.pattern) {
        ord <- rev(order(nchar(pattern)))
        pattern <- pattern[ord]
        if (length(replacement) != 1) replacement <- replacement[ord]
    }
    if (length(replacement) == 1) replacement <- rep(replacement, length(pattern))

    for (i in seq_along(pattern)){
        text.var <- gsub(pattern[i], replacement[i], text.var, fixed = fixed, ...)
    }

    if (trim) text.var <- gsub("\\s+", " ", gsub("^\\s+|\\s+$", "", text.var, perl=TRUE), perl=TRUE)
    text.var
}


spaste <- function (terms, trailing = TRUE, leading = TRUE) {
    if (leading) {
        s1 <- " "
    }
    else {
        s1 <- ""
    }
    if (trailing) {
        s2 <- " "
    }
    else {
        s2 <- ""
    }
    pas <- function(x) paste0(s1, x, s2)
    if (is.list(terms)) {
        z <- lapply(terms, pas)
    }
    else {
        z <- pas(terms)
    }
    return(z)
}
