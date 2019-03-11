% MATLAB Graph extractor 
%   Created by Pargorn Puttapirat at XJTU (pargorn.puttapirat@g.swu.ac.th)
%   Created on 20190310
%   Last update 20190310

%% Script configuration
graph_filename = 'img1.png';   % input filename
trim_val = [50,50];     % Trim left and right part of the signal, input 0 for no trim. 
output_filename = 'save';
num_of_grid = 18; 
grid_scale = 1;     % in the original unit
cropping_coordinate = [5.5100   34.5100  896.9800  497.9800];   % [5.5100   34.5100  896.9800  497.9800]

%% Load the image 
I = imread(graph_filename);

% crop the image
if isempty(cropping_coordinate)
    [I_crop, rect] = imcrop(I);
else
    [I_crop, rect] = imcrop(I, cropping_coordinate);
end
disp('Cropping coordinate'); 
disp(rect);
imshowpair(I,I_crop,'montage'); 

%% Extract the graph from the image based on color
mask = createMaskv1(I_crop);

%% Use morphological operations to clean the data 
SE = strel('square',2);
mask_clean = imclose(mask, SE);
mask_clean2 = bwskel(mask_clean); 

clean = mask_clean2;

%% Map the 'col' to the x-axis
[max_y, y_axis] = size(clean);
y_val = zeros(y_axis, 1);
y_flag = zeros(y_axis, 1);
for i = 1:y_axis
    graph_col = clean(:,i);
    
    % Find the position of the bright spot in the column
    idx = find(graph_col,1,'last');     % Select the highest value
    
    if isempty(idx)
        y_flag(i) = 1;
    else
        y_val(i) = idx;
    end
end

% Revert the data
y_val_revt = (-y_val) + max_y;

%% Calculate x-scale 
entire_x = grid_scale * num_of_grid; 
sampling_rate = entire_x / length(y_val_revt);

% Generate x scale 
x_scale = (0:length(y_val_revt))' * sampling_rate;
x_scale(end) = [];

%% Trim the data 
y_val_trim = y_val_revt(trim_val(1):length(y_val_revt)-trim_val(2),1); 
x_scale_trim = x_scale(trim_val(1):length(x_scale)-trim_val(2),1); 

%% Save the data
h = figure();
hold on; 
plot(x_scale_trim, y_val_trim);
hold off; 
saveas(h, [output_filename '.png']);

final_mat = [x_scale_trim, y_val_trim];
xlswrite([output_filename '_raw.xls'], final_mat); 
