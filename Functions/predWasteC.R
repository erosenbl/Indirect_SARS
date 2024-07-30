#' pred.waste.C: a function to predict SARS-CoV-2 viral load in raw sewage using
#'  human prevalence
#'
#' @param humanPositivity A vector of proportion(s) of human population infected
#' with SARS-CoV-2.
#' @param model The model coefficient used to make this prediction. Default 
#' coefficient is stored in Data/PFUWastePosRelationship.RDS.
#'
#' @return Prediced SARS-CoV-2 viral laod in raw sewage
#' @export
#'
#' @examples
#' \dontrun{
#' pred.waste.C(0.1, model = 
#' readRDS("Software Release/Data/PFUWastePosRelationship.RDS"))
#' }
pred.waste.C <- function(humanPositivity, model) 
{predict(model, newdata = data.frame(Positivity = humanPositivity), 
         se.fit = TRUE )}
