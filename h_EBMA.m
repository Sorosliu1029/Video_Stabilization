%% EBMA for HBMA, motion estimaton for one block
% called by HBMA function
function [mv_x, mv_y,MB_search,pre_block,error] = ...
    h_EBMA(ta_f,an_f,block_size,block_loc,rs,re,accuracy)
% input parameters
% ta_f, an_f: target and anchor frame
% block_size: block size
% block_loc: block location in the anchor frame
% rs,re: search area, (rs(1),rs(2)) --> (re(1), re(2))
% accuracy: 1 for integer pel, 2 for half pel
% output result
% mv_x,mv_y: motion vector
% MB_search: search times
% pre_block: best estimated block
% error: minimal SAD

%% initialize
if nargin < 7
    accuracy = 1;
end

MB_search = 0;
ly = block_loc(1);
lx = block_loc(2);
Ny = block_size;
Nx = block_size;

% get anchor block
AnchorBlock = an_f(ly:ly+Ny-1,lx:lx+Nx-1);
pre_block = AnchorBlock;

mv_x=0;
mv_y=0;

error = 255*Nx*Ny*100;

% search the area
for y = rs(1):re(1)-accuracy*Ny+1
    for x = rs(2):re(2)-accuracy*Nx+1
        TargetBlock = ta_f(y:accuracy:y+accuracy*Ny-1,x:accuracy:x+accuracy*Nx-1);
        % get SAD
        temp_error = sum(sum(abs(AnchorBlock - TargetBlock)));
        MB_search = MB_search+1;
        if temp_error < error
            error = temp_error;
            mv_x = x/accuracy-lx;
            mv_y = y/accuracy-ly;
            pre_block = TargetBlock;
        end
    end
end