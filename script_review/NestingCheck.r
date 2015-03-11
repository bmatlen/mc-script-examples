# ———————————————————————————————————
# SCRIPT FILE: NestingCheck.R
# @AUTHORS: Bryan Matlen & AH 
# DATE CREATED: 2/15/15
#
# LAST UPDATED BY: Bryan Matlen
# LAST UDPATED: 3/11/15
# 
# PURPOSE:
# Identify students, teachers, and schools that aren't nested with an entity at a higher level
# Output files will give .csv files of student, teacher, and school id's that should be flagged in spss 
# because they violate nesting in any possible way of student - teacher - school.
#
# INPUT FILES:
# f7.1.1.V2.S1.1_ComputeSES&SciRep_ConvertCSV.csv
# f7.1.2.V2.S0.TEST.csv
# f7.1.3.V2.S1.1_ConvertCSV.csv
# schools_mapping.csv
#
# OUTPUT FILES:
# studentOut2 <- "f7.1.1.V2.S1.3_ComputeSES&SciRep_StudentOut2.csv"
# studentOut3 <- "f7.1.1.V2.S1.4_ComputeSES&SciRep_StudentOut3.csv"
# teacherOut <- "f7.1.2.V2.S0.1__TeacherOut.csv" 
# teacherOut2 <- "f7.1.2.V2.S0.2_TeacherOut2.csv" 
# schoolOut <- "f7.1.3.V2.S1.2_SchoolOut.csv"
# schoolOut2 <- "f7.1.3.V2.S1.3_SchoolOut2.csv"
# schoolOut3 <- "f7.1.3.V2.S1.4_SchoolOut3.csv"
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
studentOut <- "f7.1.1.V2.S1.2_ComputeSES&SciRep_StudentOut.csv"
studentOut2 <- "f7.1.1.V2.S1.3_ComputeSES&SciRep_StudentOut2.csv"
studentOut3 <- "f7.1.1.V2.S1.4_ComputeSES&SciRep_StudentOut3.csv"
teacherOut <- "f7.1.2.V2.S0.1__TeacherOut.csv" 
teacherOut2 <- "f7.1.2.V2.S0.2_TeacherOut2.csv" 
schoolOut <- "f7.1.3.V2.S1.2_SchoolOut.csv"
schoolOut2 <- "f7.1.3.V2.S1.3_SchoolOut2.csv"
schoolOut3 <- "f7.1.3.V2.S1.4_SchoolOut3.csv"

# merge student and teacher files
stu_teach <- merge(student, teacher, by = "IDTEA", all = TRUE)

# identify all teachers who have no students; results printed to teacherOut file 
idtea_freq <- aggregate(stu_teach$IDSTU, list(stu_teach$IDTEA), max)
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

###LINES BELOW were modified as of 3/9/11 by BM###

# identify all students who have no teachers, or who have repeat teachers
# BM wrote this code by modifying AH's code above in creating the TeachOut file
idstu_freq <- aggregate(stu_teach$IDTEA, list(stu_teach$IDSTU), max)
colnames(idstu_freq) <- c('STUID', 'freq')
remove_stu <- idstu_freq[which(is.na(idtstu_freq$freq)), 'STUID']

if(length(remove_stu) == 0){
  write("No students with teacher nesting issues", file=studentOut)
} else {
  remove_stu <- as.data.frame(remove_stu)
  write.table(remove_stu, file=studentOut, sep=",")  
}

rm(remove_stu)
rm(idstu_freq)

# merge school and mapping files 
newSchool <- merge(school, mapping, by.x = "IDSCH", by.y = "X__pID_School")

# merge teacher and newSchool files 
tea_school <- merge(teacher, newSchool, by.x = "IDSCH", by.y = "UUID_School", all = TRUE)
colnames(tea_school)[1] <- "SCHID_1" # will give warning so rename column 1

# identify all schools who have no teachers (in remove_sch) 
remove_sch <- tea_school[is.na(tea_school$IDTEA), 'SCHID_1']
if(length(remove_sch) == 0){
  write("No schools with teacher nesting issues", file=schoolOut)
} else {
  remove_sch <- as.data.frame(remove_sch)
  write.table(remove_sch, file=schoolOut, sep=",")  
}

# identify all teachers who have no schools 
remove_tea2 <- tea_school[is.na(tea_school$SCHID_1), 'IDTEA']
if(length(remove_tea2) == 0){
  write("No teachers with school nesting issues", file=teacherOut2)
} else {
  remove_tea2 <- as.data.frame(remove_tea2)
  write.table(remove_tea2, file=teacherOut2, sep=",")  
}

# identify schools without students
# merge students and newSchool files 
stu_school <- merge(student, newSchool, by.x = "IDSCH", by.y = "UUID_School", all = TRUE)
colnames(stu_school)[1] <- "SCHID_1" # will give warning so rename column 1

# all schools without students with one of the school mapping id numbers
remove_sch2 <- stu_school[is.na(stu_school$IDSTU), 'SCHID_1']
remove_sch2
if(length(remove_sch2) == 0){
  write("No schools with student nesting issues", file=schoolOut2)
} else {
  remove_sch2 <- as.data.frame(remove_sch2)
  write.table(remove_sch2, file=schoolOut2, sep=",")  
}
# remove the students without schools from the other school mapping id number
remove_sch3 <- stu_school[is.na(stu_school$IDSTU), 'IDSCH']
remove_sch3
if(length(remove_sch3) == 0){
  write("No schools with student nesting issues", file=schoolOut3)
} else {
  remove_sch3 <- as.data.frame(remove_sch3)
  write.table(remove_sch3, file=schoolOut3, sep=",")  
}


# all students without schools from one of the school mapping id numbers
remove_stu2 <- stu_school[is.na(stu_school$SCHID_1), 'IDSTU']
if(length(remove_stu2) == 0){
  write("No students with school nesting issues", file=studentOut2)
} else {
  remove_stu2 <- as.data.frame(remove_stu2)
  write.table(remove_stu2, file=studentOut2, sep=",")  
}
# remove the students without schools from the other school mapping id number
remove_stu3 <- stu_school[is.na(stu_school$IDSCH), 'IDSTU']
if(length(remove_stu3) == 0){
  write("No students with school nesting issues", file=studentOut)
} else {
  remove_stu3 <- as.data.frame(remove_stu3)
  write.table(remove_stu3, file=studentOut3, sep=",")  
}
