###################################################################
# Identify the subject, test and class you want to graph  		  #
# using information from the TestScoresDBSep2018.xlsx file        #
# and set the values below accordingly                            #
###################################################################

DoAll			<- "no"			# if "yes" then plots for all subjects will be produced as separate files but in one go
WhichSubject	<- "biology"		# as per TestScoresDBSep2018.xlsx file 

###############################################
# Do not alter anything below this line       #
###############################################

setwd(paste(grass_directory, "GRASS Data", sep="/"))


library(tidyverse)
library(readxl)
library(gridExtra)


df <- read_excel("TestScoresDB.xlsx", sheet=1)
df$marks_perc <- df$marks/df$max_marks*100

df$subject <- factor(tolower(df$subject))
df$test_desc <- factor(tolower(df$test_desc))
df$name_short <- factor(df$name_short)
df$test_occ_no_f <- factor(paste("Occ", df$test_occ, sep=":"))


setwd(paste(grass_directory, "GRASS Plots", sep='/'))

if(DoAll=="no") {
	n <- 1
	subjects <- WhichSubject
}

if(DoAll=="yes") {
	n <- length(unique(df$subject))
	subjects <- sort(unique(df$subject))
}

for(i in 1:n) {
	print(i)
	print(paste(unique(df$subject[df$subject==subjects[i]])))
	setwd(paste(grass_directory, "GRASS Plots", subjects[i], sep="/"))
	my_file_name <- unique(paste(df$subject[df$subject==subjects[i]]))
	adf <- df %>% filter (subject==subjects[i])
	pdf (paste(my_file_name, "pdf", sep='.'), width=15, height=10)
	p1 <- ggplot(adf, aes(x=test_occ_no_f, y=marks_perc)) +
			geom_boxplot()+
			facet_wrap(class~test_desc)+
			ylab("% Score")+
			xlab("Test Occ")+
			scale_y_continuous(breaks = seq(0, 100, 10), limits=c(0,100))+
			ggtitle(my_file_name)
	print(p1)
	dev.off()
}

	



