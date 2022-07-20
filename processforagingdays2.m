function [folderlist,err,errmsg,errID]=processforagingdays2(parentfolder)
%
%Jon Rueckemann 2022

if nargin<1
    parentfolder=uigetdir;
end

%Find folders that contain txt files with "Arnov" in the title
folderlist=findfoldertoken(parentfolder,'Arnov','txt');

err=false(size(folderlist));
errmsg=cell(size(err));
errID=cell(size(err));
for n=1:numel(folderlist) 
    disp(folderlist{n});
    try        
        %Find all associated behavior files
        foraglist=dir(fullfile(folderlist{n},'*Arnov*eye*.txt'));
        feye={foraglist.name}';
        fbeh=cellfun(@(x) replace(x,'EyeLog','Log'),feye,'uni',0);
        ymazelist=dir(fullfile(folderlist{n},'*ymaze*eye*.txt'));
        yeye={ymazelist.name}';
        ybeh=cellfun(@(x) replace(x,'EyeLog','Log'),yeye,'uni',0);
        
        calilist=dir(fullfile(folderlist{n},'*cali*eye*.txt'));
        assert(~isempty(calilist),'No calibration file found.');
        [~,caliidx]=max([calilist.bytes]); %find largest calibration file
        calieye=fullfile(folderlist{n},calilist(caliidx).name);         
        calibeh=replace(calieye,'EyeLog','Log');        
        
        
        %Load nlx NEV file and align data streams
        containfolder=fileparts(folderlist{n});
        nevfiles=dir(fullfile(containfolder,'*.nev'));       
        assert(numel(nevfiles)==1,['Code cannot'...
            ' currently handle two sources of NLX events.']);        
        nevfile=fullfile(nevfiles.folder,nevfiles.name);
        offset=alignTTLfromEV(calibeh,nevfile); %in milliseconds (native unity)
        
        %Order recordings based on file name
        txtbeh=[fbeh; ybeh];
        tmp=cellfun(@(x) strtok(x,'.'),txtbeh,'uni',0);
        tmp=cellfun(@(x) split(x,'_'),tmp,'uni',0);
        tmp=cellfun(@(x) x(end-2:end),tmp,'uni',0);
        tmp=cellfun(@(x) cellfun(@(y) ['0' y],x,'uni',0),tmp,'uni',0);
        tmp=cellfun(@(x) cellfun(@(y) y(end-1:end),x,'uni',0),tmp,'uni',0);
        tmp=cell2mat(cellfun(@(x) ...
            str2double(cell2mat(reshape(x,1,[]))),tmp,'uni',0));
        [~,sidx]=sort(tmp,'ascend');
        
        txtbeh=fullfile(folderlist{n},txtbeh);
        tasktype=repmat({'Ymaze'},size(txtbeh,1),1);
        tasktype(1:numel(fbeh))={'Arnov'};
        txtbeh=txtbeh(sidx);
        tasktype=tasktype(sidx);
        
        
        %Iterate through all text file pairs
        taskrng=nan(numel(txtbeh),2);
        behdata=struct('Txtfiles',[],'Position',[],'Direction',[],...
            'Gaze',[],'Input',[],'Arduino',[],'Banana',[]);
        for m=1:numel(txtbeh)
            [behdata(m), taskrng(m,:)] = convertbehlog(txtbeh{m},offset);
        end
        [behdata.Task]=tasktype{:};
        behdata=orderfields(behdata,[8 1:7]); 
        %!!!THIS COULD BE THE CAUSE OF "Index in position 2 exceeds array bounds (must not exceed 8)."
        
        infostruct=struct('Function','processforagingdays.m',...
            'FunctionVersion','2.0','Subfunction','alignTTL.m',...
            'SubfunctionVersion','1.0','User','Jon','Date',datestr(now),...
            'FolderProcessed',containfolder,'TxtFiles',{txtbeh});
%         
        %Save data in NLX folder
        [~,curdate]=fileparts(containfolder);
%         save(fullfile(containfolder,[curdate '_ForgYmazBeh.mat']),...
%             'behdata','taskrng','infostruct');
        fname=fullfile(containfolder,[curdate '_ForgYmazBeh.mat']);
        parforsave(fname,behdata,taskrng,infostruct);
    catch ME
        err(n)=true;
        errmsg{n}=ME.message;
        errID{n}=ME.identifier;
        disp('Error Message:')
        disp(folderlist{n})
        disp(ME.message)
    end
end
end
function parforsave(fname,behdata,taskrng,infostruct) 
    save(fname,'behdata','taskrng','infostruct');
end