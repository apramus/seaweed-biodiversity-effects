# clear field, load/detach packages
rm(list=ls(all.names = T))
library(reshape)
detach(package:plyr)
library(dplyr)
library(ggplot2)
library(egg)
library(cowplot)

# load data and organize factors
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

# because there is one case (block #33) where codium fragile was not recovered during any of the final 4 weeks (and thus time-averaging results in NaN) lets replace this value with 0s, otherwise we will completely lost that replicate in all subsquent analyses
# for me this could go either way. i think its justified in that one species in one treatment should not preclude that treatment from being dropped in all subsequent analyses, esp. given there were only 5 replicates of each treatment to begin with...in some sense seems to also incorporate the realism of the macroalgal assemblage on the rock jetty, in that codium was becoming increasingly hard to find on the rock revetment at that point in time...
# alternatively, would happen if you just subsetted this value out?
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
write.csv(cumTPP, "./derived-data/partitioned-effects-on-consumer-responses.csv")
write.csv(cumStats, "./output/anova-summary-table-for-effects-on-partition.csv")
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
cumStats$panel2 <- with(cumStats, paste("(",panel, ")", sep=""))
cumStats$value[5] <- Inf
cumStats$value[8] <- Inf
cumStats$value[11] <- Inf
cumStats$value[10] <- Inf
cumStats$value[12] <- Inf
cumStats$vjust <- -0.75
cumStats$vjust[5] <- 1.75
cumStats$vjust[8] <- 1.75
cumStats$vjust[11] <- 1.75
cumStats$vjust[10] <- 15.5
cumStats$vjust[12] <- 13
cumStats$hjust <- 1.1
cumStats$hjust[10] <- 1.44
cumStats$hjust[12] <- 1.44


levels(melt$trt.id)
#library(forcats)
melt$trt.id <- as.character(melt$trt.id)
melt$trt.id <- factor(melt$trt.id, levels = c("3 species native", "3 species invasive", "4 species"))
#<- fct_relevel(melt$trt.id, "3 species native", "3 species invasive", "4 species")
melt$trt.id2 <- melt$trt.id
melt$trt.id <- as.character(melt$trt.id)
melt$trt.id <- factor(melt$trt.id, levels = c("3 species native", "3 species invasive", "4 species"))
melt3 <- subset(melt, trt.rich < 4)
melt
cumStats
str(melt)

# plot it
pAll <- ggplot(aes(x=trt.id, y=value), data = melt) +
   geom_hline(yintercept=0, linetype=2, color="grey85") + # size=0.1
   facet_grid(response~variable, scales="free_y", switch="y") + #, strip.position.y="left") +
   #facet_grid(variable~response, scales="free", space="free") + #, strip.position.y="left") +
   #facet_wrap(variable~., scales="free_y", strip.position="left") +
   #facet_wrap(.~response, scales="free_y", strip.position="top") +
   #facet_wrap(variable~response, scales = "free_y") + #, strip.position="left") +
   geom_boxplot(colour="grey85", aes(group=trt.rich), data=melt3) + 
   #geom_boxplot(width=0.5, aes(fill=ProDivTrtID), position=position_dodge(0.75), outlier.shape = NA) +
   geom_boxplot(width=0.5, aes(fill=trt.id), position=position_dodge(0.5), outlier.shape=NA) +
   geom_point(pch=21, position = position_jitterdodge(0.5), aes(fill=trt.id)) +
   theme_article(base_size=8) +
   #theme_half_open(8) +
   labs(fill="Treatment") +
   scale_fill_manual(values=c("#00B6EB", "#A58AFF", "#FB61D7")) +
   scale_x_discrete(limits = c("3 species native", "3 species invasive", "4 species")) +
   theme(
      legend.position="none",
      axis.text.x = element_text(angle=45, hjust=1, vjust=1), 
      axis.text = element_text(color="black"),
      panel.grid=element_blank(), 
      #panel.border = element_rect(color=NA),
      aspect.ratio=1,
      #axis.line.x = element_line(color = "black", size=1),
      axis.title=element_blank(),
      axis.text.y=element_text(angle=90, hjust=0.5),
      strip.background = element_blank(),
      strip.placement = "outside"
      )
     # legend.position = "none",
   #theme(strip.text = element_text(size=rel(0.8), margin=unit(c(3, 3, 3, 3), "pt")), strip.background = element_rect(fill="grey85"))
pAll <- pAll + 
   geom_text(aes(label=lab, vjust=vjust, hjust=hjust), data=cumStats, parse=T,  size=1.75) +
   geom_text(aes(label=panel2, x=-Inf, y=Inf), data=cumStats, fontface="bold", vjust=1.25, hjust=-0.125, size=2.5)
   #vjust=2, hjust=1.25, parse=T, size=1.8)
   #lab(x="Macroalgal diversity treatment")
   #theme(aspect.ratio=1)
   #ylab(paste(eval(plot.name)))
pAll
ggsave(pAll, file="./figures-and-tables/Figure_4. Partition effects.pdf", dpi=1200, height=6, width=4.33)

#library("scales")
#n1 <- 7                           
#hex_codes1 <- hue_pal()(n1) 
#hex_codes1