function [behdata,taskrng]=convertbehlog(txtbeh,offset)
%
%Jon Rueckemann 2022

%Convert unity behavior times to nlx time
Y=readcell(txtbeh,'Delimiter',',');
Y(1,:)=[];

if ischar(Y{1,1})
    disp('First cell is identified as a char');
    Y{1,1} = str2double(Y{1,1});
end



Y=[cellfun(@(x) x+offset,Y(:,1),'uni',0) Y];
taskrng=[Y{1,1} Y{end,1}];

xyzpos=cell2mat(Y(strcmpi(Y(:,4),'Player'),[1 2 3 6:8]));
lookpos=cell2mat(Y(strcmpi(Y(:,4),'Main Camera'),[1 2 3 6:8]));
looklabel=Y(strcmpi(Y(:,4),'LOOKAT'),[1 2 3 5 7:9]);
joystick=Y(strcmpi(Y(:,4),'input'),[1 2 3 5 6]);
arduino=Y(strcmpi(Y(:,4),'ARDUINO_WRITE_STRING'),[1 2 5]);

%Each banana has a unique identifier suffix
%Banana evt: Spawned, Alpha, and Eaten have no additional data
%Banana evt: Position, Rotation, Destroyed have positional/rotational info
%There is a position entry after the banana is spawned (used below).
w=cellfun(@ischar,Y(:,4));
bananaidx=false(size(w));
bananaidx(w)=cellfun(@(x) contains(x,'banana'),Y(w,4));
spnidx=false(size(bananaidx));
spnidx(find(strcmpi(Y(:,5),'SPAWNED'))+1)=true;
bananadata=Y(bananaidx & (spnidx|strcmpi(Y(:,5),'DESTROYED')),1:8);

behdata=struct('Txtfiles',txtbeh,'Position',xyzpos,...
    'Direction',lookpos,'Gaze',{looklabel},'Input',{joystick},...
    'Arduino',{arduino},'Banana',{bananadata});