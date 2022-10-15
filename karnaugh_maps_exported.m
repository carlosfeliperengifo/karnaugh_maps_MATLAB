classdef karnaugh_maps_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        TabGroup           matlab.ui.container.TabGroup
        TruthtableTab      matlab.ui.container.Tab
        ReadExcelButton    matlab.ui.control.Button
        UITable            matlab.ui.control.Table
        KarnaughTab        matlab.ui.container.Tab
        Label_Error        matlab.ui.control.Label
        Label_LogicOutput  matlab.ui.control.Label
        LogicOutputLabel   matlab.ui.control.Label
        Label_7            matlab.ui.control.Label
        ClearButton        matlab.ui.control.Button
        AddTermButton      matlab.ui.control.Button
        CDLabel            matlab.ui.control.Label
        Label_R4           matlab.ui.control.Label
        Label_R3           matlab.ui.control.Label
        Label_R2           matlab.ui.control.Label
        Label_R1           matlab.ui.control.Label
        ABLabel            matlab.ui.control.Label
        CheckBox_11        matlab.ui.control.CheckBox
        Label_11           matlab.ui.control.Label
        CheckBox_15        matlab.ui.control.CheckBox
        Label_15           matlab.ui.control.Label
        CheckBox_7         matlab.ui.control.CheckBox
        CheckBox_3         matlab.ui.control.CheckBox
        Label_3            matlab.ui.control.Label
        CheckBox_12        matlab.ui.control.CheckBox
        Label_12           matlab.ui.control.Label
        CheckBox_16        matlab.ui.control.CheckBox
        Label_16           matlab.ui.control.Label
        CheckBox_8         matlab.ui.control.CheckBox
        Label_8            matlab.ui.control.Label
        CheckBox_4         matlab.ui.control.CheckBox
        Label_4            matlab.ui.control.Label
        CheckBox_10        matlab.ui.control.CheckBox
        Label_10           matlab.ui.control.Label
        CheckBox_14        matlab.ui.control.CheckBox
        Label_14           matlab.ui.control.Label
        CheckBox_6         matlab.ui.control.CheckBox
        Label_6            matlab.ui.control.Label
        CheckBox_2         matlab.ui.control.CheckBox
        Label_2            matlab.ui.control.Label
        CheckBox_9         matlab.ui.control.CheckBox
        Label_9            matlab.ui.control.Label
        CheckBox_13        matlab.ui.control.CheckBox
        Label_13           matlab.ui.control.Label
        CheckBox_5         matlab.ui.control.CheckBox
        Label_5            matlab.ui.control.Label
        CheckBox_1         matlab.ui.control.CheckBox
        Label_1            matlab.ui.control.Label
        Label_C4           matlab.ui.control.Label
        Label_C3           matlab.ui.control.Label
        Label_C2           matlab.ui.control.Label
        Label_C1           matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: ReadExcelButton
        function ReadExcelButtonPushed(app, event)
            global matrix;                                                  %#ok<*GVMIS>             

            %% Read the Excel file with the truth table
            [file, path] = uigetfile({'*.xlsx';'*.xls';'*.csv'},'Excel file with the truth table');
            data = readtable(fullfile(path,file),'Sheet',1);
            app.UITable.Data = data;
            
            %% Load truth table in a 16x5 matrix
            matrix = table2array(data);           
            
            %% Delete logic output
            app.Label_LogicOutput.Text = '';

            %% Configure the labels and checkboxes of the Karnaugh map
            for i = 1:16
                % Write the output of the truth table
                numlabel = sprintf('Label_%d',i);
                app.(numlabel).Text = num2str(matrix(i,5)); 
                
                % Font color is set to black
                app.(numlabel).FontColor = [0,0,0];
                
                % Disable the checkboxes of outputs equal to zero
                numcheckbox = sprintf('CheckBox_%d',i);
                app.(numcheckbox).Enable = matrix(i,5);
            end    
        end

        % Button pushed function: AddTermButton
        function AddTermButtonPushed(app, event)
            %% Disable the selected checkboxes
            current_selection = zeros(16,1);
            for i=1:16
                numlabel = sprintf('Label_%d',i);
                numcheckbox = sprintf('CheckBox_%d',i);                
                checked = app.(numcheckbox).Value;
                enabled = app.(numcheckbox).Enable;
                if checked && enabled
                    app.(numlabel).FontColor = [1,0,0];
                    current_selection(i) = 1;
                end 
            end

            %% The number of selected ones must be a power of 2
            if all(sum(current_selection) ~= [1,2,4,8,16])
                uialert(app.UIFigure,'The number of selected values must be 1,2,4,8 or 16','Wrong number of entries');
                for i = 1:length(current_selection)
                    if current_selection(i) == 1                        
                        numlabel = sprintf('Label_%d',i);
                        numcheckbox = sprintf('CheckBox_%d',i);
                        app.(numcheckbox).Value = false;
                        app.(numlabel).FontColor = [0,0,0];
                    end    
                end
                return;
            end    

            %% Get matrix
            global matrix;

            %% Get A, B, C, and D for the selected rows
            letter = ["A","B","C","D"];
            term   = app.Label_LogicOutput.Text;

            %% Add a plus when term is not empty
            if ~isempty(term)
                term = term + "+";
            end

            %% Check for constant columns across selected rows
            for i=1:4
                inputvar = matrix(logical(current_selection),i);
                if all(inputvar == 1)
                    term = term + sprintf(" %s ",letter(i));
                elseif all(inputvar == 0)
                    term = term + sprintf(" NOT(%s) ",letter(i));
                end
            end                
            app.Label_LogicOutput.Text = term;

            %% Uncheck checked boxes
            for i=1:16
                numcheckbox = sprintf('CheckBox_%d',i);                
                app.(numcheckbox).Value = false;
            end
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
        %% Delete logic output
        app.Label_LogicOutput.Text = '';

        %% Configure the labels and checkboxes of the Karnaugh map    
        for i = 1:16
            % Disable the checkboxes of outputs equal to zero
            numlabel = sprintf('Label_%d',i);
            numcheckbox = sprintf('CheckBox_%d',i);
            Value = app.(numlabel).Text;
            app.(numcheckbox).Enable = (Value == '1');
            app.(numcheckbox).Value = false;
            app.(numlabel).FontColor = [0,0,0];
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
            app.TabGroup.Position = [9 1 632 480];

            % Create TruthtableTab
            app.TruthtableTab = uitab(app.TabGroup);
            app.TruthtableTab.Title = 'Truth table';

            % Create UITable
            app.UITable = uitable(app.TruthtableTab);
            app.UITable.ColumnName = {'A'; 'B'; 'C'; 'D'; 'Output'};
            app.UITable.RowName = {};
            app.UITable.Position = [31 44 401 390];

            % Create ReadExcelButton
            app.ReadExcelButton = uibutton(app.TruthtableTab, 'push');
            app.ReadExcelButton.ButtonPushedFcn = createCallbackFcn(app, @ReadExcelButtonPushed, true);
            app.ReadExcelButton.Position = [495 412 100 22];
            app.ReadExcelButton.Text = 'Read Excel';

            % Create KarnaughTab
            app.KarnaughTab = uitab(app.TabGroup);
            app.KarnaughTab.Title = 'Karnaugh';

            % Create Label_C1
            app.Label_C1 = uilabel(app.KarnaughTab);
            app.Label_C1.FontSize = 16;
            app.Label_C1.FontWeight = 'bold';
            app.Label_C1.Position = [147 362 25 22];
            app.Label_C1.Text = '00';

            % Create Label_C2
            app.Label_C2 = uilabel(app.KarnaughTab);
            app.Label_C2.FontSize = 16;
            app.Label_C2.FontWeight = 'bold';
            app.Label_C2.Position = [207 362 25 22];
            app.Label_C2.Text = '01';

            % Create Label_C3
            app.Label_C3 = uilabel(app.KarnaughTab);
            app.Label_C3.FontSize = 16;
            app.Label_C3.FontWeight = 'bold';
            app.Label_C3.Position = [270 362 25 22];
            app.Label_C3.Text = '11';

            % Create Label_C4
            app.Label_C4 = uilabel(app.KarnaughTab);
            app.Label_C4.FontSize = 16;
            app.Label_C4.FontWeight = 'bold';
            app.Label_C4.Position = [330 362 25 22];
            app.Label_C4.Text = '10';

            % Create Label_1
            app.Label_1 = uilabel(app.KarnaughTab);
            app.Label_1.FontSize = 16;
            app.Label_1.Position = [147 321 25 22];
            app.Label_1.Text = '0';

            % Create CheckBox_1
            app.CheckBox_1 = uicheckbox(app.KarnaughTab);
            app.CheckBox_1.Text = '';
            app.CheckBox_1.Position = [171 321 25 22];

            % Create Label_5
            app.Label_5 = uilabel(app.KarnaughTab);
            app.Label_5.FontSize = 16;
            app.Label_5.Position = [207 321 25 22];
            app.Label_5.Text = '0';

            % Create CheckBox_5
            app.CheckBox_5 = uicheckbox(app.KarnaughTab);
            app.CheckBox_5.Text = '';
            app.CheckBox_5.Position = [231 321 25 22];

            % Create Label_13
            app.Label_13 = uilabel(app.KarnaughTab);
            app.Label_13.FontSize = 16;
            app.Label_13.Position = [270 321 25 22];
            app.Label_13.Text = '0';

            % Create CheckBox_13
            app.CheckBox_13 = uicheckbox(app.KarnaughTab);
            app.CheckBox_13.Text = '';
            app.CheckBox_13.Position = [294 321 25 22];

            % Create Label_9
            app.Label_9 = uilabel(app.KarnaughTab);
            app.Label_9.FontSize = 16;
            app.Label_9.Position = [330 321 25 22];
            app.Label_9.Text = '0';

            % Create CheckBox_9
            app.CheckBox_9 = uicheckbox(app.KarnaughTab);
            app.CheckBox_9.Text = '';
            app.CheckBox_9.Position = [354 321 25 22];

            % Create Label_2
            app.Label_2 = uilabel(app.KarnaughTab);
            app.Label_2.FontSize = 16;
            app.Label_2.Position = [147 283 25 22];
            app.Label_2.Text = '0';

            % Create CheckBox_2
            app.CheckBox_2 = uicheckbox(app.KarnaughTab);
            app.CheckBox_2.Text = '';
            app.CheckBox_2.Position = [171 283 25 22];

            % Create Label_6
            app.Label_6 = uilabel(app.KarnaughTab);
            app.Label_6.FontSize = 16;
            app.Label_6.Position = [207 283 25 22];
            app.Label_6.Text = '0';

            % Create CheckBox_6
            app.CheckBox_6 = uicheckbox(app.KarnaughTab);
            app.CheckBox_6.Text = '';
            app.CheckBox_6.Position = [231 283 25 22];

            % Create Label_14
            app.Label_14 = uilabel(app.KarnaughTab);
            app.Label_14.FontSize = 16;
            app.Label_14.Position = [270 283 25 22];
            app.Label_14.Text = '0';

            % Create CheckBox_14
            app.CheckBox_14 = uicheckbox(app.KarnaughTab);
            app.CheckBox_14.Text = '';
            app.CheckBox_14.Position = [294 283 25 22];

            % Create Label_10
            app.Label_10 = uilabel(app.KarnaughTab);
            app.Label_10.FontSize = 16;
            app.Label_10.Position = [330 283 25 22];
            app.Label_10.Text = '0';

            % Create CheckBox_10
            app.CheckBox_10 = uicheckbox(app.KarnaughTab);
            app.CheckBox_10.Text = '';
            app.CheckBox_10.Position = [354 283 25 22];

            % Create Label_4
            app.Label_4 = uilabel(app.KarnaughTab);
            app.Label_4.FontSize = 16;
            app.Label_4.Position = [147 246 25 22];
            app.Label_4.Text = '0';

            % Create CheckBox_4
            app.CheckBox_4 = uicheckbox(app.KarnaughTab);
            app.CheckBox_4.Text = '';
            app.CheckBox_4.Position = [171 246 25 22];

            % Create Label_8
            app.Label_8 = uilabel(app.KarnaughTab);
            app.Label_8.FontSize = 16;
            app.Label_8.Position = [207 246 25 22];
            app.Label_8.Text = '0';

            % Create CheckBox_8
            app.CheckBox_8 = uicheckbox(app.KarnaughTab);
            app.CheckBox_8.Text = '';
            app.CheckBox_8.Position = [231 246 25 22];

            % Create Label_16
            app.Label_16 = uilabel(app.KarnaughTab);
            app.Label_16.FontSize = 16;
            app.Label_16.Position = [270 246 25 22];
            app.Label_16.Text = '0';

            % Create CheckBox_16
            app.CheckBox_16 = uicheckbox(app.KarnaughTab);
            app.CheckBox_16.Text = '';
            app.CheckBox_16.Position = [294 246 25 22];

            % Create Label_12
            app.Label_12 = uilabel(app.KarnaughTab);
            app.Label_12.FontSize = 16;
            app.Label_12.Position = [330 246 25 22];
            app.Label_12.Text = '0';

            % Create CheckBox_12
            app.CheckBox_12 = uicheckbox(app.KarnaughTab);
            app.CheckBox_12.Text = '';
            app.CheckBox_12.Position = [354 246 25 22];

            % Create Label_3
            app.Label_3 = uilabel(app.KarnaughTab);
            app.Label_3.FontSize = 16;
            app.Label_3.Position = [147 206 25 22];
            app.Label_3.Text = '0';

            % Create CheckBox_3
            app.CheckBox_3 = uicheckbox(app.KarnaughTab);
            app.CheckBox_3.Text = '';
            app.CheckBox_3.Position = [171 206 25 22];

            % Create CheckBox_7
            app.CheckBox_7 = uicheckbox(app.KarnaughTab);
            app.CheckBox_7.Text = '';
            app.CheckBox_7.Position = [231 206 25 22];

            % Create Label_15
            app.Label_15 = uilabel(app.KarnaughTab);
            app.Label_15.FontSize = 16;
            app.Label_15.Position = [270 206 25 22];
            app.Label_15.Text = '0';

            % Create CheckBox_15
            app.CheckBox_15 = uicheckbox(app.KarnaughTab);
            app.CheckBox_15.Text = '';
            app.CheckBox_15.Position = [294 206 25 22];

            % Create Label_11
            app.Label_11 = uilabel(app.KarnaughTab);
            app.Label_11.FontSize = 16;
            app.Label_11.Position = [330 206 25 22];
            app.Label_11.Text = '0';

            % Create CheckBox_11
            app.CheckBox_11 = uicheckbox(app.KarnaughTab);
            app.CheckBox_11.Text = '';
            app.CheckBox_11.Position = [354 206 25 22];

            % Create ABLabel
            app.ABLabel = uilabel(app.KarnaughTab);
            app.ABLabel.HorizontalAlignment = 'center';
            app.ABLabel.FontSize = 16;
            app.ABLabel.FontWeight = 'bold';
            app.ABLabel.Position = [160 391 208 22];
            app.ABLabel.Text = 'AB';

            % Create Label_R1
            app.Label_R1 = uilabel(app.KarnaughTab);
            app.Label_R1.FontSize = 16;
            app.Label_R1.FontWeight = 'bold';
            app.Label_R1.Position = [97 321 25 22];
            app.Label_R1.Text = '00';

            % Create Label_R2
            app.Label_R2 = uilabel(app.KarnaughTab);
            app.Label_R2.FontSize = 16;
            app.Label_R2.FontWeight = 'bold';
            app.Label_R2.Position = [97 283 25 22];
            app.Label_R2.Text = '01';

            % Create Label_R3
            app.Label_R3 = uilabel(app.KarnaughTab);
            app.Label_R3.FontSize = 16;
            app.Label_R3.FontWeight = 'bold';
            app.Label_R3.Position = [97 246 25 22];
            app.Label_R3.Text = '11';

            % Create Label_R4
            app.Label_R4 = uilabel(app.KarnaughTab);
            app.Label_R4.FontSize = 16;
            app.Label_R4.FontWeight = 'bold';
            app.Label_R4.Position = [97 206 25 22];
            app.Label_R4.Text = '10';

            % Create CDLabel
            app.CDLabel = uilabel(app.KarnaughTab);
            app.CDLabel.HorizontalAlignment = 'center';
            app.CDLabel.FontSize = 16;
            app.CDLabel.FontWeight = 'bold';
            app.CDLabel.Position = [-18 267 140 22];
            app.CDLabel.Text = 'CD';

            % Create AddTermButton
            app.AddTermButton = uibutton(app.KarnaughTab, 'push');
            app.AddTermButton.ButtonPushedFcn = createCallbackFcn(app, @AddTermButtonPushed, true);
            app.AddTermButton.Position = [450 362 116 22];
            app.AddTermButton.Text = 'Add Term';

            % Create ClearButton
            app.ClearButton = uibutton(app.KarnaughTab, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [450 321 116 22];
            app.ClearButton.Text = 'Clear';

            % Create Label_7
            app.Label_7 = uilabel(app.KarnaughTab);
            app.Label_7.FontSize = 16;
            app.Label_7.Position = [207 206 25 22];
            app.Label_7.Text = '0';

            % Create LogicOutputLabel
            app.LogicOutputLabel = uilabel(app.KarnaughTab);
            app.LogicOutputLabel.FontSize = 16;
            app.LogicOutputLabel.FontWeight = 'bold';
            app.LogicOutputLabel.Position = [77 151 111 22];
            app.LogicOutputLabel.Text = 'Logic Output:';

            % Create Label_LogicOutput
            app.Label_LogicOutput = uilabel(app.KarnaughTab);
            app.Label_LogicOutput.Position = [195 148 400 29];
            app.Label_LogicOutput.Text = '';

            % Create Label_Error
            app.Label_Error = uilabel(app.KarnaughTab);
            app.Label_Error.Position = [78 68 301 29];
            app.Label_Error.Text = '';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = karnaugh_maps_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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