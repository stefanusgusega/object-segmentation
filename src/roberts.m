function imgOut = roberts(imgIn, T)
    filterX = [1  0; 
               0 -1];
    
    filterY = [0  1; 
              -1  0];
    
    resX = conv2(double(imgIn), double(filterX), 'same');
    resY = conv2(double(imgIn), double(filterY), 'same');
    
    result = uint8(sqrt(resX.^2 + resY.^2));
    
    % tresholding
    imgOut = tresholding(result,T);
    %imshow(imgIn);
    %figure, imshow(imgOut);
end