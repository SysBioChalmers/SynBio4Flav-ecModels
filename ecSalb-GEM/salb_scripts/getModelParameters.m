function parameters = getModelParameters
% getModelParameters
%
%   Set model and organism specific parameters that are used by the
%   ecModel generation pipeline.
%
%   Cheewin Kittikunapong. Last edited: 2021-01-15

%Average enzyme saturation factor
parameters.sigma = 0.5;

% Define the GAM
parameters.GAM = 71.714; % use checkObjective to find ATP coefficient

%Total protein content in the cell [g protein/gDw]
parameters.Ptot    = 0.456; % As reported by Shabab 1996 for S. coeilicolor

%Minimum growth rate the model should grow at [1/h]
parameters.gR_exp = 0.7;  % Wang 2018
% link: https://onlinelibrary.wiley.com/doi/full/10.1111/gcbb.12590

%Provide your organism scientific name
parameters.org_name = 'Streptomyces albus';

%Provide your organism KEGG ID
%parameters.keggID = 'salb';

%The name of the exchange reaction that supplies the model with carbon (rxnNames)
parameters.c_source = 'D-Glucose exchange (reversible)'; 

% calculated GUR from Y(x/s) & GR from Wang 2018
%parameters.GUR = 1.64;

%Rxn Id for biomass pseudoreaction
parameters.bioRxn = 'BIOMASS_SALB';

%Rxn Id for non-growth associated maitenance pseudoreaction
parameters.NGAM = 'ATPM';

%Compartment name in which the added enzymes should be located
parameters.enzyme_comp = 'Cytoplasm';

%Rxn names for the most common experimentally measured "exchange" fluxes
%For glucose and o2 uptakes add the substring: " (reversible)" at the end
%of the corresponding rxn name. This is due to the irreversible model
%nature of ecModels. NOTE: This parameter is only used by fitGAM.m, so if
%you do not use said function you don not need to define it.
parameters.exch_names{1} = 'S. coelicolor biomass objective function - with 75.79 GAM estimate';
parameters.exch_names{2} = 'D-Glucose exchange (reversible)';
parameters.exch_names{3} = 'O2 exchange (reversible)';
parameters.exch_names{4} = 'CO2 exchange';

%Biomass components pseudoreactions (proteins, carbs and lipids lumped
%pools). NOTE: This parameter is only used by scaleBioMass.m, so if you do
%not use said function you don not need to define it. (optional)
%parameters.bio_comp{1} = 'protein';
%parameters.bio_comp{2} = 'carbohydrate';
%parameters.bio_comp{3} = 'lipid backbone';
%parameters.bio_comp{4} = 'lipid chain';

%Rxn IDs for reactions in the oxidative phosphorylation pathway (optional)
%parameters.oxPhos{1} = 'ATPS4rpp';
%parameters.oxPhos{2} = 'r_0439';
%parameters.oxPhos{3} = 'r_0438';
%parameters.oxPhos{4} = 'r_0226';
%parameters.oxPhos{5} = 't_0001';
end
