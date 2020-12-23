
dataDirectory = 'F:\Myasthenia Gravis\20171123 O26 movies MG BTX and others\selected movies\MG effect and recovery A2b\reanalysis'

overrideMovieFlag = 1;

%% Get videos
list = {};
list = recursiveMovieSearch(dataDirectory, list)

%% Set parallel processing parameters

% Figure out computer memory
[user system] = memory;
memorySystem = system.PhysicalMemory.Total;

% If we are on a system with 64GB memory
if memorySystem > 5e+10
    poolSize = 6;
% Otherwise
else
    poolSize = 2;
end

% Start parallel pool
delete(gcp('nocreate'));
poolID = parpool(poolSize);

%% Make movies
parfor i = 1:length(list)
%     try
        % Run analysis function
        OSMovie(list{i, 1}, list{i, 2}, overrideMovieFlag);
%     catch
%          fprintf('there was an error in movie' )   
%          list(i,2)
%          list(i,2)
%     end
end

% End parallel pool
delete(poolID);