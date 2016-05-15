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
mvfs = EBMA(movie, range, accuracy, start_frame, num_frames, block_size);


mvx=mvfs.mvx;
mvy=mvfs.mvy;
mad=mvfs.mad;
mvmad=mvfs.mvmad;
for i=1:num_frames-1
    [f_mvx, f_mvy, b_mvx, b_mvy]=splitmv(mvx(:,:,i),mvy(:,:,i),range);%将运动矢量场分割为前景与背景
    [fhx(i), fhy(i), fc(i)]=hist2d(f_mvx,f_mvy,range,mad(:,:,i));%2D运动矢量场直方图
    [bhx(i), bhy(i), bc(i)]=hist2d(b_mvx,b_mvy,range,mad(:,:,i));
end
%%
hx=-fhx;%why-?
hy=+fhy;%why+?
sumx=0;
sumy=0;
mov=VideoReader('shaky_car.avi');
len = mov.Height;
w = mov.Width;
mov = read(mov, [start_frame, inf]);
new_fo=zeros(len-range,w-range);
back_fo=zeros(len,w);
% aviobj=VideoReader('demo.avi');
% aviobjo=VideoReader('demo_orig.avi');
aviobj = VideoWriter('demo.avi','Uncompressed AVI');
open(aviobj);
aviobjo = VideoWriter('demo_orig.avi','Uncompressed AVI');
open(aviobjo);
for index=1:num_frames-1
    %      an_f=mov(index+1).cdata;
    an_f = mov(:,:,:,index+1);
    sumy=sumy+hy(index);
    sumx=sumx+hx(index);
    if(hy(index)>range-1&&hx(index)>range-1)
        sumy=sumy;
        sumx=sumx;
    end
    smad(index)=sum(sum(mvmad(:,:,index)));
    if(index>1&&index<num_frames-1)
        smad(index+1)=sum(sum(mvmad(:,:,index+1)));
        if((smad(index)/(smad(index-1)+eps)>3)&&smad(index)/(smad(index+1)+eps)>3)
            %用于场景切换判断
            sumy=0;           
            sumx=0;
        end
    end
    for com=1:3%r,g,b通道
        back_f=back_fo;
        an_fr=an_f(:,:,com);
        if (sumy>=0&&sumx>=0)%抖动补偿
            back_f(1+sumy:len,1:w-sumx)=an_fr(1:len-sumy,1+sumx:w);
        elseif(sumy>=0&&sumx<0)
            back_f(1+sumy:len,1-sumx:w)=an_fr(1:len-sumy,1:w+sumx);
        elseif(sumy<0&&sumx>=0)
            back_f(1:len+sumy,1:w-sumx)=an_fr(1-sumy:len,1+sumx:w);
        else %(sumy<0&&sumx<0)
            back_f(1:len+sumy,1-sumx:w)=an_fr(1-sumy:len,1:w+sumx);
        end
        new_f(:,:,com)=back_f;
    end
    %imshow(uint8(new_f(:,:,:)));
    %      aviobj = addframe(aviobj,uint8(new_f(:,:,:)));
    %      aviobjo = addframe(aviobjo,uint8(an_f(:,:,:)));
    writeVideo(aviobj, uint8(new_f(:,:,:)));
    writeVideo(aviobjo, uint8(an_f(:,:,:)));
end
close(aviobj);
close(aviobjo);
clear all;



