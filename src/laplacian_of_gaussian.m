function value = laplacian_of_gaussian(sigma, mask_dim)
    %laplacian_of_gaussian - Generate the Laplacian of Gaussian mask
    %
    % Syntax: value = laplacian_of_gaussian(sigma, mask_dim)

    left_boundary = -floor(mask_dim / 2);
    right_boundary = floor(mask_dim / 2);
    lin = round(linspace(left_boundary, right_boundary, mask_dim));

    [meshgrid_x, meshgrid_y] = meshgrid(lin, lin);

    D = meshgrid_x.^2 + meshgrid_y.^2;
    value = ((D - 2 * (sigma^2)) ./ (sigma^4)) .* exp(-D ./ (2 * (sigma^2)));

    h = surf(value);

end
