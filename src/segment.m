function imgOut = segment(edgeIm, oriIm)
    %segment - Description
    %
    % Syntax: imgOut = segment(edgeIm)
    %
    % Image Segmentation based on edge image.

    [h,w,d] = size(edgeIm);
    
    % clean image border
    clear = edgeIm;
    clear(1,:) = 0;
    clear(h,:) = 0;
    clear(:,1) = 0;
    clear(:,w) = 0;

    %disp(clear);
    %imshow(clear);
    %figure,imshow(clear);

    % connecting edge lines
    mask = imdilate(clear, strel('line', 3, 0));
    mask = imdilate(mask, strel('line', 3, 45));
    mask = imdilate(mask, strel('line', 3, 90));
    mask = imdilate(mask, strel('line', 3, 135));

    mask = imdilate(mask, strel('disk', 5));

    % fill in object gaps
    mask = imfill(mask, 8, 'holes');
    % figure,imshow(mask);
    % seg = imclose(imfill(edgeIm, 'holes'), strel('disk', 10));

    % apply to original image
    imgOut = oriIm .* uint8(mask)
end
