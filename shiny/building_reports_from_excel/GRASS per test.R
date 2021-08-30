###################################################################
# Identify the subject, test and class you want to graph  		  #
# using information from the TestScoresDBSep2018.xlsx file        #
# and set the values below accordingly                            #
###################################################################

WhichSubject 	<- "urdu" # subject name in "" - as per TestScoresDBSep2018.xlsx file
WhichTestDesc	<- "summer 2019 exam"	# test desc as in "" - as per TestScoresDBSep2018.xlsx file
WhichClass	 	<- "8" # class id in "" - as per TestScoresDBSep2018.xlsx file

###############################################
# Do not alter anything below this line       #
###############################################

df$marks_perc <- df$marks / df$max_marks * 100
df$subject <- factor(tolower(df$subject))
df$test_desc <- factor(tolower(df$test_desc))

WhichSubject <- tolower(WhichSubject)
WhichTestDesc <- tolower(WhichTestDesc)

df <- df %>% 
  dplyr::filter(class == WhichClass,
                subject == WhichSubject,
                test_desc == WhichTestDesc)

# init
my_file_name <- paste0(
  paste("Yr", df$class[df$test_desc==WhichTestDesc], 
        df$subject[df$test_desc==WhichTestDesc], 
        df$test_desc[df$test_desc==WhichTestDesc], 
        "Occ",
        max(df$test_occ[df$test_desc==WhichTestDesc]), 
        max(df$test_date[df$test_desc==WhichTestDesc]), sep = "_"),
  ".pdf")

pdf (paste(my_file_name, "pdf", sep='.'), width=15, height=10)
df$name_short <- factor(df$name_short)
df$test_occ_no_f <- factor(paste("Occ", df$test_occ, sep=":"))

# plot 1 - boxplot
ggplot(df, aes(x=test_occ_no_f, y=marks_perc))+
  geom_boxplot()+
  ylab("% Score")+
  xlab("Test Occ")+
  scale_y_continuous(breaks = seq(0, 100, 10), limits=c(0,100))+
  ggtitle(unique(paste("Yr", df$year, "Class", df$class, df$subject, df$test_desc, df$test_date, sep=":")))


# plot 2 - facet per pupil
df$name_short <- with(df, factor(name_short, levels = sort(levels(name_short))))
ggplot(df, aes(x=test_occ_no_f, y=marks_perc, group=name_short))+
  geom_point()+
  geom_line()+
  facet_wrap(~name_short)+
  xlab("Test occasion number")+
  ylab("% Score")+
  scale_y_continuous(breaks = seq(0, 100, 10), limits=c(0,100))+
  ggtitle(unique(paste("Yr", df$year, "Class", df$class, df$subject, df$test_desc, df$test_date, sep=":")))

# plot 3 - dot plot
df$name_short <- with(df, factor(name_short, levels = rev(levels(name_short))))
sdf <-
  df %>% 
  group_by(test_occ_no_f) %>%
  summarise(mu=round(mean(marks_perc, na.rm=T),0))

ggplot(df, aes(y=name_short, x=marks_perc))+
  geom_point()+
  facet_wrap(~test_occ_no_f)+
  geom_vline(data=sdf,aes(xintercept=mu, group=test_occ_no_f), color='grey', size=1)+
  xlab("% Score")+
  ylab("Pupil Name")+
  scale_x_continuous(breaks = seq(0, 100, 10), limits=c(0,100))+
  ggtitle(unique(paste("Yr", df$year, "Class", df$class, df$subject, df$test_desc, df$test_date, sep=":")))

dev.off()




