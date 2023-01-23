function importExternalData(movieData, processClass, varargin)
% importExternalData imports external results into the movie infrastructure
%
% Copies all the external data from the input structure into an output
% directory and register them as part of an external process.
%
%     importExternalData(movieData, processClass) runs the external process
%     specified by processClass on the input movie
%
%     importExternalData(movieData, processClass, paramsIn) also takes the
%     a structure with inputs for optional parameters as an input
%     The parameters should be stored as fields in the structure, with the
%     field names and possible values as described below
%
%   Possible Parameter Structure Field Names:
%       ('FieldName' -> possible values)
%
%       ('OutputDirectory' -> character string)
%       Optional. A character string specifying the directory to save the
%       external data to.
%
%       ('InputData' -> Positive integer scalar or vector)
%       Optional. A nChanx1 cell array containing the paths to the data
%       generated by the external process
%t  
% Sebastien Besson, Nov 2014
%
% Copyright (C) 2023, Danuser Lab - UTSouthwestern 
%
% This file is part of GrangerCausalityAnalysisPackage.
% 
% GrangerCausalityAnalysisPackage is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% GrangerCausalityAnalysisPackage is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with GrangerCausalityAnalysisPackage.  If not, see <http://www.gnu.org/licenses/>.
% 
% 

%% ----------- Input ----------- %%

%Check input
ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('movieData', @(x) isa(x,'MovieData'));
ip.addRequired('processClass',@ischar);
ip.addOptional('paramsIn',[], @isstruct);
ip.parse(movieData,processClass,varargin{:});
paramsIn=ip.Results.paramsIn;

%Get the indices of any previous dummy detection processes
iProc = movieData.getProcessIndex(processClass,1,0);

%If the process doesn't exist, create it
if isempty(iProc)
    processConstr = str2func(processClass);
    iProc = numel(movieData.processes_)+1;
    movieData.addProcess(processConstr(movieData,...
        movieData.outputDirectory_));
end
dummyProc = movieData.getProcess(iProc);

%Parse input, store in parameter structure
p = parseProcessParams(dummyProc,paramsIn);

%% --------------- Initialization ---------------%%

% Get channel paths and initialize process paths and output dirs
nChan = numel(movieData.channels_);

%
channelIndex = find(~cellfun(@isempty, p.InputData));
channelIndex = channelIndex(:)';

% Setup the  input directories
inFilePaths = cell(1,nChan);
for i = channelIndex
    assert(exist(p.InputData{i}, 'file') == 2 || ...
        exist(p.InputData{i}, 'dir') == 7);
    inFilePaths{1, i} = p.InputData{i};
end
dummyProc.setInFilePaths(inFilePaths);

% Setup the output directories
outFilePaths = cell(1,nChan);
if ~isdir(p.OutputDirectory), mkdir(p.OutputDirectory); end
for  i = channelIndex
    [~, name, ext] = fileparts(p.InputData{i});
    if isempty(ext)
        copyfile(p.InputData{i}, fullfile(p.OutputDirectory, name));
        outFilePaths{1,i} = fullfile(p.OutputDirectory, name);
    else
        copyfile(p.InputData{i}, p.OutputDirectory);
        outFilePaths{1,i} = fullfile(p.OutputDirectory, [name ext]);
    end
    
end
dummyProc.setOutFilePaths(outFilePaths);

disp('Finished importing external data!')
