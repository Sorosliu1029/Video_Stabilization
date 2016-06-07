%% main body
clear;
close all;
input_video = 'bike2.mp4';
output_video = 'bike2_sta10.mp4';
start_frame = 2625;
number_frame = 25*10;
search_range = 7;
accuracy = 1;
block_size = 16;
stabilize(input_video, output_video, start_frame, number_frame, ...
    search_range, accuracy, block_size);
clear;