% This script generates occupancy grids from each frame using distance data
% and xml file for each video 

clc;
clear all;

image_proc_root = '/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/';
addpath('/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/');
load('/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/ped_data.mat');
storage_folder_root = '/Users/oafolabi/Downloads/';

frame_rate = 1/(29.99);

num_files = size(d,1);
%num_files = 1;

width = 7;
height = 21;

gaussian_window_width = 3; 

gaussian_window_idx = zeros(gaussian_window_width*gaussian_window_width, 2);

middle = median([1:1:gaussian_window_width]);


for i = 1:gaussian_window_width
    for j = 1:gaussian_window_width
        gaussian_window_idx((i-1)*gaussian_window_width+j, :) = [i-middle,j-middle]; %% test
    end
end




for i = 1:num_files

    specific_index = sprintf('%0.04d',i);
    specific_filename = strcat('JAAD_behavioral_data_xml/video_',specific_index);
    specific_filename = strcat(specific_filename,'.xml');
    
    video_filename = strcat('/Users/oafolabi/Downloads/JAAD_clips/video_',specific_index);
    video_filename = strcat(video_filename,'.mp4');
    
    occ_folder_filename = strcat('JAAD_clips/occupancy/video_',specific_index);
    
    % create folder to store occupancy grid data for this video clip
    absolute_occ_folder_filename = strcat(storage_folder_root,occ_folder_filename);
    mkdir(absolute_occ_folder_filename); 


    % load xml files
    jaad_xml = xml2struct(strcat(image_proc_root, specific_filename));
    jaad_xml = strip_JAAD_xml(jaad_xml);

    % match number of subjects to size of colums in d2 matrix

    % get actions struct

    actions = jaad_xml.Children(3);

    % get subjects struct

    subjects = jaad_xml.Children(2);

    % compare with d2

    framei = d(i);
    framei_x = x(i);
    framei_xv = xv(i);
    framei_y = y(i);
    framei_yv = yv(i);
    
   

    if( size(subjects.Children,2) ~= size(framei{1},2))
        
        disp('false');
    end
    
    % generate occupancy grid with depth data
    
    num_frames = size(framei{1},1);
    %num_frames = 1;
    num_subjects = size(framei{1},2);
    
    
    
    map = robotics.OccupancyGrid(width,height);
    map2 = robotics.OccupancyGrid(width,height);
    
    video = VideoReader(video_filename);
    for j = 1:num_frames
        
        % set occupncy value for each subject in scene
        for k = 1:num_subjects 
            
            x_val = framei_x{1}(j,k);
            y_val = framei_y{1}(j,k);
            
            sampling_points = gaussian_window_idx + [x_val, y_val]; %% test
            epsilon = 10^(-10);
            epsilon2 = 0.0001; % helps edge cases
            
            gaussian_window = mvnpdf(sampling_points,[x_val,y_val], [framei_xv{1}(j,k)+epsilon,framei_xv{1}(j,k)+epsilon]); %% test
            gaussian_window = (gaussian_window./max(gaussian_window))*0.5 + 0.5;
            

            if(-x_val < width && x_val < 0  && y_val < height)
                %setOccupancy(map,[floor(x_val+width) ,floor(y_val)],1);
                for a = 1:gaussian_window_width
                    for b = 1:gaussian_window_width
                        window_x_point = gaussian_window_idx((a-1)*gaussian_window_width+b,1);
                        window_y_point = gaussian_window_idx((a-1)*gaussian_window_width+b,2);
                        world_x = x_val  + window_x_point + epsilon2;
                        world_y = y_val + window_y_point + epsilon2;
                        if (-world_x < width && world_x < 0  && world_y < height && world_y >= 0)
                            world_x = x_val + width   + window_x_point + epsilon2;
                            pdf_value = gaussian_window((a-1)*gaussian_window_width+b);
                            setOccupancy(map,[world_x,world_y],pdf_value);
                        end
                    end
                end
            end
            
            if(x_val < width && x_val >= 0 && y_val < height)
                for a = 1:gaussian_window_width
                    for b = 1:gaussian_window_width
                        window_x_point = gaussian_window_idx((a-1)*gaussian_window_width+b,1);
                        window_y_point = gaussian_window_idx((a-1)*gaussian_window_width+b,2);
                        world_x = x_val + window_x_point + epsilon2;
                        world_y = y_val + window_y_point + epsilon2;
                        if (world_x < width && world_x >= 0  && world_y < height && world_y >= 0)
                            pdf_value = max(gaussian_window((a-1)*gaussian_window_width+b), getOccupancy(map2,[world_x,world_y]));
                            setOccupancy(map2,[world_x,world_y],pdf_value);
                        end
                    end
                end
               %setOccupancy(map2,[floor(x_val) ,floor(y_val)],1);
            end

        end
        %figure
        %show(map);
        %figure
        %show(map2);
        
        img = readFrame(video);
        %figure
        %imshow(img);
        
        data_struct = {};
        occupancy_mat = occupancyMatrix(map);
        occupancy_mat2 = occupancyMatrix(map2);
        data_struct{1} = occupancy_mat;
        data_struct{2} = occupancy_mat2;
        
        %get driver actions index
        driver_actions_idx = 0;
        for ii = 1:size(actions.Children,2)
            super_tmp =cellstr(actions.Children(ii).Name); 
            if(strcmp(super_tmp{1},'Driver'))
               driver_actions_idx = ii; 
               break 
            end
            
        end
   
        driver_actions = actions.Children(driver_actions_idx);

        sz_driver_actions = size(driver_actions.Children,2);

        for m = 1:sz_driver_actions

            driver_actions_attributes = driver_actions.Children(m).Attributes;


            start_time = str2double(driver_actions_attributes(3).Value);
            end_time = str2double(driver_actions_attributes(1).Value);
            id = driver_actions_attributes(2).Value;

            if  (j*frame_rate >=  start_time && j*frame_rate < end_time)

                disp(id);
                data_struct{3} = id;
                
                if( strcmp(id, 'stopped'))
                    disp('waiting for user');
                    w = waitforbuttonpress;
                    
                    
                end
                
                clip_index = sprintf('%0.04d',j);
                occ_clip_filename = strcat('/frame_',clip_index);
                absolute_occ_clip_filename = strcat(absolute_occ_folder_filename,occ_clip_filename);
                %save(absolute_occ_clip_filename,'data_struct');

            end


        end
        


        %w = waitforbuttonpress;
    end
    
    

end

 disp('done');