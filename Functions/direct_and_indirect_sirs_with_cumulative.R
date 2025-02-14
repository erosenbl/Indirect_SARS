#' Function to generate SIRS model projections, including both direct and 
#' indirect transmission
#'
#' `direct_and_indirect_sirs_with_cumulative` is written to work alongside the
#' `deSolve::ode()` function, and it will return an object with the proportion
#' of individuals found in each of the SIR compartments at each of the specified
#' time points.
#'
#' @param time vector of values for which to generate the projection (length in
#'   days).
#' @param state initial state for compartment populations. This should be a
#'   named vector for starting values of S_wild, I_wild, R_wild,
#'   I_wild_cumulative, S_captive, I_captive, R_captive, I_captive_cumulative.
#' @param parameters list of parameters to generate projection. The parameters
#'   should include transmission parameters, immunity and recovery rates, and
#'   proportion of infected humans.
#'
#' @details `direct_and_indirect_sirs_with_cumulative()` cannot be run with 
#' `run_steady()` to estimate probability of persistence. Instead, use 
#' `simple_sirs()`, which does
#' not return cumulative proportion of population infected. The parameter
#' `boost` is included in the ODE equations for captive deer to allow
#' implementation of applying vaccine boosters to captive deer herds as a
#' potential management alternative to influence outbreak dynamics. See the
#' vignette `Management_Alternative_Systems.Rmd` from the whitetailedSIRS 
#' package to see an example of its use.
#' In all other cases where boosters would not be applied, boost should be set
#' to 0.
#'
#' @return when used with the `deSolve::ode()` function, it will return a
#' dataframe with the proportion of individuals in each of the SIR compartments
#' at each time point, as well as a cumulative case count (proportion)
#' @export
#'
#'
#'
#' @examples
#' # prepare the input parameters:
#' example_inits <- c(S_wild = 1, I_wild = 0,
#'                    R_wild = 0, I_wild_cumulative = 0,S_captive = 1,
#'                    I_captive = 0, R_captive = 0, I_captive_cumulative = 0)
#'
#' # set the time to run
#' example_times <-  seq(0, 500, by = 1)
#' # Set parameters of transmission, immunity, recovery
#'
#' example_params <- c(alpha_immunity = 0.03,
#'                     beta_aero_ww = 0.01,
#'                     beta_aero_cw = 0.01,
#'                     beta_aero_cc = 0.02,
#'                     beta_aero_hw = 0.01,
#'                     beta_aero_hc = 0.2,
#'                     beta_dc_ww = 0.01,
#'                     beta_dc_cw = 0.01,
#'                     beta_dc_cc = 0.01,
#'                     beta_wastewater = 0.001,
#'                     beta_food_waste = 0.001,
#'                     beta_feed_pile = 0.001,
#'                     gamma_recov = 0.01,
#'                     I_human = 0.05,
#'                     boost = 0)
#'
#' # run the ode function:
#'
#' deSolve::ode(y = example_inits,
#' times = example_times,
#' parms = example_params,
#' func = direct_and_indirect_sirs_with_cumulative)
#'
#'
direct_and_indirect_sirs_with_cumulative <- function(time, state, parameters){
   with(as.list(c(state, parameters)), {

      # wild deer functions

      dS_wild <- alpha_immunity * R_wild -
         (S_wild * ((beta_aero_ww * I_wild) + (beta_dc_ww * I_wild) +
                       (beta_aero_cw * I_captive) + (beta_dc_cw * I_captive) +
                       (beta_aero_hw * I_human) + beta_wastewater + 
                      (beta_food_waste * I_human) + (beta_feed_pile * I_wild)))

      dI_wild <- (S_wild * ((beta_aero_ww * I_wild) + (beta_dc_ww * I_wild) +
                               (beta_aero_cw * I_captive) + 
                              (beta_dc_cw * I_captive) +
                               (beta_aero_hw * I_human) + beta_wastewater + 
                              (beta_food_waste * I_human) + 
                              (beta_feed_pile * I_wild))) -
         (gamma_recov * I_wild)

      dR_wild <- (gamma_recov * I_wild) -
         (alpha_immunity * R_wild)

      cumulative_I_wild <- (S_wild * ((beta_aero_ww * I_wild) + 
                                        (beta_dc_ww * I_wild) +
                                         (beta_aero_cw * I_captive) + 
                                        (beta_dc_cw * I_captive) +
                                         (beta_aero_hw * I_human) + 
                                        beta_wastewater +
                                        (beta_food_waste * I_human) + 
                                        (beta_feed_pile * I_wild)))

      # captive deer functions

      dS_captive <- alpha_immunity * R_captive -
         (S_captive * ((beta_aero_cc * I_captive) + (beta_dc_cc *I_captive) +
                          (beta_aero_cw * I_wild) + (beta_dc_cw * I_wild) +
                          (beta_aero_hc * I_human))) - (S_captive*boost)

      dI_captive <- (S_captive * ((beta_aero_cc * I_captive) + 
                                    (beta_dc_cc *I_captive) +
                                     (beta_aero_cw*I_wild) + 
                                    (beta_dc_cw * I_wild) +
                                     (beta_aero_hc * I_human))) -
         (gamma_recov * I_captive)

      dR_captive <- (gamma_recov * I_captive) -
         (alpha_immunity * R_captive) + (S_captive*boost)

      cumulative_I_captive <- (S_captive * ((beta_aero_cc * I_captive) + 
                                              (beta_dc_cc *I_captive) +
                                               (beta_aero_cw*I_wild) + 
                                              (beta_dc_cw * I_wild) +
                                               (beta_aero_hc * I_human)))

      return(list(c(dS_wild, dI_wild, dR_wild, cumulative_I_wild, dS_captive, 
                    dI_captive, dR_captive, cumulative_I_captive)))
   })
}
