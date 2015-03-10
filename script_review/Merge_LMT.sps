
COMMENT Place all files in the same directory. Rename the directory listed under the dataDirectory handle and the file of labels_sps_file.
FILE HANDLE lmtdir /NAME='/Volumes/MATHCENTER/Data2/LMT_final'.

Comment SET FILE PATHS*.

Comment Raw data *.
FILE HANDLE ncRraw /NAME='lmtdir/RawData/LMT_NC_actualresponses_spss.xls'.

COMMENT ID files.
FILE HANDLE LMTdups /NAME='lmtdir/IDFiles/LMTDuplicates.xls'.
FILE HANDLE LMTIDs /NAME='lmtdir/IDFiles/LMTIDs.xls'.

Comment Raw data with Duplicate IDs taken care of*.
FILE HANDLE ncR /NAME='lmtdir/Interim/ncR.sav'.

* NC vars *.
FILE HANDLE nc1varsR /NAME='lmtdir/Merge/nc1varsR.sps'.

FILE HANDLE nc2varsR /NAME='lmtdir/Merge/nc2varsR.sps'.

FILE HANDLE nc3varsR /NAME='lmtdir/Merge/nc3varsR.sps'.

Comment Interim Data Files - Each tests' Data with Labels*.
FILE HANDLE nc1R /NAME='lmtdir/Interim/nc1R.sav'.

FILE HANDLE nc2R /NAME='lmtdir/Interim/nc2R.sav'.

FILE HANDLE nc3R /NAME='lmtdir/Interim/nc3R.sav'.

Comment Interim Data Files - Interim Merges*.
FILE HANDLE IDs_nc1R /NAME='lmtdir/Interim/ID_nc1R.sav'.
FILE HANDLE IDs_nc2R /NAME='lmtdir/Interim/ID_nc2R.sav'.
FILE HANDLE IDs_nc3R /NAME='lmtdir/Interim/ID_nc3R.sav'.

FILE HANDLE IDs_All /NAME='lmtdir/Interim/IDs_All.sav'.

COMMENT Final Saved Files*.
FILE HANDLE LMT_merge_output /NAME='lmtdir/Output/LMT_merge_output.spv'.
FILE HANDLE FinalData /NAME='lmtdir/Output/LMT_data_v1.sav'.

COMMENT Open temp data so can close other data files and leave this open.

DATASET DECLARE tempdata.
DATASET ACTIVATE tempdata.
DATASET NAME tempdata.
DATA LIST /ID 1-3.
BEGIN DATA
001
End data.

COMMENT Open LMTdups so is available for merges.
GET DATA /TYPE=XLS /FILE= 'LMTdups'. 
DATASET NAME LMTdups_orig.
DATASET COPY LMTdups.
DATASET ACTIVATE LMTdups.
DATASET CLOSE LMTdups_orig.

SORT CASES BY UserID.

COMMENT Open ncR.  Add in LMT_ID which gets rid of duplicates..

GET DATA /TYPE=XLS /FILE= 'ncRraw'. 
DATASET NAME ncR_orig.
DATASET COPY ncRraw.
DATASET activate ncRraw.
DATASET CLOSE ncR_orig.

SORT CASES BY UserID.

MATCH FILES FILE=*
     /TABLE=LMTdups
     /BY UserID.

SAVE OUTFILE='ncR'
     /DROP LastName FirstName.
DATASET ACTIVATE tempdata.
DATASET CLOSE ncRraw.

COMMENT *******************************************************.
COMMENT Set variable attributes (codebook)  for each LMT administration
COMMENT Merge
COMMENT *******************************************************.

Comment Open Ids.

GET DATA /TYPE=XLS /FILE= 'LMTIDs'. 
DATASET NAME lmtids_orig.
DATASET COPY lmtids.
DATASET activate lmtids.
DATASET CLOSE lmtids_orig.

SORT CASES BY LMT_ID.
DESCRIPTIVES LMT_ID.


COMMENT Open ncR as Pre. Set up variables *.

GET FILE= 'ncR'. 
DATASET NAME ncR_orig.
DATASET COPY ncRpre.
DATASET activate ncRpre.
DATASET CLOSE ncR_orig.

SELECT IF (EpisodeID=1).
Execute.
INSERT FILE='nc1varsR'.
SAVE OUTFILE='nc1R'.

DESCRIPTIVES LMT_ID.
SORT CASES BY LMT_ID.
MATCH FILES /File='lmtids' 
     /IN INlmtids
     /FILE='ncRpre' 
     /IN=INnc1R 
     /BY LMT_ID.
