# clear field, load/detach packages
rm(list=ls(all.names = T))
library(reshape)
detach(package:plyr)
library(dplyr)
library(ggplot2)
library(egg)
library(cowplot)
library(ggh4x)

# load data and organize factors ######
data <- read.csv("./0-ramus-thesis-data-cleaned.csv")
data$ProDivTrtID <- factor(data$ProDivTrtID, levels=c("Cf", "Gt", "Gv", "Gg", "NM", "IM", "CM"))
data$Species<- factor(data$Species, levels=c("Cf", "Gt", "Gv", "Gg", "All"))
summary(data)
str(data)
colnames(data)
data$ProBiomass2 <- data$ProBiomass

# # select the most resolved data from the final 4 weeks of the experiment
df0 <- subset(data, Week > 8)
str(df0)

# replace responses with NAs where algae was not recovered (for time averaging) 
df0[,c("ConAbund", "ConBiomass", "ConDivRich", "ProBiomass2")] <- as.numeric(apply(df0[,c("ConAbund", "ConBiomass", "ConDivRich", "ProBiomass2")], 2, function(x) ifelse(df0$ProBiomass>0, x, NA)))
df0

# calculated time-averaged mean for each species in each treatment over the last 4 weeks
summary.df0 <- df0 %>% # the names of the new data frame and the data frame to be summarised
  group_by(Block, Species, ProDivTrtType, ProDivTrtID) %>%   # the grouping variable
  summarise(Abund = mean(ConAbund, na.rm=T),  # calculates the mean of each group
            Biomass = mean(ConBiomass, na.rm=T),
            Rich =  mean(ConDivRich, na.rm=T),
            Amass = mean(ProBiomass2, na.rm=T),
            n =  n()-sum(is.na(ConAbund))) # calculates the sample size per group
summary.df0
sdf0 <- as.data.frame(summary.df0)
sdf0
detach(package:dplyr)

# because there is one case (block #33) where codium fragile was not recovered during any of the final 4 weeks (and thus time-averaging results in NaN) we've elected to replace this value with 0s, otherwise we will completely lost that replicate in all subsquent analyses. our justification behind this is twofold in that (1) one species in one treatment should not preclude that treatment from being dropped in all subsequent analyses, esp. given there were only 5 replicates of each treatment to begin with, and (2) in another regard this seems to also incorporate the realism of the macroalgal assemblage on the rock jetty, given that codium was becoming increasingly hard to find on the rock revetment at that point in time.
sdf0 <- replace(sdf0, is.na(sdf0), 0)
sdf0

# create "replicate" column needed for biodiversity partition calculations
sdf0$Rep <- sdf0$Block
sdf0$Rep <- ifelse(sdf0$Block>5 & sdf0$Block<11, sdf0$Rep-5, sdf0$Rep)
sdf0$Rep <- ifelse(sdf0$Block>10 & sdf0$Block<16, sdf0$Rep-10, sdf0$Rep)
sdf0$Rep <- ifelse(sdf0$Block>15 & sdf0$Block<21, sdf0$Rep-15, sdf0$Rep)
sdf0$Rep <- ifelse(sdf0$Block>20 & sdf0$Block<26, sdf0$Rep-20, sdf0$Rep)
sdf0$Rep <- ifelse(sdf0$Block>25 & sdf0$Block<31, sdf0$Rep-25, sdf0$Rep)
sdf0$Rep <- ifelse(sdf0$Block>30 & sdf0$Block<36, sdf0$Rep-30, sdf0$Rep)

# rename columns for continuity in partition calculations
colnames(sdf0)[5:8] <- c("ConAbund", "ConBiomass", "ConDivRich", "ProBiomass")

# create object to accumulate partition data in 
cumTPP <- NULL
cumStats <- NULL

# perform partition loop for consumer abundance

response.id <- "ConAbund"
response <- "Invertebrate abundance (#)"
source("./4b-calculate-and-fit-partition.R")

# perform partition loop for consumer biomass
response.id <- "ConBiomass"
response <- "Invertebrate biomass (g)"
source("./4b-calculate-and-fit-partition.R")

# perform partition loop for consumer richness
response.id <- "ConDivRich"
response <- "Invertebrate richness (# of taxa)"
source("./4b-calculate-and-fit-partition.R")

response.id <- "ProBiomass"
response <- "Macroalgal wet mass (g)"
source("./4b-calculate-and-fit-partition.R")

