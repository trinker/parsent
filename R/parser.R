#' Parse Sentences
#'
#' A wrapper for \pkg{NLP},/\pkg{openNLP}'s named sentence parsing tools.
#'
#' @param text.var The text string variable.
#' @param parse.annotator A parse annotator.  See \code{?parse_annotator}.  Due
#' to \pkg{Java} memory allocation limits the user must generate the annotator
#' and supply it directly to \code{parser}.
#' @param word.annotator A word annotator.
#' @param element.chunks The number of elements to include in a chunk. Chunks are
#' passed through an \code{\link[base]{lapply}} and size is kept within a tolerance
#' because of memory allocation in the tagging process with \pkg{Java}.
#' @return Returns a list of character vectors of parsed sentences.
#' @keywords parse sentence
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
#' plot(x[[2]])
#' par(
#'     mfrow = c(3, 2),
#'     oma = c(5,4,0,0) + 0.1,
#'     mar = c(0,0,1,1) + 0.1
#' )
#' lapply(x[1:5], plot)
#' }
parser <- function(text.var, parse.annotator, word.annotator = word_annotator(),
    element.chunks = floor(2000 * (23.5/mean(sapply(text.var, nchar), na.rm = TRUE)))){

    len <- length(text.var)

    ## locate empty or missing text elements
    nas <- sort(union(which(is.na(text.var)), grep("^\\s*$", text.var)))

    ## replace empty text with a period
    if(!identical(nas, integer(0))){
       text.var[nas] <- "."
    }

    ## Chunking the text into memory sized chunks:
    ## caluclate the start/end indexes of the chunks
    ends <- c(utils::tail(seq(0, by = element.chunks,
        length.out = ceiling(len/element.chunks)), -1), len)
    starts <- c(1, utils::head(ends + 1 , -1))

    ## chunk the text
    text_list <- Map(function(s, e) {text.var[s:e]}, starts, ends)

    ## loop through the chunks and tag them
    out <- unlist(lapply(text_list, function(x){
        x <- parsify(x, word.annotator, parse.annotator)
        gc()
        x
    }))

    out[nas] <- NA

    out <- as.list(out)
    lapply(out, function(x){
        if (is.na(x)) return(NA)
        class(x) <- c("parsed_character", "character")
        x
    })
}


parsify <- function(text.var, word, parse, ...){

    #text.var <- gsub("-+", " ", text.var)
    text.var <- gsub("^\\s+|\\s+$", "", text.var)
    s <- NLP::as.String(paste(text.var, collapse=""))

    ## Manually calculate the starts and ends via nchar
    lens <- sapply(text.var, nchar)
    ends <- cumsum(lens)
    starts <- c(1, utils::head(ends + 1, -1))

    a2 <- NLP::Annotation(seq_along(starts), rep("sentence", length(starts)), starts, ends)
    a2 <- NLP::annotate(s, word, a2)
    p <- parse(s, a2)
    sapply(p$features, `[[`, "parse")

}


#' Prints a parsed_character Object
#'
#' Prints a parsed_character object
#'
#' @param x A parsed_character Object.
#' @param \ldots ignored.
#' @method print parsed_character
#' @export
print.parsed_character <- function(x, ...){
    class(x) <- "character"
    print(x)
}


#' Plots a plot.parsed_character Object
#'
#' Plots a plot.parsed_character object
#'
#' @param x A \code{parsed_character} object (see \code{\link[parsent]{parser}}.
#' @param vertex.color The vertex color (see \code{?igraph::igraph_options}).
#' @param vertex.frame.color The vertex frame color (see \code{?igraph::igraph_options}).
#' @param vertex.label.font The vertex label font (see \code{?igraph::igraph_options}).
#' @param vertex.label.cex The vertex label scaled relative to the default (see
#' \code{?igraph::igraph_options}).
#' @param edge.width The edge width (see \code{?igraph::igraph_options}).
#' @param edge.color The edge color (see \code{?igraph::igraph_options}).
#' @param edge.arrow.size The edge arrow size (see \code{?igraph::igraph_options}).
#' @param leaf.color The color of the leaves (tokens).
#' @param phrase.marker.color The color of the non-terminal grammar categories
#' (e.g., NP, VP, D, etc.).
#' @param title The main title of the graph.
#' @param cex.title The size of the title relative to the default.
#' @param asp The y/x aspect ratio.
#' @param \ldots Other arguments passed to \code{\link[igraph]{plot.igraph}}.
#' @author StackOverflow's \href{http://stackoverflow.com/users/2415684/thetime}{TheTime} and Tyler Rinker <tyler.rinker@@gmail.com>.
#' @references \url{http://stackoverflow.com/a/33536291/1000343}
#' @method plot parsed_character
#' @export
plot.parsed_character <- function(x, vertex.color=NA, vertex.frame.color=NA,
    vertex.label.font=2, vertex.label.cex=1, edge.width=1.5,
    edge.color='black', edge.arrow.size=0, leaf.color='chartreuse4',
    phrase.marker.color='blue4', title=NULL, cex.title=.9, asp=0.5, ...) {

    ## Replace words with unique versions
    ms <- gregexpr("[^() ]+", x)                                      # just ignoring spaces and brackets?
    words <- regmatches(x, ms)[[1]]                                   # just words
    regmatches(x, ms) <- list(paste0(words, seq.int(length(words))))  # add id to words

    ## Going to construct an edgelist and pass that to igraph
    ## allocate here since we know the size (number of nodes - 1) and -1 more to exclude 'TOP'
    edgelist <- matrix('', nrow=length(words)-2, ncol=2)

    ## Function to fill in edgelist in place
    edgemaker <- (function() {
        i <- 0                                       # row counter
        g <- function(node) {                        # the recursive function
            if (inherits(node, "Tree")) {            # only recurse subtrees
                if ((val <- node$value) != 'TOP1') { # skip 'TOP' node (added '1' above)
                    for (child in node$children) {
                        childval <- if(inherits(child, "Tree")) child$value else child
                        i <<- i+1
                        edgelist[i,1:2] <<- c(val, childval)
                    }
                }
                invisible(lapply(node$children, g))
            }
        }
    })()

    ## Create the edgelist from the parse tree
    edgemaker(NLP::Tree_parse(x))

    ## Make the graph, add options for coloring leaves separately
    g <- igraph::graph_from_edgelist(edgelist)
    igraph::vertex_attr(g, 'label.color') <- phrase.marker.color  # non-leaf colors
    igraph::vertex_attr(g, 'label.color', igraph::V(g)[!igraph::degree(g, mode='out')]) <- leaf.color
    igraph::V(g)$label <- sub("\\d+", '', igraph::V(g)$name)      # remove the numbers for labels
    igraph::plot.igraph(g, layout=igraph::layout.reingold.tilford, vertex.color = vertex.color,
        vertex.frame.color = vertex.frame.color,
        vertex.label.font = vertex.label.font,
        vertex.label.cex = vertex.label.cex, asp = asp, edge.width = edge.width,
        edge.color = edge.color, edge.arrow.size = edge.arrow.size)
    if (!missing(title)) title(title, cex.main=cex.title)
}
