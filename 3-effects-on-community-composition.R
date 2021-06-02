# clear field, load/detach packages
rm(list=ls(all.names=T))
#library(rgl)
#library(lattice)
#library(scatterplot3d)
#library(BiodiversityR)
#library(ellipse)
library(ecodist)
library(vegan)
library(MASS)
library(ggplot2)
library(egg)

# load data and organize factors
data <- read.csv("./1-ramus-thesis-data-cleaned.csv")
data$ProDivTrtID <- factor(data$ProDivTrtID, levels=c("Cf", "Gt", "Gv", "Gg", "NM", "IM", "CM"))

# give factors pretty names for plots
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="Cf", paste("Codium fragile"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="Gt", paste("Gracilaria tikvahiae"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="Gv", paste("Gracilaria vermiculophylla"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="Gg", paste("Gymnogongrus griffithsiae"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="NM", paste("3 species native"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="IM", paste("3 species invasive"), paste(data$ProDivTrtID))
data$ProDivTrtID <- ifelse(data$ProDivTrtID=="CM", paste("4 species"), paste(data$ProDivTrtID))
data$ProDivTrtID <- factor(data$ProDivTrtID, levels=c("Codium fragile", "Gracilaria tikvahiae", "Gracilaria vermiculophylla", "Gymnogongrus griffithsiae", "3 species native", "3 species invasive", "4 species"))

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
write.csv(all, "./derived-data/nmds-of-consumer-composition.csv")

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
write.csv(stats, "./derived-data/permanova-summary-table.csv")

# create experession list of names for pretty legend
names <- expression(italic(paste("Codium fragile")), italic(paste("Gracilaria tikvahiae")), italic(paste("Gracilaria vermiculopylla")), italic(paste("Gymnogongrus griffithsiae")), "3 species native", "3 species invasive", "4 species")

# calculate convex hulls
detach(package:plyr)
library(dplyr)
hull_trt <- all %>%
  group_by(trt) %>%
  slice(chull(X1, X2))

# create nmds plot
nmds1 <- ggplot(all, aes(X1, X2)) +
   coord_fixed() +
   theme_article(base_size=8) + 
   labs(x="NMDS1", y="NMDS2") +
   guides(fill=F) +
   geom_polygon(aes(fill=trt), data = hull_trt, alpha = 0.4) +
   #stat_ellipse(aes(fill=trt), alpha=0.25, level=0.75, geom="polygon") +
   #geom_hull(aes(fill=trt), alpha=0.5) +
   #geom_point(aes(color=trt)) +
   #geom_point(aes(fill=trt, color=trt)) +
   #geom_jitter(aes(fill=trt, shape=trt), width=0.002, height=0.002) +
   geom_jitter(aes(color=trt), alpha=0.6, width=0.002, height=0.002, size=2) +
   #scale_shape_manual(values=c(23, 21, 22, 24, 21, 22, 25), labels = names) +
   #scale_shape_manual(values=c(21, 22, 23, 24, 25, 21, 22)) +
   scale_color_manual(values=c("#F8766D", "#C49A00", "#53B400", "#00C094", "#00B6EB", "#A58AFF", "#FB61D7"), labels = names, name="Treatment") +
   #scale_color_manual(name="Treatment", values=rainbow(7)) +
   scale_fill_manual(
      values=c("#F8766D", "#C49A00", "#53B400", "#00C094", "#00B6EB", "#A58AFF", "#FB61D7"), 
      labels = names, name="Treatment") +
   #scale_fill_manual(name="Treatment", values=rainbow(7)) +
   geom_text(data=stats, aes(label=lab), parse=T, x=-Inf, y=-Inf, vjust=-0.5, hjust=-0.05, size=2) +
   #geom_text(data=stats, aes(label=lab), parse=T, x=Inf, y=Inf, vjust=2, hjust=1.05, size=2) +
   theme(
      aspect.ratio=1, 
      #legend.position = c(0.7,0.545),
      legend.position = c(0.75,0.545),
      legend.text = element_text(hjust=0), 
      legend.key = element_blank(),
      #legend.title=element_text(hjust=0.5)
      legend.title=element_blank()
      #panel.background=element_rect(fill="grey99"), 
      #panel.grid=element_blank(),
      #panel.grid=element_line(color="gray80"),
      #legend.key.size=unit(0.5, "lines"), 
      #legend.background = element_rect(fill=NA), 
      #legend.title=element_text(size=rel(0.9)) 
      #axis.ticks.length = unit(-0.05, "cm"),
      #axis.text.y=element_text(hjust=0.1)
      #legend.border=element_line(color="black"))
      #guides(color=guide_legend(title="Species")) 
   )
nmds1
ggsave(nmds1, file="./figures/figure-2-nmds-effects-on-consumer-composition.jpg", height=3.5, width=3.5, dpi=1200)

##### planned contrasts (pairwise betweem treatments) #####

### Cf vs. ###

# Gt
contr.mine<- function (...) cbind(c(1, -1, 0, 0, 0, 0,0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# Gv
contr.mine<- function (...) cbind(c(1,0, -1,  0, 0, 0,0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# Gg
contr.mine<- function (...) cbind(c(1,0, 0,  -1, 0, 0,0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 3 species native
contr.mine<- function (...) cbind(c(1,0, 0,  0, -1, 0,0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 3 species invasive
contr.mine<- function (...) cbind(c(1,0, 0,  0, 0, -1,0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 4 species
contr.mine<- function (...) cbind(c(1,0, 0,  0, 0, 0,-1))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# looks like Cf differs from everything

### Gt vs. ###

# Gv
contr.mine<- function (...) cbind(c(0,1, -1,  0, 0, 0,0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# Gg
contr.mine<- function (...) cbind(c(0,1, 0,  -1, 0, 0,0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 3 species native
contr.mine<- function (...) cbind(c(0,1, 0,  0, -1, 0,0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 3 species invasive
contr.mine<- function (...) cbind(c(0,1, 0,  0, 0, -1,0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 4 species
contr.mine<- function (...) cbind(c(0,1, 0,  0, 0, 0,-1))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# looks like Gt does not differ from Gv, but that it does differ from the rest

### Gv vs. ###

# Gg
contr.mine<- function (...) cbind(c(0,0, 1,  -1, 0, 0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 3 species native
contr.mine<- function (...) cbind(c(0,0, 1,  0, -1, 0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 3 species invasive
contr.mine<- function (...) cbind(c(0,0, 1,  0, 0, -1, 0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 4 species 
contr.mine<- function (...) cbind(c(0,0, 1,  0, 0, 0,-1))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# looks like Gv does not differ from either Gg, 3 species native, 3 species invasive, or all 4 species

### Gg vs. ###

# 3 species native
contr.mine<- function (...) cbind(c(0,0, 0,  1, -1, 0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 3 species invasive
contr.mine<- function (...) cbind(c(0,0, 0,  1, 0, -1, 0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 4 species
contr.mine<- function (...) cbind(c(0,0, 0,  1, 0, 0,-1))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# looks like Gg does not differ from either 3 species native, 3 species invasive, or 4 species

### 3 species native vs. ###

# 3 species invasive
contr.mine<- function (...) cbind(c(0,0, 0,  0, 1, -1, 0))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# 4 species
contr.mine<- function (...) cbind(c(0,0, 0,  0, 1, 0,-1))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# looks like 3 species native does not differ from either 3 species invasive or 4 species

### 3 species invasive vs. ###

# 4 species
contr.mine<- function (...) cbind(c(0,0, 0,  0, 0, 1,-1))
adonis(p12.md~p11$trt, permutations = 99, contr.unordered= "contr.mine")

# looks like 3 species invasive does not differ from 4 species
