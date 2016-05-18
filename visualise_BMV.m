%% Visualise BMV with arrow
function visualise_BMV(movie, mvx, mvy, ta_f_index, s)
ta_f = read(movie, ta_f_index);
an_f = read(movie, ta_f_index+1);
h = size(ta_f, 1);
w = size(ta_f, 2);
[sx, sy] = meshgrid(1:s:w, 1:s:h);
imshowpair(ta_f, an_f, 'ColorChannels', 'red-cyan');
hold on;
quiver(sx, sy, -mvx, -mvy, 0.5, 'g');
end
