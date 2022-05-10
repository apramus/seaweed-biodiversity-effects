# clear field, load/detach packages
rm(list=ls(all.names=T))
library(ecodist)
library(vegan)
library(MASS)
library(ggplot2)
library(egg)

# load data and organize factors
data <- read.csv("./0-ramus-thesis-data-cleaned.csv")
data$ProDivTrtID <- factor(data$ProDivTrtID, levels=c("Cf", "Gt", "Gv", "Gg", "NM", "IM", "CM"))

# give factors pretty names for plots
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="Cf", paste("Codium fragile"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="Gt", paste("Gracilaria tikvahiae"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="Gv", paste("Gracilaria vermiculophylla"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="Gg", paste("Gymnogongrus griffithsiae"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="NM", paste("3 species native"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="IM", paste("3 species nonnative"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="CM", paste("4 species"), paste(data$ProDivTrtID))
data$ProDivTrtID <- factor(data$ProDivTrtID, levels=c("Codium fragile", "Gracilaria tikvahiae", "Gracilaria vermiculophylla", "Gymnogongrus griffithsiae", "3 species native", "3 species nonnative", "4 species"))

# subset for sums
sum <- subset(data, Data=="Sum")

# select the most resolved data from the final 4 weeks of the experiment
sum <- subset(sum, Week > 8)
sum

# permanova for all 7 treatments
set.seed(3)
p1 <- aggregate(sum, by=list(sum$ProDivTrtID, sum$Block, sum$ProDivTrtType), mean, na.rm=T)
colnames(p1)[1:3]<-c("trt", "blk", "culture")
colnames(p1)
p11 <- p1[rowSums(p1[,21:32])!=0,]
p12.md <- vegdist(p11[,21:32])
test <- simper(p11[,21:32], p11$trt)
permanova <- adonis(p12.md~p11$trt)
permanova

# perform nmds
nms.final <- nmds(p12.md, mindim = 2, maxdim = 3, nits =  50)  # prepare to sit back and wait...
nm1 <- nmds.min(nms.final)
nm1$trt <- p11$trt

# write output as .csv file
all <- as.data.frame(nm1)
write.csv(all, "./derived-data/nmds-of-invertebrate-community-composition.csv")

# extract stat info for plot
str(permanova)
str(nm1)
stats <- data.frame(
   DFnum=permanova$aov.tab$Df[1],
   DFdnm=permanova$aov.tab$Df[2],
   DFtot=permanova$aov.tab$Df[3],
   SSnum=round(permanova$aov.tab$SumsOfSqs[1],3),
   SSdnm=round(permanova$aov.tab$SumsOfSqs[2],3),
   SStot=round(permanova$aov.tab$SumsOfSqs[3],3),
   MSnum=round(permanova$aov.tab$MeanSqs[1],3),
   MSdnm=round(permanova$aov.tab$MeanSqs[2],3),
   f=round(permanova$aov.tab$F.Model[1],2),
   r2num=round(permanova$aov.tab$R2[1],2),
   r2dnm=round(permanova$aov.tab$R2[2],2),
   r2tot=round(permanova$aov.tab$R2[3],2),
   p=permanova$aov.tab$'Pr(>F)'[1],
   stress=round(attributes(nm1)$stress, 2),
   minr2=round(attributes(nm1)$r2, 2)
)
stats$fvalue <-with(stats, paste("==", f, sep=""))
stats$pvalue <- with(stats, paste("==", p, sep=""))
stats$r2 <- with(stats, paste("==", minr2, sep=""))
stats$stress <- with(stats, paste("==", stress, sep=""))
stats$pvalue <- ifelse(stats$p<=0.001, "<0.001", stats$pvalue)
stats$lab <- with(stats, paste("italic(F)", "[", DFnum, "*", "','", "*", DFdnm, "]", fvalue, "*", "','", "~~ italic(P)", pvalue, "*", "','", "~~ italic(R)^2", r2, "*", "','", "~~ stress", stress, sep=""))
stats

# write stat info to csv
write.csv(stats, "./results-summary-tables/PERMANOVA.csv")

# create experession list of names for pretty legend
names <- expression(italic(paste("Codium fragile")), italic(paste("Gracilaria tikvahiae")), italic(paste("Gracilaria vermiculopylla")), italic(paste("Gymnogongrus griffithsiae")), "3 species native", "3 species nonnative", "4 species")

# calculate convex hulls
detach(package:plyr)
library(dplyr)
hull_trt <- all %>%
  group_by(trt) %>%
  slice(chull(X1, X2))

# create nmds plot
nmds1 <- ggplot(all, aes(X1, X2)) +
   coord_fixed() +
   theme_classic(base_size=8) + 
   labs(x="NMDS1", y="NMDS2") +
   guides(fill=F) +
   geom_polygon(aes(fill=trt), data = hull_trt, alpha = 0.4) +
   geom_jitter(aes(color=trt), alpha=0.6, width=0.002, height=0.002, size=2) +
   scale_color_manual(values=c("#F8766D", "#C49A00", "#53B400", "#00C094", "#00B6EB", "#A58AFF", "#FB61D7"), labels = names, name="Treatment") +
   scale_fill_manual(
      values=c("#F8766D", "#C49A00", "#53B400", "#00C094", "#00B6EB", "#A58AFF", "#FB61D7"), 
      labels = names, name="Treatment") +
   geom_text(data=stats, aes(label=lab), parse=T, x=-Inf, y=-Inf, vjust=-0.5, hjust=-0.05, size=1.75) +
   theme(
      aspect.ratio=1, 
      legend.position = c(0.75,0.545),
      legend.text = element_text(hjust=0), 
      legend.key = element_blank(),
      legend.title=element_blank(),
      legend.key.height = unit(0.8, "lines"),
      axis.text.y=element_text(angle=90, hjust=0.5),
      axis.text=element_text(colour="black")
   )

nmds1
ggsave(nmds1, file="./figures/Figure_3.pdf", height=3, width=3, dpi=1200)

tiff(filename="./figures/Figure_3.tif", height=3*800, width=3*800, units="px", res=800, compression="lzw")
print(nmds1)
dev.off()


##### planned contrasts (pairwise betweem treatments) #####

# create data frame to stuff information in
pairs <- NULL
pairs <- data.frame(contrast=c(
   "Gracilaria tikvahiae - Codium fragile",
   "Gracilaria vermiculophylla - Codium fragile",
   "Gymnogongrus griffithsiae - Codium fragile",
   "3 species native - Codium fragile",
   "3 species nonnative - Codium fragile",
   "4 species - Codium fragile",
   "Gracilaria vermiculophylla - Gracilaria tikvahiae",
   "Gymnogongrus griffithsiae - Gracilaria tikvahiae",
   "3 species native -Gracilaria tikvahiae",
   "3 species nonnative - Gracilaria tikvahiae",
   "4 species - Gracilaria tikvahiae",
   "Gymnogongrus griffithsiae - Gracilaria vermiculophylla",
   "3 species native - Gracilaria vermiculophylla",
   "3 species nonnative - Gracilaria vermiculophylla",
   "4 species - Gracilaria vermiculophylla",
   "3 species native - Gymnogongrus griffithsiae",
   "3 species nonnative - Gymnogongrus griffithsiae",
   "4 species - Gymnogongrus griffithsiae",
   "3 species nonnative -  3 species native",
   "4 species - 3 species native",
   "4 species - 3 species nonnative"
   ), f.model=0, r2=0, p.value=0)
 
### Cf vs. ###

# Gt
contr.mine<- function (...) cbind(c(1, -1, 0, 0, 0, 0,0))
x1 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[1] <- x1$aov.tab$F.Model[1]
pairs$r2[1] <- x1$aov.tab$R2[1]
pairs$p.value[1] <- x1$aov.tab$'Pr(>F)'[1]

# Gv
contr.mine<- function (...) cbind(c(1,0, -1,  0, 0, 0,0))
x2 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[2] <- x2$aov.tab$F.Model[1]
pairs$r2[2] <- x2$aov.tab$R2[1]
pairs$p.value[2] <- x2$aov.tab$'Pr(>F)'[1]

# Gg
contr.mine<- function (...) cbind(c(1,0, 0,  -1, 0, 0,0))
x3 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[3] <- x3$aov.tab$F.Model[1]
pairs$r2[3] <- x3$aov.tab$R2[1]
pairs$p.value[3] <- x3$aov.tab$'Pr(>F)'[1]

# 3 species native
contr.mine<- function (...) cbind(c(1,0, 0,  0, -1, 0,0))
x4 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[4] <- x4$aov.tab$F.Model[1]
pairs$r2[4] <- x4$aov.tab$R2[1]
pairs$p.value[4] <- x4$aov.tab$'Pr(>F)'[1]

# 3 species invasive
contr.mine<- function (...) cbind(c(1,0, 0,  0, 0, -1,0))
x5 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[5] <- x5$aov.tab$F.Model[1]
pairs$r2[5] <- x5$aov.tab$R2[1]
pairs$p.value[5] <- x5$aov.tab$'Pr(>F)'[1]

# 4 species
contr.mine<- function (...) cbind(c(1,0, 0,  0, 0, 0,-1))
x6 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[6] <- x6$aov.tab$F.Model[1]
pairs$r2[6] <- x6$aov.tab$R2[1]
pairs$p.value[6] <- x6$aov.tab$'Pr(>F)'[1]

# looks like Cf differs from everything

### Gt vs. ###

# Gv
contr.mine<- function (...) cbind(c(0,1, -1,  0, 0, 0,0))
x7 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[7] <- x7$aov.tab$F.Model[1]
pairs$r2[7] <- x7$aov.tab$R2[1]
pairs$p.value[7] <- x7$aov.tab$'Pr(>F)'[1]

# Gg
contr.mine<- function (...) cbind(c(0,1, 0,  -1, 0, 0,0))
x8 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[8] <- x8$aov.tab$F.Model[1]
pairs$r2[8] <- x8$aov.tab$R2[1]
pairs$p.value[8] <- x8$aov.tab$'Pr(>F)'[1]

# 3 species native
contr.mine<- function (...) cbind(c(0,1, 0,  0, -1, 0,0))
x9 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[9] <- x9$aov.tab$F.Model[1]
pairs$r2[9] <- x9$aov.tab$R2[1]
pairs$p.value[9] <- x9$aov.tab$'Pr(>F)'[1]

# 3 species invasive
contr.mine<- function (...) cbind(c(0,1, 0,  0, 0, -1,0))
x10 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[10] <- x10$aov.tab$F.Model[1]
pairs$r2[10] <- x10$aov.tab$R2[1]
pairs$p.value[10] <- x10$aov.tab$'Pr(>F)'[1]

# 4 species
contr.mine<- function (...) cbind(c(0,1, 0,  0, 0, 0,-1))
x11 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[11] <- x11$aov.tab$F.Model[1]
pairs$r2[11] <- x11$aov.tab$R2[1]
pairs$p.value[11] <- x11$aov.tab$'Pr(>F)'[1]

# looks like Gt does not differ from Gv, but that it does differ from the rest

### Gv vs. ###

# Gg
contr.mine<- function (...) cbind(c(0,0, 1,  -1, 0, 0))
x12 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[12] <- x12$aov.tab$F.Model[1]
pairs$r2[12] <- x12$aov.tab$R2[1]
pairs$p.value[12] <- x12$aov.tab$'Pr(>F)'[1]

# 3 species native
contr.mine<- function (...) cbind(c(0,0, 1,  0, -1, 0))
x13 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[13] <- x13$aov.tab$F.Model[1]
pairs$r2[13] <- x13$aov.tab$R2[1]
pairs$p.value[13] <- x13$aov.tab$'Pr(>F)'[1]

# 3 species invasive
contr.mine<- function (...) cbind(c(0,0, 1,  0, 0, -1, 0))
x14 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[14] <- x14$aov.tab$F.Model[1]
pairs$r2[14] <- x14$aov.tab$R2[1]
pairs$p.value[14] <- x14$aov.tab$'Pr(>F)'[1]

# 4 species 
contr.mine<- function (...) cbind(c(0,0, 1,  0, 0, 0,-1))
x15 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[15] <- x15$aov.tab$F.Model[1]
pairs$r2[15] <- x15$aov.tab$R2[1]
pairs$p.value[15] <- x15$aov.tab$'Pr(>F)'[1]

# looks like Gv does not differ from either Gg, 3 species native, 3 species invasive, or all 4 species

### Gg vs. ###

# 3 species native
contr.mine<- function (...) cbind(c(0,0, 0,  1, -1, 0))
x16 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[16] <- x16$aov.tab$F.Model[1]
pairs$r2[16] <- x16$aov.tab$R2[1]
pairs$p.value[16] <- x16$aov.tab$'Pr(>F)'[1]

# 3 species invasive
contr.mine<- function (...) cbind(c(0,0, 0,  1, 0, -1, 0))
x17 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[17] <- x17$aov.tab$F.Model[1]
pairs$r2[17] <- x17$aov.tab$R2[1]
pairs$p.value[17] <- x17$aov.tab$'Pr(>F)'[1]

# 4 species
contr.mine<- function (...) cbind(c(0,0, 0,  1, 0, 0,-1))
x18 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[18] <- x18$aov.tab$F.Model[1]
pairs$r2[18] <- x18$aov.tab$R2[1]
pairs$p.value[18] <- x18$aov.tab$'Pr(>F)'[1]

# looks like Gg does not differ from either 3 species native, 3 species invasive, or 4 species

### 3 species native vs. ###

# 3 species invasive
contr.mine<- function (...) cbind(c(0,0, 0,  0, 1, -1, 0))
x19 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[19] <- x19$aov.tab$F.Model[1]
pairs$r2[19] <- x19$aov.tab$R2[1]
pairs$p.value[19] <- x19$aov.tab$'Pr(>F)'[1]

# 4 species
contr.mine<- function (...) cbind(c(0,0, 0,  0, 1, 0,-1))
x20 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[20] <- x20$aov.tab$F.Model[1]
pairs$r2[20] <- x20$aov.tab$R2[1]
pairs$p.value[20] <- x20$aov.tab$'Pr(>F)'[1]

# looks like 3 species native does not differ from either 3 species invasive or 4 species

### 3 species invasive vs. ###

# 4 species
contr.mine<- function (...) cbind(c(0,0, 0,  0, 0, 1,-1))
x21 <- adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")
pairs$f.model[21] <- x21$aov.tab$F.Model[1]
pairs$r2[21] <- x21$aov.tab$R2[1]
pairs$p.value[21] <- x21$aov.tab$'Pr(>F)'[1]

# looks like 3 species invasive does not differ from 4 species
pairs$f.model <- round(pairs$f.model, 2)
pairs$r2 <- round(pairs$r2, 2)
pairs
colnames(pairs) <- c("Contrast", "F-Value", "R2", "P-Value")
pairs$sig <- ifelse(pairs$"P-Value"<0.05, paste("*"), paste(""))


# write to csv
write.csv(pairs, "./results-summary-tables/Table-S2.csv")

