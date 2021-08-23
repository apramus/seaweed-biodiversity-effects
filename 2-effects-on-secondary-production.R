# clear field, load/detach packages
rm(list=ls(all.names=T))
library(reshape)
detach(package:plyr)
library(dplyr)
library(ggplot2)
library(egg)

# load data and organize factors
data <- read.csv("0-ramus-thesis-data-cleaned.csv")
data$ProDivTrtID <- factor(data$ProDivTrtID, levels=c("Cf", "Gt", "Gv", "Gg", "NM", "IM", "CM"))
str(data)
summary(data)
colnames(data)

# subset for sums
sum <- subset(data, Data=="Sum")
sum$ProBiomass2 <- sum$ProBiomass
str(sum)

# select vars for melting
df <- sum[,c("Week", "Block", "ProDivTrtType", "ProDivTrtRich", "ProDivTrtID", "ProBiomass", "ProBiomass2", "ConAbund", "ConBiomass", "ConDivRich")]

# melt to long format
melt <- melt(df, id=c("Week", "Block", "ProDivTrtType", "ProDivTrtRich", "ProDivTrtID", "ProBiomass"))
str(melt)

# give treatments and response variables pretty names for plotting
melt$ProDivTrtID <- ifelse(melt$ProDivTrtID=="Cf", paste("Codium fragile"), paste(melt$ProDivTrtID))
melt$ProDivTrtID <- ifelse(melt$ProDivTrtID=="Gt", paste("Gracilaria tikvahiae"), paste(melt$ProDivTrtID))
melt$ProDivTrtID <- ifelse(melt$ProDivTrtID=="Gv", paste("Gracilaria vermiculophylla"), paste(melt$ProDivTrtID))
melt$ProDivTrtID <- ifelse(melt$ProDivTrtID=="Gg", paste("Gymnogongrus griffithsiae"), paste(melt$ProDivTrtID))
melt$ProDivTrtID <- ifelse(melt$ProDivTrtID=="NM", paste("3 species native"), paste(melt$ProDivTrtID))
melt$ProDivTrtID <- ifelse(melt$ProDivTrtID=="IM", paste("3 species invasive"), paste(melt$ProDivTrtID))
melt$ProDivTrtID <- ifelse(melt$ProDivTrtID=="CM", paste("4 species"), paste(melt$ProDivTrtID))
melt$ProDivTrtID <- factor(melt$ProDivTrtID, levels=c("Codium fragile", "Gracilaria tikvahiae", "Gracilaria vermiculophylla", "Gymnogongrus griffithsiae", "3 species native", "3 species invasive", "4 species"))
melt$ProDivTrtType <- ifelse(melt$ProDivTrtType=="Mono", paste("Monocultures"), paste(melt$ProDivTrtType))
melt$ProDivTrtType <- ifelse(melt$ProDivTrtType=="Poly", paste("Polycultures"), paste(melt$ProDivTrtType))
melt$ProDivTrtType <- factor(melt$ProDivTrtType, levels=c("Monocultures", "Polycultures"))

melt$variable <- ifelse(melt$variable=="ProBiomass2", paste("Macroalgal wet mass (g)"), paste(melt$variable))
melt$variable <- ifelse(melt$variable=="ConAbund", paste("Invertebrate abundance (#)"), paste(melt$variable))
melt$variable <- ifelse(melt$variable=="ConBiomass", paste("Invertebrate biomass (g)"), paste(melt$variable))
melt$variable <- ifelse(melt$variable=="ConDivRich", paste("Invertebrate richness (# of taxa)"), paste(melt$variable))
melt$variable <- factor(melt$variable, levels=c("Invertebrate abundance (#)",  "Invertebrate biomass (g)", "Invertebrate richness (# of taxa)", "Macroalgal wet mass (g)"))

# select the most resolved data from the final 4 weeks of the experiment
melt <- subset(melt, Week > 8)
str(melt)

# remove samples that were not returned (i.e., where no algal mass was recovered) and are thus not informative
melt <- subset(melt, ProBiomass > 0)
str(melt)

# calculate time averaged mean of each treatment
melt.summary <- melt %>% # the names of the new data frame and the data frame to be summarised
  group_by(Block, ProDivTrtType, ProDivTrtRich, ProDivTrtID, variable) %>%   # the grouping variable
  summarise(mean = mean(value),  # calculates the mean of each group
            sd = sd(value), # calculates the standard deviation of each group
            n = n(),  # calculates the sample size per group
            se = sd(value)/sqrt(n())) # calculates the standard error of each group
