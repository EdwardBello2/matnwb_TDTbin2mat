



% Read in basic stream info from TDT
pn = 'C:\DATAtemp\STNstim_GPrecord\Data Acquisition\Nebula-210726\';
TDTblock = 'AzNeuralverTwo-210726-105657';

blockpath = [pn TDTblock];


contrib.tdt.TDTbin2NWB([pn TDTblock])
% contrib.tdt.TDTbin2NWB


%% Subset of test blocks to concatenate

pn = 'C:\DATAtemp\STNstim_GPrecord\Data Acquisition\Nebula-210726\';
TDTblocks = {
    [pn 'AzNeuralverTwo-210726-105657'], ...
    [pn 'AzNeuralverTwo-210726-105928'], ...
    [pn 'AzNeuralverTwo-210726-110153']};

nwbSess = contrib.tdt.TDTbin2NWBconcat(TDTblocks);


% write and read back an NWB file
% write file
nwbfn = nwbSess.general_session_id;
nwbfullpath = [pn nwbfn '.nwb'];
disp(['Exporting ' nwbfn '...']);
nwbExport(nwbSess, nwbfullpath)
disp('DONE!')


% test read
nwbTest = nwbRead(nwbfullpath, 'ignorecache');



%% Full extent of blocks to concatenate
pn = 'C:\DATAtemp\STNstim_GPrecord\Data Acquisition\Nebula-210726\';
TDTblocks = {
    [pn 'AzNeuralverTwo-210726-105657'], ...
    [pn 'AzNeuralverTwo-210726-105928'], ...
    [pn 'AzNeuralverTwo-210726-110153'], ...
    [pn 'AzNeuralverTwo-210726-110428'], ...
    [pn 'AzNeuralverTwo-210726-110705'], ...
    [pn 'AzNeuralverTwo-210726-110934'], ...
    [pn 'AzNeuralverTwo-210726-111240'], ...
    [pn 'AzNeuralverTwo-210726-111525'], ...
    [pn 'AzNeuralverTwo-210726-111915'], ...
    [pn 'AzNeuralverTwo-210726-112157'], ...
    [pn 'AzNeuralverTwo-210726-112448'], ...
    [pn 'AzNeuralverTwo-210726-112727']};

nwbSess = contrib.tdt.TDTbin2NWBconcat(TDTblocks);


% write and read back an NWB file
% write file
nwbfn = nwbSess.general_session_id;
nwbfullpath = [pn nwbfn '.nwb'];
disp(['Exporting ' nwbfn '.nwb...']);
tic
nwbExport(nwbSess, nwbfullpath)
toc
disp('DONE!')


% test read
nwbTest = nwbRead(nwbfullpath, 'ignorecache');
