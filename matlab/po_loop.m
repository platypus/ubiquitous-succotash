% Get a list of all txt files in the current folder, or subfolders of it.

fds = fileDatastore('*_po.csv', 'ReadFcn', @importdata)
fullFileNames = fds.Files
numFiles = length(fullFileNames)

% Loop over all files reading them in and plotting them.

for k = 1 : numFiles
    fprintf('Now reading file %s\n', fullFileNames{k});

    % Now have code to read in the data using whatever function you want.
    % Now put code to plot the data or process it however you want...
	
	newStr=strrep(fullFileNames{k},'csv','em');
	peet=dlmread(fullFileNames{k});
	tom_emwrite(newStr,peet);
	
end
