% Look at lines 404 - 409 to change the save file location for your
% computer. Make it savelocation = "C:\My Computer\my_image_folder";

function NMR2DPlotter
% Create figure
h.f(1) = figure('units','normalized','position',[0.05,0.15,0.5,0.775],...
             'toolbar','none','menu','none');
% Create Text Input Fields
h.c(1) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.05,0.9,0.7,0.05],'String','Input 2D Folder','FontSize',14); %2D file input
h.c(2) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.05,0.825,0.7,0.05],'String','Input F2 Dimension','FontSize',14); %F2 file input
h.c(3) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.05,0.75,0.7,0.05],'String','Input F1 Dimension','FontSize',14); %F1 file input
h.c(4) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.8,0.9,0.15,0.05],'String','Proc. no.','FontSize',14); %Proc. no. string
h.c(5) = uicontrol('Style','popupmenu','Units','normalized',...
                'Position',[0.8,0.875,0.15,0.05],'String',{1:5}); %Proc. no. dropdown
h.c(6) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.8,0.825,0.15,0.05],'String','F2 Nucleus','FontSize',14); %F2 nucleus string
h.c(7) = uicontrol('Style','popupmenu','Units','normalized',...
                'Position',[0.8,0.8,0.15,0.05],'String',{'<HTML><sup>1</sup>H','<HTML><sup>13</sup>C','<HTML><sup>27</sup>Al','<HTML><sup>14</sup>N'}); %F2 dropdown
h.c(8) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.8,0.75,0.15,0.05],'String','F1 Nucleus','FontSize',14); %F1 nucleus string
h.c(9) = uicontrol('Style','popupmenu','Units','normalized',...
                'Position',[0.8,0.725,0.15,0.05],'String',{'<HTML><sup>1</sup>H','<HTML><sup>13</sup>C','<HTML><sup>27</sup>Al','<HTML><sup>14</sup>N'}); %F2 dropdown
h.c(10) = uicontrol('Style','edit','Units','normalized',...
                'Position',[0.05,0.2,0.7,0.05],'String','Input Save File Name','FontSize',14); %Save name input
h.c(11) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.05,0.5,0.9,0.05],'String','','FontSize',14); %Slider edit box - threshold
h.c(12) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.05,0.375,0.9,0.05],'String','','FontSize',14); %Slider edit box - levels
h.c(13) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.05,0.55,0.9,0.05],'String','Threshold Factor','FontSize',14); %Threshold string
h.c(14) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.05,0.45,0.9,0.05],'String','Number of Levels','FontSize',14); %Levels nucleus string
h.c(15) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.3,0.03,0.65,0.16],'String','First input the file path for the 2D folder, and for the text files for the 1D axes generated in topspin using "convbin2asc" and push the "Load Data" button. Then move the sliders to edit the thresholds and number of contour levels in the plot, then push "Plot". If you change the sliders, you can push "Plot" again to change. Once you are happy with the plot, input a save file name and push "Save". Spectum processing (e.g. line-broadening) must be done in topspin before running the code. Code prepared by Leo Gordon, contact at lgordon@ccny.cuny.edu for questions.','FontSize',14);
h.c(16) = uicontrol('Style','text','Units','normalized',...
                'Position',[0.527,0.5,0.2,0.05],'String','% of maximum signal','FontSize',14); % % of maximum signal string
% Create Sliders
% range = [10^0 10^2];
h.s(1) = uicontrol('Style','slider','Units','normalized',...
               'Position',[0.05,0.525,0.9,0.05],'Min',0.01,'Value',0.1,'SliderStep',[0.010101 0.1]);
h.s(2) = uicontrol('Style','slider','Units','normalized',...
               'Position',[0.05,0.4,0.9,0.05],'Min',0.04,'Value',0.32,'SliderStep',[0.04 0.1]);
% Live update of threshold text box
           fun1 = @(~,e)set(h.c(11),'String',num2str(100*get(e.AffectedObject,'Value')));
           addlistener(h.s(1), 'Value', 'PostSet',fun1);
           
           fun2 = @(~,e)set(h.c(12),'String',num2str(ceil(25*get(e.AffectedObject,'Value'))));
           addlistener(h.s(2), 'Value', 'PostSet',fun2);

% Create Pushbuttons
h.p(1) = uicontrol('style','pushbutton','units','normalized',...
                'position',[0.05,0.625,0.9,0.1],'string','Load Data','FontSize',14,...
                'callback',@p_load);
h.p(2) = uicontrol('style','pushbutton','units','normalized',...
                'position',[0.05,0.275,0.9,0.1],'string','Plot','FontSize',14,...
                'callback',@p_plot);
