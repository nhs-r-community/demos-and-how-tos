# NHSColourPalette -----------------------------------------------------------
NHSBlue <- "#005EB8"
NHSWhite <- "#FFFFFF"
NHSDarkBlue <- "#003087"
NHSBrightBlue <- "#0072CE"
NHSLightBlue <- "#41B6E6"
NHSAquaBlue <- "#00A9CE"
NHSBlack <- "#231F20"
NHSDarkGrey <- "#425563"
NHSMidGrey <- "#768692"
NHSPaleGrey <- "#E8EDEE"
NHSDarkGreen <- "#006747"
NHSGreen <- "#009639"
NHSLightGreen <- "#78BE20"
NHSAquaGreen <- "#00A499"
NHSPurple <- "#330072"
NHSDarkPink <- "#7C2855"
NHSPink <- "#AE2573"
NHSDarkRed <- "#8A1538"
NHSOrange <- "#ED8B00"
NHSWarmYellow <- "#FFB81C"
NHSYellow <- "#FAE100"
NHSText <- "#212B32"
NHSTextSecondary <- "#4C6272"
NHSLink <- "#005EB8"
NHSLinkHover <- "#7C2855"
NHSLinkVisited <- "#330072"
NHSLinkActive <- "#002F5C"
NHSFocus <- "#FFEB3B"
NHSFocusText <- "#212B32"
NHSBorder <- "#D8DDE0"
NHSBorderForm <- "#4C6272"
NHSError <- "#D5281B"
NHSButton <- "#007F3B"
NHSButtonSecondary <- "#4C6272"

# LinePlotTheme -----------------------------------------------------------
#This is the Line Plot theme I use for making graphs, feel free to change anything here

LinePlotTheme <- function() {
  theme(plot.title = element_text(family = "Bierstadt",
                                  size = 10,
                                  margin = margin(6,
                                                  0,
                                                  2,
                                                  0),
                                  color = NHSBlack,
                                  face = "bold",
                                  hjust = 0),
        plot.title.position = "plot",
        plot.subtitle = element_text(family = "Bierstadt",
                                     size = 8,
                                     margin = margin(2,
                                                     0,
                                                     6,
                                                     0),
                                     colour = NHSBlack),
        plot.caption = element_text(family = "Bierstadt",
                                    size = 6,
                                    color = NHSMidGrey,
                                    margin = margin(2,
                                                    0,
                                                    4,
                                                    0),
                                    hjust = 0),
        plot.caption.position = "plot",
        plot.background = element_rect(fill = NHSWhite),
        legend.position = "none",
        legend.text.align = 0,
        legend.background = element_blank(),
        legend.title = element_blank(),
        legend.key = element_blank(),
        legend.text = element_text(family = "Bierstadt",
                                   size = 10,
                                   color = NHSBlack),
        legend.justification = 'left',
        legend.margin = margin(-0.2,
                               0,
                               0.2,
                               -1.7,
                               "cm"),
        axis.title = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(family = "Bierstadt",
                                 size = 8,
                                 color = NHSBlack),
        axis.text.x = element_text(margin = margin(5,
                                                   0,
                                                   4,
                                                   0)),
        axis.text.y = element_text(margin = margin(0,
                                                   5,
                                                   0,
                                                   0)),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line.y = element_blank(),
        axis.line.x = element_line(color = NHSPaleGrey,
                                   size = 0.25),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_line(color = NHSPaleGrey,
                                          size = 0.25),
        panel.grid.major.x = element_blank(),
        panel.background = element_rect(fill = NHSWhite,
                                        colour = NHSWhite,
                                        size = 0.5,
                                        linetype = "solid"),
        strip.background = element_blank(),
        strip.text = element_text(size = 8,
                                  hjust = 0),
        plot.margin = unit(c(0,
                             0.2,
                             0,
                             0.2),
                           "cm"))}

