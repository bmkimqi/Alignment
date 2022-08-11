function [folderlist]=findfoldertoken(parentfolder,token,suffix)
%
%Jon Rueckemann

% Get user input on parent folder
if isempty(parentfolder)
    parentfolder=uigetdir;
end

% If empty, suffix is everything
if nargin<3 || isempty(suffix)
    suffix='*';
end

% Find directory and create a list of all files
filelist=dir(fullfile(parentfolder,'**',['*' token '*.' suffix]));
% Find unique folders
folderlist=unique({filelist.folder}');
end