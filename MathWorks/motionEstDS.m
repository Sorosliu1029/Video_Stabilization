% Computes motion vectors using Diamond Search method
%
% Based on the paper by Shan Zhu, and Kai-Kuang Ma
% IEEE Trans. on Image Processing
% Volume 9, Number 2, February 2000 :  Pages 287:290
%
% Input
%   imgP : The image for which we want to find motion vectors
%   imgI : The reference image
%   mbSize : Size of the macroblock
%   p : Search parameter  (read literature to find what this means)
%
% Ouput
%   motionVect : the motion vectors for each integral macroblock in imgP
%   DScomputations: The average number of points searched for a macroblock
%
% Written by Aroh Barjatya


function [motionVect, DScomputations] = motionEstDS(imgP, imgI, mbSize, p)

[row col] = size(imgI);

vectors = zeros(2,row*col/mbSize^2);
costs = ones(1, 9) * 65537;


% we now take effectively log to the base 2 of p
% this will give us the number of steps required

L = floor(log10(p+1)/log10(2));   


% The index points for Large Diamond search pattern
LDSP(1,:) = [ 0 -2];
LDSP(2,:) = [-1 -1]; 
LDSP(3,:) = [ 1 -1];
LDSP(4,:) = [-2  0];
LDSP(5,:) = [ 0  0];
LDSP(6,:) = [ 2  0];
LDSP(7,:) = [-1  1];
LDSP(8,:) = [ 1  1];
LDSP(9,:) = [ 0  2];

% The index points for Small Diamond search pattern
SDSP(1,:) = [ 0 -1];
SDSP(2,:) = [-1  0];
SDSP(3,:) = [ 0  0];
SDSP(4,:) = [ 1  0];
SDSP(5,:) = [ 0  1];


% we start off from the top left of the image
% we will walk in steps of mbSize
% for every marcoblock that we look at we will look for
% a close match p pixels on the left, right, top and bottom of it

computations = 0;

mbCount = 1;
for i = 1 : mbSize : row-mbSize+1
    for j = 1 : mbSize : col-mbSize+1
        
        % the Diamond search starts
        % we are scanning in raster order
        
        x = j;
        y = i;
        
        costs(5) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(i:i+mbSize-1,j:j+mbSize-1),mbSize);
        computations = computations + 1;
        
        % This is the first search so we evaluate all the 9 points in LDSP
        for k = 1:9
            refBlkVer = y + LDSP(k,2);   % row/Vert co-ordinate for ref block
            refBlkHor = x + LDSP(k,1);   % col/Horizontal co-ordinate
            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                 || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                continue;
            end

            if (k == 5)
                continue
            end
            costs(k) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                  imgI(refBlkVer:refBlkVer+mbSize-1, refBlkHor:refBlkHor+mbSize-1), mbSize);
            computations = computations + 1;
        end
        
        [cost, point] = min(costs);
        
        
        % The SDSPFlag is set to 1 when the minimum
        % is at the center of the diamond           
        
        if (point == 5)
            SDSPFlag = 1;
        else
            SDSPFlag = 0;
            if ( abs(LDSP(point,1)) == abs(LDSP(point,2)) )
                cornerFlag = 0;
            else
                cornerFlag = 1; % the x and y co-ordinates not equal on corners
            end
            xLast = x;
            yLast = y;
            x = x + LDSP(point, 1);
            y = y + LDSP(point, 2);
            costs = ones(1,9) * 65537;
            costs(5) = cost;
        end
        
           
        while (SDSPFlag == 0)
            if (cornerFlag == 1)
                for k = 1:9
                    refBlkVer = y + LDSP(k,2);   % row/Vert co-ordinate for ref block
                    refBlkHor = x + LDSP(k,1);   % col/Horizontal co-ordinate
                    if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                        || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                        continue;
                    end

                    if (k == 5)
                        continue
                    end
            
                    if ( refBlkHor >= xLast - 1  && refBlkHor <= xLast + 1 ...
                            && refBlkVer >= yLast - 1  && refBlkVer <= yLast + 1 )
                        continue;
                    elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                        continue;
                    else
                        costs(k) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                        computations = computations + 1;
                    end
                end
                
            else
                switch point
                    case 2
                        refBlkVer = y + LDSP(1,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(1,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                        else 
                           costs(1) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                                   
                        refBlkVer = y + LDSP(2,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(2,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                        else
                         
                           costs(2) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                        
                        refBlkVer = y + LDSP(4,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(4,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                        else
                         
                           costs(4) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                     
                    case 3
                        refBlkVer = y + LDSP(1,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(1,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                        else
                         
                           costs(1) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                                   
                        refBlkVer = y + LDSP(3,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(3,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                        else
                            
                           costs(3) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                        
                        refBlkVer = y + LDSP(6,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(6,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                        else
                             
                           costs(6) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                        
                        
                    case 7
                        refBlkVer = y + LDSP(4,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(4,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                            
                        else 
                           costs(4) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                                   
                        refBlkVer = y + LDSP(7,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(7,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                            
                        else 
                           costs(7) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                        
                        refBlkVer = y + LDSP(9,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(9,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                            
                        else 
                           costs(9) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                        
                    
                    case 8
                        refBlkVer = y + LDSP(6,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(6,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                            
                        else 
                           costs(6) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                                   
                        refBlkVer = y + LDSP(8,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(8,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                            
                        else 
                           costs(8) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                        
                        refBlkVer = y + LDSP(9,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(9,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                           % do nothing, outside image boundary
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            % do nothing, outside search window
                            
                        else 
                           costs(9) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                       imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                        end
                    otherwise
                end
            end
            
            [cost, point] = min(costs);
           
            if (point == 5)
                SDSPFlag = 1;
            else
                SDSPFlag = 0;
                if ( abs(LDSP(point,1)) == abs(LDSP(point,2)) )
                    cornerFlag = 0;
                else
                    cornerFlag = 1;
                end
                xLast = x;
                yLast = y;
                x = x + LDSP(point, 1);
                y = y + LDSP(point, 2);
                costs = ones(1,9) * 65537;
                costs(5) = cost;
            end
            
        end  % while loop ends here
        
        % we now enter the SDSP calculation domain
        costs = ones(1,5) * 65537;
        costs(3) = cost;
        
        for k = 1:5
            refBlkVer = y + SDSP(k,2);   % row/Vert co-ordinate for ref block
            refBlkHor = x + SDSP(k,1);   % col/Horizontal co-ordinate
            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                  || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                continue; % do nothing, outside image boundary
            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                continue;   % do nothing, outside search window
            end

            if (k == 3)
                continue
            end
            
            costs(k) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                              imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                  refBlkHor:refBlkHor+mbSize-1), mbSize);
            computations = computations + 1;
                   
        end
         
        [cost, point] = min(costs);
        
        x = x + SDSP(point, 1);
        y = y + SDSP(point, 2);
        
        vectors(1,mbCount) = y - i;    % row co-ordinate for the vector
        vectors(2,mbCount) = x - j;    % col co-ordinate for the vector            
        mbCount = mbCount + 1;
        costs = ones(1,9) * 65537;
        
    end
end
    
motionVect = vectors;
DScomputations = computations/(mbCount - 1);
    
    
    
 