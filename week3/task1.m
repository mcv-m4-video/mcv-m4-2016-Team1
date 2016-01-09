function [foreEstim, seq_starting_test] = task1(seq,alpha, show_videos, color_space)
global params;
% parameters
% alpha = 1;

% total elements in the sequence for training
seq_length = length(seq);
seq_starting_test = round(seq_length/2) + 1; % first frame for test

% dimensions of each frame (for future 3d)
dims = ndims(seq{1});

M = cat(dims+1,seq{1:round(seq_length/2)});
seq_mean = mean(M,dims+1);
seq_std = std(double(M),0,dims+1);
clear M;

if(strcmp(color_space,'HSV'))
    seq_mean_to_show = 255*hsv2rgb(double(seq_mean)/255);
    seq_std_to_show = 255*hsv2rgb(double(seq_std)/255);
elseif(strcmp(color_space,'YUV'))
    seq_mean_to_show = ycbcr2rgb(uint8(seq_mean));
    seq_std_to_show = ycbcr2rgb(uint8(seq_std));
else
    seq_mean_to_show = seq_mean;
    seq_std_to_show = seq_std;
end

for f = seq_starting_test : seq_length
    
    % We pick as foreground those pixels which differ too much from the mean
    estimation = abs(double(seq{f}) - seq_mean) >= alpha.*(seq_std + 2);
    
    if(strcmp(color_space,'RGB'))
        estimation = max(estimation,[],3);
    elseif(strcmp(color_space,'HSV'))
        %% If the next two lines uncommented and the last commented -> Model 2. Opposite -> Model 1.
%         H_foregroud = estimation(:,:,1);
%         estimation = H_foregroud;
        estimation = max(estimation,[],3);
    elseif(strcmp(color_space,'YUV'))
        %% If the next two lines uncommented and the last commented -> Model 2. Opposite -> Model 1.
%         UV_foregroud = estimation(:,:,[2,3]);
%         estimation = max(UV_foregroud,[],3);
        estimation = max(estimation,[],3);
    end
        
        if params.fill_conn==0
            foreEstim{f-seq_starting_test+1} = estimation;
        else
            foreEstim{f-seq_starting_test+1} = imfill(estimation,params.fill_conn,'holes');
        end
        
        if show_videos
            subplot(2,2,1)
            imshow(foreEstim{f-seq_starting_test+1})
            subplot(2,2,2)
            if(strcmp(color_space,'HSV'))
                input_to_show = hsv2rgb(double(seq{f})/255);
            elseif(strcmp(color_space,'YUV'))
                input_to_show = ycbcr2rgb(seq{f});
            else
                input_to_show = seq{f};
            end
            imshow(input_to_show)
            
            subplot(2,2,3)
            imshow(uint8(seq_mean_to_show))
            subplot(2,2,4)
            imshow(uint8(seq_std_to_show))
            pause(0.001);
        end
        
end