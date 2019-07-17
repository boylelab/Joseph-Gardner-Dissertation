function [modeldz, modelpa, soldz, solpa] = makeTERY(model, FBAMode)
% If running simple FBA
if(nargin<2)
    FBAMode=true;
end
% Make diazotroph and photoautotroph bounds
%
% Add glycogen export for photoautotrophs
model = addReaction(model, 'EX_glycogen', {'m_glycogen[e]'}, -1);
model = addReaction(model, 'TR_glycogen', {'m_glycogen[c]','m_glycogen[e]'}, [-1 1]);

% Set general export reactions (close exogenous carbon, nitrogen sources)
model = changeRxnBounds(model, 'EX_no2', 0, 'b');
model = changeRxnBounds(model, 'TR_orthopi', 0, 'l');
model = changeRxnBounds(model, 'ASP_ASPASE', 0, 'b');
model = changeRxnBounds(model, 'GLX_SGTAMN', 0, 'l');
model = changeRxnBounds(model, 'NUC_ndk_AG', 0, 'l');
model = changeRxnBounds(model, 'VAL_avtA', 0, 'l');
model = changeRxnBounds(model, 'GLY_G3PDH', 0, 'l');
model = changeRxnBounds(model, 'EX_photon', -80, 'l');
model = changeRxnBounds(model, 'EX_proton', 0, 'b');
model = changeRxnBounds(model, 'EX_biomass', 1000, 'u');
model = changeRxnBounds(model, 'EX_biomass', 0, 'l');
model = changeObjective(model, 'EX_biomass', 1);
model = changeRxnBounds(model, 'EN_ATP',64.3, 'l');
model = changeRxnBounds(model, 'EN_ATP',1000,'u');

% Create photoautroph model
modelpa = model;
modelpa = changeRxnBounds(modelpa, 'EX_o2', 0, 'l');
modelpa = changeRxnBounds(modelpa, 'EX_o2', 1000, 'u');
modelpa = changeRxnBounds(modelpa, 'EX_co2', -100, 'b');
modelpa = changeRxnBounds(modelpa, 'EX_n2', 0, 'l');
modelpa = changeRxnBounds(modelpa, 'EX_n2', 1000, 'u');
modelpa = changeRxnBounds(modelpa, 'EX_glycogen', 0, 'b');
modelpa = changeRxnBounds(modelpa, 'EX_glycogen', 1000, 'u');
modelpa = changeRxnBounds(modelpa, 'EX_nh4', -1000, 'l');

% Create diazotroph model
modeldz = model;
modeldz = changeRxnBounds(modeldz, 'EN_ATP', 67.4, 'l');
modeldz = changeRxnBounds(modeldz, 'EX_o2', -1000, 'l');
modeldz = changeRxnBounds(modeldz, 'EX_o2', 1000, 'u');
modeldz = changeRxnBounds(modeldz, 'EX_NO3', 1000, 'u');
modeldz = changeRxnBounds(modeldz, 'EX_nh4', 1000, 'u');
modeldz = changeRxnBounds(modeldz, 'EX_co2', 0, 'l');
modeldz = changeRxnBounds(modeldz, 'EX_co2', 1000, 'u');
modeldz = changeRxnBounds(modeldz, 'Photo_II', 0, 'u');
modeldz = changeRxnBounds(modeldz, 'EX_n2', -1000, 'l');
modeldz = changeRxnBounds(modeldz, 'EX_n2', 0, 'u');

% Set specific constraints
if FBAMode
    modeldz=changeRxnBounds(modeldz,'N_chIL',0.132,'b');
    modelpa=changeRxnBounds(modelpa,'EX_co2',-0.927,'b');
    modelpa=changeRxnBounds(modelpa,'EX_biomass',0.0146,'u');
    modeldz=changeRxnBounds(modeldz,'EX_biomass',0.0146,'u');
end

soldz=optimizeCbModel(modeldz);
solpa=optimizeCbModel(modelpa);

