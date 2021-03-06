function wma_segMajTracks_BL_v2()
% [classification] =wma_segMajTracks__BL(wbfg, fsDir)
%
% This function automatedly segments the major human white matter tracts
% from a given whole brain fiber group using the subject's 2009 DK
% freesurfer parcellation.  Brain-life version

% Inputs:
% -wbfg: a whole brain fiber group structure
% -fsDir: path to THIS SUBJECT'S freesurfer directory

% Outputs:
% classificaton: a standardly organized classification structure
% (C) Daniel Bullock, Indiana University
%% Begin Code
if ~isdeployed
    disp('adding paths');
    addpath(genpath('/N/soft/rhel7/spm/8')) %spm needs to be loaded before vistasoft as vistasoft provides anmean that works
    addpath(genpath('/N/u/brlife/git/jsonlab'))
    addpath(genpath('/N/u/brlife/git/vistasoft'))
    addpath(genpath('/N/u/brlife/git/wma_tools'))
end

config = loadjson('config.json');

wbfg = dtiImportFibersMrtrix(config.track, .5);

%fsDir=strcat(pwd,'/freesurfer');

%atlasPath=fullfile(fsDir,'/mri/','aparc.a2009s+aseg.nii.gz');

if ~exist(atlasPath,'file')
    %fprintf('\n FILE %i NOT FOUND',atlasPath)
end

classificationOut=[];
classificationOut.names=[];
classificationOut.index=zeros(length(wbfg.fibers),1);
tic


fprintf('\n creating priors')   
[categoryPrior] =bsc_streamlineCategoryPriors_v6(wbfg, atlas,2);
[~, effPrior] =bsc_streamlineGeometryPriors(wbfg);

fprintf('\n prior creation complete')

[AntPostclassificationOut] =bsc_segmentAntPostTracts_v3(wbfg, fsDir,categoryPrior,effPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,AntPostclassificationOut);

[CCclassificationOut] =bsc_segmentCorpusCallosum_v3(wbfg, fsDir,1,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,CCclassificationOut);

[SubCclassificationOut] =bsc_segmentSubCortical_v2(wbfg, fsDir,categoryPrior,effPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,SubCclassificationOut);

[AslantclassificationOut] =bsc_segmentAslant(wbfg, fsDir,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,AslantclassificationOut);

[MDLFclassificationOut] =bsc_segmentMdLF_ILF_v4(wbfg, fsDir,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,MDLFclassificationOut);

[pArcTPCclassificationOut] = bsc_segpArcTPC(wbfg, fsDir);
classificationOut=bsc_reconcileClassifications(classificationOut,pArcTPCclassificationOut);

[opticclassificationOut] =bsc_opticRadiationSeg_V7(wbfg, fsDir, 0,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,opticclassificationOut);

[cerebellarclassificationOut] =bsc_segmentCerebellarTracts_v2(wbfg, fsDir,0,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,cerebellarclassificationOut);

[VOFclassificationOut] =bsc_segmentVOF_v4(wbfg, fsDir,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,VOFclassificationOut);

[CSTclassificationOut] =bsc_segmentCST(wbfg, fsDir,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,CSTclassificationOut);

%do it again to compensate for something eating it earlier
[cingclassificationBool] =bsc_segmentCingulum_v3(wbfg, fsDir,categoryPrior);
classificationOut=bsc_reconcileClassifications(classificationOut,cingclassificationBool);

classification= wma_resortClassificationStruc(classificationOut);
% savepath=strcat(pwd,'classification.mat');
% which('classification')
% save(savepath,'classification');
% which('classification')
toc

wma_formatForBrainLife_v2(classification,wbfg);

end