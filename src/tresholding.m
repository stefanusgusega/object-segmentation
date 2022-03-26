function [imgOut] = tresholding(imgIn, T)
    imgOut=imgIn;
    
    [height, width] = size(imgIn);

    for i = 1:height
        for j = 1:width
            if (imgIn(i,j)<T) 
                imgOut(i,j) = 0;
            else
                imgOut(i,j) = 255;
            end
        end
    end