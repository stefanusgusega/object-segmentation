classdef app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        GradientTab                    matlab.ui.container.Tab
        GradientT2EditField            matlab.ui.control.EditField
        T1Label_2                      matlab.ui.control.Label
        GradientT1EditField            matlab.ui.control.EditField
        T1Label                        matlab.ui.control.Label
        GradientThresholdEditField     matlab.ui.control.EditField
        ThresholdEditFieldLabel_2      matlab.ui.control.Label
        GradientSigmaEditField         matlab.ui.control.NumericEditField
        SigmaEditFieldLabel_2          matlab.ui.control.Label
        GradientTechniqueDropDown      matlab.ui.control.DropDown
        TechniqueDropDownLabel_2       matlab.ui.control.Label
        GradientTransformButton        matlab.ui.control.Button
        GradientBrowseButton           matlab.ui.control.Button
        GradientBasedMethodLabel       matlab.ui.control.Label
        GradientEdgeAxes               matlab.ui.control.UIAxes
        GradientSegmentAxes            matlab.ui.control.UIAxes
        GradientOriAxes                matlab.ui.control.UIAxes
        LaplacianTab                   matlab.ui.container.Tab
        LaplacianMaskDimensionEditField  matlab.ui.control.EditField
        MaskDimensionLabel             matlab.ui.control.Label
        LaplacianThresholdEditField    matlab.ui.control.EditField
        ThresholdEditFieldLabel        matlab.ui.control.Label
        LaplacianVersionDropDown       matlab.ui.control.DropDown
        LaplacianVersionDropDownLabel  matlab.ui.control.Label
        LaplacianSigmaEditField        matlab.ui.control.NumericEditField
        SigmaEditFieldLabel            matlab.ui.control.Label
        LaplacianTransformButton       matlab.ui.control.Button
        LaplacianBrowseButton          matlab.ui.control.Button
        LaplacianTechniqueDropDown     matlab.ui.control.DropDown
        TechniqueDropDownLabel         matlab.ui.control.Label
        LaplacianBasedMethodLabel      matlab.ui.control.Label
        LaplacianEdgeAxes              matlab.ui.control.UIAxes
        LaplacianSegmentAxes           matlab.ui.control.UIAxes
        LaplacianOriAxes               matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        inputImageAxesArr % Array to store all input image axes
        edgeImageAxesArr % Array to store all edge detection result axes
        segmentImageAxesArr % Array to store all object segmentation result axes
        laplacianFname % Filename that used in Laplacian Tab
        gradientFname % Filename that used in Gradient Tab
    end
    
    methods (Access = private)
        
        function initiateImageAxesComponent(~, component)
            component.Visible = 'off';
            component.Colormap = gray(256);
            axis(component, 'image');
        end
        
        function updateImage(app, fname, tab_num)
            % techniqueDropDownArr = [app.GradientTechniqueDropDown, app.LaplacianTechniqueDropDown];
            
            % Read the image
            try
                im = imread(fname);
            catch ME
                % if problem reading image, display error message
                uialert(app.UIFigure, ME.message, 'Image Error');
                return;
            end

            % assign current tab input
            currInputImageAxes = app.inputImageAxesArr(tab_num);

            % assign current tab edge
            currEdgeImageAxes = app.edgeImageAxesArr(tab_num);
            
            % assign current tab segmented object
            currSegmentImageAxes = app.segmentImageAxesArr(tab_num);    

            % display the image
            imagesc(currInputImageAxes, im);

            % create histograms based on number of color channel
            switch size(im,3)
                case 1
                    % Display the grayscale image
                    edge_only = getOutput(app, im, tab_num);
                    segmented = segment(edge_only, im) %, lower(techniqueDropDownArr(tab_num).Value));
                    imagesc(currEdgeImageAxes, edge_only);
                    imagesc(currSegmentImageAxes, segmented);

                case 3
                    edge_1 = getOutput(app, im(:,:,1), tab_num);
                    edge_2 = getOutput(app, im(:,:,2), tab_num);
                    edge_3 = getOutput(app, im(:,:,3), tab_num);
                    edge_only = edge_1 & edge_2 & edge_3;
                    segmented = segment(edge_only, im) %lower(techniqueDropDownArr(tab_num).Value));
                    % Do bitwise AND to merge all channels
                    imagesc(currEdgeImageAxes, edge_only);
                    imagesc(currSegmentImageAxes, segmented);

                    % Alternatively. convert to grayscale first
