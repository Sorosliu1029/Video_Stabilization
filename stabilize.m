%% main function for video stabilization
function stabilize(read_video_path, write_video_path, ...
    start_frame, num_frames, range, accuracy, block_size)
% input parameters
% read_video_path: path to the original video
% write_video_path: path to the stabilized video
% start_frame: frame index to start with
% num_frames: number of frames
% range: motion search range
% accuracy: search step
% block_size: match block size (block is square)

tic
movie = VideoReader(read_video_path);
%% calculate block motion vectors for all frames
mvfs = EBMA(movie, range, accuracy, start_frame, num_frames, block_size);
toc
save mvfs.mat -struct mvfs;
mvx = mvfs.mvx;
mvy = mvfs.mvy;
mad = mvfs.mad;
mvmad = mvfs.mvmad;

%% show motion vector between two frames
frame_idx = 5;
visualise_BMV(movie, mvx(:,:,frame_idx), mvy(:,:,frame_idx), ...
    frame_idx+start_frame-1, block_size);

%% Deal with each frame
% initialize
fhx = zeros(num_frames-1);  fhy = fhx;  fc = fhx;
bhx = fhx; bhy = fhx; bc = fhx;

for i=1:num_frames-1
    % split block motion vectors into foreground and background part
    [f_mvx, f_mvy, b_mvx, b_mvy] = splitmv(mvx(:,:,i), mvy(:,:,i), range);
    % get global motion vector for each frame
    [fhx(i), fhy(i), fc(i)] = GMV(f_mvx, f_mvy, range, mad(:,:,i));
    [bhx(i), bhy(i), bc(i)] = GMV(b_mvx, b_mvy, range, mad(:,:,i));
end
toc

%% Motion compensation
% initialize
h = movie.Height;
w = movie.Width;
[sumxs, sumys, an_fs, new_fs] = ...
    compensate(movie, start_frame, num_frames, fhx, fhy, mvmad);
to_f_h = h + 20;
to_f_w = w * 2 + 30;
to_f = zeros(to_f_h, to_f_w, 3);
aviwriter = VideoWriter(write_video_path, 'Uncompressed AVI');
open(aviwriter);
for i=1:num_frames-1
    to_f(11:10+h,11:10+w,:) = an_fs(:,:,:,i);
    to_f(11:10+h,21+w:20+2*w,:) = new_fs(:,:,:,i);
    
    to_f(floor(to_f_h/2),:,:) = 0;
    to_f(floor(to_f_h/2),:,2) = 255;
    to_f(:, floor(to_f_w/4),:) = 0;
    to_f(:, floor(to_f_w/4),2) = 255;
    to_f(:, floor(to_f_w/4*3),:) = 0;
    to_f(:, floor(to_f_w/4*3),2) = 255;
    writeVideo(aviwriter, uint8(to_f(:,:,:)));
end
toc
close(aviwriter);
end