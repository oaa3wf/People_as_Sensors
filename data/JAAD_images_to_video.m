% This script generates occupancy grids from each frame using distance data
% and xml file for each video 

clc;
clear all;

image_proc_root = '/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/';
addpath('/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/');
load('/Users/oafolabi/Dropbox/SuperCoolCarStuff/image_proc/ped_data.mat');
storage_folder_root = '/Users/oafolabi/Downloads/';

frame_rate = 1/(30);

num_files = size(d,1);
%num_files = 1;





for i = 1:num_files

   
    specific_index = sprintf('%0.04d',i);
    imgs_folder_filename = strcat('/Volumes/SP PHD U3/JAAD/images/video_',specific_index);
    video_folder_filename = strcat('/Volumes/SP PHD U3/JAAD/annotated_videos/video_',specific_index);
    video_folder_filename = strcat(video_folder_filename, '.avi');
    
    all_images = strcat(imgs_folder_filename, '/*.jpg');
    imageNames = dir(all_images);
    %imageNames = imageNames(arrayfun(@(x)(~any(strcmp(x.name,{'.'})))))
    imageNames = {imageNames.name}';
    
    
    outputVideo = VideoWriter(video_folder_filename);
    outputVideo.FrameRate = 1/frame_rate;
    open(outputVideo);
    
    for ii = 1:length(imageNames)
        
        imgs_filename = strcat(imgs_folder_filename, '/');
        
        img = imread(strcat(imgs_filename, imageNames{ii}));
        writeVideo(outputVideo, img);
    end
    
    close(outputVideo);    

end

 disp('done');