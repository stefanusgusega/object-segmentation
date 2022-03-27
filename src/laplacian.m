function mask = laplacian()
    %laplacian - Generate Laplacian mask
    %
    % Syntax: mask = laplacian()
    %
    mask = [0 1 0;
        1 -4 1;
        0 1 0];

end