DATASET NAME IDs_ncRpre.
SAVE OUTFILE='IDs_nc1R'.
DESCRIPTIVES LMT_ID INlmtids INnc1R.

DATASET ACTIVATE tempdata.
DATASET CLOSE ncRpre.
DATASET CLOSE lmtids.


COMMENT Open ncR as Post. Set up variables *.

GET FILE= 'ncR'. 
DATASET NAME ncR_orig.
DATASET COPY ncRpost.
DATASET activate ncRpost.
DATASET CLOSE ncR_orig.

SELECT IF (EpisodeID=2).
Execute.
INSERT FILE='nc2varsR'.
SAVE OUTFILE='nc2R'.

DESCRIPTIVES LMT_ID.
SORT CASES BY LMT_ID.
MATCH FILES /File='IDs_ncSpre' 
     /FILE='ncRpost' 
     /IN=INnc2R 
     /BY LMT_ID.
DATASET NAME IDs_ncRpost.
RECODE EpisodeIDnc2R (SYSMIS=888888).
RECODE LNC2TOTL to LNC2COMP (SYSMIS=888888).
RECODE LNC2FORM LNC2TMST (''='888888').
SAVE OUTFILE='IDs_nc2R'.
DESCRIPTIVES LMT_ID INlmtids INnc1R INnc1S INnc2R.

DATASET ACTIVATE tempdata.
DATASET CLOSE ncRpost.
DATASET CLOSE IDs_ncSpre.

COMMENT Open ncR as Post-Post. Set up variables *.

GET FILE= 'ncR'. 
DATASET NAME ncR_orig.
DATASET COPY ncRpostpost.
DATASET activate ncRpostpost.
DATASET CLOSE ncR_orig.

SELECT IF (EpisodeID=3).
Execute.
INSERT FILE='nc3varsR'.
SAVE OUTFILE='nc3R'.

DESCRIPTIVES LMT_ID.
SORT CASES BY LMT_ID.
MATCH FILES /File='IDs_ncSpost' 
     /FILE='ncRpostpost' 
     /IN=INnc3R 
     /BY LMT_ID.
DATASET NAME IDs_ncRpostpost.

RECODE EpisodeIDnc3R (SYSMIS=888888).
RECODE LNC3TOTL to LNC3COMP (SYSMIS=888888).
RECODE LNC3FORM LNC3TMST (''='888888').

SAVE OUTFILE='IDs_nc3R'.
DESCRIPTIVES LMT_ID INlmtids INnc1R INnc1S INnc2R INnc2S INnc3R.

DATASET ACTIVATE tempdata.
DATASET CLOSE ncRpostpost.

DATASET ACTIVATE tempdata.
DATASET CLOSE IDs_ncRpostpost.

 
COMMENT label the id and system variables.

DATASET ACTIVATE IDs_pfSpostpost.

VARIABLE LABELS IDTEA 'Teacher ID'.
VARIABLE LABELS SCHTX 'Treatment'.
Value Labels SCHTX 0 'Control' 1 'Treatment'.
VARIABLE LABELS IDSCH 'School ID'.
VARIABLE LABELS IDDIS 'District ID'.
VARIABLE LABELS TEAYR1 'CMP7 Yr1 Teacher'.
Value Labels TEAYR1 1 'Yes' 0 'No'.
VARIABLE LABELS TEAYR2 'CMP7 Yr2 Teacher'.
Value Labels TEAYR2 1 'Yes' 0 'No'.
RENAME VARIABLES (ACTIVE=TEAACTIV).
VARIABLE LABELS TEAACTIV 'Teacher Active/Inactive (from FMP)'.


COMPUTE DATADATE = $time.
exe.
FORMATS DATADATE (datetime).
MEANS DATADATE /cell = mean.

VARIABLE LABELS DATADATE 'Dataset Creation Timestamp'.

SAVE OUTFILE='IDs_All'.

SAVE outfile='FinalData'
/DROP LMT_ID pID_People pID_School pID_District UserID EpisodeIDnc1R EpisodeIDnc1S EpisodeIDnc2R EpisodeIDnc2S EpisodeIDnc3R EpisodeIDnc3S EpisodeIDpf1R EpisodeIDpf1S EpisodeIDpf2R EpisodeIDpf2S EpisodeIDpf3R EpisodeIDpf3S
/KEEP All.

OUTPUT SAVE OUTFILE ='LMT_merge_output'.

OUTPUT CLOSE *.