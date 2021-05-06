###################################################################
# Identify the class you want to graph  		  #
# using information from the TestScoresDBSep2018.xlsx file        #
# and set the values below accordingly                            #
###################################################################

WhichClass	<- "7"				# As per TestScoresDBSep2018.xlsx file 

###############################################
# Do not alter anything below this line       #
###############################################

library(tidyverse)
library(readxl)
library(gridExtra)

df <- read_excel("data/TestScoresDB.xlsx", sheet=1)
df$marks_perc <- df$marks/df$max_marks*100

df$subject <- factor(tolower(df$subject))
df$test_desc <- factor(tolower(df$test_desc))
df$name_short <- factor(df$name_short)
df$test_occ_no_f <- factor(paste("Occ", df$test_occ, sep=":"))

if (!dir.exists("plots")) {
  dir.create("plots")
}

df <- df[df$class==WhichClass,]

admission_numbers <- unique(df$adm_no)

n_subjects <- length(unique(levels(df$subject)))
n_pupils <- length(unique((df$adm_no)))

for (i in 1:n_pupils) {
  xdf <- df[df$adm_no==admission_numbers[i],]
  for(j in 1:n_subjects) {
    my_file_name <- unique(paste(	xdf$name_short[xdf$adm_no==admission_numbers[i]], "AdmNo", 	
                                  xdf$adm_no[xdf$adm_no==admission_numbers[i]], 
                                  "Class", xdf$class[xdf$adm_no==admission_numbers[i]]),sep="-")		
    my_file_name <- paste(my_file_name, sep="-")
    print(my_file_name)
    pdf (paste(my_file_name, "pdf", sep='.'), width=15, height=10)
    p1 <- ggplot(xdf, aes(x=test_occ_no_f, y=marks_perc, group=name_short)) +
      geom_line()+
      geom_point()+	
      facet_wrap(subject~test_desc)+
      ylab("% Score")+
      xlab("Test Occ")+
      scale_y_continuous(breaks = seq(0, 100, 10), limits=c(0,100))+
      ggtitle(my_file_name)
    print(p1)
    dev.off()
  }
}
