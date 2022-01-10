# loading libraries
library("dplyr")                                                
library("plyr")                                                 
library("readr")

# 1. reading csv files function from pcibex -------
read.pcibex <- function(filepath, auto.colnames=TRUE, fun.col=function(col,cols){cols[cols==col]<-paste(col,"Ibex",sep=".");return(cols)}) {
  n.cols <- max(count.fields(filepath,sep=",",quote=NULL),na.rm=TRUE)
  if (auto.colnames){
    cols <- c()
    con <- file(filepath, "r")
    while ( TRUE ) {
      line <- readLines(con, n = 1, warn=FALSE)
      if ( length(line) == 0) {
        break
      }
      m <- regmatches(line,regexec("^# (\\d+)\\. (.+)\\.$",line))[[1]]
      if (length(m) == 3) {
        index <- as.numeric(m[2])
        value <- m[3]
        if (is.function(fun.col)){
          cols <- fun.col(value,cols)
        }
        cols[index] <- value
        if (index == n.cols){
          break
        }
      }
    }
    close(con)
    return(read.csv(filepath, comment.char="#", header=FALSE, col.names=cols))
  }
  else{
    return(read.csv(filepath, comment.char="#", header=FALSE, col.names=seq(1:n.cols)))
  }
}


# Creating a variable with the function 
results1<- read.pcibex("results1.csv")

# Saving it to csv 
write.csv(results1, "1.csv", row.names = FALSE)

# 2. List filenames to be merged --------
filenames <- list.files(path="...",
                          pattern="*.csv")

# 3. Merge listed files from the path above ------
all_data <- do.call("rbind",lapply(filenames,FUN=function(files){ read.csv(files)}))

# 4. write file into a csv -------
write.csv(all_data, "...", row.names = FALSE)
