%% Motion Compensation due to GMV
function [sumxs, sumys, an_fs, new_fs] = ...
    compensate(movie, start_frame, num_frames, hx, hy, mvmad) 
% input parameters
% movie: original frame sequence
% start_frame: start of frame
% num_frames: number of frames
% hx, hy: GMVs
% mvmad: minimal motion MAD

%% initialize
h = movie.Height;
w = movie.Width;
% new stabilized frame
new_fs = zeros(h, w, 3, num_frames-1);
% AGMV (absolute global motion vector)
sumx = 0;
sumy = 0;
sumxs = zeros(num_frames-1);
sumys = sumxs;
% frames of interest
fs = read(movie, [start_frame, start_frame+num_frames]);

%% sum of each frame's MAD to determine whether jiggling or panning
smad = sum(sum(mvmad));
smad = smad(:);
smad = smad(1:num_frames-1);
%% Generate new frame backwards due to AGMV(absolute global motion vector)
for index=1:num_frames-1
    an_f = fs(:,:,:,index+1);
    % accumulate each frame's GMV to get AGMV
    sumx = sumx + hx(index);
    sumy = sumy + hy(index);
    
    if (index > 1 && index < num_frames-1)        
        if ((smad(index)/(smad(index-1)+eps) > 3) && ...
                (smad(index)/smad(index+1)+eps) > 3)
            % shake is caused by panning
            sumy = 0;
            sumx = 0;
        end
    end
    
    % compensate the motion with AGMV
    if (sumy >= 0 && sumx >= 0)
        new_fs(1+sumy:h, 1+sumx:w,:,index) = an_f(1:h-sumy, 1:w-sumx,:);
    elseif (sumy >= 0 && sumx < 0)
        new_fs(1+sumy:h, 1:w+sumx,:,index) = an_f(1:h-sumy, 1-sumx:w,:);
    elseif (sumy < 0 && sumx >= 0)
        new_fs(1:h+sumy, 1+sumx:w,:,index) = an_f(1-sumy:h, 1:w-sumx,:);
    else
        new_fs(1:h+sumy, 1:w+sumx,:,index) = an_f(1-sumy:h, 1-sumx:w,:);
    end
end
an_fs = fs(:,:,:,1:num_frames-1);