%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sample Data for Drivers as Sensors
% Katie DC - 6/7/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;

% select scenario / data for unpacking
fileLoc = 'exp3/';

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
figure; hold on;
% plot all agents
plot(x_ego,y_ego,'o')
plot(x_obs,y_obs,'o')
plot(x_haz,y_haz,'o')

% plot road bnds -- lane width is 3.6
plot([0 0 ],[-120 0],'y--')
plot([3.6 3.6],[-120 0],'k--')
plot(2*[3.6 3.6],[-120 -4],'k')
plot(2*[3.6 6],[-4 -4],'k') % where left turn lane is
plot([0 2*3.6],[-6 -6],'r') % where intersection starts

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
 
% perfect vision data
load([fileLoc 'CamData.mat']);
% this is data associated with a camera with object detection.  it's
% structured data, so it's relatively self explanatory?
% each field is a time series, giving data of up to 32 objects (hence its long)
% the ObjectTypeID tells you what it is, (1 = vehicle, 9 = pedestrian)
% The left, right, bottom, top, give the bounding boxes in the image

% the images associated with each timestamp are in the SimResults folder,
% so you can get an idea of what's happening!





