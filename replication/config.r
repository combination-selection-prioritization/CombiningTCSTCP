library(wesanderson)

draft_mode <- FALSE

subjects <- c( "Cli", "Codec", "Collections", "Compress", "Gson", "Jsoup", "JxPath", "Lang", "Math")
#, "Time"
max_faults <- c(30, 8, 2, 39, 18, 92, 4, 14, 90)
#, 23
names(max_faults) <- subjects

# Colors
#my.cols = c(wes_palette("Zissou1", n = 5)[2:3], wes_palette("Darjeeling1", n = 5)[2], wes_palette("Zissou1", n = 5)[5])
library(wesanderson)

# Obtendo 11 cores combinando diferentes paletas
# Especificar 9 cores no formato hexadecimal
my.cols <- c("#FF5733", "#33FF57", "#3366FF", "#FF33A1", "#A133FF", "#FFD700", "#33FFD7", "#A1FF33", "#FF3366")



