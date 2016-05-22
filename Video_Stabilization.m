%% main body
clear;
close all;
input_video = 'shaky_car.avi';
output_video = 'demo.avi';
start_frame = 1;
number_frame = 120;
search_range = 7;
accuracy = 1;
block_size = 16;
stabilize(input_video, output_video, start_frame, number_frame, ...
    search_range, accuracy, block_size);
clear;