% Construct strain for Naringenin production
load('model/ecModel_batch.mat');
%%
% initialize model
model = ecModel_batch;

% load table with enzyme data
% choose enzyme table for either TAL/PAL or TAL only strains
% enzymeData = readtable('method/heterologous_rxns_enzymeData.txt','Delimiter','\t');
enzymeData = readtable('method/heterologous_rxns_enzymeData_TAL.txt','Delimiter','\t');

% set up struct for reactions to be added
rxnsToAdd.rxns      = enzymeData.Rxn;
rxnsToAdd.rxnNames  = enzymeData.RxnName;
rxnsToAdd.equations = enzymeData.Reaction;
rxnsToAdd.eccodes   = enzymeData.EC;
rxnsToAdd.grRules   = enzymeData.Gene;

% set up struct for metabolites
metsToAdd.mets      = strcat('prot_', enzymeData.Protein);
metsToAdd.metNames  = metsToAdd.mets;
metsToAdd.compartments = 'c';
lt = numel(enzymeData.Rxn); %length of table

% included to ensure all enzyme-related fields have same dimension
C = cell(1,lt); C(:) = {'n.a.'};
paths = cell(1,lt); paths(:) = {'Heterologous naringenin pathway'};

% modify enzyme fields with data from table
model.enzymes(end+1:end+lt)       = enzymeData.Protein;
model.enzGenes(end+1:end+lt)      = enzymeData.Gene;
model.enzNames(end+1:end+lt)      = enzymeData.Gene;
model.MWs(end+1:end+lt)           = enzymeData.MW_KDa_;
model.sequences(end+1:end+lt)     = C;
model.pathways(end+1:end+lt)      = paths;
model.concs(end+1:end+lt)         = repmat(NaN, lt, 1);

% add pathway for naringenin
model = addMets(model, metsToAdd);
model = addRxns(model, rxnsToAdd, 3, 'c', 1, 1);

% add draw reactions for heterologous enzymes
% using COBRA function for now due to convenience
for i = 1:lt
    model = addReaction(model,strcat('draw_prot_', enzymeData.Protein{i}),'metaboliteList',{'prot_pool',strcat('prot_', enzymeData.Protein{i})},'stoichCoeffList',[-enzymeData.MW_KDa_(i) 1],'reversible',false);
end

% rename met ID of naringenin for ease of reference
idx = find(contains(model.mets, 'm_NaN'));
model.mets(idx) = {'narchal_c'; 'nar_c'; 'pca_c'; 'pccoa_c'};

%% Scale protein usage reactions by 10^3 magnitude
scalingFactor = 1000;

mets = model.mets;
mets(find(contains(mets, 'prot_pool'))) = '';
idxProt = find(contains(mets, 'prot_'));

model2 = model;

for i = 1:numel(idxProt)
    idx = find(model.S(idxProt(i),:)<0);
    model2.S(idxProt(i), idx) = model.S(idxProt(i), idx) * scalingFactor;
end

idx = find(contains(model.rxns, 'prot_pool'));
model2.ub(idx) = model.ub(idx) * scalingFactor;

% convert to main model
% model = model2;

%% Save model
save('model/ecModel_naringenin.mat', 'model', 'model2', 'ecModel_batch', 'enzymeData');