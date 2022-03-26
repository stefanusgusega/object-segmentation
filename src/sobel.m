function [filterX,filterY] = sobel()
    filterX = [-1  0  1; 
               -2  0  2;
               -1  0  1];
    
    filterY = [1  2  1; 
               0  0  0;
              -1 -2 -1];
    
end