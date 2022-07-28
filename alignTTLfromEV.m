function [offset, seshdur]=alignTTLfromEV(txtcal,nevfile)


Y=readcell(txtcal,'Delimiter',',');
arduino=Y(strcmpi(Y(:,3),'ARDUINO_WRITE_STRING'),[1 4]);

[evtts,~,TTL,~,evtstr,~]=Nlx2MatEV(nevfile,ones(1,5),1,1,[]);


C=arduino;
C(~strcmpi(C(:,2),'LIGHTON')&~strcmpi(C(:,2),'LIGHTOFF')&...
    ~strcmpi(C(:,2),'ENDTRIAL')&~strcmpi(C(:,2),'SUCCESS'),2)={nan};
C(strcmpi(C(:,2),'LIGHTON'),2)={32};
C(strcmpi(C(:,2),'LIGHTOFF'),2)={0};
C(strcmpi(C(:,2),'ENDTRIAL')|strcmpi(C(:,2),'SUCCESS'),2)={2};
C=cell2mat(C);


G = evtstr;
G(~strcmpi(G(:,1),'LIGHTON')&~strcmpi(G(:,1),'LIGHTOFF')&...
    ~contains(G(:,1),'NUMBERVAL'),1)={nan};
G(strcmpi(G(:,1),'LIGHTON'),1)={32};
G(strcmpi(G(:,1),'LIGHTOFF'),1)={0};
for ii = 1:length(G)
    if ischar(G{ii})
        if contains(G{ii}, 'NUMBERVAL')
             G(ii) = {2};
        end
    end
end
G = cell2mat(G);

D = [round(evtts(:)/1000) G(:)];
D = D(D(:,2)==32|D(:,2)==2|D(:,2)==0,:);


idxC=C(:,2)==32 & [C(2:end,2);0]==0 & [C(3:end,2);0;0]==2;
idxD=D(:,2)==32 & [D(2:end,2);0]==0 & [D(3:end,2);0;0]==2;
logTS=C(idxC,1);
nlxTS=D(idxD,1);

logsig=zeros(1,ceil(logTS(end)-logTS(1)));
logsig(logTS-logTS(1)+1)=1;
nlxsig=zeros(1,ceil(nlxTS(end)-nlxTS(1)));
nlxsig(nlxTS-nlxTS(1)+1)=1;
d=finddelay(logsig,nlxsig); %add d 1ms steps to align log to nlx signal
offset=d-logTS(1)+nlxTS(1);
seshdur = nlxTS(end) - nlxTS(1);

disp(d)
disp(offset)

figure;
plot(D(:,1),D(:,2));
hold(gca,'on');
plot(C(:,1)+offset,C(:,2));
title(txtcal,'Interpreter','None');