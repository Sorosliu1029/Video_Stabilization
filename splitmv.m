%% splitmv: split motion vectors into foreground and background part
function [f_mvx, f_mvy, b_mvx, b_mvy] = splitmv(mvx, mvy, r)
% input parameters
% mvx, mvy: motion vectors for a certain frame
% r: search range
% 
% output result
% f_mvx, f_mvy: foreground motion vectors
% b_mvx, b_mvy: background motion vectors

%% Split parameter
top_dis_factor1 = 0.25;
top_dis_factor2 = 0.60;
stripe_len_factor = 0.25;

%% initialize
h = size(mvx, 1);
w = size(mvx, 2);

f_mvx = zeros(h, w) - (r+1);
f_mvy = f_mvx;
b_mvx = f_mvx;
b_mvy = f_mvx;

top_dis1 = ceil(h*top_dis_factor1);
top_dis2 = ceil(h*top_dis_factor2);
stripe_len = ceil(w*stripe_len_factor);

%% foreground motion vector
f_mvx(top_dis1+1:top_dis2, stripe_len+1:w-stripe_len) = ...
    mvx(top_dis1+1:top_dis2, stripe_len+1:w-stripe_len);
f_mvy(top_dis1+1:top_dis2, stripe_len+1:w-stripe_len) = ...
    mvy(top_dis1+1:top_dis2, stripe_len+1:w-stripe_len);

%% background motion vector
b_mvx(1:top_dis1, 1:w) = mvx(1:top_dis1, 1:w);
b_mvy(1:top_dis1, 1:w) = mvy(1:top_dis1, 1:w);
b_mvx(top_dis1+1:top_dis2, 1:stripe_len) = ...
    mvx(top_dis1+1:top_dis2, 1:stripe_len);
b_mvy(top_dis1+1:top_dis2, 1:stripe_len) = ...
    mvy(top_dis1+1:top_dis2, 1:stripe_len);
b_mvx(top_dis1+1:top_dis2, w-stripe_len+1:w) = ...
    mvx(top_dis1+1:top_dis2, w-stripe_len+1:w);
b_mvy(top_dis1+1:top_dis2, w-stripe_len+1:w) = ...
    mvy(top_dis1+1:top_dis2, w-stripe_len+1:w);
end