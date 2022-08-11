function [offset, seshdur] = alignTTLfromEV(txtcal, nevfile)

% Jon Rueckemann

% Read unity calibration behavior file
Y = readcell(txtcal,'Delimiter',',');

% Pick lines that had 'Arduino_write_string'
% Tell NLX system something happend by using the arduino
arduino=Y(strcmpi(Y(:,3), ARDUINO_WRITE_STRING'),[1 4]);

% Read NLX NEV file
[evtts,~,TTL,~,evtstr,~]=Nlx2MatEV(nevfile,ones(1,5),1,1,[]);
% TTL is unused because we're using event strings.

% Compare LIGHTON and ENDTRIAL signals across records
% Convert arduino (txt) to C(numeric code). 
% C = unity text code
C=arduino;
% If it's anything but LIGHTON/LIGHTOFF/ENDTRIAL/SUCCESS -> turn into NaN
C(~strcmpi(C(:,2),'LIGHTON')&~strcmpi(C(:,2),'LIGHTOFF')&...
    ~strcmpi(C(:,2),'ENDTRIAL')&~strcmpi(C(:,2),'SUCCESS'),2)={nan};
% LIGHTON = 32
C(strcmpi(C(:,2),'LIGHTON'),2)={32};
% LIGHTOFF = 0
C(strcmpi(C(:,2),'LIGHTOFF'),2)={0};
% ENDTRIAL or SUCCESS = 2
C(strcmpi(C(:,2),'ENDTRIAL')|strcmpi(C(:,2),'SUCCESS'),2)={2};
% Check if first value is a string 
if ischar(C{1,1})
    C{1,1}=cellfun(@str2num,C(1,1));
end
C=cell2mat(C);

% G = grab event strings
G=evtstr;

% Convert text to numeric code
% If it's anything but LIGHTON/LIGHTOFF/ENDTRIAL/SUCCESS -> turn into NaN
G(~strcmpi(G(:,1),'LIGHTON')&~strcmpi(G(:,1),'LIGHTOFF')&...
    ~contains(G(:,1),'NUMBERVAL'),1)={nan};
% LIGHTON = 32
G(strcmpi(G(:,1),'LIGHTON'),1)={32};
% LIGHTOFF = 0
G(strcmpi(G(:,1),'LIGHTOFF'),1)={0};

% NUMBERVAL = 2
for ii=1:length(G)
    if ischar(G{ii})
        if contains(G{ii},'NUMBERVAL')
             G(ii)={2};
        end
    end
end
G=cell2mat(G);

% Grab all events from G
D=[round(evtts(:)/1000) G(:)];
D=D(D(:,2)==32|D(:,2)==2|D(:,2)==0,:);

% Find indices when LIGHTON precedes consecutive
% hiLIGHTOFF and ENDTRIAL
idxC = C(:,2)==32&[C(2:end,2);0]==0&[C(3:end,2);0;0]==2;
idxD = D(:,2)==32&[D(2:end,2);0]==0&[D(3:end,2);0;0]==2;
% Pull timestamp from unity log
logTS=C(idxC,1);
% Pull timestamp from nlx
nlxTS=D(idxD,1);

% Create 1kHz signals and align to find offset between nlx and log files
logsig=zeros(1,ceil(logTS(end)-logTS(1)));
logsig(logTS-logTS(1)+1)=1;
nlxsig=zeros(1,ceil(nlxTS(end)-nlxTS(1)));
nlxsig(nlxTS-nlxTS(1)+1)=1;
d=finddelay(logsig,nlxsig); %add d 1ms steps to align log to nlx signal
offset=d-logTS(1)+nlxTS(1); %Convert log time to nlx time
seshdur=nlxTS(end)-nlxTS(1);

disp(d)
disp(offset)

% figure;
% plot(D(:,1),D(:,2));
% hold(gca,'on');
% plot(C(:,1)+offset,C(:,2));
% title(txtcal,'Interpreter','None'); %No interpreter seems to fix the
% warnings thrown.