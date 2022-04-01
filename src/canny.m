function imgOut = canny(imgIn, T1, T2, sigma)
    %canny - Edge detection for Canny method
    %
    % Syntax: imgOut = canny(imgIn, T1, T2, sigma)
    %
    % This is the shortcut to edge function of MATLAB function

    % If T1 and T2 undefined, then pick the automatically
    if (isempty(T1) & isempty(T2))
        T2 = max(imgIn, [], 'all') * 0.09;
        T1 = T2 * 0.05;
    end

    % Check the T1 and T2 within the range
    if (~(T1 > 0 & T2 > 0 & T1 < 255 & T2 < 255))
        throw(MException('RangeError:outOfRange', 'The T1 and T2 should be in range (0, 255). Current: T1 = %d, T2 = %d', T1, T2))
    end

    % Check if T1 <= T2
    if (~(T1 < T2))
        throw(MException('OrderError:wrongOrder', 'The T1 should be less than T2.'))
    end

    % Normalize to [0, 1]
    T1 = double(T1) / 255
    T2 = double(T2) / 255

    % Do edge detection
    imgOut = edge(imgIn, 'Canny', [T1 T2], sigma);
end
