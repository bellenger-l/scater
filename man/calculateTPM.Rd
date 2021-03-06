% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculateTPM.R
\name{calculateTPM}
\alias{calculateTPM}
\title{Calculate transcripts-per-million (TPM)}
\usage{
calculateTPM(object, effective_length = NULL, exprs_values = "counts",
  subset_row = NULL)
}
\arguments{
\item{object}{A SingleCellExperiment object or a count matrix.}

\item{effective_length}{Numeric vector containing the effective length for each feature in \code{object}.
If \code{NULL}, it is assumed that \code{exprs_values} has already been adjusted for transcript length.}

\item{exprs_values}{String or integer specifying the assay containing the counts in \code{object}, if it is a SingleCellExperiment.}

\item{subset_row}{A vector specifying the subset of rows of \code{object} for which to return a result.}
}
\value{
A numeric matrix of TPM values.
}
\description{
Calculate transcripts-per-million (TPM) values for expression from counts for a set of features.
}
\details{
For read count data, this function assumes uniform coverage along the (effective) length of the transcript.
Thus, the number of transcripts for a gene is proportional to the read count divided by the transcript length.

For UMI count data, this function should be run with \code{effective_length=NULL}, i.e., no division by the effective length.
This is because the number of UMIs is a direct (albeit probably biased) estimate of the number of transcripts.
}
\examples{
data("sc_example_counts")
data("sc_example_cell_info")
example_sce <- SingleCellExperiment(
    assays = list(counts = sc_example_counts), 
    colData = sc_example_cell_info)

eff_len <- runif(nrow(example_sce), 500, 2000)
tout <- calculateTPM(example_sce, effective_length = eff_len)


}
