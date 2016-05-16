%% GMV: Global Motion Vector based on MAD value as weight
function [hx, hy, c] = GMV(x, y, r, mad)
% input parameters
% x, y: all block motion vectors of a certain frame
% r: search range
% mad: all block MAD value of a certain frame
% 
% output result
% hx, hy: global motion vector
% c: mosted weighted motion counter

%% initialize
h = size(x, 1);
w = size(x, 2);
x = x + r + 1;
y = y + r + 1;

% weighted counter for block motion vectors
histo = zeros(2*r+1, 2*r+1);

% count
for i=1:h
    for j=1:w
        if (x(i, j) > 0 && y(i, j) > 0)
            if (mad(i, j) < 1)
                histo(x(i,j), y(i,j)) = histo(x(i,j), y(i,j));
            elseif (mad(i, j) < 5)
                histo(x(i,j), y(i,j)) = histo(x(i,j), y(i,j)) + 1;
            elseif (mad(i, j) < 40)
                histo(x(i,j), y(i,j)) = histo(x(i,j), y(i,j)) + 2;
            elseif (mad(i, j) < 60)
                histo(x(i,j), y(i,j)) = histo(x(i,j), y(i,j)) + 4;
            elseif (mad(i, j) < 80)
                histo(x(i,j), y(i,j)) = histo(x(i,j), y(i,j)) + 8;
            else
                histo(x(i,j), y(i,j)) = histo(x(i,j), y(i,j)) + 16;
            end;
        end;
    end;
end;

% get most weighted motion vector
[c, I] = max(histo(:));
[hx, hy] = ind2sub(size(histo), I);
hx = hx - r - 1;
hy = hy - r - 1;
end