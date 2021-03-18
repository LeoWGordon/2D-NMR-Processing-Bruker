% GUI to plot 2D NMR experiments
% Bruker data reading functions derived from NMRFAM code found at the
% following link: <http://pine.nmrfam.wisc.edu/download_scripts.html>
% Prepared by Leo W. Gordon, lgordon@ccny.cuny.edu

% Look at lines 515-520 to change the save file location for your
% computer. Make it savelocation = "C:\My Computer\my_image_folder";

%% Version 1.2.1
% Version Changes:-
% - Changed the figure and axis size parameters to fit more closely
% - Figures are now produced as 9"x9"figures

%% Version 1.2
% Version Changes:-
% - Default is now for internal projection (sum of each dimension) with
% option to add external projections
% - Changed the input for the external projections, now just choose
% experiment folder (assumes proc. no. = 1)
% - Added more status messages in the command window
% - Fixed issue where threshold factor and number of levels values didn't
% update until the slider was moved
% - Minor aesthetic changes
% - Axis ticks now outward only (instead of both)
%%%%%%

%% Version 1.1
% Recent changes:
% -Added file browser
% -Added manual limit adjustments
% -Threshold factor is now as a percentage of maximum signal
%%%%%%

function NMR2DPlotter
% Create figure
h.f(1) = figure('units','normalized','position',[0.05,0.15,0.5,0.775],...
             'toolbar','none','menu','none');
         
% Radio Buttons for internal or external projection
bg = uibuttongroup('Visible','off','units','normalized',...
                'position',[0.05,0.675,0.7,0.2],'BorderType','none');
h.r(1) = uicontrol(bg,'Style','radiobutton','units','normalized',...
                'position',[0.05,0.825,0.3,0.1],...
                'string','Internal Projection','FontSize',14,...
                'Callback',@internalproj);            
h.r(2) = uicontrol(bg,'Style','radiobutton','units','normalized',...
                'position',[0.35,0.825,0.3,0.1],...
                'string','External Projection','FontSize',14,...
                'Callback',@externalproj);

bg.Visible = 'on';

% Panel Conatainers
h.b(1) = uipanel('Title','Limits','Units','normalized',...
                'FontSize',14,'FontWeight','bold',...
                'Position',[0.05,0.575,0.4,0.175]);

         
% Create Text Input Fields
h.c(1) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.25,0.9,0.25,0.05],'String','Input 2D Folder','FontSize',14); %2D file input
h.c(2) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.25,0.7625,0.225,0.05],'String','Input F2 Dimension','FontSize',14); %F2 file input
h.c(3) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.725,0.7625,0.225,0.05],'String','Input F1 Dimension','FontSize',14); %F1 file input
h.c(4) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.55,0.9,0.1,0.05],'String','Proc. no.','FontSize',14); %Proc. no. string
h.c(5) = uicontrol('Style','popupmenu','Units','normalized',...
                'Position',[0.55,0.875,0.1,0.05],'String',{1:5}); %Proc. no. dropdown
h.c(6) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.7,0.9,0.1,0.05],'String','F2 Nucleus','FontSize',14); %F2 nucleus string
h.c(7) = uicontrol('Style','popupmenu','Units','normalized',...
                'Position',[0.7,0.875,0.1,0.05],'String',{'<HTML><sup>1</sup>H','<HTML><sup>13</sup>C','<HTML><sup>27</sup>Al','<HTML><sup>14</sup>N'}); %F2 dropdown
h.c(8) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.85,0.9,0.1,0.05],'String','F1 Nucleus','FontSize',14); %F1 nucleus string
h.c(9) = uicontrol('Style','popupmenu','Units','normalized',...
                'Position',[0.85,0.875,0.1,0.05],'String',{'<HTML><sup>1</sup>H','<HTML><sup>13</sup>C','<HTML><sup>27</sup>Al','<HTML><sup>14</sup>N'}); %F2 dropdown
