#==================================================
# Time Efficiency Comparison Analysis - CORRIGIDO
#==================================================

# Carregar dados
raw_results <- read.table("subjects/all/time_avg.csv", header=TRUE, sep=",")

# Carregar bibliotecas
library(rstatix)
library(effsize)

# Criar subsets
ekstazi <- subset(raw_results, Group == "Ekstazi")
fast <- subset(raw_results, Group == "FAST")
fastazi <- subset(raw_results, Group == "Ekstazi + FAST")
EkstaziDPT <- subset(raw_results, Group == "Ekstazi + DPT")
STARTSDPT <- subset(raw_results, Group == "STARTS + DPT")
DPT <- subset(raw_results, Group == "DPT")
STARTSfast <- subset(raw_results, Group == "STARTS + FAST")
STARTS <- subset(raw_results, Group == "STARTS")

# Obter p-values do Wilcoxon
wilcox_results <- wilcox_test(raw_results, Time ~ Group, p.adjust.method = "bonferroni")

# Função CORRIGIDA para extrair p-value
get_p_value <- function(g1, g2) {
  result <- wilcox_results %>% 
    filter((group1 == g1 & group2 == g2) | (group1 == g2 & group2 == g1))
  if(nrow(result) > 0) return(result$p.adj[1])
  return(NA)
}

# FAZER ANÁLISES NOVAS
cat("=== EKSTAZI + FAST ===\n")
cat("FAST vs Ekstazi: p =", get_p_value("FAST", "Ekstazi"), "A =", VD.A(fast$Time, ekstazi$Time)$estimate, "\n")
cat("FAST vs Ekstazi+FAST: p =", get_p_value("FAST", "Ekstazi + FAST"), "A =", VD.A(fast$Time, fastazi$Time)$estimate, "\n")
cat("Ekstazi+FAST vs Ekstazi: p =", get_p_value("Ekstazi + FAST", "Ekstazi"), "A =", VD.A(fastazi$Time, ekstazi$Time)$estimate, "\n\n")

cat("=== EKSTAZI + DPT ===\n")
cat("DPT vs Ekstazi: p =", get_p_value("DPT", "Ekstazi"), "A =", VD.A(DPT$Time, ekstazi$Time)$estimate, "\n")
cat("DPT vs Ekstazi+DPT: p =", get_p_value("DPT", "Ekstazi + DPT"), "A =", VD.A(DPT$Time, EkstaziDPT$Time)$estimate, "\n")
cat("Ekstazi+DPT vs Ekstazi: p =", get_p_value("Ekstazi + DPT", "Ekstazi"), "A =", VD.A(EkstaziDPT$Time, ekstazi$Time)$estimate, "\n\n")

cat("=== STARTS + DPT ===\n")
cat("DPT vs STARTS: p =", get_p_value("DPT", "STARTS"), "A =", VD.A(DPT$Time, STARTS$Time)$estimate, "\n")
cat("DPT vs STARTS+DPT: p =", get_p_value("DPT", "STARTS + DPT"), "A =", VD.A(DPT$Time, STARTSDPT$Time)$estimate, "\n")
cat("STARTS+DPT vs STARTS: p =", get_p_value("STARTS + DPT", "STARTS"), "A =", VD.A(STARTSDPT$Time, STARTS$Time)$estimate, "\n\n")

cat("=== STARTS + FAST ===\n")
cat("FAST vs STARTS: p =", get_p_value("FAST", "STARTS"), "A =", VD.A(fast$Time, STARTS$Time)$estimate, "\n")
cat("FAST vs STARTS+FAST: p =", get_p_value("FAST", "STARTS + FAST"), "A =", VD.A(fast$Time, STARTSfast$Time)$estimate, "\n")
cat("STARTS+FAST vs STARTS: p =", get_p_value("STARTS + FAST", "STARTS"), "A =", VD.A(STARTSfast$Time, STARTS$Time)$estimate, "\n")