melt.summary
str(melt.summary)
melt.summary <- as.data.frame(melt.summary)

melt.summary$variable <- factor(melt.summary$variable, levels = c("Invertebrate abundance (#)",  "Invertebrate biomass (g)", "Invertebrate richness (# of taxa)", "Macroalgal wet mass (g)"))

# perform one-way anovas for each response variable and stuff it into a data frame with pretty labels for plotting
library(plyr)
fits <- dlply(melt.summary, .(variable), function(x) lm(mean ~ ProDivTrtID, data=x))
labs <- data.frame(variable=levels(melt.summary$variable),
   DFnum=round(sapply(fits, function(x) anova(x)[1,1]), 0),
   DFdnm=round(sapply(fits, function(x) anova(x)[2,1]), 0),
   SSnum=round(sapply(fits, function(x) anova(x)[1,2]), 3),
   SSdnm=round(sapply(fits, function(x) anova(x)[2,2]), 3),
   MSnum=round(sapply(fits, function(x) anova(x)[1,3]), 3),
   MSdnm=round(sapply(fits, function(x) anova(x)[2,3]), 3),
   f=round(sapply(fits, function(x) anova(x)[1,4]), 2),
	p=sapply(fits, function(x) anova(x)[1,5]), 
   panel=paste(letters[1:4]),
   ProDivTrtType=Inf, 
   ProDivTrtID=Inf,
	mean=-Inf)
labs$fvalue <-with(labs, paste("==", f, sep=""))
labs$pvalue <- with(labs, paste("==", p, sep=""))
#labs$DF <- with(labs, paste(DFnum, , ',', DFdnm, sep=""))
labs$pvalue <- ifelse(labs$p<=0.05, paste("<0.05"), labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.01, "<0.01", labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.001, "<0.001", labs$pvalue)
labs$lab <- with(labs, paste("italic(F)", "[", DFnum, "*", "','", "*", DFdnm, "]", fvalue, "*", "','", "~~ italic(P)", pvalue, sep=""))
labs$panel2 <- with(labs, paste("(",panel, ")", sep=""))
labs$transform <- "none"

# save stats in data frame for later use and examination
stats <- as.data.frame(labs)
stats

# plot it
pAll <- ggplot(aes(x=ProDivTrtID, y=mean), data = melt.summary) +
   facet_wrap(~factor(variable, levels=c("Invertebrate abundance (#)",  "Invertebrate biomass (g)", "Invertebrate richness (# of taxa)", "Macroalgal wet mass (g)")), scales = "free_y", ncol=1, strip.position="left") +
   #facet_wrap(~variable, scales = "free_y", ncol=1, strip.position="left") +
   geom_boxplot(alpha=0.5, colour="grey85", aes(group=ProDivTrtType)) + 
   #geom_boxplot(width=0.5, aes(fill=ProDivTrtID), position=position_dodge(0.75), outlier.shape = NA) +
   geom_boxplot(width=0.5, aes(fill=ProDivTrtID), position=position_dodge(0.5), outlier.shape=NA) +
   geom_point(pch=21, position = position_jitterdodge(0.5), aes(fill=ProDivTrtID)) +
   theme_article(base_size=8) +
   labs(fill="Treatment") +
   theme(
      legend.position="none",
      #axis.text.x = element_text(angle=45, hjust=1, vjust=0.4, face=c( "italic", "italic", "italic", "italic", "plain", "plain", "plain")), 
      axis.text.x = element_text(angle=45, hjust=1, vjust=1, face=c( "italic", "italic", "italic", "italic", "plain", "plain", "plain")), 
      #axis.text = element_text(color="black"),
      #panel.grid=element_blank(), 
      #panel.border = element_rect(color=NA),
      aspect.ratio=0.6,
      #axis.line.x = element_line(color = "black", size=1),
      axis.title=element_blank(),
      #strip.background = element_blank(),
      strip.placement = "outside"
      )
     # legend.position = "none",
   #theme(strip.text = element_text(size=rel(0.8), margin=unit(c(3, 3, 3, 3), "pt")), strip.background = element_rect(fill="grey85"))
