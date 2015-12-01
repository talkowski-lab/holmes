#!/bin/bash

#liWGS-SV Pipeline: Module 3 (Per-Sample Clustering)
#August 2015
#Contact: rcollins@chgr.mgh.harvard.edu

#Read input
samples_list=$1
params=$2

#Source params file
. ${params}

#Skips running bamstat if ${pre_bamstat}==TRUE
if ! [ ${pre_bamstat}=="TRUE" ] || ! [ -e ${bamstat_paths} ]; then

  #Submit bamstat job per sample
  while read ID bam sex; do
    #Syntax for running old bamstat:
    # bsub -q normal -o ${OUTDIR}/logs/bamstat.log -e ${OUTDIR}/logs/bamstat.log -sla miket_sc -J ${COHORT_ID}_bamstat "${liWGS_SV}/scripts/bamstat.sh -n -s 3 -i ${WRKDIR}/${ID}/${ID}.bam -o ${WRKDIR}/${ID}/bamstat/" 
    #Instead, run Matt's new bamstat/RPC combo:
    bsub -q normal -o ${OUTDIR}/logs/bamstat.log -e ${OUTDIR}/logs/bamstat.log -sla miket_sc -J ${COHORT_ID}_bamstat "module load sambamba/0.5.8; mkdir ${WRKDIR}/${ID}/bamstat; cd ${WRKDIR}/${ID}/bamstat/; ${liWGS_SV}/rpc_single.sh -m ${OUTDIR}/QC/sample/${ID}/${ID}.insert_size_metrics ${ID} ${WRKDIR}/${ID}/${ID}.bam"
  done < ${samples_list}

  #Gate until complete; 20 sec check; 5 min report
  GATEcount=$( bjobs -w | awk '{ print $7 }' | grep -e "${COHORT_ID}_bamstat\|BAMSTAT_GATE" | wc -l )
  GATEwait=0
  until [[ $GATEcount == 0 ]]; do
    sleep 20s
    GATEcount=$( bjobs -w | awk '{ print $7 }' | grep -e "${COHORT_ID}_bamstat\|BAMSTAT_GATE" | wc -l )
    GATEwait=$[${GATEwait} +1]
    if [[ $GATEwait == 15 ]]; then
      echo "$(date): INCOMPLETE"
      echo "$(date): Waiting on ${GATEcount} jobs to complete"
      GATEwait=0
    fi
  done

  #Remove unnecessary pairs files
  while read ID bam sex; do
    rm ${WRKDIR}/${ID}/bamstat/*pairs*txt
  done < ${samples_list}

  #Rename new bamstat files to be consistent with old naming convention
  while read ID bam sex; do
    mv ${WRKDIR}/${ID}/bamstat/*del*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_deletion_dX_q-1_sX.txt
    mv ${WRKDIR}/${ID}/bamstat/*dup*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_insertion_dX_q-1_sX.txt
    mv ${WRKDIR}/${ID}/bamstat/*ins*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_inversion_dX_q-1_sX.txt
    mv ${WRKDIR}/${ID}/bamstat/*inv*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_transloc_dX_q-1_sX.txt
  done < ${samples_list}
else

  #copy clusters and stats file from previous bamstat run
  while read ID bam sex; do
    mkdir ${WRKDIR}/${ID}/bamstat/
    bpath=$( fgrep -w ${ID} ${bamstat_paths} | cut -f2 )
    cp ${bpath}/*del*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_deletion_dX_q-1_sX.txt
    if [ $( l ${bpath}/*dup*clusters* | wc -l ) -gt 0 ]; then
      cp ${bpath}/*dup*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_insertion_dX_q-1_sX.txt
    else
      cp ${bpath}/*ins*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_insertion_dX_q-1_sX.txt
    fi
    cp ${bpath}/*inv*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_inversion_dX_q-1_sX.txt
    if [ $( l ${bpath}/*tloc*clusters* | wc -l ) -gt 0 ]; then
      cp ${bpath}/*tloc*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_transloc_dX_q-1_sX.txt
    else
      cp ${bpath}/*transloc*clusters* ${WRKDIR}/${ID}/bamstat/${ID}_transloc_dX_q-1_sX.txt
    fi
  done < ${samples_list}
fi