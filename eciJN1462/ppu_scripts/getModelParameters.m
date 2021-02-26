function parameters = getModelParameters
% getModelParameters
%
%   Set model and organism specific parameters that are used by the
%   ecModel generation pipeline.
%
%   Cheewin Kittikunapong. Last edited: 2021-01-15
%

%Average enzyme saturation factor
parameters.sigma = 0.5;

% Define the GAM
parameters.GAM = 46.919; % use checkObjective to find ATP coefficient

%Total protein content in the cell [g protein/gDw]
parameters.Ptot = 0.5793;      %Assumed constant

%Minimum growth rate the model should grow at [1/h]
parameters.gR_exp = 0.61;  % Wang 2018
% link: https://onlinelibrary.wiley.com/doi/full/10.1111/gcbb.12590

%Provide your organism scientific name
parameters.org_name = 'Pseudomonas putida';

%Provide your organism KEGG ID
%parameters.keggID = 'ppu';

%The name of the exchange reaction that supplies the model with carbon (rxnNames)
parameters.c_source = 'D_Glucose_exchange (reversible)'; 

% calculated GUR from Y(x/s) & GR from Wang 2018
%parameters.GUR = 1.64;

%Rxn Id for biomass pseudoreaction
parameters.bioRxn = 'BiomassKT2440_WT3';

%Rxn Id for non-growth associated maitenance pseudoreaction
parameters.NGAM = 'ATPM';

%Compartment name in which the added enzymes should be located
parameters.enzyme_comp = 'Cytosol';

%Rxn names for the most common experimentally measured "exchange" fluxes
%For glucose and o2 uptakes add the substring: " (reversible)" at the end
%of the corresponding rxn name. This is due to the irreversible model
%nature of ecModels. NOTE: This parameter is only used by fitGAM.m, so if
%you do not use said function you don not need to define it.
parameters.exch_names{1} = 'Biomass_P_putida_KT2440__aa_DNA_RNA_ATP_murein_FA_ions_soluble_';
parameters.exch_names{2} = 'D_Glucose_exchange (reversible)';
parameters.exch_names{3} = 'O2_exchange (reversible)';
parameters.exch_names{4} = 'CO2_exchange';

end
