%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Occupancy grid test for People as Sensors
% Oladapo Afolabi - 6/10/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;

% select scenario / data for unpacking
fileLoc = 'exp3/';
image_prefix = 'SimResults_20170607_131746/ObjectCameraSensor_1_Image/ObjectCameraSensor_1_Image_';

% vehicle state information
load([fileLoc 'VehicleData.mat']);
% timeseries data structure gives Time and Data pieces, where all data is
% synchronized with Time
Time = VehicleData.Time;
ego_data = VehicleData.Data;
% data columns are: [x y z rotx roty rotz gps_lat gps_long gps_alt vel theta yaw_rate]
% all angles are in degrees

% get positions / trajectory
x_ego = ego_data(:,1);
y_ego = ego_data(:,2);
theta_ego = ego_data(:,11);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ground Truth Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the other vehicle is labeled as Obstacle Data
% that vehicle state information
load([fileLoc 'ObstacleData.mat']);
obs_data = ObstacleData.Data;
% data columns are same as above

% get positions / trajectory
x_obs = obs_data(:,1);
y_obs = obs_data(:,2);

% the hazard or thing that is being occluded is labeled as Hazard Data
% that object state information
load([fileLoc 'HazardData.mat']);
haz_data = HazardData.Data;
% data columns are same as above

% get positions / trajectory
x_haz = haz_data(:,1);
y_haz = haz_data(:,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% figure; hold on;
% % plot all agents
% plot(x_ego,y_ego,'o')
% plot(x_obs,y_obs,'o')
% plot(x_haz,y_haz,'o')
% 
% % plot road bnds -- lane width is 3.6
% plot([0 0 ],[-120 0],'y--')
% plot([3.6 3.6],[-120 0],'k--')
% plot(2*[3.6 3.6],[-120 -4],'k')
% plot(2*[3.6 6],[-4 -4],'k') % where left turn lane is
% plot([0 2*3.6],[-6 -6],'r') % where intersection starts
% 
% hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mock Sensor data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perfect radar data --- PS this formating is awful
load([fileLoc 'AIRData.mat'])
radar_data = AIRData.Data;
% get total number of detected objects by size of array
num_obj = size(radar_data,2)/6;
% the format of the data is: 
% [(IDs for all objects) (range to each) (angle to each obj) 
%   (elevation angle to each obj) (velocity of each obj) (heading of each obj)]
% note that this is ordered by object so we have to go through each one.
% if the ID entry is 0, then the object is not detected.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hack to get radar data from cam data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([fileLoc 'CamData.mat']);
id_data = CamData.Object_ID___.Data(:,1:4);
range_x_data = CamData.RangeX_m_.Data(:,1:4);
range_y_data = CamData.RangeY_m_.Data(:,1:4);
angle_data = CamData.Theta_deg_.Data(:,1:4);

% Don't really care about these, just there for completeness, may be wrong
elevation_angle_data = CamData.Phi_deg_.Data(:,1:4);
velocity_data = CamData.DopplerVelocity_ms_1_.Data(:,1:4) + ego_data(:,10);
shifted_velocity_data = circshift(velocity_data,1);
shifted_velocity_data(1,:) = 0;
acceleration_data = velocity_data - shifted_velocity_data;
%

heading_data = zeros(size(id_data));

% split radar data into key value pairs
num_of_objects_detected = size(radar_data,2)/6;
col_sz = size(radar_data,2);
    
% each row of data is sensor data for each object
data = zeros(num_of_objects_detected,size(radar_data,1),6);
for i = 1:num_of_objects_detected
    tmp = [i:num_of_objects_detected:col_sz];
    data(i,:,:) = radar_data(:,tmp);
    %tzz = radar_data(:,tmp)';
end

% for each time step, loop through all id's in id_data and find
% corresponding id in radar data, use id as key to find heading value

for i = 1:size(id_data,1)
    
    for j=1:4
        
        id = id_data(i,j);
        if id == 0
            heading_data(i,j) = 0;
        else
            idx = find(data(:,i,1) == id);

            if(~isempty(idx))
                heading_data(i, j) = squeeze(data(idx,i,6));
            else
                heading_data(i,j) = 0;
            end
        end
    
    end
    
    
end

new_range_data = sqrt(range_x_data.^2 + range_y_data.^2);

cam_radar_data = [id_data,new_range_data,angle_data,elevation_angle_data,velocity_data,heading_data];

%%
T = size(Time,1);



% create occupancy grid, I know apriori that it's 12x120
map = robotics.OccupancyGrid(12,120);
[X_world,Y_world] = meshgrid(0:1:12,0:1:120);
ij = world2grid(map,[X_world(:),Y_world(:)]);

l_initial = [ij(:,2),ij(:,1),zeros(size(ij,1),1)];

% shift data to match grid
y_ego2 = y_ego + 120;
l_t = l_initial;

% convert to radians and between -pi to pi
theta_ego = (theta_ego./180)*pi - pi;
figHandle = figure;
figHandle2 = figure;
figHandle3 = figure;
for i = 1:T
   
    l_t = occupancy_grid_mapping(l_t,[x_ego(i);y_ego2(i);theta_ego(i)],cam_radar_data(i,:));
    tmp = 1-(1./(1+exp(l_t(:,3))));
    setOccupancy(map,[l_t(:,1),l_t(:,2)],tmp);
    % updates based on actions
    % at ech time step, identify other cars
    figure(figHandle2);
    show(map);
    figure(figHandle);
    hold on
    
    % plot all agents
    plot(x_ego(i),y_ego(i),'o')
    plot(x_obs(i),y_obs(i),'o')
    plot(x_haz(i),y_haz(i),'o')

    % plot road bnds -- lane width is 3.6
    plot([0 0 ],[-120 0],'y--')
    plot([3.6 3.6],[-120 0],'k--')
    plot(2*[3.6 3.6],[-120 -4],'k')
    plot(2*[3.6 6],[-4 -4],'k') % where left turn lane is
    plot([0 2*3.6],[-6 -6],'r') % where intersection starts

    hold off
    
    image_index = sprintf('%0.05d',i-1);
    image_filename = strcat(fileLoc,image_prefix);
    image_filename = strcat(image_filename,image_index);
    image_filename = strcat(image_filename,'.png');
    figure(figHandle3);
    imshow(imread(image_filename));
    
    

    
    waitforbuttonpress;
    i
end
    