# write all TPP responses and statistics into single dataframes, respectively
write.csv(cumTPP, "./derived-data/partitioned-effects-on-response-metrics.csv")
write.csv(cumStats, "./results-summary-tables/ANOVA-effects-on-partition.csv")
str(cumTPP)
cumStats$response <- factor(cumStats$response)
cumStats

# select vars for melting
vars <- cumTPP[,c("response", "trt.rich", "trt.id", "net.bdef.tran", "complementarity.tran", "selection.tran")]

# melt it to long format
melt <- melt(vars, id=c("trt.rich", "trt.id", "response"))
melt
str(melt)

# give treatments and response variables pretty names for plots
melt$variable <- ifelse(melt$variable=="net.bdef.tran", paste("Net biodiversity effect"), paste(melt$variable))
melt$variable <- ifelse(melt$variable=="complementarity.tran", paste("Complementarity effect"), paste(melt$variable))
melt$variable <- ifelse(melt$variable=="selection.tran", paste("Selection effect"), paste(melt$variable))
melt$variable <- factor(melt$variable, levels = c("Complementarity effect", "Selection effect", "Net biodiversity effect"))
cumStats$variable <- ifelse(cumStats$variable=="net.bdef.tran", paste("Net biodiversity effect"), paste(cumStats$variable))
cumStats$variable <- ifelse(cumStats$variable=="complementarity.tran", paste("Complementarity effect"), paste(cumStats$variable))
cumStats$variable <- ifelse(cumStats$variable=="selection.tran", paste("Selection effect"), paste(cumStats$variable))
cumStats$variable <- factor(cumStats$variable, levels = c("Complementarity effect", "Selection effect", "Net biodiversity effect"))

# other various manipulations require for plots
cumStats
cumStats$panel <- letters[1:12]
cumStats$panel2 <- cumStats$panel
cumStats$value[5] <- Inf
cumStats$value[8] <- Inf
cumStats$value[11] <- Inf
cumStats$value[10] <- Inf
cumStats$value[12] <- Inf
cumStats$vjust <- -0.75
cumStats$vjust[2] <- -1.26
cumStats$vjust[5] <- 3.75
cumStats$vjust[8] <- 3.75
cumStats$vjust[11] <- 3.75
cumStats$vjust[10] <- 15.5
cumStats$vjust[12] <- 15.4
cumStats$hjust <- 1.1
cumStats$hjust[10] <- 1.12
cumStats$hjust[12] <- 1.12

levels(melt$trt.id)

melt$trt.id <- gsub("invasive", "nonnative", melt$trt.id)
melt$trt.id <- as.character(melt$trt.id)
melt$trt.id <- factor(melt$trt.id, levels = c("3 species native", "3 species nonnative", "4 species"))
melt$trt.id2 <- melt$trt.id
melt$trt.id <- as.character(melt$trt.id)
melt$trt.id <- factor(melt$trt.id, levels = c("3 species native", "3 species nonnative", "4 species"))
melt3 <- subset(melt, trt.rich < 4)
melt
cumStats
str(melt)

# plot initial version of Fig 4
pAll <- ggplot(aes(x=trt.id, y=value), data = melt) +
   geom_hline(yintercept=0, linetype=2, color="grey85") + # size=0.1
   facet_grid2(response~variable, scales="free_y", switch="y", remove_labels = "all", axes="all", labeller = labeller(variable = label_wrap_gen(width=17))) + 
   geom_boxplot(colour="grey85", aes(group=trt.rich), data=melt3) + 
   geom_boxplot(width=0.5, aes(fill=trt.id), position=position_dodge(0.5), outlier.shape=NA) +
   geom_point(pch=21, position = position_jitterdodge(0.5), aes(fill=trt.id)) +
   theme_classic(base_size=8) +
   labs(fill="Treatment") +
   scale_fill_manual(values=c("#00B6EB", "#A58AFF", "#FB61D7")) +
   scale_x_discrete(limits = c("3 species native", "3 species nonnative", "4 species")) +
   theme(
      legend.position="none",
      axis.text.x = element_text(angle=45, hjust=1, vjust=1), 
      axis.text = element_text(color="black"),
      panel.grid=element_blank(), 
      axis.title=element_blank(),
      axis.text.y=element_text(angle=90, hjust=0.5),
      strip.background = element_blank(),
      strip.placement = "outside"
      )

