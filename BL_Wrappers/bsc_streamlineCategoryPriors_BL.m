function bsc_streamlineCategoryPriors_BL()
%[classificationOut] =bsc_streamlineCategoryPriors_BL(wbfg, fsDir,inflateITer)
%
% This function automatedly segments the wm streamlines of the brain into
% categories based on their terminations.

% Inputs:
% -wbfg: a whole brain fiber group structure
% -fsDir: path to THIS SUBJECT'S freesurfer directory
% -inflateITer: number of inflate iterations to run.  0 or empty = no run
%
% Outputs:
%  classificationOut:  standardly constructed classification structure
%  Same for the other tracts
% (C) Daniel Bullock, 2019, Indiana University
%% Begin code

if ~isdeployed
    disp('adding paths');
    addpath(genpath('/N/soft/rhel7/spm/8')) %spm needs to be loaded before vistasoft as vistasoft provides anmean that works
    addpath(genpath('/N/u/brlife/git/jsonlab'))
    addpath(genpath('/N/u/brlife/git/vistasoft'))
    addpath(genpath('/N/u/brlife/git/wma_tools'))
    addpath(genpath('/N/soft/rhel7/mrtrix/3.0/mrtrix3/matlab'))
end

config = loadjson('config.json');

if isfield(config,'inflateITer')
   inflateITer=config.inflateITer;
else
     inflateITer=0;
end

fsDir='freesurfer';

wbfg =wma_loadTck(config.track);

[classification] =bsc_streamlineCategoryPriors_v6(wbfg, fsDir,inflateITer);
%mkdir(fullfile(pwd,'classification'));
%save(fullfile(pwd,'/classification/classification.mat','classification'))

fprintf('\n classification structure stored with %i streamlines identified across %i tracts',...
    sum(classification.index>0),length(classification.names))
wma_formatForBrainLife_v2(classification,wbfg)
end