function imgOut = segment(edgeIm, oriIm, technique)
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

    if ~strcmp(technique, 'sobel') && ~strcmp(technique, 'prewitt')
        % disp(technique);
        mask = imfill(mask, 8, 'holes');
        % imshow(mask);
    end

    % seg = imclose(imfill(edgeIm, 'holes'), strel('disk', 10));
    imgOut = oriIm .* uint8(mask);
end
