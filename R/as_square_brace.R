#' Conver parser Output to Square Braces
#'
#' Many tree parsers (e.g., online, LaTeX, etc.) require square braces in the
#' parse.  These functions prepare the parse for use in other plotting venues.
#'
#' @param x A parse vector from \code{parser}.
#' @param \ldots ignored.
#' @return \code{as_square_brace} - returns a vector appropriate for use in a
#' many online parse tree generators.
#' @export
#' @note When using \code{as_square_brace_latex}, the user will need to add the
#' following LaTeX packages to the document: qtree, color, xcolor.  Additionally,
#' the user will need to add the code chunk, \code{\\newenvironment\{dummy\}\{\}\{\}},
#' to the preamble.
#' @rdname as_square_brace
#' @examples
#' \dontrun{
#' ## pass `as_square_brace` to an online parse tree:
#' ## http://yohasebe.com/rsyntaxtree
#' if(!exists('parse_ann')) {
#'     parse_ann <- parse_annotator()
#' }
#' x <- parser("Really, I like chocolate because it is good.", parse_ann)
#' xsquared <- as_square_brace(x)
#'
#' ## get tree from web
#' if (!require("pacman")) install.packages("pacman"); library(pacman)
#' p_load_gh("ropensci/RSelenium")
#' p_load(XML, RSelenium)
#'
#' # download Selenium Server, if not already present
#' checkForServer(); Sys.sleep(2)
#'
#' # Open a remote browser
#' remDr <- remoteDriver(
#'     remoteServerAddr = "localhost",
#'     port = 4444,
#'     browserName = "firefox"
#' )
#'
#' ## MIGHT NEED:
#' ## RSelenium::startServer()
#'
#' remDr$open()
#'
#' ## Now we pass the url from above and the page is opened
#' remDr$navigate("http://yohasebe.com/rsyntaxtree/")
#'
#' webElem <- remDr$findElement("css", "textarea[id='data']")
#' webElem$clearElement()
#' webElem$sendKeysToElement(list(xsquared)); Sys.sleep(.5)
#'
#'
#' webElem2 <- remDr$findElement("css", "button[id='draw_png']")
#' webElem2$clickElement()
#'
#' ## LaTeX Version
#' ## copy .Rmd from parser package
#' treeloc <- system.file("extra_files/testtree.Rmd", package = "parsent")
#' file.copy(treeloc, getwd())
#'
#' ## look at .Rmd
#' file.edit("testtree.Rmd")
#'
#' ## render .Rmd file
#' p_load(rmarkdown)
#' rmarkdown::render("testtree.Rmd")
#' }
as_square_brace <- function(x, ...){
    out <- m_gsub(c("(", ")"), c("[", "]"), gsub("(^\\(TOP )|\\)$", "", x))
    out[out == "NA"] <- NA
    out
}


#' @export
#' @rdname as_square_brace
#' @return \code{as_square_brace_latex} - returns a \code{\link[base]{cat}}
#' vector appropriate for use in a LaTeX document.
as_square_brace_latex <- function(x, ...){

    out <- as_square_brace(x)
    out <- gsub("( (?!\\[))([^]]+?)(\\])", " \\1\\\\color{green!65!blue}{\\2}\\3", out, perl=TRUE)
    out <- gsub("(\\[(?=[A-Z]))([^ ]+?)([ ])", "\\1 .\\\\textcolor{blue}{\\2} ", out, perl=TRUE)
    out <- gsub("(?<! )\\[", "[ ", gsub("(?! )\\]", " ]", out, perl=TRUE), perl=TRUE)
    out <- gsub("\\$", "\\\\$", out)

    invisible(lapply(out, function(x){
        if (is.na(x)) return(NULL)
        cat("\\begin{dummy}\n", "\\Tree ", x, "\n\\end{dummy}\n\n")
    }))
}