h.c(10) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.05,0.2,0.7,0.05],'String','Input Save File Name','FontSize',14); %Save name input
h.c(11) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.05,0.465,0.9,0.05],'String','','FontSize',14); %Slider edit box - threshold
h.c(12) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.05,0.35,0.9,0.05],'String','','FontSize',14); %Slider edit box - levels
h.c(13) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.05,0.515,0.9,0.05],'String','Threshold Factor','FontSize',14); %Threshold string
h.c(14) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.05,0.425,0.9,0.05],'String','Number of Levels','FontSize',14); %Levels nucleus string
h.c(15) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.3,0.03,0.65,0.16],'String','Input the numbered 2D experiment folder and choose whether you want the internal or external projection to be displayed, and also if you wish to plot a spectrum on the F1 axis. Choose the nucleus for both dimensions and input the desired limits, if no limits are set, defaults will be set based on the nucleus. If you select external projection, you must specify the folder path for the 1D experiment(s) (which should be proc. no. 1). Click "Load Data". Then move the sliders to edit the thresholds and number of contour levels in the plot, then push "Plot". If you change the sliders, you can push "Plot" again to change. Once you are happy with the plot, input a save file name and push "Save". Spectum processing (e.g. line-broadening) must be done in topspin before running the code. Code prepared by Leo Gordon, contact at lgordon@ccny.cuny.edu for questions.','FontSize',12);
h.c(16) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.527,0.465,0.2,0.05],'String','% of maximum signal','FontSize',14); % % of maximum signal string
% h.c(17) = uicontrol('Style','text','Units','normalized',...
%                 'Position',[0.05,0.7,0.1,0.035],'String','Limits','FontSize',14,'FontWeight','bold'); %Limits
h.c(18) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.175,0.65,0.1,0.035],'String','','FontSize',14); %F2 Lower limit
h.c(19) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.325,0.65,0.1,0.035],'String','','FontSize',14); %F2 Upper limit
h.c(20) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.175,0.6,0.1,0.035],'String','','FontSize',14); %F1 Lower limit
h.c(21) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.325,0.6,0.1,0.035],'String','','FontSize',14); %F1 Upper limit
h.c(22) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.175,0.7,0.1,0.035],'String','Lower','FontSize',14); %F2
h.c(23) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.325,0.7,0.1,0.035],'String','Upper','FontSize',14); %F1
h.c(24) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.075,0.65,0.05,0.035],'String','F2','FontSize',14); %Limits
h.c(25) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.075,0.6,0.05,0.035],'String','F1','FontSize',14); %Limits
% Create Sliders
% range = [10^0 10^2];
h.s(1) = uicontrol('Style','slider','Units','normalized',...
               'Position',[0.05,0.49,0.9,0.05],'Min',0.001,'Value',0.1,'SliderStep',[0.01001 0.1]);
h.s(2) = uicontrol('Style','slider','Units','normalized',...
               'Position',[0.05,0.375,0.9,0.05],'Min',0.04,'Value',0.32,'SliderStep',[0.04 0.1]);
% Live update of threshold text box
           fun1 = @(~,e)set(h.c(11),'String',num2str(100*get(e.AffectedObject,'Value')));
           addlistener(h.s(1), 'Value', 'PostSet',fun1);
           
           fun2 = @(~,e)set(h.c(12),'String',num2str(ceil(25*get(e.AffectedObject,'Value'))));
           addlistener(h.s(2), 'Value', 'PostSet',fun2);
           
           set(h.c(11),'String',num2str(100*h.s(1).Value))
           set(h.c(12),'String',num2str(ceil(25*h.s(2).Value)))

% Checkbox for F1 (automatically selected)
h.c(26) = uicontrol('Style','checkbox','Units','normalized',...
                'Position',[0.65,0.825,0.225,0.05],'Value',1,...
                'String','Show F1 Projection','FontSize',14,'Callback',@F1visible);
            
            
    function F1visible(varargin)
        F1vis = h.c(26).Value;
        
        if F1vis == 0
            set(h.c(3),'Visible','off')
            set(h.p(6),'Visible','off')
            % also turn off plotting for that axis
        elseif F1vis == 1 && h.r(2).Value
            set(h.c(3),'Visible','on')
            set(h.p(6),'Visible','on')
        end
    end
           
% Create Pushbuttons
h.p(1) = uicontrol('style','pushbutton','units','normalized',...
                'position',[0.5,0.6,0.45,0.1],'string','Load Data','FontSize',14,...
                'callback',@p_load);
h.p(2) = uicontrol('style','pushbutton','units','normalized',...
                'position',[0.05,0.265,0.9,0.1],'string','Plot','FontSize',14,...
                'callback',@p_plot);
h.p(3) = uicontrol('style','pushbutton','units','normalized',...
                'position',[0.8,0.2,0.15,0.05],'string','Save','FontSize',14,...
                'callback',@p_save);
