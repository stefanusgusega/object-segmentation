function [imgOut] = detect_edge(imgIn, operator, T)
    % Check the dimension
    [height, width, dim] = size(imgIn);

    if ~(dim == 1)
        throw(MException('ImageError:sizeNotOne', 'The input image should be 1D array. Current: %dD array.', dim))
    end

    if (~(T >= 0 && T <= 255))
        throw(MException('RangeError:outOfRange', 'The T should be in range [0, 255]. Current: T = %d', T))
    end

    switch (operator)
        case 'sobel'
            [filterX, filterY] = sobel();
        case 'prewitt'
            [filterX, filterY] = prewitt();
        case 'roberts'
            [filterX, filterY] = roberts();
        case 'canny'
            % tbd
        case 'log'
            % tbd
    end

    resX = conv2(double(imgIn), double(filterX), 'same');
    resY = conv2(double(imgIn), double(filterY), 'same');
    
    result = uint8(sqrt(resX.^2 + resY.^2));
    
    % tresholding
    imgOut = tresholding(result,T);
    imshow(imgIn);
    figure, imshow(imgOut);

end
