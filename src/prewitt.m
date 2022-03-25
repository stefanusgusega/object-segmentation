function imgOut = prewitt(imgIn)
    filterX = [-1  0  1; 
               -1  0  1;
               -1  0  1];
    
    filterY = [1  1  1; 
               0  0  0;
              -1 -1 -1];
    
    resX = conv2(double(imgIn), double(filterX), 'same');
    resY = conv2(double(imgIn), double(filterY), 'same');
    
    result = sqrt(resX.^2 + resY.^2);
    
    imgOut = result;
    %imshow(imgIn);
    %figure, imshow(uint8(imgOut));
    
    % to do : tresholding
end