pAll <- pAll + 
   geom_text(aes(label=lab, vjust=vjust, hjust=hjust), data=cumStats, parse=T,  size=1.75) +
   geom_text(aes(label=panel2, x=-Inf, y=Inf), data=cumStats, fontface="bold", vjust=1.25, hjust=-1, size=2.5)
pAll
#ggsave(pAll, file="./figures/Figure_4.pdf", dpi=1200, height=6, width=3)  # previously width = 4.33
#tiff(filename="./figures/Figure_4.tiff", height=6*800, width=3*800, units="px", res=800, compression="lzw")
#print(pAll)
#dev.off()


# aggregate for means ######################################################################################
detach(package:plyr)
library(reshape2)
library(dplyr)
str(melt)
colnames(melt)

# summarize
means0 <- group_by(melt, trt.rich, trt.id2, response, variable)
means <- as.data.frame(summarise(means0, 
                               n.obs = n(),
                               mean = mean(value),
                               sd = sd(value),
                               se = sd/sqrt(n.obs)
))

# rename vars
means$trt.id2 <- ifelse(means$trt.id2 == "3 species native", paste("3 species\nnative"), paste(means$trt.id2))
means$trt.id2 <- ifelse(means$trt.id2 == "3 species nonnative", paste("3 species\nnonnative"), paste(means$trt.id2))
means$trt.id2 <- factor(means$trt.id2, levels= c("3 species\nnative", "3 species\nnonnative", "4 species"))
means

means$response <- ifelse(means$response=="Invertebrate abundance (#)", paste("Invertebrate\nabundance\n(#)"), paste(means$response))
means$response <- ifelse(means$response=="Invertebrate richness (# of taxa)", paste("Invertebrate\nrichness\n(# of taxa)"), paste(means$response))
means$response <- ifelse(means$response=="Invertebrate biomass (g)", paste("Invertebrate\nbiomass\n(g)"), paste(means$response))
means$response <- ifelse(means$response=="Macroalgal wet mass (g)", paste("Macroalgal\nwet mass\n(g)"), paste(means$response))
means$response <- factor(means$response, levels=c("Invertebrate\nabundance\n(#)", "Invertebrate\nbiomass\n(g)", "Invertebrate\nrichness\n(# of taxa)", "Macroalgal\nwet mass\n(g)"))

means                    
# add panel labels
means$let <- c(rep("a", 3), rep("b", 3), rep("c", 3), rep("d", 3), rep("a", 3), rep("b", 3), rep("c", 3), rep("d", 3), rep("a", 3), rep("b", 3), rep("c", 3), rep("d", 3))


# plot it
pmeans <- 
   ggplot(aes(x=trt.id2, y=mean), data = means) +
   geom_hline(yintercept=0, linetype=1, color="black", size=0.25) + # size=0.1
   facet_wrap2(~response, scales = "free_y", ncol=1, strip.position="left", remove_labels = "x", axes="x") +
geom_errorbar(aes(ymin = ifelse(mean>=0, mean, mean-se), ymax = ifelse(mean>=0, mean+se, mean), fill=variable), color="black", width=0.15, position=position_dodge(0.7), size=0.25) +
   geom_col(aes(fill=variable), color="black", width = 0.6, position = position_dodge(0.7), size=0.25) + 
   scale_fill_manual(values=c("#FFF699", "#C34332", "#ED9B61"), labels = c("Complementarity effect", "Selection effect", "Net biodiversity effect")) +
   scale_color_manual(values=c("#FFF699", "#C34332", "#ED9B61"), labels = c("Complementarity effect", "Selection effect", "Net biodiversity effect")) +
   theme_classic(base_size=8) +
   theme(
      legend.position="top",
      axis.text = element_text(colour="black"),
      axis.title.x=element_blank(),
      axis.title.y=element_blank(),
      strip.background = element_blank(),
      strip.placement = "outside",
      legend.direction = "vertical",
      legend.title=element_blank(),
      legend.key.size = unit(0.75, "lines"),
      legend.spacing = unit(1, "lines")
      ) +
      geom_text(aes(label=let), x=-Inf, y=Inf, fontface="bold", vjust=1.25, hjust=-1, size=2.5)
   
pmeans

ggsave(pmeans, file="./figures/Figure_4.pdf", dpi=1200, height=4.5, width=3)  # previously width = 4.33

tiff(filename="./figures/Figure_4.tif", height=4.5*800, width=3*800, units="px", res=800, compression="lzw")
print(pmeans)
dev.off()

