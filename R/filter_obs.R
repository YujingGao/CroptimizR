#' @title Filter observation list to exclude situations, variables or dates
#'
#' @inheritParams estim_param
#' @param var_names (optional, if not given all variables will be kept) Vector containing the names of the variables to include or exclude
#' @param sit_names (optional, if not given all situations will be kept) Vector containing the names of the situations to include or exclude
#' @param dates (optional, if not given all dates will be kept) Vector containing the dates (POSIXct format) to include or exclude
#' @param include (optional, FALSE by default) Flag indicating if the variables / situations / dates listed in inputs must be included (TRUE) or not (FALSE) in the resulting list
#'
#' @return obs_list List of filtered observed values (same format as `obs_list` input argument)
#'
#' @seealso For more detail and examples, see the different vignettes in
#' [CroptimizR website](https://sticsrpacks.github.io/CroptimizR/)
#'
#' @export
#'
#' @importFrom rlang .data
#'
#' @examples
#'
#' obs_list <- list(sit1=data.frame(Date=as.POSIXct(c("2009-11-30","2009-12-10")),
#'                                  var1=c(1.1,1.5),var2=c(NA,2.1)),
#'                  sit2=data.frame(Date=as.POSIXct(c("2009-11-30","2009-12-5")),
#'                                  var1=c(1.3,2)))
#'
#' # Keep only var1
#' filter_obs(obs_list,var_names=c("var1"),include=TRUE)
#'
#' # Exclude observations at date "2009-11-30"
#' filter_obs(obs_list,dates=as.POSIXct(c("2009-11-30")))
#'
#'

filter_obs <- function(obs_list, var_names=NULL, sit_names=NULL, dates=NULL, include=FALSE) {

  # Check obs_list format
  if (!CroptimizR:::is.obs(obs_list)) {
    stop("Incorrect format for argument obs_list.")
  }

  # Filter Situations
  ## check that sit_names are in obs_list
  if (!is.null(sit_names)) {
    tmp=intersect(sit_names,names(obs_list))
    if (is.null(tmp) || !setequal(tmp,sit_names)) {
      warning("Argument sit_names contains situations that are not included in obs_list. \n obs_list contains: ",paste(names(obs_list), collapse=" "))
      sit_names=tmp
    }
    ## Filter
    if (include) {
      obs_list=obs_list[sit_names]
    } else {
      obs_list[sit_names]=NULL
      if (length(obs_list)==0) {
        warning("All situations have been excluded from the list")
        return(NULL)
      }
    }
  }


  # Transform obs_list in a data.frame for easier filtering of var and dates
  df=dplyr::bind_rows(obs_list,.id="id")

  # Filter Variables
  ## check that var_names are in obs_list
  if (!is.null(var_names)) {
    tmp=intersect(var_names,names(df))
    if (is.null(tmp) || !setequal(tmp,var_names)) {
      warning("Argument var_names contains variables that are not included in obs_list. \n obs_list contains: ",paste(colnames(df),collapse=" "))
      var_names=tmp
    }
    ## Filter
    if (include) {
      df=df[,c("id","Date",var_names)]
    } else {
      df[var_names]=NULL
      if (ncol(df)==2) {
        warning("All variables have been excluded from the list")
        return(NULL)
      }
    }
  }

  # Filter Dates
  ## check that dates are in obs_list
  if (!is.null(dates)) {
    included=sapply(dates, function(x) any(df$Date==x))
    if (!all(c=included)) {
      warning("Argument dates contains dates that are not included in obs_list: ",paste(dates[!included], collapse=" "))
      dates=dates[included]
    }
    ## Filter
    if (include) {
      df= dplyr::filter(df,.data$Date==dates)
    } else {
      df= dplyr::filter(df,.data$Date!=dates)
      if (nrow(df)==0) {
        warning("All dates have been excluded from the list.")
        return(NULL)
      }
    }
  }

  # Remove columns / lines with only NA, and warns the user
  ind_NA_row=sapply(1:nrow(df),function(x) all(is.na(df[x,3:ncol(df)])))
  df=df[!ind_NA_row,]
  ind_NA_col=sapply(1:ncol(df),function(x) all(is.na(df[,x])))
  df=df[,!ind_NA_col]
  if (any(ind_NA_col)) {
    warnings("No more observations of variables ",colnames(df)[ind_NA_col])
  }

  # Re-transform the df into a list
  obs_list=split(df, df$id)
  obs_list=lapply(obs_list,function(x) x[-1]) # remove id column

  return(obs_list)

}
