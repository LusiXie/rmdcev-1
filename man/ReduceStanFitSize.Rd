% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/maxLikeMDCEV.R
\name{ReduceStanFitSize}
\alias{ReduceStanFitSize}
\title{ReduceStanFitSize}
\usage{
ReduceStanFitSize(stan_fit)
}
\arguments{
\item{stan_fit}{A stanfit object.}
}
\value{
A stanfit object with a reduced size.
}
\description{
This function reduces the size of the stan.fit object to reduce the time
it takes to return it from the R server.
}
