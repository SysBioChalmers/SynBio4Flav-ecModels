function [model,pos] = changeMedia_batch(model,c_source,media,flux)
% changeMedia_batch
%
% function that modifies the ecModel and makes it suitable for batch growth
% simulations on different carbon sources. Script designed for iML1515
% metabolic network of E. coli metabolism.
%
% model:  An enzyme constrained model
% meadia: Media type ('MAA' minimal with Aminoacids,
%                          'Min' for minimal M9 media)
% flux:   (Optional) A cell array with measured uptake fluxes in mmol/gDwh
%
% model: a constrained ecModel
%
% usage: [model,pos] = changeMedia_batch(model,c_source,media,flux)
%
% Ivan Domenzain        2019-06-05

% Give the carbon source (c_source) input variable with the following
% format: c_source  = 'D-glucose exchange (reversible)'

if nargin<3
    %Minimal medium based on M9 formulation
    media = 'Min';
end
%first block any uptake
[rxnIDs,exchange] = getExchangeRxns(model);
%Exclude protein pool from exchange reactions list
protIndex = find(contains(model.rxnNames,'prot_'));
exchange  = setdiff(exchange,protIndex);
%First allow any exchange (uptakes and secretions)
model.ub(exchange) = Inf;
%Then block all uptakes
uptakes            = exchange(find(contains(rxnIDs,'_REV')));

model = buildRxnEquations(model);
idx = find(contains(model.rxnEquations(uptakes), '-->'));
model.S(:,uptakes(idx)) = -model.S(:,uptakes(idx));
model.ub(uptakes)  = 0;
pos = getComponentIndexes(model,c_source);

%Block O2 and glucose production (avoids multiple solutions):
model.ub(strcmp(model.rxnNames,'O2_exchange'))    = 0;
%model.ub(strcmp(model.rxnNames,'D-glucose exchange (reversible)')) = 0;
model.ub(strcmp(model.rxnNames,'D_Glucose_exchange')) = 0;
%Find substrate production rxn and block it:
pos_rev = strcmpi(model.rxnNames,c_source(1:strfind(c_source,' (reversible)')-1));
model.ub(pos_rev) = 0;

%The media will define which rxns to fix:
if strcmpi(media,'MAA')
    N = 21;     %Aminoacids
elseif strcmpi(media,'Min')
    N = 1;      %Only the carbon source
end
%UB parameter (manually optimized for glucose on Min+AA):
b = 0.08;
%UB parameter (manually optimized for glucose complex media):
c = 2;
%Define fluxes in case of ec model:
if nargin < 4   %Limited protein    
    if N>1
       flux    = b*ones(1,N);
       if N>21
           flux(22:25) = c;
       end
    end
    flux(1) = Inf;
end
%Fix values as UBs:
for i = 1:N
    model.ub(pos(i)) = flux(i);
end
model.ub(find(model.c)) = Inf;
%Allow uptake of essential components
model = setParam(model, 'ub', 'EX_o2_e_REV', Inf); %Inf % 'oxygen exchange';
%Ions
model = setParam(model, 'ub', 'EX_na1_e_REV', Inf); % 'sodium exchange';
model = setParam(model, 'ub', 'EX_k_e_REV', Inf); % potassium exchange';
model = setParam(model, 'ub', 'EX_zn2_e_REV', Inf); % zinc exchange';
model = setParam(model, 'ub', 'EX_cu_e_REV', Inf); % Cu+ exchange';
model = setParam(model, 'ub', 'EX_cu2_e_REV', Inf); % Cu2+ exchange';
model = setParam(model, 'ub', 'EX_ni2_e_REV', Inf); % Ni2+ exchange';
model = setParam(model, 'ub', 'EX_mn2_e_REV', Inf); % Mn2+ exchange';
model = setParam(model, 'ub', 'EX_mg2_e_REV', Inf); % Mg exchange';
model = setParam(model, 'ub', 'EX_cobalt2_e_REV', Inf); % cobalt exchange';
model = setParam(model, 'ub', 'EX_ca2_e_REV', Inf); % calcium exchange';
model = setParam(model, 'ub', 'EX_mobd_e_REV', Inf); % Molybdate exchange';
model = setParam(model, 'ub', 'EX_fe2_e_REV', Inf); % Fe2+ exchange';
model = setParam(model, 'ub', 'EX_fe3_e_REV', Inf); % Fe3+ exchange';
%Others
model = setParam(model, 'ub', 'EX_pi_e_REV', Inf); % phosphate exchange';
model = setParam(model, 'ub', 'EX_so4_e_REV', Inf); % sulphate exchange';
model = setParam(model, 'ub', 'EX_so3_e_REV', Inf); % sulphite exchange';
model = setParam(model, 'ub', 'EX_so2_e_REV', Inf); % Sulfur dioxide
model = setParam(model, 'ub', 'EX_h2o_e_REV', Inf); % Water exchange
model = setParam(model, 'ub', 'EX_h_e_REV', Inf); % H+ exchange
%Nitrogen source
model = setParam(model, 'ub', 'EX_nh4_e_REV', Inf); % ammonia exchange';
%Inorganic compounds
model = setParam(model, 'ub', 'EX_cl_e_REV', Inf); % chloride exchange';
%Vitamins
model = setParam(model, 'ub', 'EX_btn_e_REV', Inf); % Biotin exchange';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pos = getComponentIndexes(model,c_source)
    pos(1)  = find(strcmpi(model.rxnNames,c_source));
%     pos(2)  = find(strcmpi(model.rxnNames,'alanine exchange (reversible)'));
%     pos(3)  = find(strcmpi(model.rxnNames,'L-arginine exchange (reversible)'));
%     pos(4)  = find(strcmpi(model.rxnNames,'L-asparagine exchange (reversible)'));
%     pos(5)  = find(strcmpi(model.rxnNames,'L-aspartate exchange (reversible)'));
%     pos(6)  = find(strcmpi(model.rxnNames,'L-cysteine exchange (reversible)'));
%     pos(7)  = find(strcmpi(model.rxnNames,'L-glutamine exchange (reversible)'));
%     pos(8)  = find(strcmpi(model.rxnNames,'L-glutamate exchange (reversible)'));
%     pos(9)  = find(strcmpi(model.rxnNames,'glycine exchange (reversible)'));
%     pos(10) = find(strcmpi(model.rxnNames,'L-histidine exchange (reversible)'));
%     pos(11) = find(strcmpi(model.rxnNames,'L-isoleucine exchange (reversible)'));
%     pos(12) = find(strcmpi(model.rxnNames,'L-leucine exchange (reversible)'));
%     pos(13) = find(strcmpi(model.rxnNames,'L-lysine exchange (reversible)'));
%     pos(14) = find(strcmpi(model.rxnNames,'L-methionine exchange (reversible)'));
%     pos(15) = find(strcmpi(model.rxnNames,'L-phenylalanine exchange (reversible)'));
%     pos(16) = find(strcmpi(model.rxnNames,'L-proline exchange (reversible)'));
%     pos(17) = find(strcmpi(model.rxnNames,'L-serine exchange (reversible)'));
%     pos(18) = find(strcmpi(model.rxnNames,'L-threonine exchange (reversible)'));
%     pos(19) = find(strcmpi(model.rxnNames,'L-tryptophan exchange (reversible)'));
%     pos(20) = find(strcmpi(model.rxnNames,'L-tyrosine exchange (reversible)'));
%     pos(21) = find(strcmpi(model.rxnNames,'L-valine exchange (reversible)'));
%     pos(22) = find(strcmpi(model.rxnNames,'D-glucose exchange (reversible)'));
end