pAll <- pAll + 
   geom_text(aes(label=lab), data=labs, parse=T, vjust=-0.75, hjust=1.1, size=1.75) +
   geom_text(aes(label=panel2, x=-Inf, y=Inf), data=labs, fontface="bold", vjust=1.75, hjust=-0.5, size=2.5)
   #vjust=2, hjust=1.25, parse=T, size=1.8)
   #lab(x="Macroalgal diversity treatment")
   #theme(aspect.ratio=1)
   #ylab(paste(eval(plot.name)))
print(pAll)
ggsave(pAll, file="./figures-and-tables/Figure_2. Effects on secondary production.pdf", dpi=1200, height=6, width=3.22)


# perform log, natural log, and sqrt transforms of means used in the above plot
summary <- melt.summary[,c(1:6)]
colnames(summary)
summary$log10p1 <- log10(summary$mean+1)
summary$lnp1 <- log1p(summary$mean)
summary$sqrt <- sqrt(summary$mean)
summary

# melt transformed data for histograms
sm <- melt(summary, id=c("Block", "ProDivTrtType", "ProDivTrtRich", "ProDivTrtID", "variable"))
colnames(sm)[6] <- "trans"
str(sm)

# plot histograms to compare distributions of transformed and untransformed responses
histograms <- 
   ggplot(data=sm, aes(x=value, y=..density..)) +
   geom_density(alpha=0.1) +
   geom_histogram(position="identity", alpha=0.4) + 
   #geom_histogram() + 
   #geom_vline(data=melt.ied.mu, aes(xintercept=grp.mean, color=time), linetype="dashed") +
   #labs(title="\n histograms.ied.cleaned.derived") +
   facet_wrap(variable~trans, scales="free", ncol=4) +
   theme_bw(base_size=10) +
   theme(panel.grid.minor=element_blank())
print(histograms)
ggsave(histograms, file="./output/histograms-of-consumer-response-distributions.pdf", dpi=1200, height=8, width=10.5)

# hereafter are repeats of a code segment used above that performs one-way anovas for each transformed response variable and stuff them into a data frame

# transform = log10(mean+1)
fits <- dlply(melt.summary, .(variable), function(x) lm(log10(mean+1) ~ ProDivTrtID, data=x))
labs <- data.frame(variable=levels(melt.summary$variable),
   DFnum=round(sapply(fits, function(x) anova(x)[1,1]), 0),
   DFdnm=round(sapply(fits, function(x) anova(x)[2,1]), 0),
   SSnum=round(sapply(fits, function(x) anova(x)[1,2]), 3),
   SSdnm=round(sapply(fits, function(x) anova(x)[2,2]), 3),
   MSnum=round(sapply(fits, function(x) anova(x)[1,3]), 3),
   MSdnm=round(sapply(fits, function(x) anova(x)[2,3]), 3),
   f=round(sapply(fits, function(x) anova(x)[1,4]), 2),
	p=sapply(fits, function(x) anova(x)[1,5]), 
   panel=paste(letters[1:4]),
   ProDivTrtType=Inf, 
   ProDivTrtID=Inf,
	mean=-Inf)
labs$fvalue <- with(labs, paste("==", f, sep=""))
labs$pvalue <- with(labs, paste("==", p, sep=""))
labs$pvalue <- ifelse(labs$p<=0.05, paste("<0.05"), labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.01, "<0.01", labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.001, "<0.001", labs$pvalue)
labs$lab <- with(labs, paste("italic(F)", "[", DFnum, "*", "','", "*", DFdnm, "]", fvalue, "*", "','", "~~ italic(P)", pvalue, sep=""))
labs$transform <- "log10(x+1)"
stats <- as.data.frame(rbind(stats, labs))
stats

# transform = natural log = log1p(mean)
fits <- dlply(melt.summary, .(variable), function(x) lm(log1p(mean) ~ ProDivTrtID, data=x))
labs <- data.frame(variable=levels(melt.summary$variable),
   DFnum=round(sapply(fits, function(x) anova(x)[1,1]), 0),
   DFdnm=round(sapply(fits, function(x) anova(x)[2,1]), 0),
   SSnum=round(sapply(fits, function(x) anova(x)[1,2]), 3),
   SSdnm=round(sapply(fits, function(x) anova(x)[2,2]), 3),
   MSnum=round(sapply(fits, function(x) anova(x)[1,3]), 3),
   MSdnm=round(sapply(fits, function(x) anova(x)[2,3]), 3),
   f=round(sapply(fits, function(x) anova(x)[1,4]), 2),
	p=sapply(fits, function(x) anova(x)[1,5]), 
   panel=paste(letters[1:4]),
   ProDivTrtType=Inf, 
   ProDivTrtID=Inf,
	mean=-Inf)
