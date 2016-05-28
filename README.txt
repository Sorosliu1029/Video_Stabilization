Video_Stabilization.m is the main function for video stabilization purpose.
EBMA.m use EBMA algorithm to generate block motion vectors.
splitmv.m split the frame into foreground and background parts.
GMV.m get global motion vector from BMVs.
compensate.m uses GMV to compensate motions.
stabilize.m connects all functions together to stabilize the video.

HBMA.m is a implement of HBMA algorithm.
h_EBMA.m is EBMA function only called by HBMA.
HBMA_visualize.m is used to visualize the result of each level of HBMA.

visualise_BMV.m is used to show block motion vectors.

“MathWorks” folder is provided by MathWorks website. It is used to compare three algorithms: EBMA, 2DLS, TSS.

experiment video is ‘shaky_car.avi’, which is provided by MATLAB R2015b. It could be found in path: /Applications/MATLAB_R2015b.app/toolbox/vision/visiondata/shaky_car.avi

report.pptx is the class representation for this course project.

demo2 is better than demo1.

Liu Yang
22 May, 2016