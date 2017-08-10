clc;
clear all;

% create (6x3 +1) x N matrix of zeros
training_data = [];
id_map = containers.Map({'moving fast', 'moving slow', 'slowing down', 'speeding up', 'standing'},{1,2,3,4,5});
% Load folder 
image_proc_root = '/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/';
addpath('/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/');
load('/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/ped_data.mat');
folder_root = '/Users/oafolabi/Downloads/JAAD_clips/occupancy/';
output_root = '/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/training_data/';

% for each folder in filename
num_folders = size(d,1);
width = 3;
height = 6;

for i = 1:num_folders

% create new folder with same filename in Dropbox
    filename = strcat(folder_root,'video_');
    specific_index = sprintf('%0.04d',i);
    filename = strcat(filename,specific_index)
    filename = strcat(filename, '/*.mat');
    
    files = dir(filename);
    
    
    
    for file = files'
        
        % load map1 and map2
        specific_filename = strcat(file.folder, '/');
        specific_filename = strcat(specific_filename, file.name);
        load(specific_filename)
        map1 = data_struct{1};
        map2 = data_struct{2};
        action = data_struct{3};
        
        % cut off height x width window
        width_sz = size(map1,2);
        height_sz = size(map1,1);
        
        new_map1 = map1(end-height+1:end,end-width+1:end);
        new_map2 = map2(end-height+1:end,1:width);
        
        % reshape and add to matrix, % get action, map to id, % add id to end of matrix
        training_data = [training_data;[reshape(new_map1,[1, width*height]), id_map(action)]];
        training_data = [training_data;[reshape(new_map2,[1, width*height]), id_map(action)]];
        
        
        
        
    end













end

% save training data, need to verify what standing is? Seems weird that a
% driver should be standing

output_filename = strcat(output_root, 'training_data.mat');
save(output_filename,'training_data');
disp('done');
