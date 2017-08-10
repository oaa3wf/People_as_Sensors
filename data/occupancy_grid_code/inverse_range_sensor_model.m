function [ l ] = inverse_range_sensor_model(m_i,p_t, z_t, l_0)
%INVERSE_RANGE_SENSOR_MODEL This function returns the log likelihood
%of occupancy of cell m_i, at time t, given position of robot x_t
%and range measurement z_t
%   This function is similar to that in Prob. Robotics p.g 288
%   @param m_i {[x_i, y_i,]} - a 2x1 vector of query cell position (center of mass) in grid
%
%   @param p_t {[x_t, y_t, theta_t]} - a 3x1 vector with robot x,y postion 
%   and heading theta in grid at time t
%
%   @param z_t {[]} -  the format of the data is: 
%   [(IDs for all objects) (range to each) (angle to each obj) 
%   (elevation angle to each obj) (velocity of each obj) (heading of each obj)]
%   note that this is ordered by object so we have to go through each one.
%   if the ID entry is 0, then the object is not detected. Divide by 6 to get
%   number of objects detected.
%
%   @return l - loglikelihood of cell m_i being occupied based only on
%   current measurement

%   some fixed parameters for the sensor
    l_occ = log(0.99/(1-0.99)); % corresponding to 99% for occupied measurement
    l_free = log((1-0.99)/(0.99)); % value returned if unoccupied. Idea is that
%   three unoccupied measurements cancel out preiously occupied
%   measurement. This should allow for dynamic obstacles.

    alpha = 2; % about the length of the car
    beta = 0.175*2/(4*2); % about 2.5 degrees in radians, thickness of beam
    
    z_max = 120; % max range
    
    x_i = m_i(1);
    y_i = m_i(2);
    
    x_t = floor(p_t(1));
    y_t = floor(p_t(2));
    theta_t = p_t(3); % already between -pi to pi
    %r_t = norm([x_t;y_t])
    
    r = sqrt((x_i-x_t)^2 + (y_i-y_t)^2);
    phi = atan2(x_i-x_t,y_i-y_t)-theta_t;
    
    % keep within -pi to pi
%     if(phi > pi)
%         phi = phi - pi;
%     elseif (phi < -pi)
%         phi = phi + pi;
%     end
    
    num_of_objects_detected = size(z_t,2)/6;
    col_sz = size(z_t,2);
    
    % each row of data is sensor data for each object
    data = zeros(num_of_objects_detected,6);
    for i = 1:num_of_objects_detected
        tmp = [i:num_of_objects_detected:col_sz];
        data(i,:) = z_t(tmp);
        % make sure undetected objects don't mess everything up
        if(data(i,1)) == 0
            data(i,:) = Inf;
        end
    end
    
    % add own position as obstacle
%    (IDs for all objects) (range to each) (angle to each obj) 
%   (elevation angle to each obj) (velocity of each obj) (heading of each obj)]
    data(size(data,1)+1,:) = [100,0,0,0,0,0];
    %data
    
    if (norm(m_i -[5; 100]) <= 2.0)
        
        m_i
        
    end
    
    
   
   theta_k_all = (data(:,3)./180)*pi - pi; 
   [~, k] = min(abs(phi - theta_k_all));
   data_k = data(k,:);
   if(r < 0.4*0.4)
    %data_k = data(k,:)
   end
   z_k = data_k(2);    %range
   theta_k = (data_k(3)/180)*pi - pi;%theta
   l = l_0;
   if ( r > min(z_max, z_k+alpha/2) || (abs(phi - theta_k) > beta/2)) % out of sensor range
       l = l_0;
   elseif ((z_k < z_max) && (abs(r-z_k) < alpha/2)) % in occupied range
       l = l_occ;
       if(data_k(1) == 5.0)
           m_i
           data_k
           x_t
           y_t
           
       end
   elseif (r <= z_k) % out of occupied range
       l = l_free;
   end
    
        
end

