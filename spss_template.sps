*----------------------------------------------------------
* SCRIPT FILE: spss_template.sps
* ORIGINAL AUTHOR: AH
* DATE CREATED: 03/10/2015
*
* LAST UPDATED BY: AH
* LAST UPDATED: 03/10/2015
*
* PURPOSE:
* A sample SPSS script to model file format that should be used with MC scripts.
*
* INPUT FILES:
* orig_data_file.sav
*
* OUTPUT FILES:
* new_data_file.sav
* getting_started.spv
*
* OTHER NOTES:
* When using this script template, be sure to update the working directory in the setwed command
* If any special packages were used, mention them here
*----------------------------------------------------------.

OUTPUT NEW.
CD '.../mc-script-examples'.




COMMENT Timestamp dataset and close files.
COMPUTE DATADATE = $time.
exe.
FORMATS DATADATE (datetime).
VARIABLE LABELS DATADATE 'Dataset Creation Timestamp'.

OUTPUT CLOSE *.