h.p(4) = uicontrol('style','pushbutton','units','normalized',...
                'position',[0.05,0.9,0.2,0.05],'string','Browse Data','FontSize',14,...
                'callback',@p_browsefolder);
h.p(5) = uicontrol('style','pushbutton','units','normalized',...
                'position',[0.05,0.7625,0.2,0.05],'string','Browse Data','FontSize',14,...
                'callback',@p_browse_f2);
h.p(6) = uicontrol('style','pushbutton','units','normalized',...
                'position',[0.525,0.7625,0.2,0.05],'string','Browse Data','FontSize',14,...
                'callback',@p_browse_f1);
            
            
    try
        % Load in a background image and display it using the correct colors
        % The image used below, is in the Image Processing Toolbox.  If you do not have %access to this toolbox, you can use another image file instead.
        I=imread('./Messinger_Logo_Design.png');
        % This creates the 'background' axes
        ha = axes('units','normalized', ...
                    'position',[0.05 0.03 0.2 0.16]);
        % Move the background axes to the bottom
        uistack(ha,'bottom');

        hi = imagesc(I);
        % Turn the handlevisibility off so that we don't inadvertently plot into the axes again
        % Also, make the axes invisible
        set(ha,'handlevisibility','off', ...
                    'visible','off')  
    catch
    end
       
    
        if h.r(1).Value == 1
            set(h.c(2),'Visible','off')
            set(h.c(3),'Visible','off')
            set(h.p(5),'Visible','off')
            set(h.p(6),'Visible','off')
        end
    % Radio button callbacks
    function internalproj(varargin)
        internal_on = h.r(1).Value;
        if internal_on == 1
            set(h.c(2),'Visible','off')
            set(h.c(3),'Visible','off')
            set(h.p(5),'Visible','off')
            set(h.p(6),'Visible','off')
        end
    end

    function externalproj(varargin)
        external_on = h.r(2).Value;
        if external_on == 1
            set(h.c(2),'Visible','on')
            set(h.c(3),'Visible','on')
            set(h.p(5),'Visible','on')
            set(h.p(6),'Visible','on')
        end
    end

    % Pushbutton callbacks
    function p_browsefolder(varargin)
       
        filefolder = uigetdir('~/','Choose the folder of the 2D experiment');
        if filefolder == 0
            set(h.c(1),'String','Input 2D Folder')
        else
            set(h.c(1),'String',filefolder)
        end
        
    end

    function p_browse_f2(varargin)
        
        f2name = uigetdir('~/','Choose the folder of the F2 dimension');
        if f2name == 0
            set(h.c(2),'String','Input 1D Folder')
        else
            set(h.c(2),'String',f2name)
        end

    end

    function p_browse_f1(varargin)

        f1name = uigetdir('~/','Choose the folder of the F2 dimension');
        if f1name == 0
            set(h.c(3),'String','Input 1D Folder')
        else
            set(h.c(3),'String',f1name)
        end

    end
    function p_load(varargin)

        % get values
            fileinput = h.c(1).String;
            proc_no = get(h.c(5), 'Value');
            f2 = h.c(2).String;
            f1 = h.c(3).String;
            int_logic = h.r(1).Value;
            showF1 = h.c(26).Value;
            
            try
            if fileinput ~= "Input 2D Folder"
                [Spectrum,~,xppm,yppm] = brukimp2d(fileinput, proc_no);
                else
                disp('Please input folder')
            end
            catch
                disp('Error in reading file, please fix 2D folder input.')
                h.c(1).String = 'Input 2D folder';
                return
            end
            
            if int_logic == 1 % proceed with internal proj
                x2 = xppm;
                y2 = sum(Spectrum,1);
                disp('Loaded internal projection in the F2 dimension')            
                if showF1 == 1
                    x1 = yppm;
                    y1 = sum(Spectrum,2);

                    DATA.x1 = x1;
                    DATA.y1 = y1;
                    disp('Loaded internal projection in the F1 dimension')
                end
                
            else
            
                if f2 ~= "Input F2 Dimension"
                    [x2, y2, ~] = brukimp1d(f2,1);
                    disp('Loaded external projection in the F2 dimension')
                else
                    disp('Please input filepath for the F2 dimension')
                end

                try
                    [x1, y1, ~] = brukimp1d(f1,1);
                    DATA.x1 = x1;
                    DATA.y1 = y1;
                    disp('Loaded external projection in the F1 dimension')
                catch
                    ErrorMessage='No 1D spectrum input for F1 dimension, continuing without.';
                    disp(ErrorMessage);
                end
            end

            DATA.spec = Spectrum;
            DATA.xppm = xppm;
            DATA.yppm = yppm;

            DATA.x2 = x2;
            DATA.y2 = y2;
            guidata(gcf,DATA);
            %%%%%%%%%%%%%%%% Called Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%
            function [Spectrum, Params,xppm,yppm] = brukimp2d(fileinput, proc_no)

                input_file = strcat(fileinput,'/pdata/',string(proc_no),'/2rr');
                Acqus_2D_H_File_Path = string([fileinput '/acqus']);
                Procs_2D_H_File_Path = strcat(fileinput, '/pdata/', string(proc_no), '/procs');
                Acqus_2D_C_File_Path = string([fileinput '/acqu2s']);
                Procs_2D_C_File_Path = strcat(fileinput, '/pdata/', string(proc_no), '/proc2s');

                fid = fopen(input_file, 'rb');
                if fid < 1
                    error('File not found %s\n', input_file);
                else
                    Spectrum_2D = fread(fid, 'int');
                end
                fclose(fid);

                fid_aqus = fopen(Acqus_2D_H_File_Path, 'r');
                fid_procs = fopen(Procs_2D_H_File_Path, 'r');
                if fid_aqus < 1 || fid_procs < 1
                    fclose(fid_aqus);
                    fclose(fid_procs);
                    error('Could not open %s or %s\n', Acqus_2D_H_File_Path, Procs_2D_H_File_Path);
                else
                    [H_OBS, H_CAR, H_Error_aqus] = Get_Bruker_Info_1D_Acqus(fid_aqus);
                    [H_SF, H_SW, H_Length, H_Error_proc] = Get_Bruker_Info_1D_Procs(fid_procs);
                    if ~isempty(H_Error_aqus) || ~isempty(H_Error_proc)
                        fclose(fid_aqus);
                        fclose(fid_procs);
                        error('Something went wrong with the params in %s or %s\n', Acqus_2D_H_File_Path, Procs_2D_H_File_Path);
                    end
                end
                fclose(fid_aqus);
                fclose(fid_procs);

                Params.xOBS = H_OBS;
                Params.xCAR = H_CAR;
                Params.xSW = H_SW;
                Params.xSF = H_SF;

                fid_acqus = fopen(Acqus_2D_C_File_Path, 'r');
                fid_procs = fopen(Procs_2D_C_File_Path, 'r');
                if fid_acqus < 1 || fid_procs < 1
                    fclose(fid_acqus);
                    fclose(fid_procs);
                    error('Could not open  %s or %s \n', Acqus_2D_C_File_Path, Procs_2D_C_File_Path);
                else
                    [C_OBS, C_CAR, C_Error_aqus] = Get_Bruker_Info_1D_Acqus(fid_acqus);
                    [C_SF, C_SW, C_Length, C_Error_proc] = Get_Bruker_Info_1D_Procs(fid_procs);
                    if ~isempty(C_Error_aqus) || ~isempty(C_Error_proc)
                        fclose(fid_acqus);
                        fclose(fid_procs);
                        error('Something went wrong with the params in %s or %s\n', Acqus_2D_C_File_Path, Procs_2D_C_File_Path);
                    end
                end
                fclose(fid_acqus);
                fclose(fid_procs);


                Params.yOBS = C_OBS;
                Params.yCAR = C_CAR;
                Params.ySW = C_SW;
                Params.ySF = C_SF;

                Spectrum = reshape(Spectrum_2D, H_Length, C_Length);
                Spectrum = Spectrum';

                xaxcen=Params.xCAR*Params.xOBS-((Params.xSF-Params.xOBS)*1000000); % why don't I just read in SFO1? not same?
                xaxmin=xaxcen-Params.xSW/2;
                xaxmax=xaxcen+Params.xSW/2;
                xaxlen=(xaxmax-xaxmin)/(length(Spectrum)-1);
                xaxhz=(xaxmin:xaxlen:xaxmax);
                xppm=xaxhz/Params.xOBS;
                xppm=sort(xppm,'descend');

                yaxcen=Params.yCAR*Params.yOBS-((Params.ySF-Params.yOBS)*1000000); % why don't I just read in SFO1?
                yaxmin=yaxcen-Params.ySW/2;
                yaxmax=yaxcen+Params.ySW/2;
                yaxlen=(yaxmax-yaxmin)/(size(Spectrum,1)-1);
                yaxhz=(yaxmin:yaxlen:yaxmax);
                yppm=yaxhz/Params.yOBS;
                yppm=sort(yppm,'descend');


                function [SF, SW, Length, Error] = Get_Bruker_Info_1D_Procs(fid)

                    SW = 0;
                    Length = 0;
                    SF = 0;

                    tline = fgetl(fid);
                    Satisfied = false;
                    while ~Satisfied
                            if ~isempty(strfind(tline, '##$SW_p= '))
                                tline = strrep(tline, '##$SW_p= ', '');
                                SW = str2double(tline);
                            end
                            if ~isempty(strfind(tline, '##$SI= '))
                                tline = strrep(tline, '##$SI= ', '');        
                                Length = str2double(tline);
                            end
                            if ~isempty(strfind(tline, '##$SF= '))
                                tline = strrep(tline, '##$SF= ', '');
                                SF = str2double(tline);
                            end
                        tline = fgetl(fid);
                            if ~ischar(tline) || (SW~=0 && Length~= 0 && SF~=0)
                                Satisfied = true;
                            end
                    end
                    

                        if (SW~=0 && Length ~= 0)
                            Error = '';
                        else
                            Error = 'Could not find all the parameters from the aqcus file';
                        end
                end


                function [OBS, CAR, Error] = Get_Bruker_Info_1D_Acqus(fid)

                    OBS = nan;
                    CAR = nan;
                    O1 = nan;

                    tline = fgetl(fid);
                    Satisfied = false;
                    while ~Satisfied
                        if ~isempty(strfind(tline, '##$O1= '))
                            tline = strrep(tline, '##$O1= ', '');
                            O1 = str2double(tline);
                        end
                        if ~isempty(strfind(tline, '##$BF1= '))
                            tline = strrep(tline, '##$BF1= ', '');
                            OBS = str2double(tline);
                        end
                        tline = fgetl(fid);
                        if ~isnan(OBS) && ~isnan(O1)
                            Satisfied = true;
                        end
                    end

                    if (OBS~=0 && O1~=0)
                        CAR = O1/OBS;
                        Error = '';
                    elseif O1==0
                        CAR = 1e-30;
                        Error = '';
                    else
                        Error = 'Could not find all the parameters from the aqcus file';
                    end
                end
            end 
            

    end

    function p_plot(varargin)
            
        factor = h.s(1).Value;
        DATA = guidata(gcf);
        Spectrum = DATA.spec;
        xc = DATA.xppm;
        yc = DATA.yppm;  
        
        x2 = DATA.x2;
        y2 = DATA.y2;

        logicalll = Spectrum>0; % Positive values only
        thres = logicalll.*Spectrum;
        
        thresmax = max(thres(:));      
        thresmin = factor*thresmax;
        clevels = ceil(25*h.s(2).Value);
        thresvec=nan(1,clevels);
        for i=1:clevels
            thresvec(i)=thresmin*((thresmax/thresmin)^(1/clevels))^i;
        end
        
        f2l = h.c(18).String;
        f2u = h.c(19).String;
        f1l = h.c(20).String;
        f1u = h.c(21).String;
        
        if (~isempty(f2u) && ~isempty(f2l))
            F2upper = str2double(f2u);
            F2lower = str2double(f2l);
        else
            disp('Incomplete F2 axis limits, using defaults')
        end
        
        if (~isempty(f1u) && ~isempty(f1l))
            F1upper = str2double(f1u);
            F1lower = str2double(f1l);
        else
            disp('Incomplete F1 axis limits, using defaults')
        end
        
        F2_nuc_num = get(h.c(7), 'Value');
        if F2_nuc_num == 1
