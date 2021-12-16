# Looping graphs and tabs in RMarkdown

This is a demo of using a loop to produce several charts and tabs in an RMarkdown document. It requires using the SPC package {qicharts2}.

Loop examples like this often relate to base R plot code but this works with {ggplot2} and consequently also {qicharts2}. Each category group is it's own plot, in this case it's gender, and these are presented in a separate tab. This is useful for many plots as otherwise reports can grow very long. As each tab requires a title, this is generated within the loop using the category name.