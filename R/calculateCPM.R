#' Calculate counts per million (CPM)
#'
#' Calculate count-per-million (CPM) values from the count data.
#'
#' @param object A SingleCellExperiment object or count matrix.
#' @param exprs_values A string specifying the assay of \code{object} containing the count matrix, if \code{object} is a SingleCellExperiment.
#' @param use_size_factors A logical scalar indicating whether size factors in \code{object} should be used to compute effective library sizes.
#' If not, all size factors are deleted and library size-based factors are used instead (see \code{\link{librarySizeFactors}}.
#' Alternatively, a numeric vector containing a size factor for each cell, which is used in place of \code{sizeFactor(object)}.
#' @param subset_row A vector specifying the subset of rows of \code{object} for which to return a result.
#'
#' @details 
#' If requested, size factors are used to define the effective library sizes. 
#' This is done by scaling all size factors such that the mean scaled size factor is equal to the mean sum of counts across all features. 
#' The effective library sizes are then used to in the denominator of the CPM calculation.
#'
#' Assuming that \code{object} is a SingleCellExperiment:
#' \itemize{
#' \item If \code{use_size_factors=TRUE}, size factors are automatically extracted from the object.
#' Note that effective library sizes may be computed differently for features marked as spike-in controls.
#' This is due to the presence of control-specific size factors in \code{object}, see \code{\link{normalizeSCE}} for more details.
#' \item If \code{use_size_factors=FALSE}, all size factors in \code{object} are ignored.
#' The total count for each cell will be used as the library size for all features (endogenous genes and spike-in controls).
#' \item If \code{use_size_factors} is a numeric vector, it will override the any size factors for non-spike-in features in \code{object}.
#' The spike-in size factors will still be used for the spike-in transcripts.
#' }
#' If no size factors are available, the library sizes will be used.
#'
#' If \code{object} is a matrix or matrix-like object, size factors will only be used if \code{use_size_factors} is a numeric vector.
#' Otherwise, the sum of counts for each cell is directly used as the library size.
#'
#' @return Numeric matrix of CPM values.
#' @export
#' @importFrom SingleCellExperiment SingleCellExperiment
#' @importFrom SummarizedExperiment assay
#' @importFrom BiocGenerics sizeFactors sizeFactors<- 
#' @importFrom DelayedArray DelayedArray
#' @importFrom DelayedMatrixStats colSums2
#'
#' @examples
#' data("sc_example_counts")
#' data("sc_example_cell_info")
#' example_sce <- SingleCellExperiment(
#'     list(counts = sc_example_counts), 
#'     colData = sc_example_cell_info)
#'
#' cpm(example_sce) <- calculateCPM(example_sce, use_size_factors = FALSE)
#'
calculateCPM <- function(object, exprs_values="counts", use_size_factors = TRUE, subset_row = NULL) {
    subset_row <- .subset2index(subset_row, object, byrow=TRUE)
    if (!is(object, "SingleCellExperiment")) {
        assays <- list(object)
        names(assays) <- exprs_values
        object <- SingleCellExperiment(assays)
    }

    # Setting up the size factors.
    object <- .replace_size_factors(object, use_size_factors)
    lib_sizes <- colSums2(assay(object, exprs_values, withDimnames=FALSE), rows=subset_row)
    if (is.null(sizeFactors(object))) {
        sizeFactors(object) <- lib_sizes
    }

    meanlib_millions <- mean(lib_sizes)/1e6
    object <- centreSizeFactors(object, centre=meanlib_millions)
    sf.list <- .get_all_sf_sets(object)

    # Computing the CPM values.
    output <- .Call(cxx_norm_exprs, assay(object, i = exprs_values, withDimnames=FALSE),
        sf.list$size.factors, sf.list$index - 1L,
        0, FALSE, subset_row = subset_row - 1L)

    dimnames(output) <- list(rownames(object)[subset_row], colnames(object))
    output
}
