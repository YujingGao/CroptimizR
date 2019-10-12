#' @title Extract param names from prior information
#'
#' @param prior_information Prior information on the parameters to estimate.
#' For the moment only uniform distribution are allowed.
#' Either a list containing (named) vectors of upper and lower
#' bounds (\code{ub} and \code{lb}), or a named list containing for each
#' parameter the list of situations per group (\code{sit_list})
#' and the vector of upper and lower bounds (one value per group) (\code{ub} and \code{lb})
#'
#' @return A vector of parameter names
#'
#' @export
#'
#' @examples
#' # A simple case
#' prior_information=list(lb=c(dlaimax=0.0005, durvieF=50),
#'                        ub=c(dlaimax=0.0025, durvieF=400))
#' get_params_names(prior_information)
#'
#' # A case with groups of situations per parameter
#' prior_information=list()
#' prior_information$dlaimax=list(sit_list=list(c("bou99t3", "bou00t3", "bou99t1", "bou00t1", "bo96iN+", "lu96iN+", "lu96iN6", "lu97iN+")),lb=0.0005,ub=0.0025)
#' prior_information$durvieF=list(sit_list=list(c("bo96iN+", "lu96iN+", "lu96iN6", "lu97iN+"), c("bou99t3", "bou00t3", "bou99t1", "bou00t1")),lb=c(50,50),ub=c(400,400))
#' get_params_names(prior_information)

get_params_names <- function(prior_information) {

  if (!is.null(prior_information$lb) && !is.null(prior_information$ub)) {

    return(names(prior_information$lb))

  } else {

    nb_groups=sapply(prior_information, function (x) length(x$sit_list))

    # The name of the parameter is replicated by its number of groups
    res=names(prior_information)[unlist(sapply(1:length(nb_groups),function(x) rep(x,nb_groups[x])))]

    return(res)

  }

}