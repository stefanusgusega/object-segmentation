function imgOut = laplacian_of_gaussian(imgIn, sigma, mask_dim)
    %laplacian_of_gaussian - Description
    %
    % Syntax: imgOut = laplacian_of_gaussian(imgIn,s sigma)
    %
    % Long description
    [height, width, dim] = size(imgIn);

    % Check the dimension
    if ~(dim == 1)
        throw(MException('ImageError:sizeNotOne', 'The input image should be 1D array. Current: %dD array.', dim));
    end

    % Check if sigma defined. If not, then set automatically to 2
    if nargin == 1
        sigma = 2;
    end

    % Check if mask_dim defined. If not, then set automatically based on sigma
    if nargin == 2
        mask_dim = ceil(sigma * 3) * 2 + 1;
    end

    % disp(mask_dim);

    left_boundary = -floor(mask_dim / 2);
    right_boundary = floor(mask_dim / 2);
    [U, V] = meshgrid(linspace(left_boundary, right_boundary, mask_dim));

    mask = log_mask(U, V, sigma);
    disp(mask);

    im = double(imgIn);

    imgOut = uint8(convn(im, double(mask)));
    % imgOut = mask;
end
