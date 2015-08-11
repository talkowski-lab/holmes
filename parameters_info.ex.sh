#!/bin/bash

#liWGS-SV Pipeline: Example parameters file
#August 2015
#Contact: rcollins@chgr.mgh.harvard.edu

#Copy this format exactly to create your own parameters file

#Run preferences
export COHORT_ID=test #cohort ID (string)
export OUTDIR=/scratch/miket/rlc47temp/liWGS-SV_${COHORT_ID} #output directory - only final outputs will be written here
export WRKDIR=/scratch/miket/rlc47temp/tmp.files/${COHORT_ID}_liWGS-SV #working directory - all temp files will be written here. May temporarily need lots of storage, so best to avoid writing to /tmp
export other_assign=MALE #sex group to assign "other" sex for depth-based calling. must be either "MALE" or "FEMALE"

#Full paths for reference files & executables 
export liWGS_SV=/data/talkowski/rlc47/code/liWGS-SV #path to liWGS-SV git repo
export REF=/data/talkowski/tools/ref/Ensembl_hgGRCh37_71_reord_bwa07/Ensembl_hgGRCh37_71_ERCC_reord.fa #reference fasta
export DICT=/data/talkowski/tools/ref/Ensembl_hgGRCh37_71_reord_bwa07/Ensembl_hgGRCh37_71_ERCC_reord.mainContigs.dict #reference dictionary, restricted to chromosomes where calls should be made
export CLASSIFIER_DIR=/data/talkowski/rlc47/code/classifier #classifier git repo
export PYCLUSTER_DIR=/data/talkowski/rlc47/code/pycluster #pycluster git repo
export PICARD=/data/talkowski/tools/bin/picard-tools-1.137/picard.jar #picard.jar executable
export sambamba=/data/talkowski/tools/bin/sambamba_v0.4.6 #sambamba executable

#Update user paths
export PATH=${PATH}:${CLASSIFIER_DIR}:${PYCLUSTER_DIR}
export PYTHOPATH=${PYTHONPATH}:${CLASSIFIER_DIR}:${PYCLUSTER_DIR}