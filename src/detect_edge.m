function [imgOut] = detect_edge(imgIn, operator, T, sigma, laplacian_version, T1, T2, mask_dim)
    % Check the dimension
    [height, width, dim] = size(imgIn);

    % Check the dimension
    if ~(dim == 1)
        throw(MException('ImageError:sizeNotOne', 'The input image should be 1D array. Current: %dD array.', dim))
    end

    % Check if threshold defined. If not, then set automatically to 127
    if (nargin == 2 | isempty(T))
        T = median(imgIn, 'all');
    end

    if (~(T >= 0 && T <= 255))
        throw(MException('RangeError:outOfRange', 'The T should be in range [0, 255]. Current: T = %d', T));
    end

    % Check if mask_dim defined. If not, then set automatically based on sigma
    if nargin == 7
        mask_dim = ceil(sigma * 3) * 2 + 1;
    end

    % Generate mask based on operator
    switch (operator)
        case 'sobel'
            [filterX, filterY] = sobel();
        case 'prewitt'
            [filterX, filterY] = prewitt();
        case 'roberts'
            [filterX, filterY] = roberts();
        case 'laplacian'
            mask = laplacian(laplacian_version);
        case 'log'
            mask = laplacian_of_gaussian(sigma, mask_dim);
    end

    % Do convolution between input image and the mask
    if ismember(operator, {'sobel' 'prewitt' 'roberts'})
        resX = conv2(double(imgIn), double(filterX), 'same');
        resY = conv2(double(imgIn), double(filterY), 'same');

        result = sqrt(resX.^2 + resY.^2);

    elseif (strcmp(operator, 'canny'))
        % If canny, directly output the resulting image
        imgOut = canny(imgIn, T1, T2, sigma);
    else
        result = conv2(double(imgIn), double(mask), 'same');
    end

    % Typecasting to unsigned integer except Canny
    if (~(strcmp(operator, 'canny')))
        imgOut = thresholding(uint8(result), T);
    end

    imshow(imgIn);
    figure, imshow(imgOut);

end
