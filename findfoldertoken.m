function [folderlist]=findfoldertoken(parentfolder,token,suffix)
%
%Jon Rueckemann

if isempty(parentfolder)
    parentfolder=uigetdir;
end
if nargin<3 || isempty(suffix)
    suffix='*';
end
filelist=dir(fullfile(parentfolder,'**',['*' token '*.' suffix]));
folderlist=unique({filelist.folder}');
end