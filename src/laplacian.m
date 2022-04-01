function mask = laplacian(version)
    %laplacian - Generate Laplacian mask
    %
    % Syntax: mask = laplacian(version)
    %

    % Check the version
    if ~ismember(version, {'original' 'diagonal'})
        throw(MException('VersionError:wrongVersion', "The Laplacian version should be one of these: 'original' or 'diagonal'. Current: %s.", version))
    end

    if strcmp(version, 'original')
        mask = [0 1 0;
            1 -4 1;
            0 1 0];
    elseif strcmp(version, 'diagonal')
        mask = [1 1 1;
            1 -8 1;
            1 1 1];
    end

end
