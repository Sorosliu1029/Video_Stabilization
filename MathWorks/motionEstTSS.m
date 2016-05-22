% Computes motion vectors using Three Step Search method
%
% Input
%   imgP : The image for which we want to find motion vectors
%   imgI : The reference image
%   mbSize : Size of the macroblock
%   p : Search parameter  (read literature to find what this means)
%
% Ouput
%   motionVect : the motion vectors for each integral macroblock in imgP
%   TSScomputations: The average number of points searched for a macroblock
%
% Written by Aroh Barjatya


function [motionVect, TSScomputations] = motionEstTSS(imgP, imgI, mbSize, p)

[row col] = size(imgI);

vectors = zeros(2,row*col/mbSize^2);
costs = ones(3, 3) * 65537;

computations = 0;

% we now take effectively log to the base 2 of p
% this will give us the number of steps required

L = floor(log10(p+1)/log10(2));   
stepMax = 2^(L-1);

% we start off from the top left of the image
% we will walk in steps of mbSize
% for every marcoblock that we look at we will look for
% a close match p pixels on the left, right, top and bottom of it

mbCount = 1;
for i = 1 : mbSize : row-mbSize+1
    for j = 1 : mbSize : col-mbSize+1
        
        % the three step search starts
        % we will evaluate 9 elements at every step
        % read the literature to find out what the pattern is
        % my variables have been named aptly to reflect their significance

        x = j;
        y = i;
        
        % In order to avoid calculating the center point of the search
        % again and again we always store the value for it from teh
        % previous run. For the first iteration we store this value outside
        % the for loop, but for subsequent iterations we store the cost at
        % the point where we are going to shift our root.
        
        costs(2,2) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(i:i+mbSize-1,j:j+mbSize-1),mbSize);
        
        computations = computations + 1;
        stepSize = stepMax;               

        while(stepSize >= 1)  

            % m is row(vertical) index
            % n is col(horizontal) index
            % this means we are scanning in raster order
            for m = -stepSize : stepSize : stepSize        
                for n = -stepSize : stepSize : stepSize
                    refBlkVer = y + m;   % row/Vert co-ordinate for ref block
                    refBlkHor = x + n;   % col/Horizontal co-ordinate
                    if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                        || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                        continue;
                    end


                    costRow = m/stepSize + 2;
                    costCol = n/stepSize + 2;
                    if (costRow == 2 && costCol == 2)
                        continue
                    end
                    costs(costRow, costCol ) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                        imgI(refBlkVer:refBlkVer+mbSize-1, refBlkHor:refBlkHor+mbSize-1), mbSize);
                    
                    computations = computations + 1;
                end
            end
        
            % Now we find the vector where the cost is minimum
            % and store it ... this is what will be passed back.
        
            [dx, dy, min] = minCost(costs);      % finds which macroblock in imgI gave us min Cost
            
            
            % shift the root for search window to new minima point

            x = x + (dx-2)*stepSize;
            y = y + (dy-2)*stepSize;
            
            % Arohs thought: At this point we can check and see if the
            % shifted co-ordinates are exactly the same as the root
            % co-ordinates of the last step, then we check them against a
            % preset threshold, and ifthe cost is less then that, than we
            % can exit from teh loop right here. This way we can save more
            % computations. However, as this is not implemented in the
            % paper I am modeling, I am not incorporating this test. 
            % May be later...as my own addition to the algorithm
            
            stepSize = stepSize / 2;
            costs(2,2) = costs(dy,dx);
            
        end
        vectors(1,mbCount) = y - i;    % row co-ordinate for the vector
        vectors(2,mbCount) = x - j;    % col co-ordinate for the vector            
        mbCount = mbCount + 1;
        costs = ones(3,3) * 65537;
    end
end

motionVect = vectors;
TSScomputations = computations/(mbCount - 1);
                    