function imgOut = laplacian(imgIn, threshold)
    %laplacian - Edge detection using Laplacian mask
    %
    % Syntax: imgOut = laplacian(imgIn, threshold)
    %
    % Using Laplacian mask based on threshold defined
    [height, width, dim] = size(imgIn)

    % Check the dimension
    if ~(dim == 1)
        throw(MException('ImageError:sizeNotOne', 'The input image should be 1D array. Current: %dD array.', dim))
    end

    % Check if threshold defined. If not, then set automatically to 127
    if nargin == 2
        threshold = 127
    end

    mask = [0 1 0;
        1 -4 1;
        0 1 0];

    convoluted = uint8(convn(double(imgIn), double(mask)))

    imgOut = convoluted

end
