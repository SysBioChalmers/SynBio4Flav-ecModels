%% ecFSEOF predictions for naringenin production using ecModel
% initialize model
load('model/ecModel_batch.mat');

%% First section introduces heterologous pathway using only rxn stoichiometries

rxnsToAdd = struct();
rxnsToAdd.rxns = 'NAR_c';
rxnsToAdd.equations = 'tyr__L_c + 3.0 malcoa_c + atp_c => nar_c + nh4_c + amp_c + ppi_c + 3 coa_c + 3 co2_c';
model = addRxns(ecModel_batch, rxnsToAdd, 1, 'c', 1);
%% Or you can instead utilize a model with the pathway incorporated with enzymes
% model can be constructed in constructStrain.m and imported here

% make sure to run the constructStrain script before proceeding!
load('ecModel_naringenin.mat');

%% Set up model for FSEOF

% include exchange rxn to be set as objective
model = addExchangeRxn(model, 'nar_c');
rxnTarget = model.rxns(end);

% specify parameters for ecFSEOF and robust ecFSEOF
cSource = 'EX_glc__D_e_REV';
alphaLims = [0.039, 0.042];
Nsteps = 10;
file1 = 'ecFSEOF_genes_naringenin_enzymes.txt';
file2 = 'ecFSEOF_rxns_naringenin_enzymes.txt';
%% Run ecFSEOF
cd GECKO/geckomat/utilities/ecFSEOF/
results = run_ecFSEOF(model,rxnTarget,cSource,alphaLims,Nsteps,file1,file2);

%% Run robust ecFSEOF
expYield = 0.040;
CS_MW = 0.18015;

cd method
[mutantStrain,filtered,step] = robust_ecFSEOF(model2,rxnTarget,cSource,expYield,CS_MW,'output_enzymes_SALB_1.0.1_scale1000');