%                 F2_nuc = 1H;
            try
                F2ax = [F2lower F2upper];
            catch
                F2ax = [-2 20];
            end
            F2ticks = [-100:2:300];
            xstr = '^{1}H Chemical Shift (ppm)';
        elseif F2_nuc_num == 2
%                 F2_nuc = 13C;
            try
                F2ax = [F2lower F2upper];
            catch
            F2ax = [0 200];
            end
            F2ticks = [-100:20:300];
            xstr = '^{13}C Chemical Shift (ppm)';
        elseif F2_nuc_num == 3
%                 F2_nuc = 27Al;
            try
                F2ax = [F2lower F2upper];
            catch
            F2ax = [-60 120];
            end
            F2ticks = [-100:20:300];
            xstr = '^{27}Al Shift (ppm)';
        elseif F2_nuc_num == 4
%                 F2_nuc = 14N;
            try
                F2ax = [F2lower F2upper];
            catch
            F2ax = [-80 80];
            end
            F2ticks = [-100:20:300];
            xstr = '^{14}N Shift (ppm)';
        end

        F1_nuc_num = get(h.c(9), 'Value');
        if F1_nuc_num == 1
%                 F1_nuc = 1H;
            try
                F1ax = [F1lower F1upper];
            catch
            F1ax = [-2 20];
            end
            F1ticks = [-100:2:300];
            ystr = '^{1}H Chemical Shift (ppm)';
        elseif F1_nuc_num == 2
