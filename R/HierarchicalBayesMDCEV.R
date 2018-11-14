#' @title HierarchicalBayesMDCEV
#' @description Fit a MDCEV model HB
#' @import rstan
#' @import dplyr
#' @export
#'

HierarchicalBayesMDCEV <- function(dat,
								   model_option,
								   hb_options,
								 seed = 123,
								 initial.parameters = initial.parameters,
								 keep.samples = FALSE,
								 include.stanfit = TRUE,
								 hb_random_parameters = hb_random_parameters,
								 show.stan.warnings = TRUE)
{
	if (model_option$n_iterations <= 0)
		stop("The specified number of iterations must be greater than 0.")

	# allows Stan chains to run in parallel on multiprocessor machines
	options(mc.cores = parallel::detectCores())

	# Create indices for individual level psi parameters
	indexes <- data_frame(individual = rep(1:dat$I, each = dat$J),
						  task = rep(1:dat$I, each = dat$J),
						  row = 1:(dat$I*dat$J)) %>%
		group_by(task) %>%
		summarise(task_individual = first(individual),
				  start = first(row),
				  end = last(row))

	dat$start = indexes$start
	dat$end = indexes$end
	dat$task_individual = indexes$task_individual
	dat$task = indexes$task
	dat$IJ = dat$I * dat$J
	dat$lkj_shape = hb_option$hb.lkj.prior.shape

#	initial.parameters2 <- list(initial.parameters)#, initial.parameters,initial.parameters,initial.parameters)
#	initial.parameters2 <- list(list(scale = as.array(1, dim = 1)))#, initial.parameters,initial.parameters,initial.parameters)

#	has.covariates <- !is.null(dat$covariates)
	stan.model <- stanModel(hb_random_parameters)

#	on.warnings <- GetStanWarningHandler(show.stan.warnings)
#	on.error <- GetStanErrorHandler()


#	InterceptExceptions(
#		{
	stan_fit <- RunStanSampling(dat, hb_option$n_iterations, hb_option$n_chains,
								hb_option$max.tree.depth, hb_option$adapt.delta, seed,
								stan.model, keep.beta)
#		}, warning.handler = on.warnings, error.handler = on.error)

#		result <- c(result, LogLikelihoodAndBIC(stan.fit, #n.hb.parameters,
#												stan.dat$R,
#												dat$n.questions.left.out,
#												dat$subset))
#		result

	result <- list()
	result$stan_fit <- stan_fit
#	n_parameters <- stan_fit[["par_dims"]][["mu"]] + stan_fit[["par_dims"]][["tau"]]
#	result$log.likelihood <- stan_fit[["par"]][["sum_log_lik"]]
#	result$effective.sample.size <- ess <- sum(weights)
#	n_parameters <- n_classes * n_parameters + n_classes - 1
#	result$bic <- -2 * result$log.likelihood + log(ess) * n_parameters
#	result$log.likelihood
	result
}

#' @title RunStanSampling
#' @description Wrapper function for \code{rstan:stan} and
#' \code{rstan:sampling} to run Stan HB analysis.
#' @param stan.dat The data to be passed to Stan.
#' @param n_iterations The number of iterations in the analysis.
#' @param n_chains The number of chains in the analysis.
#' @param max.tree.depth Maximum tree depth setting. See Stan documentation.
#' @param adapt.delta Adapt delta setting. See Stan documentation.
#' @param seed Random seed.
#' @param stan.model Complied Stan model
#' @param keep.beta Whether retain the beta draws in the output.
#' @param pars Stan parameters whose draws to retain. If NULL, a default
#'     selection of parameters is used instead.
#' @param ... Additional parameters to pass on to \code{rstan::stan} and
#' \code{rstan::sampling}.
#' @return A stanfit object.
#' @importFrom rstan stan sampling
#' @import Rcpp
#' @export
RunStanSampling <- function(stan.dat, n_iterations, n_chains, max.tree.depth,
							adapt.delta, seed, stan.model, keep.beta)
{
#	if (is.null(pars))
#		pars <- stanParameters(stan.dat, keep.beta, stan.model)
#	init <- initialParameterValues(stan.dat)
	sampling(stan.model, data = stan.dat, chains = n_chains,
#			 pars = pars,
			 iter = n_iterations, seed = seed,
			 control = list(max_treedepth = max.tree.depth,
			 			   adapt_delta = adapt.delta))
#			 init = init,
}


#stanParameters <- function(stan.dat, keep.beta, stan.model)
#{
#	full.covariance <- is.null(stan.dat$U)
#	multiple.classes <- !is.null(stan.dat$P)
#	has.covariates <- !is.null(stan.dat$covariates)
#
#	pars <- c("theta", "sigma")
#
#	if (multiple.classes)
#	{
#		if (has.covariates)
#			pars <- c(pars, "covariates_beta")
#		else
#			pars <- c(pars, "class_weights")
#	}else if (stan.model@model_name == "choicemodelRCdiag")
#		pars <- c("resp_fixed_coef", "sigma", "sig_rc",
#				  "log_likelihood")
#	if (keep.beta)
#		pars <- c(pars, "beta")
#
#	pars
#}


stanModel <- function(hb_random_parameters)
{
	covariates.error.msg <- paste0("Covariates are not currently implemented ",
								   "for the specified settings.")
#	if (n_classes == 1)
#	{
		if (hb_random_parameters == "fixed")
			stanmodels$mdcev
		else if (hb_random_parameters == "uncorr")
			stanmodels$mdcev_hb_uncorr
		else if (hb_random_parameters == "corr")
			stanmodels$mdcev_hb_corr
#	}
}