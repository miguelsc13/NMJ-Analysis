% Runs the analysis of all the movie files present in a given directory,
% using the stimulation parameters and an initial set of analysis
% parameters. Can be set to only run in new, non-processed movies
% (overrideRampFlag = 0) or in every movie found in the
% folder(overrideRampFlag = 1). After the analysis, performs runs the
% PostAnalysis function that shows the results of the initial analysis and
% asks for confirmation of the analysis, giving the option to readjust the
% intial parameters. This reanalysis can be performed in only new movies
% (overridePostAnalysisFlag = 0) or in every movie in the folder
% (overridePostAnalysisFlag = 1). After the post-analysis it compiles the
% resulst in an excel file named CompiledData.
% This script uses parallel processing so this option should be activated
% in MATLAB.


%% Load folder with movie files
dataDirectory = 'F:\Myasthenia Gravis\20171123 O26 movies MG BTX and others\selected movies\MG effect and recovery A2b\reanalysis';

%% Set Flags
overrideRampFlag = 1; %if 1,runs in previously analyzed movies
overridePostAnalysisFlag = 1; % if 1,reruns PostAnalysis in processed movies

%% Introduce stimulation parameters
numSteps = 30;
startFrequency = 0.2; % Hertz
endFrequency = 2; % Hertz

stimPar = {numSteps, startFrequency, endFrequency};

%% Initial analysis parameters
%These parameters can be adjusted during the post analysis

baselineTime = 0.1; % seconds
peakDistance = 20;
minPeakProminence = 5;
minMinProminence = 0.1;
minMinWidth = 0.1;

%These parameters can only be adjusted before the analysis
maxPeakWidth = 200;
minPeakWidth = 5;
maxMatchLength = 0.2; % time that can elapse between a pulse and a contraction to be considered triggered, in seconds

anPar = {baselineTime, peakDistance, minPeakProminence, minMinProminence,...
    minMinWidth,maxPeakWidth,minPeakWidth, maxMatchLength};
%% Get videos
list = {};
list = recursiveMovieSearch(dataDirectory, list);

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


%% Analyze movies

%Try-catch can be activated here to prevent the function to stop if a movie
%file is corrupted, instead of manually have to find the movie. The code
%will just skip the faulty movie and go on with the analysis.

parfor i = 1:length(list)
%     try 
%        Run analysis function
        OSAnalysis(list{i, 1}, list{i, 2}, stimPar, anPar, overrideRampFlag);
%     catch
%          fprintf('there was an error in movie' )   
%          list(i,2)
%          list(i,2)
%     end
end

%% Post-processing

% Get trace
for i = 1:length(list)
    OSPostAnalysis(list{i, 1}, list{i, 2}, stimPar, anPar,...
        overridePostAnalysisFlag);
 end

%compile data in one excel file

compiledDataDir = strcat(dataDirectory, '\' , 'OS_analysis_results');
nameSep = strfind(list{1,2}, '_');

numPar= length(nameSep) + 1;
compileData(compiledDataDir,numPar);

% End parallel pool
delete(poolID);