%                 F1_nuc = 13C;
            try
                F1ax = [F1lower F1upper];
            catch
            F1ax = [0 200];
            end
            F1ticks = [-100:20:300];
            ystr = '^{13}C Chemical Shift (ppm)';
        elseif F1_nuc_num == 3
%                 F1_nuc = 27Al;
            try
                F1ax = [F1lower F1upper];
            catch
            F1ax = [-60 120];
            end
            F1ticks = [-100:20:300];
            ystr = '^{27}Al Shift (ppm)';
        elseif F1_nuc_num == 4
%                 F2_nuc = 14N;
            try
                F1ax = [F1lower F1upper];
            catch
            F1ax = [-80 80];
            end
            F1ticks = [-100:20:300];
            ystr = '^{14}N Shift (ppm)';
        end

        h.f(2) = figure('Units','inches','Position',[0 0 10 10]);
        contour(xc,yc,thres,thresvec(:),'.-k','LineWidth',1.5);
        axis([F2ax F1ax])
        axc=gca;
        axc.Units = 'inches';
        axc.Position = [2.5 1.5 6 6];
        axc.XDir='reverse';
        axc.YDir='reverse';
        axc.YAxisLocation='right';
        xlabel(xstr)
        ylabel(ystr)
        axc.FontWeight = 'bold';
        axc.LineWidth = 2;
        axc.FontSize = 18;
        axc.XAxis.TickDirection='out';
        axc.YAxis.TickDirection='out';
        xticks(F2ticks)
        yticks(F1ticks)
        axc.XMinorTick = 'on';
        axc.YMinorTick = 'on';

        conpos=get(axc,'Position');
        axc.Position=conpos;

        % [left bottom width height]
        % x -> [leftsame bottom+height widthsame height=0.2]
        % y -> [left-width bottomsame width=0.2 heightsame]

        conposx = [2.5 7.55 6 2];
        conposy = [0.45 1.5 2 6];

        try
            x1 = DATA.x1;
            y1 = DATA.y1;
            axy=axes('Units','inches','Position',conposy);
            plot(axy,y1,x1,'-k','LineWidth',3);
            axy.XDir='reverse';
            axy.YDir='reverse';
            axy.YLim=F1ax;
            axy.Box='off';
            axy.XAxis.Visible='off';
            axy.YAxis.Visible='off';
        catch
            disp('No F1 data to plot')
        end

        axx=axes('Units','inches','Position',conposx);
        plot(axx,x2,y2,'-k','LineWidth',3);
        axx.XDir='reverse';
        axx.XLim=F2ax;
        axx.Box='off';
        axx.XAxis.Visible='off';
        axx.YAxis.Visible='off';

    end

    function p_save(varargin)
        savenmrfig(h.c(10).String)
                function savenmrfig(name)
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Here you can make the savelocation variable to suit 
                    % your computer. Change to:
                    % savelocation = "xxx";
                    savelocation = "~";
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    filenamepdf=strcat(string(name), '.pdf');

                    orient(h.f(2),'landscape')
                    h.f(2).PaperSize = [9,9];
                    h.f(2).Renderer='painters'; % ensures the figure is actually saved as a vector graphic
                    print(h.f(2),filenamepdf,'-dpdf','-fillpage')
                    movefile(filenamepdf,savelocation)
                    disp(strcat(["Figure saved to path: "], savelocation))
                end
    end

