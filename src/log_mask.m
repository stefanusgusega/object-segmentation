function value = log_mask(meshgrid_x, meshgrid_y, sigma)
    %log_mask - Description
    %
    % Syntax: value = log_mask(meshgrid_x, meshgrid_y, sigma)
    %
    % Long description

    D = meshgrid_x.^2 + meshgrid_y.^2;
    value = ((D - 2 * (sigma^2)) ./ (sigma^4)) .* exp(-D ./ (2 * (sigma^2)));

end
