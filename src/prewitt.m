function [filterX,filterY] = prewitt()
    filterX = [-1  0  1; 
               -1  0  1;
               -1  0  1];
    
    filterY = [1  1  1; 
               0  0  0;
              -1 -1 -1];
    
end