%%%%%%
    function [xppm, Spectrum, Params] = brukimp1d(fileinput, proc_no)

        input_file = strcat(fileinput,'/pdata/',string(proc_no),'/1r');
        Acqus_1D_H_File_Path = string([fileinput '/acqus']);
        Procs_1D_H_File_Path = strcat(fileinput, '/pdata/', string(proc_no), '/procs');

        fid = fopen(input_file, 'rb');
        if fid < 1
            error('File not found %s\n', input_file);
        else
            Spectrum_1D = fread(fid, 'int');
        end
        fclose(fid);

        fid_aqus = fopen(Acqus_1D_H_File_Path, 'r');
        fid_procs = fopen(Procs_1D_H_File_Path, 'r');
        if fid_aqus < 1 || fid_procs < 1
            fclose(fid_aqus);
            fclose(fid_procs);
            error('Could not open %s or %s\n', Acqus_1D_H_File_Path, Procs_1D_H_File_Path);
        else
            [H_OBS, H_CAR, H_Error_aqus] = Get_Bruker_Info_1D_Acqus(fid_aqus);
            [H_SF, H_SW, H_Length, H_Error_proc] = Get_Bruker_Info_1D_Procs(fid_procs);
            if ~isempty(H_Error_aqus) || ~isempty(H_Error_proc)
                fclose(fid_aqus);
                fclose(fid_procs);
                error('Something went wrong with the params in %s or %s\n', Acqus_1D_H_File_Path, Procs_1D_H_File_Path);
            end
        end
        fclose(fid_aqus);
        fclose(fid_procs);

        Params.xOBS = H_OBS;
        Params.xCAR = H_CAR;
        Params.xSW = H_SW;
        Params.xSF = H_SF;

        Spectrum = Spectrum_1D;
        Spectrum = Spectrum-min(Spectrum);
        Spectrum = Spectrum./max(Spectrum);

        xaxcen=Params.xCAR*Params.xOBS-((Params.xSF-Params.xOBS)*1000000); % why don't I just read in SFO1? not same?
        xaxmin=xaxcen-Params.xSW/2;
        xaxmax=xaxcen+Params.xSW/2;
        xaxlen=(xaxmax-xaxmin)/(H_Length-1);
        xaxhz=(xaxmin:xaxlen:xaxmax);
        xppm=xaxhz/Params.xOBS;
        xppm=sort(xppm,'descend');
        
