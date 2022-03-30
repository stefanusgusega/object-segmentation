function imgOut = segment(edgeIm, oriIm)
    %segment - Description
    %
    % Syntax: imgOut = segment(edgeIm)
    %
    % Long description
    mask = imdilate(edgeIm, strel('line', 3, 0));
    mask = imdilate(mask, strel('line', 3, 45));
    mask = imdilate(mask, strel('line', 3, 90));
    mask = imdilate(mask, strel('line', 3, 135));

    mask = imdilate(mask, strel('disk', 5));

    mask = imfill(mask, 8, 'holes');

    % seg = imclose(imfill(edgeIm, 'holes'), strel('disk', 10));
    imgOut = oriIm .* uint8(mask)
end
