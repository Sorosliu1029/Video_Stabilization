%% EBMA: Exhaustive Block Matching Algorithm
function [mvfs] = EBMA(movie, r, accuracy, sf, nf, s)
% input parameters
% movie: original frame sequence
% r: search range
% accuracy: search step, 1 for integer pel, 2 for half pel
% sf: start frame
% nf: number of frames
% s: match block size
%
% output result
% mvfs: motion vectors for all frames

%% initialize variables
fs = read(movie, [sf, sf+nf-1]);         % frame sequence of interest
h = movie.Height;
w = movie.Width;

mvxfs = zeros(floor(h/s), floor(w/s), nf-1);
mvyfs = mvxfs;
madfs = mvxfs;
mvmad = mvxfs;

%% Iteration of each frame
for index=1:1:nf-1
    % ta_f : target frame
    % an_f : anchor frame
    ta_f = rgb2gray(fs(:,:,:,index));
    an_f = rgb2gray(fs(:,:,:,index+1));
    
    if (r > s-1)
        r = s - 1;
    end;
    
    % start_point, end_point: corner point of search block
    start_point = zeros(1, 2);
    end_point = start_point;
    
    % mvx, mvy: block motion vectors of a certain frame
    mvx = zeros(floor((h-s)/s)+1, ...
        floor((w-s)/s)+1);
    mvy = mvx;
    MBMAD = mvx;
    MVMAD = mvx;
    
    if (accuracy ~= 1)
        ta_f = imresize(ta_f, accuracy, 'bilinear');
    end;
    
    % Estimate motion vector for a frame
    % top block to down
    for i=1:s:h-s+1
        % left block to right
        for j=1:s:w-s+1
            MAD_min = 255;
            % search vertically
            for k=-r*accuracy:r*accuracy
                start_point(1) = (i-1)*accuracy+1+k;
                end_point(1) = (i-1)*accuracy+k+s*accuracy;
                if (start_point(1) < 1)
                    start_point(1) = 1;
                    end_point(1) = s * accuracy;
                end;
                if (end_point(1) > h*accuracy)
                    end_point(1) = h*accuracy;
                    start_point(1) = h*accuracy-s*accuracy+1;
                end;
                
                % search horizontally
                for p=-r*accuracy:r*accuracy
                    start_point(2) = (j-1)*accuracy+1+p;
                    end_point(2) = (j-1)*accuracy+p+s*accuracy;
                    if (start_point(2) < 1)
                        start_point(2) = 1;
                        end_point(2) = s*accuracy;
                    end;
                    if (end_point(2) > w*accuracy)
                        end_point(2) = w*accuracy;
                        start_point(2) = w*accuracy-s*accuracy+1;
                    end;
                    
                    % calcuate MAD for this block
                    MAD = sum(sum(abs(an_f(i:i+s-1, j:j+s-1)-...
                        ta_f(start_point(1):accuracy:end_point(1), ...
                        start_point(2):accuracy:end_point(2))))) / s^2;
                    
                    % update MAD_min and motion vector [dx, dy]
                    if (MAD < MAD_min)
                        MAD_min = MAD;
                        dy = start_point(1);
                        dx = start_point(2);
                    end;
                end;
            end;
            
            % record block motion vector
            iblk = floor((i-1)/s)+1;
            jblk = floor((j-1)/s)+1;
            mvx(iblk, jblk) = round(dx/accuracy)-j;
            mvy(iblk, jblk) = round(dy/accuracy)-i;
            mean_an_f = mean(mean(an_f(i:i+s-1, j:j+s-1)));
            MBMAD(iblk, jblk) = sum(sum(abs(an_f(i:i+s-1, j:j+s-1)-...
                mean_an_f))) / s^2;
            MVMAD(iblk, jblk) = MAD_min;
        end;
    end;
    mvxfs(:,:,index) = mvx;
    mvyfs(:,:,index) = mvy;
    madfs(:,:,index) = MBMAD;
    mvmad(:,:,index) = MVMAD;
end;
mvfs = struct('mvx', mvxfs, 'mvy', mvyfs, 'mad', madfs, 'mvmad', mvmad);
end