%%%%%%

%%%%%%
        function [SF, SW, Length, Error] = Get_Bruker_Info_1D_Procs(fid)

            SW = 0;
            Length = 0;
            SF = 0;

            tline = fgetl(fid);
            Satisfied = false;
            while ~Satisfied
                    if ~isempty(strfind(tline, '##$SW_p= '))
                        tline = strrep(tline, '##$SW_p= ', '');
                        SW = str2double(tline);
                    end
                    if ~isempty(strfind(tline, '##$SI= '))
                        tline = strrep(tline, '##$SI= ', '');        
                        Length = str2double(tline);
                    end
                    if ~isempty(strfind(tline, '##$SF= '))
                        tline = strrep(tline, '##$SF= ', '');
                        SF = str2double(tline);
                    end
                tline = fgetl(fid);
                    if ~ischar(tline) || (SW~=0 && Length~= 0 && SF~=0)
                        Satisfied = true;
                    end
            end


                if (SW~=0 && Length ~= 0)
                    Error = '';
                else
                    Error = 'Could not find all the parameters from the aqcus file';
                end
        end
%%%%%%

%%%%%%
        function [OBS, CAR, Error] = Get_Bruker_Info_1D_Acqus(fid)

            OBS = nan;
            CAR = nan;
            O1 = nan;

            tline = fgetl(fid);
            Satisfied = false;
            while ~Satisfied
                if ~isempty(strfind(tline, '##$O1= '))
                    tline = strrep(tline, '##$O1= ', '');
                    O1 = str2double(tline);
                end
                if ~isempty(strfind(tline, '##$BF1= '))
                    tline = strrep(tline, '##$BF1= ', '');
                    OBS = str2double(tline);
                end
                tline = fgetl(fid);
                if ~isnan(OBS) && ~isnan(O1)
                    Satisfied = true;
                end
            end

            if (OBS~=0 && O1~=0)
                CAR = O1/OBS;
                Error = '';
            elseif O1==0
                CAR = 1e-30;
                Error = '';
            else
                Error = 'Could not find all the parameters from the aqcus file';
            end
        end
    end
%%%%%%

%%% Function End %%%
end