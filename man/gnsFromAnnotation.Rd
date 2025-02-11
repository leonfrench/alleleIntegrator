% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{gnsFromAnnotation}
\alias{gnsFromAnnotation}
\title{Build genes from annotation}
\usage{
gnsFromAnnotation(gCnts, geneID = gCnts$geneID)
}
\arguments{
\item{gCnts}{GRanges object to construct genes object from.  Usually something on which \code{\link{annotateSNPs}} has been run.}

\item{geneID}{Vector or list of same length as \code{gCnts} which will be used to build output.}
}
\value{
GRanges with gene ranges.
}
\description{
Given a \code{gCnts} object with gene information (usually from having run \code{\link{annotateSNPs}}), build a GRanges object with all the genes.
}
