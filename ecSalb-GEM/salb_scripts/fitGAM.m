%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GAM = fitGAM(model)
% Returns a fitted GAM for the yeast model.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function GAM = fitGAM(model)
%Change GAM:
cd ..
parameters = getModelParameters;
cd limit_proteins

if isfield(parameters,'GAM')
    GAM = parameters.GAM;
else
    xr_pos = strcmp(model.rxns,parameters.bioRxn);
%Get biomass precursors
    prec = find(model.S(:,xr_pos));
    prec = prec(find(strcmpi(model.metNames(prec),'ATP')));
    GAM  = abs(model.S(prec,xr_pos));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