labs$fvalue <- with(labs, paste("==", f, sep=""))
labs$pvalue <- with(labs, paste("==", p, sep=""))
labs$pvalue <- ifelse(labs$p<=0.05, paste("<0.05"), labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.01, "<0.01", labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.001, "<0.001", labs$pvalue)
labs$lab <- with(labs, paste("italic(F)", "[", DFnum, "*", "','", "*", DFdnm, "]", fvalue, "*", "','", "~~ italic(P)", pvalue, sep=""))
labs$transform <- "ln(x+1)"
stats <- as.data.frame(rbind(stats, labs))
stats

# transform = sqrt(mean)
fits <- dlply(melt.summary, .(variable), function(x) lm(sqrt(mean) ~ ProDivTrtID, data=x))
labs <- data.frame(variable=levels(melt.summary$variable),
   DFnum=round(sapply(fits, function(x) anova(x)[1,1]), 0),
   DFdnm=round(sapply(fits, function(x) anova(x)[2,1]), 0),
   SSnum=round(sapply(fits, function(x) anova(x)[1,2]), 3),
   SSdnm=round(sapply(fits, function(x) anova(x)[2,2]), 3),
   MSnum=round(sapply(fits, function(x) anova(x)[1,3]), 3),
   MSdnm=round(sapply(fits, function(x) anova(x)[2,3]), 3),
   f=round(sapply(fits, function(x) anova(x)[1,4]), 2),
	p=sapply(fits, function(x) anova(x)[1,5]),
   panel=paste(letters[1:4]),
   ProDivTrtType=Inf, 
   ProDivTrtID=Inf,
	mean=-Inf)
labs$fvalue <- with(labs, paste("==", f, sep=""))
labs$pvalue <- with(labs, paste("==", p, sep=""))
labs$pvalue <- ifelse(labs$p<=0.05, paste("<0.05"), labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.01, "<0.01", labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.001, "<0.001", labs$pvalue)
labs$lab <- with(labs, paste("italic(F)", "[", DFnum, "*", "','", "*", DFdnm, "]", fvalue, "*", "','", "~~ italic(P)", pvalue, sep=""))
labs$transform <- "sqrt"
stats <- as.data.frame(rbind(stats, labs))
stats

# save stats as .csv for comparison
write.csv(stats, "./output/anova-summary-table-for-effects-on-consumer-responses.csv")

# tukeys hsd for consumer responses

# subset by respnse variable
ca <- subset(melt.summary, variable == "Invertebrate abundance (#)")
cb <- subset(melt.summary, variable == "Invertebrate biomass (g)")
cr <- subset(melt.summary, variable == "Invertebrate richness (# of taxa)")
pb <- subset(melt.summary, variable == "Macroalgal wet mass (g)")

# perform tukeysHSD
tca <- TukeyHSD(aov(mean ~ ProDivTrtID, data=ca))
tcb <- TukeyHSD(aov(mean ~ ProDivTrtID, data=cb))
tcr <- TukeyHSD(aov(mean ~ ProDivTrtID, data=cr))
tpb <- TukeyHSD(aov(mean ~ ProDivTrtID, data=pb))
str(tca)
tca$ProDivTrtID[[1:21]]

# reorganize and combine data
t1 <- as.data.frame(tca$ProDivTrtID)
t1$response <- "Invertebrate abundance"
t2 <- as.data.frame(tcb$ProDivTrtID)
t2$response <- "Invertebrate biomass"
t3 <- as.data.frame(tcr$ProDivTrtID)
t3$response <- "Invertebrate richness"
t4 <- as.data.frame(tpb$ProDivTrtID)
t4$response <- "Macroalgal wet mass"
t <- as.data.frame(rbind(t1, t2, t3, t4))
t$pair <- rep(dimnames(tca$ProDivTrtID)[[1]], 4)
t <- t[, c("response", "pair", "diff", "lwr", "upr", "p adj")]
rownames(t) <- NULL
t$diff <- round(t$diff, 3)
t$lwr <- round(t$lwr, 3)
t$upr <- round(t$upr, 3)
t$"p adj" <- round(t$"p adj", 3)
t

# save Tukeys as .csv for comparison
write.csv(t, "./figures-and-tables/Table_S1. TukeysHSD for effects on consumer responses.csv")