function [filterX,filterY] = roberts()
    filterX = [1  0; 
               0 -1];
    
    filterY = [0  1; 
              -1  0];
    
end