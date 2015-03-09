# ———————————————————————————————————
# SCRIPT FILE: NestingCheck.R
# ORIGINAL AUTHOR: BM
# DATE CREATED: 2/??/15
#
# LAST UPDATED BY: AH
# LAST UDPATED: 3/9/15
# 
# PURPOSE:
# Identify students, teachers, and schools that aren't nested with an entity at a higher level
# Output files will give vectors of student, teacher, and school id's that shouold be flagged in spss because they aren't nested
#
# INPUT FILES:
# f7.1.1.V2.S1.1_ComputeSES&SciRep_ConvertCSV.csv
# f7.1.2.V2.S0.TEST.csv
# f7.1.3.V2.S1.1_ConvertCSV.csv
# schools_mapping.csv
#
# OUTPUT FILES:
# teachers_without_students.csv
#
# OTHER NOTES:
# Input files should be the most recent student, teacher, and school files
# Change working directory as needed in the setwd command  
#_____________________________________________________

setwd(".../mc-script-examples/script_review")

# load input files
student <- read.csv("f7.1.1.V2.S1.1_ComputeSES&SciRep_ConvertCSV.csv")
teacher <- read.csv("f7.1.2.V2.S0.TEST.csv")
school <- read.csv("f7.1.3.V2.S1.1_ConvertCSV.csv")
mapping <- read.csv("schools_mapping.csv")

# create file names for output files
teacherOut <- "teachers_without_students.csv" #change this file name to match naming conventions

# merge student and teacher files
stu_teach <- merge(student, teacher, by = "IDTEA", all = TRUE)

# identify all teachers who have no students; results printed to teacherOut file 
idtea_freq <- aggregate (stu_teach$IDSTU, list(stu_teach$IDTEA), max)
colnames(idtea_freq) <- c('TEAID', 'freq')
remove_tea <- idtea_freq[which(is.na(idtea_freq$freq)), 'TEAID']

if(length(remove_tea) == 0){
  write("No teachers with student nesting issues", file=teacherOut)
} else {
  remove_tea <- as.data.frame(remove_tea)
  write.table(remove_tea, file=teacherOut, sep=",")  
}

rm(remove_tea)
rm(idtea_freq)

###LINES BELOW WEREN'T MODIFIED###

# identify all students who have no teachers, or who have repeat teachers
idstu <- as.data.frame(table(stu_teach$IDSTU))
colnames(idstu) <- c('STUID', 'freq')
remove_stu <- idstu[which(idstu$freq != 1), 'STUID']
remove_stu <- as.data.frame(remove_stu)
remove_stu  # these students should be flagged in spss

# merge school and mapping files 
newSchool <- merge(school, mapping, by.x = "IDSCH", by.y = "X__pID_School")

# merge teacher and newSchool files 
tea_school <- merge(teacher, newSchool, by.x = "IDSCH", by.y = "UUID_School", all = TRUE)
colnames(tea_school)[1] <- "SCHID_1" # will give warning so rename column 1

# identify all schools who have no teachers (in remove_sch) 
remove_sch <- tea_school[is.na(tea_school$IDTEA), 'SCHID_1']
remove_sch  # these schools should be flagged in spss

# identify all teachers who have no schools 
remove_tea2 <- tea_school[is.na(tea_school$SCHID_1), 'IDTEA']
remove_tea2 #remove teachers with those id's from spss

# identify schools without students
# merge students and newSchool files 
stu_school <- merge(student, newSchool, by.x = "IDSCH", by.y = "UUID_School", all = TRUE)
colnames(stu_school)[1] <- "SCHID_1" # will give warning so rename column 1

# all schools without students (removethesch) need to be flagged in spss
remove_sch <- stu_school[is.na(stu_school$IDSTU), 'SCHID_1']
remove_sch
remove_sch2 <- stu_school[is.na(stu_school$IDSTU), 'IDSCH']
remove_sch2
sort(remove_sch)
sort(remove_sch2)
removethesch <- data.frame(remove_sch, remove_sch2)
removethesch # these teachers need to be flagged in spss (should be the same)

# all students without schools need to be flagged in spss
remove_stu <- stu_school[is.na(stu_school$SCHID_1), 'IDSTU']
remove_stu # these students need to be flagged in spss
remove_stu2 <- stu_school[is.na(stu_school$IDSCH), 'IDSTU']
remove_stu2 # these students need to be flagged in spss
