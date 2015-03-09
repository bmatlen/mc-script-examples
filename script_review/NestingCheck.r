# NestingCheck.R
# AUTHOR: BM
# Last Updated: 2/24/15
# 
# In files: The most recent student, teacher, and school files
# Outfiles: will give vectors of student, teacher, and school id's that shouold be flagged in spss
#  
# Still need to change teacher filename.
_____________________________________________________
# load in data - change based on where data are stored
# change working directory for your purposes
student <- read.csv("~/Box Sync/Math Center Data Analysis/Math Center CMP 7 Y1 Study (Efficacy Study Practice Year)/Data Files/V1/f7.1.1.V2.S1.1_ComputeSES&SciRep_ConvertCSV.csv")
teacher <- read.csv("~/Box Sync/Math Center Data Analysis/Math Center CMP 7 Y1 Study (Efficacy Study Practice Year)/Data Files/V1/f7.1.2.V2.S0.TEST.csv")
school <- read.csv("~/Box Sync/Math Center Data Analysis/Math Center CMP 7 Y1 Study (Efficacy Study Practice Year)/Data Files/V1/f7.1.3.V2.S1.1_ConvertCSV.csv")
mapping <- read.csv("~/Box Sync/Math Center Data Analysis/Math Center CMP 7 Y1 Study (Efficacy Study Practice Year)/Data Files/V1/schools_mapping.csv")
View(stu_teach)

# merge student and teacher files
stu_teach <- merge(student, teacher, by = "IDTEA", all = TRUE)
View(stu_teach)

# identify all teachers who have no students (in remove_tea) 
idtea <- as.data.frame(table(stu_teach$IDTEA)) # convert teacher ids and their freq's to dataframe
colnames(idtea) <- c('TEAID', 'freq')
remove_tea <- idtea[which(idtea$freq == 1), 'TEAID']
remove_tea <- as.data.frame(remove_tea)
remove_tea  # these teachers should be flagged in spss

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
