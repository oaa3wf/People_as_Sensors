function [ res ] = isInPerceptualField(x_i,y_i,x,y)
%ISINPERCEPTUALFIELD This function evaluates whether or not the query
%position is in the robot's perceptual field. For now, we're just using a
%circle of radius 50
%   @param x_i - grid query point center of mass x value
%   @param y_i - grid query point center of mass y value
%   @param x - sensor/robot position x value
%   @param y - sensor/robot position y value

p_t = [x;y];
g_i = [x_i;y_i];

res = 0;

if(norm(p_t - g_i) < 100)
    res = 1;
end


end

