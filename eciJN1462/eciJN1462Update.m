% eciJN1462Update
% Script to preprocess iJN1462 GEM and ecModel generation for organism 
% Pseudomonas putida using GECKO

% Updated: 2021-02-26 Cheewin Kittikunapong

% Note: If you do not wish to download the latest version of GECKO and
% generate the model as reported, please procee to the section titled
% "Preprocess model".

%% Clone the necessary repos:
clear;

% If you would like to download GECKO for the latest updates, you can 
% remove the directory before proceeding. Otherwise, the GECKO directory 
% is kept in order to ensure compatability with the version used in the
% reported model generation.

if ~exist('GECKO', 'dir')
    git('clone https://github.com/SysBioChalmers/GECKO.git')
    cd GECKO
    git('pull')
    git('checkout fix/updateDatabases')
    cd ..
end

%% Replace files
% If GECKO was downloaded again, scripts specific to P. putida from 
% ppu_scripts will be replaced in the corresponding directories in GECKO
for fileType={'ppu_scripts' 'databases'}
fileNames = dir(fileType{1});
for i = 1:length(fileNames)
    fileName = fileNames(i).name;
    if ~ismember(fileName,{'.' '..' '.DS_Store'})
        fullName   = [fileType{1}  '/' fileName];
        GECKO_path = dir(['GECKO/**/' fileName]);
        GECKO_path = GECKO_path.folder;
        copyfile(fullName,GECKO_path)
    end
end
end

cd GECKO
delete databases/prot_abundance.txt

cd geckomat/get_enzyme_data
updateDatabases;
cd ../..

%% Preprocess model
% Load iJN1462 model:
model    = importModel('model/iJN1462.xml');

model = buildRxnEquations(model);

% fix model identifiers
model.rxns = strrep(model.rxns, '_e_', '_e');

% ensure no carbon fixation (reversible in initial model)
idx = getIndexes(model, 'EX_co2_e', 'rxns');
model.lb(idx) = 0;

% confirm model function and objective function
sol = solveLP(model); disp(-sol.f);


%% generate ecModel using enhanceGEM.m
% Expected runtime: ~30 minutes

[ecModel,ecModel_batch] = enhanceGEM(model,'COBRA', 'eciJN1462', 1.0);

%% annotate UniProt enzymes with KEGG pathways 
% This section is optional if KEGG was not specified for use in getModelParameters.m
% Drawing from KEGG automatically would have imported additional enzymes and annotated for pathways

load('GECKO/databases/ProtDatabase.mat');
idx = find(ismember(kegg(:,1), ecModel.enzymes));
ecModel.pathways = kegg(idx, 6);

fid         = fopen(['GECKO/databases/protDatabase_all.list']);
loadedData  = textscan(fid,'%s','delimiter','\t', 'HeaderLines',0); fclose(fid);
keggPathways       = loadedData{1};
keggPathways       = unique(keggPathways);
%% Save model files
cd ../..

%Move model files:
%moveModelFiles(name)
save('model/ecModel.mat','ecModel')
save('model/ecModel_batch.mat','ecModel_batch')
%Save associated versions:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function replaceFiles(fileType,path)
fileNames = dir(fileType);
for i = 1:length(fileNames)
    fileName = fileNames(i).name;
    if ~strcmp(fileName,'.') && ~strcmp(fileName,'..') && ~strcmp(fileName,'.DS_Store')
        fullName   = [fileType '/' fileName];
        GECKO_path = dir([path fileName]);
        GECKO_path = GECKO_path.folder;
        copyfile(fullName,GECKO_path)
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function moveModelFiles(name)
cd GECKO/models
fileNames = dir(name);
cd ../..
for i=1:length(fileNames)
    fileName = fileNames(i).name;
    if ~strcmp(fileName,'.') && ~strcmp(fileName,'..') && ~strcmp(fileName,'.DS_Store')
        source      = ['GECKO/models/eciML1515/' fileName];
        destination = ['model/' fileName];
        movefile (source,destination);
    end
end
end