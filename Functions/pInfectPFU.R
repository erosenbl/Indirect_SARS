#Dose-response function for PFU, Wells-Riley
#' A simple function to estimate probability of infection given the dose 
#' received and the efficiency of ingestion to cause an infection from the dose.
#'
#' @param dose Amount of plaque-forming units (PFU) received by a susceptible 
#' individuals.
#' @param eff Transfer efficiency of SARS-CoV-2 via ingestion.
#'
#' @return A vector of probabilities of infection given dose received and 
#' transfer efficiency.
#' @export
#'
#' @examples
#' \dontrun{
#' pInfectPFU(dose = 10, eff = 0.5)
#' pInfectPFU(dose = runif(n = 20, min = 5, max = 20), eff = 0.8)
#' }
pInfectPFU <- function(dose, eff=1)
  {1 - exp(-(1/420)*dose*eff)}