# Use this script to pull school data from the NCES website and combine into a table 
# 
# Files:
#   nces.txt: a list of NCES school IDs 
#   nces_vars.txt: a list of NCES variable names with regular expressions to identify those variables on NCES html pages, separated by ;


# read in list of NCES school IDs
con <- file("nces.txt", "r")
nces_ids <- readLines(con)
close(con)

nces_ids_arr <- as.array(nces_ids)
nces_links <- apply(nces_ids_arr,1,function(x) paste("http://nces.ed.gov/globallocator/sch_info_popup.asp?Type=Public&ID=",x,sep=""))
nces_cnt <- length(nces_links)

# read in list of NCES variables and regex patterns (variables and corresponding patterns are separated by ;)
con <- file("nces_vars.txt", "r")
nces_vars <- readLines(con)
close(con)

nces_vars_arr <- as.array(nces_vars)
vars <- apply(nces_vars_arr,1,function(x) strsplit(x[1],";")[[1]][1])
vars <- c("NCESID", vars)
patterns <- apply(nces_vars_arr,1,function(x) strsplit(x[1],";")[[1]][2])
var_cnt <- length(vars)

# for each NCES school ID, read in webpage, scrape data, add to matrix
schools <- vector("character", length=nces_cnt)
nces_data <- matrix(,nrow=nces_cnt, ncol = var_cnt)
colnames(nces_data) <- vars

for (i in 1:nces_cnt){
  con <- url(nces_links[i], "r")
  school <- readLines(con)
  close(con)
  school <- sub("&nbsp;","",school,ignore.case=TRUE)
  school <- paste(school,collapse = "")
  schools[i] <- school
  nces_data[i,1] <- nces_ids_arr[i] 
  for (j in 2:var_cnt){
    found_patterns <- regmatches(schools[i], regexec(patterns[j-1],schools[i]))[[1]][2] 
    nces_data[i,j] <- found_patterns
  }
}

# save matrix of NCES data to tab delimited file
write.table(nces_data,file="nces_output.txt",sep="\t",col.names=TRUE,row.names=FALSE)
