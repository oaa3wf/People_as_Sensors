function [ l ] = state_transition_model(m_i, l_t_past)
%STATE_TRANSITION_MODEL This function computes the log_likelihood of 
%of occupancy of cell m_i at time t, given the log_likelihood of 
%cell m_i at time t-1
%   Explanantion is above
%   @param m_i {[x_i, y_i,]} - a 2x1 vector of query cell position (center of mass) in grid
%   
%   @param l_t_past - a scalar value, loglikelihood, indicating the probability of
%   occupancy cell m_i at time t-1
%
%   @ return l - loglikelihood corresponding to update of bayesian filter.

p_t_past = 1-(1./(1+exp(l_t_past)));

p_update = 0.3*p_t_past + 0.1*(1-p_t_past);

l = log(p_update/(1-p_update));
    


end

