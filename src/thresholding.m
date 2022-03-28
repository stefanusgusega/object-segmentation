function [imgOut] = thresholding(imgIn, T)
    [height, width] = size(imgIn);

    imgOut = zeros(height, width, 'logical');

    for i = 1:height

        for j = 1:width

            if (imgIn(i, j) <= T)
                imgOut(i, j) = false;
            else
                imgOut(i, j) = true;
            end

        end

    end