# SPC_Data Function -----------------------------------------------------------
#This creates the control limits and tests the data against the 4 rules implimented:
#RuleA = single point outside control
#RuleB = 7 points above/below mean
#RuleC = 6 points increasing or decreasing
#RuleD = 2 of 3 points near process limit

SPC_Data <- function(data, value_field, date_field,improvement_direction) {
  data |> 
    mutate(`Average` = mean({{value_field}}),
           MovingRangea={{value_field}} - lag({{value_field}}),
           MovingRange = abs(MovingRangea)) |> 
  mutate(MeanMovingRange = mean(MovingRange, na.rm =T)) |> 
    mutate(UCL = (Average + 2.66*MeanMovingRange) ,
           LCL = (Average - 2.66*MeanMovingRange),
           MeanCompare = case_when({{value_field}} <Average ~ -1,
                                   TRUE ~ 1),
           MovingRangeCompare = case_when(MovingRangea <0 ~ -1,
                                   TRUE ~ 1)) %>% 
  mutate(RuleA = case_when({{value_field}} < LCL ~ "Y",
                           {{value_field}} > UCL ~ "Y",
                           TRUE ~ "N"),
         RuleB = case_when(rollsum(x = MeanCompare, 7, align = "right", fill = NA) == 7 ~ "Y",
                           rollsum(x = MeanCompare, 7, align = "right", fill = NA) == -7 ~ "Y",
                           TRUE ~ "N"),
         RuleC = case_when(rollsum(x = MovingRangeCompare, 6, align = "right", fill = NA) == 6 ~ "Y",
                           rollsum(x = MovingRangeCompare, 6, align = "right", fill = NA) == -6 ~ "Y",
                           TRUE ~ "N"),
         RuleDa = case_when({{value_field}} > (Average + 2.66 *2/3*MeanMovingRange) & {{value_field}} < UCL ~1,
                            {{value_field}} < (Average - 2.66 *2/3*MeanMovingRange) & {{value_field}} > LCL ~1,
                            TRUE~0),
         RuleD = case_when(rollsum(x = RuleDa, 3, align = "right", fill = NA) >= 2 ~ "Y",
                           TRUE ~ "N"),
         Rules = case_when(RuleA == "Y" ~ "Y",
                           RuleB == "Y" ~ "Y",
                           RuleC == "Y" ~ "Y",
                           RuleD == "Y" ~ "Y",
                           TRUE ~ "N")
         )
}

# SPC_Plot Function -----------------------------------------------------------
#This uses that data frame created and plots it using the LinePlotTheme (above), including the control limits. 
#Orange indicates a point has breeched a rule

SPC_Plot <- function(data, value_field, date_field,improvement_direction) {
  data |> 
    ggplot(aes(x = {{date_field}},
               y = {{value_field}})) +
    geom_line(size = 0.7, colour = NHSBlue) +
    geom_line(aes(y= UCL), size = 0.3)+
    geom_line(aes(y= LCL), size = 0.3)+
    geom_line(aes(y= Average), size = 0.3)+
    geom_point(aes(colour = factor(Rules,
                                   level = c('Y', 'N'))), size = 2)+
    scale_colour_manual("legend",
                        values = c("Y" = NHSOrange,
                                   "N" = NHSBlue)) +
    geom_hline(yintercept = 0,
               size = 0.5,
               colour = "#000000") +
    LinePlotTheme()
}


# Example -----------------------------------------------------------

RandomData <- data.frame(Month = c(seq(from = as.Date("2018-04-01"),
                                       to = as.Date("2022-03-01"),
                                       by = "1 month")),
                         Count = sample(100:150, size = 48, replace = TRUE))

RandomData |> 
  SPC_Data(value_field = Count, date_field = Month) |> 
  SPC_Plot(value_field = Count, date_field = Month) +
  labs(title = "SPC Chart of Random Data",
     caption = paste0("Created on ",
                      format(Sys.time(),
                             '%A %d %B %Y'),
                      sep = " ")) 