h.p(3) = uicontrol('style','pushbutton','units','normalized',...
                'position',[0.8,0.2,0.15,0.05],'string','Save','FontSize',14,...
                'callback',@p_save);
       
    try
        % Load in a background image and display it using the correct colors
        % The image used below, is in the Image Processing Toolbox.  If you do not have %access to this toolbox, you can use another image file instead.
        I=imread('Messinger_Logo_Design.png');            
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
        
    % Pushbutton callbacks
    function p_load(varargin)

            fileinput = h.c(1).String;
            proc_no = get(h.c(5), 'Value');
            f2 = h.c(2).String;
            f1 = h.c(3).String;
            
            if fileinput ~= "Input 2D Folder"
                [Spectrum,~,xppm,yppm] = brukimp2d(fileinput, proc_no);
            else
                disp('Please input folder')
            end
            
            if f2 ~= "Input F2 Dimension"
                [x2, y2]=rawNMRimp(f2);
            else
                disp('Please input filepath for the F2 dimension')
            end
            
            try
                [x1, y1]=rawNMRimp(f1);
                DATA.x1 = x1;
                DATA.y1 = y1;
            catch
                ErrorMessage='No 1D spectrum input for F1 dimension, continuing without.';
                disp(ErrorMessage);
            end

            DATA.spec = Spectrum;
            DATA.xppm = xppm;
            DATA.yppm = yppm;

            DATA.x2 = x2;
            DATA.y2 = y2;
            guidata(gcf,DATA);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

                xaxcen=Params.xCAR*Params.xOBS-((Params.xSF-Params.xOBS)*1000000);
                xaxmin=xaxcen-Params.xSW/2;
                xaxmax=xaxcen+Params.xSW/2;
                xaxlen=(xaxmax-xaxmin)/(length(Spectrum)-1);
                xaxhz=(xaxmin:xaxlen:xaxmax);
                xppm=xaxhz/Params.xOBS;
                xppm=sort(xppm,'descend');

                yaxcen=Params.yCAR*Params.yOBS-((Params.ySF-Params.yOBS)*1000000);
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

        F2_nuc_num = get(h.c(7), 'Value');
        if F2_nuc_num == 1
%                 F2_nuc = 1H;
            F2ax = [-2 20];
            F2ticks = [-100:2:300];
            xstr = '^{1}H Chemical Shift (ppm)';
        elseif F2_nuc_num == 2
%                 F2_nuc = 13C;
            F2ax = [0 200];
            F2ticks = [-100:20:300];
            xstr = '^{13}C Chemical Shift (ppm)';
        elseif F2_nuc_num == 3
%                 F2_nuc = 27Al;
            F2ax = [-60 120];
            F2ticks = [-100:20:300];
            xstr = '^{27}Al Shift (ppm)';
        elseif F2_nuc_num == 4
%                 F2_nuc = 14N;
            F2ax = [-80 80];
            F2ticks = [-100:20:300];
            xstr = '^{14}N Shift (ppm)';
        end

        F1_nuc_num = get(h.c(9), 'Value');
        if F1_nuc_num == 1
%                 F1_nuc = 1H;
            F1ax = [-2 20];
            F1ticks = [-100:2:300];
            ystr = '^{1}H Chemical Shift (ppm)';
        elseif F1_nuc_num == 2
%                 F1_nuc = 13C;
            F1ax = [0 200];
            F1ticks = [-100:20:300];
            ystr = '^{13}C Chemical Shift (ppm)';
        elseif F1_nuc_num == 3
%                 F1_nuc = 27Al;
            F1ax = [-60 120];
            F1ticks = [-100:20:300];
            ystr = '^{27}Al Shift (ppm)';
        elseif F1_nuc_num == 4
%                 F2_nuc = 14N;
            F1ax = [-80 80];
            F1ticks = [-100:20:300];
            ystr = '^{14}N Shift (ppm)';
        end

        h.f(2) = figure;
        contour(xc,yc,thres,thresvec(:),'.-k','LineWidth',1.5);
        axis([F2ax F1ax])
        axis square
        axc=gca;
        axc.Position = [0.2 0.15 .6 .6];
        axc.XDir='reverse';
        axc.YDir='reverse';
        axc.YAxisLocation='right';
        xlabel(xstr)
        ylabel(ystr)
        axc.FontWeight = 'bold';
        axc.LineWidth = 2;
        axc.FontSize = 18;
        axc.XAxis.TickDirection='both';
        axc.YAxis.TickDirection='both';
        xticks(F2ticks)
        yticks(F1ticks)

        conpos=get(axc,'Position');
        axc.Position=conpos;

        % [left bottom width height]
        % x -> [leftsame bottom+height widthsame height=0.2]
        % y -> [left-width bottomsame width=0.2 heightsame]

        conposx = [0.275,0.775,0.45,0.2];
        conposy = [0.0625,0.15,0.2,0.6];

        try
            x1 = DATA.x1;
            y1 = DATA.y1;
                        axy=axes('Position',conposy);
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

                axx=axes('Position',conposx);
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
                    h.f(2).Renderer='painters'; % ensures the figure is actually saved as a vector graphic
                    print(h.f(2),filenamepdf,'-dpdf','-fillpage')
                    movefile(filenamepdf,savelocation)
                end
    end
end
