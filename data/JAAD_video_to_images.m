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





for i = 1:num_files

    % get xml file
    specific_index = sprintf('%0.04d',i);
    specific_filename = strcat('JAAD_behavioral_data_xml/video_',specific_index);
    specific_filename = strcat(specific_filename,'.xml');
    
    % get video file
    video_filename = strcat('/Users/oafolabi/Downloads/JAAD_clips/video_',specific_index);
    video_filename = strcat(video_filename,'.mp4');
    
    % create folder to store images
    imgs_folder_filename = strcat('/Volumes/SP PHD U3/JAAD/images/video_',specific_index);
    
    % create folder to store occupancy grid data for this video clip
    absolute_occ_folder_filename = imgs_folder_filename;
    mkdir(absolute_occ_folder_filename); 


    % load xml files
    jaad_xml = xml2struct(strcat(image_proc_root, specific_filename));
    jaad_xml = strip_JAAD_xml(jaad_xml);

  

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
    
   
    
    num_frames = size(framei{1},1);
    %num_frames = 1;
    
    
    
    video = VideoReader(video_filename);
    for j = 1:num_frames
        
        
        
        
        img = readFrame(video);
        RGB = img;
        %figure
        %imshow(img);
        
        driver_actions = actions.Children(end);

        sz_driver_actions = size(driver_actions.Children,2);

        for m = 1:sz_driver_actions

            driver_actions_attributes = driver_actions.Children(m).Attributes;


            start_time = str2double(driver_actions_attributes(3).Value);
            end_time = str2double(driver_actions_attributes(1).Value);
            id = driver_actions_attributes(2).Value;

            if  (j*frame_rate >=  start_time && j*frame_rate < end_time)
                
                position = [77 107];
                box_color = {'green'};
                RGB = insertText(img,position,id,'FontSize',50, 'BoxColor', ...
                    box_color, 'BoxOpacity', 0.4, 'TextColor', 'white');
                disp(id);
                
                if( strcmp(id, 'crossing'))
                    disp('waiting for user');
                    
                    
                end
                
               

            end
            
        
        end
        
        clip_index = sprintf('%0.04d',j);
        occ_clip_filename = strcat('/frame_',clip_index);
        absolute_occ_clip_filename = strcat(absolute_occ_folder_filename,occ_clip_filename);
        absolute_occ_clip_filename = strcat(absolute_occ_clip_filename,'.jpg')
        imwrite(RGB, absolute_occ_clip_filename);
        %save(absolute_occ_clip_filename,'data_struct');
        


        %w = waitforbuttonpress;
    end
    
    

end

 disp('done');