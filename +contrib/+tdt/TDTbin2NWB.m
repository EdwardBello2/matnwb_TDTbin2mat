function nwb = TDTbin2NWB(blockpath)
% Converts a single TDT block into a NWB object, automatically detecting
% all stores within the TDT recordings and translating them into the
% appropriate NWB-specified organization. 
%
% INPUT
% blockpath - String of full path to TDTblock
%
% OUTPUT
% nwb - matlab NWB object with all data from TDT block
%
% NOTE: Currently only "stream" type stores are translated by this function. All
% such stores are organized under the "acquisition" segment of the NWB
% object, with original store labels as detected by the Matlab SDK provided
% by TDT (TDTbin2mat.m). All data are stored as TimeSeries objects. 

if ~exist('blockpath', 'var') || isempty(blockpath)
    [blockpath] = uigetdir;
    
end

[basepath, blockname] = fileparts(blockpath);
disp(['Converting ' blockname ' to NWB...'])

nameTab = getTDTblockTable(blockpath);



%% Add all TDT stream data to nwb acquisition set

% Get date/time info from the TDT block
data = TDTbin2mat(blockpath, 'TYPE', 5);


% date = datevec([data.info.date data.info.utcStartTime]);
dt = datetime(data.info.date);
% tt = datetime(data.info.utcStartTime); 
tott_start = dt + timeofday(datetime(data.info.utcStartTime));
tott_stop  = dt + timeofday(datetime(data.info.utcStopTime));

sess_utcStart = datestr(tott_start, 'yyyy-mm-ddTHH:MM:SSZ');
sess_utcStop  = datestr(tott_stop, 'yyyy-mm-ddTHH:MM:SSZ');
sessionDur = data.info.duration;

% initialize nwb object   
nwb = NwbFile(...
    'session_start_time', sess_utcStart, ...
    'general_session_id', blockname, ...
    'identifier', contrib.tdt.util.genUUID, ...
    'session_description', 'a baseline day recording', ...
    'timestamps_reference_time', sess_utcStart);

% Add in stop-time datetime string to the nwb file in the "scratch" section
scr = types.core.ScratchData( ...
    'data', sessionDur, ...
    'notes', 'duration of TDT block datetime string');
nwb.scratch.set('session_duration', scr);

% cycle thru each stream and add it to nwb object
streamsTab = nameTab(strcmp(nameTab.typeStr, 'streams'),:);
nStreams = height(streamsTab);
for iStream = 1:nStreams
    nwb = addTDTstream2NWB(nwb, blockpath, streamsTab.name{iStream});
    
end

disp('CONVERSION COMPLETE!')



end

%% SUB-FUNCTIONS

function nwb = addTDTstream2NWB(nwb, blockpath, tdtstoreString)
% Reads a particular store from the TDT block and inserts it into the
% acquisition segment of the nwb object. Outputs an updated nwb object to
% reflect this change.

data = TDTbin2mat(blockpath, 'STORE', tdtstoreString);


% For the case of RS4 data having a stream store, but no SEV files
% accompany, then skip following step and output nwb file as is:
RS4warning = 'Expecting SEV files for RSn1 but none were found, skipping...';
if isempty(data.streams) && strcmp(lastwarn, RS4warning)
    return
    
else
    % Transfer data from TDT to NWB format

    % Store data as an ElectricalSeries object
    SeriesName = tdtstoreString;
    time_series = types.core.TimeSeries( ...
        'data', data.streams.(tdtstoreString).data', ...
        'data_resolution', -1.0, ... % default for unknown
        'data_unit', 'Volts', ...
        'starting_time', data.streams.(tdtstoreString).startTime, ... % seconds
        'starting_time_rate', data.streams.(tdtstoreString).fs);


    nwb.acquisition.set(SeriesName, time_series);

end


end

function nameTab = getTDTblockTable(blockpath)
% Creates reference table of stores in the TDT block and relevant metadata
% for each.

tdt = TDTbin2mat(blockpath, 'HEADERS', 1);


% Identify all stream stores
% Read tdt.stores info into table

fnames = fieldnames(tdt.stores);
nNames = length(fnames);

varNames = {'name', 'size', 'typeStr', 'typeNum'};
varTypes = {'string', 'int32', 'string', 'int32'};

% Create table for common metadata of headers
sz = [nNames, length(varNames)];
nameTab = table('Size', sz, 'VariableTypes', varTypes, ...
    'VariableNames', varNames);
for iName = 1:nNames
    nameTab{iName, 'name'} = {tdt.stores.(fnames{iName}).name};
%     nameTab{iName, 'code'} = tdt.stores.(fnames{iName}).code;
    nameTab{iName, 'size'} = tdt.stores.(fnames{iName}).size;
%     nameTab{iName, 'type'} = tdt.stores.(fnames{iName}).type;
    nameTab{iName, 'typeStr'} = {tdt.stores.(fnames{iName}).typeStr};
    nameTab{iName, 'typeNum'} = tdt.stores.(fnames{iName}).typeNum;

end



end