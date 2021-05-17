% ecPutidaUpdate
% Script to preprocess Salb-GEM and ecModel generation for organism 
% Streptomyces albus J1074 using GECKO

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

for fileType={'salb_scripts' 'databases'}
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
% Load Salb-GEM model
modelSalb    = importModel('model/Salb-GEM-1.0.1.xml');

% compile biomass pseudoreactions for GECKO model generation
% Instead of separate pseudoreactions for each macromolecule, all
% components will be compiled in one objective function

idx = find(contains(modelSalb.rxns, 'PSEUDO'));
precursors = modelSalb.rxns(idx);
precursors = precursors(~contains(precursors, ['OR_']));

idx = getIndexes(modelSalb, precursors, 'rxns');
biomass = 'BIOMASS_SALB';
biomassIdx = getIndexes(modelSalb, biomass, 'rxns');

model.S = full(modelSalb.S);
sumPrecursors = sum(model.S(:, idx),2);
compiledBiomass = sum([sumPrecursors,model.S(:,biomassIdx)],2);

modelSalb.S(:,biomassIdx) = compiledBiomass;
modelSalb = removeReactions(modelSalb, precursors);

%% generate ecModel using enhanceGEM.m
% Expected runtime: ~30 minutes

[ecModel,ecModel_batch] = enhanceGEM(modelSalb,'COBRA', 'ecSalb-GEM', 1.0);

%% Save model files

cd ../..

%Move model files:
%moveModelFiles(name)
save('model/ecModel.mat','ecModel')
save('model/ecModel_batch.mat','ecModel_batch')

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