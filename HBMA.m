%% HBMA (Hierarchical Block Matching Algorithm) (demo version)
function HBMA(ta_f,an_f,h,w,block_size,range_start,range_end)
% input parameters
% ta_f,an_f: target frame and anchor frame
% h,w: frame height and width
% block_size: block size
% range_start,range_end: search area

ta_f = double(rgb2gray(ta_f));
an_f = double(rgb2gray(an_f));

%% initialize
% pyramid levels
L = 3;
% total block search times
t_MB_search = 0;
t0 = clock;
% block index
m = 1;
Factor = 2.^(L-1);

% 3 level of resolution for anchor frame and target frame
TargetDown1 = ta_f;
AnchorDown1 = an_f;

TargetDown2 = imresize(ta_f, 0.5);
AnchorDown2 = imresize(an_f, 0.5);
TargetDown3 = imresize(ta_f, 0.25);
AnchorDown3 = imresize(an_f, 0.25);

% top sample the target frame to optimize result with half pel search
Up_Target_Img = zeros(h*2,w*2);
Up_Target_Img(1:2:h*2,1:2:w*2) = ta_f;
Up_Target_Img(1:2:h*2-1,2:2:w*2-1) = (ta_f(:,1:w-1)+ta_f(:,2:w))/2;
Up_Target_Img(2:2:h*2-1,1:2:w*2-1) = (ta_f(1:h-1,:)+ta_f(2:h,:))/2;
Up_Target_Img(2:2:h*2-1,2:2:w*2-1) = (ta_f(1:h-1,1:w-1)+ta_f(1:h-1,2:w)+...
    +ta_f(2:h,1:w-1)+ta_f(2:h,2:w))/4;

% reset the parameter for low resolution frame
range_start(1) = range_start(1)/Factor;
range_start(2) = range_start(2)/Factor;
range_end(1) = range_end(1)/Factor;
range_end(2) = range_end(2)/Factor;

h = h/Factor;
w = w/Factor;

% level 1 EBMA
for i = 1:block_size:h-block_size+1
    RangeStart(1) = i+range_start(1);
    RangeEnd(1) = i+block_size-1+range_end(1);
    if RangeStart(1) < 1
        RangeStart(1) = 1;
    end
    if RangeEnd(1) > h
        RangeEnd(1) = h;
    end
    
    for j = 1:block_size:w-block_size+1
        RangeStart(2) = j+range_start(2);
        RangeEnd(2) = j+block_size-1+range_end(2);
        if RangeStart(2) < 1
            RangeStart(2) = 1;
        end
        if RangeEnd(2) > w
            RangeEnd(2) = w;
        end
        
        temp_target = TargetDown3;
        temp_anchor = AnchorDown3;
        [px(m),py(m),MB_search] = ...
            h_EBMA(temp_target,temp_anchor,block_size,[i,j],RangeStart,RangeEnd);
        t_MB_search = MB_search+t_MB_search;
        % record start point
        ox(m) = j;
        oy(m) = i;
        m = m+1;
    end
end

figure;
imshow(uint8(AnchorDown3));
title('AnchorDown3')

hold on
quiver(ox,oy,-px,-py, 'g');

hold off
axis image

% level 2 and 3 EBMA
for ii = L-1:-1:1
    % update level parameters
    px = px*2;
    py = py*2;
    line_width = floor(w/block_size);
    h = h*2;
    w = w*2;
    mm = length(py);
    
    m = 1;
    
    for i = 1:block_size:h-block_size+1
        baseline = double(uint32(i/2/block_size))*double(line_width);
        for j = 1:block_size:w-block_size+1
            
            % get search area
            num = floor(baseline+double(uint32(j/2/block_size))+1);
            if num > mm;
                num = mm;
            end
            
            RangeStart(1) = i+py(num)+range_start(1);
            RangeEnd(1) = i+py(num)+block_size-1+range_end(1);
            if RangeStart(1) < 1
                RangeStart(1) = 1;
            end
            if RangeEnd(1) > h
                RangeEnd(1) = h;
            end
            
            RangeStart(2) = j+px(num)+range_start(2);
            RangeEnd(2) = j+px(num)+block_size-1+range_end(2);
            if RangeStart(2) < 1
                RangeStart(2) = 1;
            end
            if RangeEnd(2) > w
                RangeEnd(2) = w;
            end
            
            if ii == 2
                temp_target = TargetDown2;
                temp_anchor = AnchorDown2;
            end
            
            if ii == 1
                temp_target = TargetDown1;
                temp_anchor = AnchorDown1;
                
            end
            
            [direx(m), direy(m),MB_search] = ...
                h_EBMA(temp_target,temp_anchor,block_size,[i,j],RangeStart,RangeEnd);
%             Predict_Img(i:i+block_size-1,j:j+block_size-1) = pre;
            t_MB_search = MB_search+t_MB_search;
            
            % optimize final result
            if(ii == 1)
                RangeStart(1) = (i+direy(m))*2-1-2;
                RangeEnd(1) = (i+direy(m))*2-1+block_size*2-1+2;
                if RangeStart(1) < 1
                    RangeStart(1) = 1;
                end
                if RangeEnd(1) > h*2
                    RangeEnd(1) = h*2;
                end
                
                RangeStart(2) = (j+direx(m))*2-1-2;
                RangeEnd(2) = (j+direx(m))*2-1+block_size*2-1+2;
                if RangeStart(2) < 1
                    RangeStart(2) = 1;
                end
                if RangeEnd(2) > w*2
                    RangeEnd(2) = w*2;
                end
                
                temp_anchor = AnchorDown1;
                [direx(m),direy(m),MB_search] = ...
                    h_EBMA(Up_Target_Img,temp_anchor,block_size,[i,j],RangeStart,RangeEnd,2);
%                 Predict_Img(i:i+block_size-1,j:j+block_size-1) = pre;
                t_MB_search = MB_search+t_MB_search;
                fx(m) = direx(m);
                fy(m) = direy(m);
            end
            ox(m) = j;
            oy(m) = i;
            m = m+1;
        end
    end
    px = direx;
    py = direy;
end

imgsize = h*w;
% result
% totaltime = etime(clock,t0);%所用时间
% % Error_Img = an_f-Predict_Img;%误差图像
% totalerror = sum(sum(abs(Error_Img)));%总误差
% avgMAD = totalerror/imgsize;%平均绝对偏差
% avgMSE = mean(mean((Error_Img.^2)));%均方误差
% PSNR = 10*log10(255*255/avgMSE);%PSNR
% MB_total = imgsize/(block_size*block_size);%块的数量
% avgMBSearch = t_MB_search/MB_total;%每个块的平均搜索次数

figure;
imshow(uint8(AnchorDown2));
title('AnchorDown2')

hold on
quiver(ox,oy,-direx,-direy, 'g');

hold off
pause(2);

figure;
imshow(uint8(an_f));
title('Anchor Image')

hold on
quiver(ox,oy,-fx,-fy, 'g');

hold off
axis image