%                     imgOut = getOutput(app, rgb2gray(im), tab_num);
%                     imagesc(currEdgeImageAxes, imgOut);

                otherwise
                    % Error when image is not grayscale or truecolor
                    uialert(app.UIFigure, 'Image must be grayscale or truecolor.', 'Image Error');
                    return;
            end 
        end
        
        function edge_only = getOutput(app, im, tab_num)
            edge_only = im;
            switch (tab_num)
                case 1
                    % For Gradient Tab
                    technique = lower(app.GradientTechniqueDropDown.Value);
                    if strcmp(technique, 'canny')
                        T1 = str2num(app.GradientT1EditField.Value);
                        T2 = str2num(app.GradientT2EditField.Value);
                        sigma = app.GradientSigmaEditField.Value;
                        edge_only = detect_edge(im, technique, [], sigma, [], T1, T2, []);
                    else
                        T = str2num(app.GradientThresholdEditField.Value);
                        edge_only = detect_edge(im, technique, T, [], [], [], [], []);
                    end

                
                case 2
                    % For Laplacian Tab
                    technique = lower(app.LaplacianTechniqueDropDown.Value);
                    threshold = str2num(app.LaplacianThresholdEditField.Value);
                    version = lower(app.LaplacianVersionDropDown.Value);
                    sigma = app.LaplacianSigmaEditField.Value;
                    maskDim = str2num(app.LaplacianMaskDimensionEditField.Value);
                    edge_only = detect_edge(im, technique, threshold, sigma, version, [], [], maskDim);
                
                otherwise
                    % Error when the tab is undefined
                    uialert(app.UIFigure, 'Tab invalid.', 'Image Error');
                    return;
                
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Initiate the image axes
            app.inputImageAxesArr = [app.GradientOriAxes, app.LaplacianOriAxes];
            app.edgeImageAxesArr = [app.GradientEdgeAxes, app.LaplacianEdgeAxes];
            app.segmentImageAxesArr = [app.GradientSegmentAxes, app.LaplacianSegmentAxes];

            % image path
            path = [pwd filesep '..' filesep 'images' filesep];

            % Show loading dialog
            d = uiprogressdlg(app.UIFigure, 'Title', 'Segmenting image...', 'Indeterminate', 'on');
            drawnow

            %% Gradient
            initiateImageAxesComponent(app, app.GradientOriAxes);
            initiateImageAxesComponent(app, app.GradientEdgeAxes);
            initiateImageAxesComponent(app, app.GradientSegmentAxes);
            app.gradientFname = [path 'buah.jpg'];
            if strcmp(app.GradientTechniqueDropDown.Value, 'Canny')
                % Hide Threshold
                app.GradientThresholdEditField.Visible = "off";
                app.ThresholdEditFieldLabel_2.Visible = "off";
            else
                % Hide T1, T2, sigma
                app.GradientT1EditField.Visible = "off";
                app.T1Label.Visible = "off";
                app.GradientT2EditField.Visible = "off";
                app.T1Label_2.Visible = "off";
                app.GradientSigmaEditField.Visible = "off";
                app.SigmaEditFieldLabel_2.Visible = "off";

            end

            updateImage(app, app.gradientFname, 1);

            %% Laplacian
            initiateImageAxesComponent(app, app.LaplacianOriAxes);
            initiateImageAxesComponent(app, app.LaplacianEdgeAxes);
            initiateImageAxesComponent(app, app.LaplacianSegmentAxes);
            app.laplacianFname = [path 'buah.jpg'];
            if strcmp(app.LaplacianTechniqueDropDown.Value, 'Laplacian')
                % Hide sigma
                app.LaplacianSigmaEditField.Visible = "off";
                app.SigmaEditFieldLabel.Visible = "off";

                 % Hide mask dimension
                app.LaplacianMaskDimensionEditField.Visible = "off";
                app.MaskDimensionLabel.Visible = "off";
            elseif strcmp(app.LaplacianTechniqueDropDown.Value, 'LoG')
                app.LaplacianVersionDropDown.Visible = "off"; % Hide Laplacian version dropdown
            end
            
            updateImage(app, app.laplacianFname, 2);

            % Stop loading dialog
            close(d);
        end

        % Value changed function: LaplacianTechniqueDropDown
        function LaplacianTechniqueDropDownValueChanged(app, event)

            if strcmp(app.LaplacianTechniqueDropDown.Value, 'Laplacian')
                % Hide sigma
                app.LaplacianSigmaEditField.Visible = "off";
                app.SigmaEditFieldLabel.Visible = "off";

                % Hide mask dimension
                app.LaplacianMaskDimensionEditField.Visible = "off";
                app.MaskDimensionLabel.Visible = "off";

                % Show Laplacian version dropdown
                app.LaplacianVersionDropDown.Visible = "on";
                app.LaplacianVersionDropDownLabel.Visible = "on";
            elseif strcmp(app.LaplacianTechniqueDropDown.Value, 'LoG')
                % Hide Laplacian version dropdown
                app.LaplacianVersionDropDown.Visible = "off";
                app.LaplacianVersionDropDownLabel.Visible = "off";

                % Show sigma
                app.LaplacianSigmaEditField.Visible = "on";
                app.SigmaEditFieldLabel.Visible = "on";

                % Show mask dimension
                app.LaplacianMaskDimensionEditField.Visible = "on";
                app.MaskDimensionLabel.Visible = "on";
            end
            
        end

        % Button pushed function: LaplacianBrowseButton
        function LaplacianBrowseButtonPushed(app, event)
            % Display uigetfile dialog
            filterspec = {'*.jpg;*.tif;*.png;*.gif;*.bmp','All Image Files'};
            [f, p] = uigetfile(filterspec);
            
            % Make sure user didn't cancel uigetfile dialog
            if (ischar(p))
               app.laplacianFname = [p f];
               d = uiprogressdlg(app.UIFigure, 'Title', 'Segmenting image...', 'Indeterminate', 'on');
               drawnow
               updateImage(app, app.laplacianFname, 2);
               close(d);
            end
        end

        % Button pushed function: LaplacianTransformButton
        function LaplacianTransformButtonPushed(app, event)
            d = uiprogressdlg(app.UIFigure, 'Title', 'Segmenting image...', 'Indeterminate', 'on');
            drawnow
            updateImage(app, app.laplacianFname, 2);
            close(d);
        end

        % Value changed function: GradientTechniqueDropDown
        function GradientTechniqueDropDownValueChanged(app, event)
            value = app.GradientTechniqueDropDown.Value;

            if strcmp(value, 'Canny')
                % Hide Threshold
                app.GradientThresholdEditField.Visible = "off";
                app.ThresholdEditFieldLabel_2.Visible = "off";

                
                % Show T1, T2, sigma
                app.GradientT1EditField.Visible = "on";
                app.T1Label.Visible = "on";
                
                app.GradientT2EditField.Visible = "on";
                app.T1Label_2.Visible = "on";

                app.SigmaEditFieldLabel_2.Visible = "on";
                app.GradientSigmaEditField.Visible = "on";

            else
                % Hide T1, T2, sigma
                app.GradientT1EditField.Visible = "off";
                app.T1Label.Visible = "off";

                app.GradientT2EditField.Visible = "off";
                app.T1Label_2.Visible = "off";

                app.SigmaEditFieldLabel_2.Visible = "off";
                app.GradientSigmaEditField.Visible = "off";


                % Show Threshold
                app.GradientThresholdEditField.Visible = "on";
                app.ThresholdEditFieldLabel_2.Visible = "on";

            end

        end

        % Button pushed function: GradientTransformButton
        function GradientTransformButtonPushed(app, event)
            d = uiprogressdlg(app.UIFigure, 'Title', 'Segmenting image...', 'Indeterminate', 'on');
            drawnow
            updateImage(app, app.gradientFname, 1);
            close(d);
        end

        % Button pushed function: GradientBrowseButton
        function GradientBrowseButtonPushed(app, event)
            % Display uigetfile dialog
            filterspec = {'*.jpg;*.tif;*.png;*.gif;*.bmp','All Image Files'};
            [f, p] = uigetfile(filterspec);
            
            % Make sure user didn't cancel uigetfile dialog
            if (ischar(p))
               app.gradientFname = [p f];
               d = uiprogressdlg(app.UIFigure, 'Title', 'Segmenting image...', 'Indeterminate', 'on');
               drawnow
               updateImage(app, app.gradientFname, 1);
               close(d);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 640 480];

            % Create GradientTab
            app.GradientTab = uitab(app.TabGroup);
            app.GradientTab.Title = 'Gradient';

            % Create GradientOriAxes
            app.GradientOriAxes = uiaxes(app.GradientTab);
            title(app.GradientOriAxes, 'Original Image')
            app.GradientOriAxes.XTick = [];
            app.GradientOriAxes.YTick = [];
            app.GradientOriAxes.ZTick = [];
            app.GradientOriAxes.Position = [16 237 204 157];

            % Create GradientSegmentAxes
            app.GradientSegmentAxes = uiaxes(app.GradientTab);
            title(app.GradientSegmentAxes, 'Segmentation Result')
            app.GradientSegmentAxes.XTick = [];
            app.GradientSegmentAxes.YTick = [];
            app.GradientSegmentAxes.ZTick = [];
            app.GradientSegmentAxes.Position = [421 237 204 157];

            % Create GradientEdgeAxes
            app.GradientEdgeAxes = uiaxes(app.GradientTab);
            title(app.GradientEdgeAxes, 'Edge Detection Result')
            app.GradientEdgeAxes.XTick = [];
            app.GradientEdgeAxes.YTick = [];
            app.GradientEdgeAxes.ZTick = [];
            app.GradientEdgeAxes.Position = [218 237 204 157];

            % Create GradientBasedMethodLabel
            app.GradientBasedMethodLabel = uilabel(app.GradientTab);
            app.GradientBasedMethodLabel.FontSize = 18;
            app.GradientBasedMethodLabel.FontWeight = 'bold';
            app.GradientBasedMethodLabel.Position = [36 402 219 32];
            app.GradientBasedMethodLabel.Text = 'Gradient-Based Method';

            % Create GradientBrowseButton
            app.GradientBrowseButton = uibutton(app.GradientTab, 'push');
            app.GradientBrowseButton.ButtonPushedFcn = createCallbackFcn(app, @GradientBrowseButtonPushed, true);
            app.GradientBrowseButton.Position = [80 216 100 23];
            app.GradientBrowseButton.Text = 'Browse';

            % Create GradientTransformButton
            app.GradientTransformButton = uibutton(app.GradientTab, 'push');
            app.GradientTransformButton.ButtonPushedFcn = createCallbackFcn(app, @GradientTransformButtonPushed, true);
            app.GradientTransformButton.Position = [480 217 100 23];
            app.GradientTransformButton.Text = 'Transform';

            % Create TechniqueDropDownLabel_2
            app.TechniqueDropDownLabel_2 = uilabel(app.GradientTab);
            app.TechniqueDropDownLabel_2.HorizontalAlignment = 'right';
            app.TechniqueDropDownLabel_2.Position = [245 217 60 22];
            app.TechniqueDropDownLabel_2.Text = 'Technique';

            % Create GradientTechniqueDropDown
            app.GradientTechniqueDropDown = uidropdown(app.GradientTab);
            app.GradientTechniqueDropDown.Items = {'Sobel', 'Roberts', 'Prewitt', 'Canny'};
            app.GradientTechniqueDropDown.ValueChangedFcn = createCallbackFcn(app, @GradientTechniqueDropDownValueChanged, true);
            app.GradientTechniqueDropDown.Position = [320 217 100 22];
            app.GradientTechniqueDropDown.Value = 'Sobel';

            % Create SigmaEditFieldLabel_2
            app.SigmaEditFieldLabel_2 = uilabel(app.GradientTab);
            app.SigmaEditFieldLabel_2.HorizontalAlignment = 'right';
            app.SigmaEditFieldLabel_2.Position = [268 84 39 22];
            app.SigmaEditFieldLabel_2.Text = 'Sigma';

            % Create GradientSigmaEditField
            app.GradientSigmaEditField = uieditfield(app.GradientTab, 'numeric');
            app.GradientSigmaEditField.Position = [322 84 100 22];
            app.GradientSigmaEditField.Value = 1.2;

            % Create ThresholdEditFieldLabel_2
            app.ThresholdEditFieldLabel_2 = uilabel(app.GradientTab);
            app.ThresholdEditFieldLabel_2.HorizontalAlignment = 'right';
            app.ThresholdEditFieldLabel_2.Position = [248 170 59 22];
            app.ThresholdEditFieldLabel_2.Text = 'Threshold';

            % Create GradientThresholdEditField
            app.GradientThresholdEditField = uieditfield(app.GradientTab, 'text');
            app.GradientThresholdEditField.HorizontalAlignment = 'right';
            app.GradientThresholdEditField.Placeholder = 'auto';
            app.GradientThresholdEditField.Position = [322 170 100 22];

            % Create T1Label
            app.T1Label = uilabel(app.GradientTab);
            app.T1Label.HorizontalAlignment = 'right';
            app.T1Label.Position = [282 170 25 22];
            app.T1Label.Text = 'T1';

            % Create GradientT1EditField
            app.GradientT1EditField = uieditfield(app.GradientTab, 'text');
            app.GradientT1EditField.HorizontalAlignment = 'right';
            app.GradientT1EditField.Placeholder = 'auto';
            app.GradientT1EditField.Position = [322 170 100 22];

            % Create T1Label_2
            app.T1Label_2 = uilabel(app.GradientTab);
            app.T1Label_2.HorizontalAlignment = 'right';
            app.T1Label_2.Position = [282 129 25 22];
            app.T1Label_2.Text = 'T2';

            % Create GradientT2EditField
            app.GradientT2EditField = uieditfield(app.GradientTab, 'text');
            app.GradientT2EditField.HorizontalAlignment = 'right';
            app.GradientT2EditField.Placeholder = 'auto';
            app.GradientT2EditField.Position = [322 129 100 22];

            % Create LaplacianTab
            app.LaplacianTab = uitab(app.TabGroup);
            app.LaplacianTab.Title = 'Laplacian';

            % Create LaplacianOriAxes
            app.LaplacianOriAxes = uiaxes(app.LaplacianTab);
            title(app.LaplacianOriAxes, 'Original Image')
            app.LaplacianOriAxes.XTick = [];
            app.LaplacianOriAxes.YTick = [];
            app.LaplacianOriAxes.ZTick = [];
            app.LaplacianOriAxes.Position = [16 237 204 157];

            % Create LaplacianSegmentAxes
            app.LaplacianSegmentAxes = uiaxes(app.LaplacianTab);
            title(app.LaplacianSegmentAxes, 'Segmentation Result')
            app.LaplacianSegmentAxes.XTick = [];
            app.LaplacianSegmentAxes.YTick = [];
            app.LaplacianSegmentAxes.ZTick = [];
            app.LaplacianSegmentAxes.Position = [421 237 204 157];

            % Create LaplacianEdgeAxes
            app.LaplacianEdgeAxes = uiaxes(app.LaplacianTab);
            title(app.LaplacianEdgeAxes, 'Edge Detection Result')
            app.LaplacianEdgeAxes.XTick = [];
            app.LaplacianEdgeAxes.YTick = [];
            app.LaplacianEdgeAxes.ZTick = [];
            app.LaplacianEdgeAxes.Position = [218 237 204 157];

            % Create LaplacianBasedMethodLabel
            app.LaplacianBasedMethodLabel = uilabel(app.LaplacianTab);
            app.LaplacianBasedMethodLabel.FontSize = 18;
            app.LaplacianBasedMethodLabel.FontWeight = 'bold';
            app.LaplacianBasedMethodLabel.Position = [36 402 219 32];
            app.LaplacianBasedMethodLabel.Text = 'Laplacian-Based Method';

            % Create TechniqueDropDownLabel
            app.TechniqueDropDownLabel = uilabel(app.LaplacianTab);
            app.TechniqueDropDownLabel.HorizontalAlignment = 'right';
            app.TechniqueDropDownLabel.Position = [245 217 60 22];
            app.TechniqueDropDownLabel.Text = 'Technique';

            % Create LaplacianTechniqueDropDown
            app.LaplacianTechniqueDropDown = uidropdown(app.LaplacianTab);
            app.LaplacianTechniqueDropDown.Items = {'Laplacian', 'LoG'};
            app.LaplacianTechniqueDropDown.ValueChangedFcn = createCallbackFcn(app, @LaplacianTechniqueDropDownValueChanged, true);
            app.LaplacianTechniqueDropDown.Position = [320 217 100 22];
            app.LaplacianTechniqueDropDown.Value = 'Laplacian';

            % Create LaplacianBrowseButton
            app.LaplacianBrowseButton = uibutton(app.LaplacianTab, 'push');
            app.LaplacianBrowseButton.ButtonPushedFcn = createCallbackFcn(app, @LaplacianBrowseButtonPushed, true);
            app.LaplacianBrowseButton.Position = [80 216 100 23];
            app.LaplacianBrowseButton.Text = 'Browse';

            % Create LaplacianTransformButton
            app.LaplacianTransformButton = uibutton(app.LaplacianTab, 'push');
            app.LaplacianTransformButton.ButtonPushedFcn = createCallbackFcn(app, @LaplacianTransformButtonPushed, true);
            app.LaplacianTransformButton.Position = [480 217 100 23];
            app.LaplacianTransformButton.Text = 'Transform';

            % Create SigmaEditFieldLabel
            app.SigmaEditFieldLabel = uilabel(app.LaplacianTab);
            app.SigmaEditFieldLabel.HorizontalAlignment = 'right';
            app.SigmaEditFieldLabel.Position = [129 121 39 22];
            app.SigmaEditFieldLabel.Text = 'Sigma';

            % Create LaplacianSigmaEditField
            app.LaplacianSigmaEditField = uieditfield(app.LaplacianTab, 'numeric');
            app.LaplacianSigmaEditField.Position = [183 121 100 22];
            app.LaplacianSigmaEditField.Value = 1.2;

            % Create LaplacianVersionDropDownLabel
            app.LaplacianVersionDropDownLabel = uilabel(app.LaplacianTab);
            app.LaplacianVersionDropDownLabel.HorizontalAlignment = 'right';
            app.LaplacianVersionDropDownLabel.Position = [366 162 100 22];
            app.LaplacianVersionDropDownLabel.Text = 'Laplacian Version';

            % Create LaplacianVersionDropDown
            app.LaplacianVersionDropDown = uidropdown(app.LaplacianTab);
            app.LaplacianVersionDropDown.Items = {'Original', 'Diagonal'};
            app.LaplacianVersionDropDown.Position = [481 162 100 22];
            app.LaplacianVersionDropDown.Value = 'Original';

            % Create ThresholdEditFieldLabel
            app.ThresholdEditFieldLabel = uilabel(app.LaplacianTab);
            app.ThresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.ThresholdEditFieldLabel.Position = [108 162 59 22];
            app.ThresholdEditFieldLabel.Text = 'Threshold';

            % Create LaplacianThresholdEditField
            app.LaplacianThresholdEditField = uieditfield(app.LaplacianTab, 'text');
            app.LaplacianThresholdEditField.HorizontalAlignment = 'right';
            app.LaplacianThresholdEditField.Placeholder = 'auto';
            app.LaplacianThresholdEditField.Position = [182 162 100 22];

            % Create MaskDimensionLabel
            app.MaskDimensionLabel = uilabel(app.LaplacianTab);
            app.MaskDimensionLabel.HorizontalAlignment = 'right';
            app.MaskDimensionLabel.Position = [371 121 94 22];
            app.MaskDimensionLabel.Text = 'Mask Dimension';

            % Create LaplacianMaskDimensionEditField
            app.LaplacianMaskDimensionEditField = uieditfield(app.LaplacianTab, 'text');
            app.LaplacianMaskDimensionEditField.HorizontalAlignment = 'right';
            app.LaplacianMaskDimensionEditField.Placeholder = 'auto';
            app.LaplacianMaskDimensionEditField.Position = [480 121 100 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end