%% main function for video stabilization
function main(video_path, start_frame, num_frames, range, accuracy, block_size)
% input parameters
% video_path: path to the video
% start_frame: frame index to start with
% num_frames: number of frames
% range: motion search range
% accuracy: search step
% block_size: match block size (block is square)

movie = VideoReader(video_path);
%% calculate block motion vectors for all frames
mvfs = EBMA(movie, range, accuracy, start_frame, num_frames, block_size);

mvx = mvfs.mvx;
mvy = mvfs.mvy;
mad = mvfs.mad;
mvmad = mvfs.mvmad;

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

%% Motion compensation
% initialize
h = movie.Height;
w = movie.Width;
[sumxs, sumys, an_fs, new_fs] = ...
    compensate(movie, start_frame, num_frames, fhx, fhy, mvmad);
to_f = zeros(h + 20, w*2+30, 3);
aviwriter = VideoWriter('demo2.avi', 'Uncompressed AVI');
open(aviwriter);
for i=1:num_frames-1
    to_f(11:10+h,11:10+w,:) = an_fs(:,:,:,i);
    to_f(11:10+h,21+w:20+2*w,:) = new_fs(:,:,:,i);
    writeVideo(aviwriter, uint8(to_f(:,:,:)));
end
close(aviwriter);
clear;