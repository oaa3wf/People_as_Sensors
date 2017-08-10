function [ l_t_current ] = occupancy_grid_mapping( l_t_past,p_t,z_t )
%OCCUPANCY_GRID_MAPPING This function computes the loglikelihood
%of occupancy over a grid given the previous belief, current robot 
%position and current measurement
%   @param l_t_past {[x,y,l_t-1]} - an nx3 matrix with center of mass of
%   grid points (x,y) and past belief of loglikelihood of occupancy
%   
%   @param p_t {[x_t,y_t]} - a 2x1 vector containing current robot x,y
%   position values.
%
%   @param z_t -  the format of the data is: 
%   [(IDs for all objects) (range to each) (angle to each obj) 
%   (elevation angle to each obj) (velocity of each obj) (heading of each obj)]
%   note that this is ordered by object so we have to go through each one.
%   if the ID entry is 0, then the object is not detected. Divide by 6 to get
%   number of objects detected.
%
%   @return l_t_current {[x,y,l_t]} - an nx3 matrix with center of mass of
%   grid points (x,y) and current belief of loglikelihood of occupancy

l_t_current = l_t_past;
n = size(l_t_current,1);

x = p_t(1);
y = p_t(2);

% fixed parameter l_0
 l_0 = 0; % corresponding to 50% probability for unknown regions
 inverse_debug = zeros(size(l_t_current,1),1);

for i =1:n 
    x_i = l_t_current(i,1);
    y_i = l_t_current(i,2);
    
    if(norm([x_i;y_i]-[x,;y]) <= 0.5 )
        %x_i
        %y_i
        %x
        %y
    end
    if(isInPerceptualField(x_i,y_i,x,y) == 1)
        m_i = [x_i;y_i];
        l_t_current(i,3) = state_transition_model(m_i,l_t_current(i,3)) + inverse_range_sensor_model(m_i,p_t,z_t,l_0)- l_0;
        %l_t_current(i,3) = l_t_current(i,3) + inverse_range_sensor_model(m_i,p_t,z_t,l_0)- l_0;
        inverse_debug(i) = inverse_range_sensor_model(m_i,p_t,z_t,l_0);
    end
    
    
end



end

