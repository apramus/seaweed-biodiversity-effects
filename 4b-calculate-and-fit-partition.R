# selects vars, subset and and reogranize data
df <- sdf0[,c("ProDivTrtType", "ProDivTrtID", "Species", "Block", "Rep", paste(response.id))]
colnames(df)<-c("type", "trt", "species", "num", "rep", "value")
tpp <- subset(df, species != "All")
str(tpp)
monos <- subset(tpp, type=="Mono")

### 1) Native polyculture #######################################################################

# 1.1 Native polyculture

# 1.1.1 Average monoculture yield of species i
Mi <- aggregate(x=monos$value, list(sp=monos$species), mean)
colnames(Mi) <- c("species", "value")	# column names of Mi

# 1.1.2 Average observed yield of species i in polyculture
Yoi <- subset(tpp, trt=="NM")

# 1.1.3 Merge average mono- and polyculture yields of species i
native <- merge(Mi, Yoi, by="species")

# 1.1.4 Observed relative yield of species i in polyculture
native$RYoi <- (native$value.y)/(native$value.x)

# 1.1.5 Initial abundance of species i in polyculture
native$RYei <- 1/3

# 1.1.6 Summation of RYoi by replciate
RYoi.tot <- aggregate(native$RYoi, list(rep=native$rep), sum)

# 1.1.7 Merge by replicate and rename columns
native <- merge(native, RYoi.tot, by="rep")
colnames(native) <- c("rep", "species", "Mi", "type", "trt", "num", "Yoi", "RYoi", "RYei", "RYoi.tot")

# 1.1.9 Calculate the difference between the observed and expected relative yields of species i
native$deltaRY <- (native$RYoi)-(native$RYei)

# 1.2 Native polyculture TIC

# 1.2.1 Average relative yield by replicate
avg.delta.RY <- aggregate(native$deltaRY, list(rep=native$rep), mean)

# 1.2.2 Average of monoculture yields by replicate
avg.M <- aggregate(native$Mi, list(rep=native$rep), mean)
	# what is happening here? should this be by species?
	
# 1.2.3 Merge by replicate and rename columns
TPP <- merge(avg.delta.RY, avg.M, by="rep")
colnames(TPP) <- c("rep", "avg.delta.RY", "avg.M")

# 1.2.4 Calculate TIC
TPP$tic <- (3*TPP$avg.delta.RY[]*TPP$avg.M[])

# 1.3 Native polyculture DOM

# 1.3.1 
native$dom.1=(native$RYoi/native$RYoi.tot)-native$RYei
	groupvariable2=as.factor(native[[1]])
	levels=levels(groupvariable2)
	numlevels=length(levels)
	variable1=native$Mi
	variable2=native$dom.1
	cov.dom=NULL
	for (i in 1:numlevels){
		covw=NULL
		leveli=levels[i]
		levelidata1=variable1[native[[1]]==leveli]
		levelidata2=variable2[native[[1]]==leveli]
		covw$rep=leveli
		covw$cov.dom=cov(levelidata1, levelidata2)
		covw$dom=3*covw$cov.dom
		cov.dom=rbind(cov.dom, covw)
	}

# 1.3.2
TPP <- as.data.frame(merge(TPP, as.data.frame(cov.dom), by="rep"))

# 1.4 Native polyculture TDC

# 1.4.1
native$tdc.1=native$RYoi-(native$RYoi/native$RYoi.tot)
  	groupvariable2=as.factor(native[[1]])
  	levels=levels(groupvariable2)
  	numlevels=length(levels)
  	variable1=native$Mi
  	variable2=native$tdc.1
  	cov.tdc=NULL
  	for (i in 1:numlevels){
  		covw=NULL
  		leveli=levels[i]
  		levelidata1=variable1[native[[1]]==leveli]
  		levelidata2=variable2[native[[1]]==leveli]
  		covw$rep=leveli
  		covw$cov.tdc=cov(levelidata1, levelidata2)
  		covw$tdc=3*covw$cov.tdc
  		cov.tdc=rbind(cov.tdc, covw)         
    }

# 1.4.2   
TPP <- as.data.frame(merge(TPP, as.data.frame(cov.tdc), by = "rep"))
TPP$trt <- "nat.mix"

# 1.4.3
end1 <- TPP





### 2) Invasive polyculture #####################################################################

# 2.1 Invasive polyculture

# 2.1.2 Average observed yield of species i in polyculture
Yoi <- subset(tpp, trt=="IM")

# 2.1.3 Merge average mono- and polyculture yields of species i
invasive <- merge(Mi, Yoi, by="species")

# 2.1.4 Observed relative yield of species i in polyculture
invasive$RYoi <- (invasive$value.y)/(invasive$value.x)

# 2.1.5 Initial abundance of species i in polyculture
invasive$RYei <- 1/3

# 2.1.6 Summation of RYoi by replciate
RYoi.tot <- aggregate(invasive$RYoi, list(rep=invasive$rep), sum)

# 2.1.7 Merge by replicate and rename columns
invasive <- merge(invasive, RYoi.tot, by="rep")
colnames(invasive) <- c("rep", "species", "Mi", "type", "trt", "num", "Yoi", "RYoi", "RYei", "RYoi.tot")

# 2.1.9 Calculate the difference between the observed and expected relative yields of species i
invasive$deltaRY <- (invasive$RYoi)-(invasive$RYei)

# 2.2 Invasive polyculture TIC

# 2.2.1 Average relative yield by replicate
avg.delta.RY <- aggregate(invasive$deltaRY, list(rep=invasive$rep), mean)

# 2.2.2 Average of monoculture yields by replicate
avg.M <- aggregate(invasive$Mi, list(rep=invasive$rep), mean)
	
# 2.2.3 Merge by replicate and rename columns
TPP <- merge(avg.delta.RY, avg.M, by="rep")
colnames(TPP) <- c("rep", "avg.delta.RY", "avg.M")

# 2.2.4 Calculate TIC
TPP$tic <- (3*TPP$avg.delta.RY[]*TPP$avg.M[])

# 2.3 Invasive polyculture DOM

# 2.3.1 
invasive$dom.1=(invasive$RYoi/invasive$RYoi.tot)-invasive$RYei
	groupvariable2=as.factor(invasive[[1]])
	levels=levels(groupvariable2)
	numlevels=length(levels)
	variable1=invasive$Mi
	variable2=invasive$dom.1
	cov.dom=NULL
	for (i in 1:numlevels){
		covw=NULL
		leveli=levels[i]
		levelidata1=variable1[invasive[[1]]==leveli]
		levelidata2=variable2[invasive[[1]]==leveli]
		covw$rep=leveli
		covw$cov.dom=cov(levelidata1, levelidata2)
		covw$dom=3*covw$cov.dom
		cov.dom=rbind(cov.dom, covw)
	}

# 2.3.2
TPP <- as.data.frame(merge(TPP, as.data.frame(cov.dom), by="rep"))

# 2.4 Invasive polyculture TDC

# 2.4.1
invasive$tdc.1=invasive$RYoi-(invasive$RYoi/invasive$RYoi.tot)
  	groupvariable2=as.factor(invasive[[1]])
  	levels=levels(groupvariable2)
  	numlevels=length(levels)
  	variable1=invasive$Mi
  	variable2=invasive$tdc.1
  	cov.tdc=NULL
  	for (i in 1:numlevels){
  		covw=NULL
  		leveli=levels[i]
  		levelidata1=variable1[invasive[[1]]==leveli]
  		levelidata2=variable2[invasive[[1]]==leveli]
  		covw$rep=leveli
  		covw$cov.tdc=cov(levelidata1, levelidata2)
  		covw$tdc=3*covw$cov.tdc
  		cov.tdc=rbind(cov.tdc, covw)         
    }

# 2.4.2   
TPP <- as.data.frame(merge(TPP, as.data.frame(cov.tdc), by = "rep"))
TPP$trt <- "inv.mix"

# 2.4.3
end2 <- rbind(end1, TPP)

### 3) Complete mixture #########################################################################

# 3.1 Complete mixture

# 3.1.2 Average observed yield of species i in polyculture
Yoi <- subset(tpp, trt=="CM")

# 3.1.3 Merge average mono- and polyculture yields of species i
complete <- merge(Mi, Yoi, by="species")

# 3.1.4 Observed relative yield of species i in polyculture
complete$RYoi <- (complete$value.y)/(complete$value.x)

# 3.1.5 Initial abundance of species i in polyculture
complete$RYei <- 1/4

# 3.1.6 Summation of RYoi by replciate
RYoi.tot <- aggregate(complete$RYoi, list(rep=complete$rep), sum)

# 3.1.7 Merge by replicate and rename columns
complete <- merge(complete, RYoi.tot, by="rep")
colnames(complete) <- c("rep", "species", "Mi", "type", "trt", "num", "Yoi", "RYoi", "RYei", "RYoi.tot")

# 3.1.9 Calculate the difference between the observed and expected relative yields of species i
complete$deltaRY <- (complete$RYoi)-(complete$RYei)

# 3.2 Complete mixture TIC

# 3.2.1 Average relative yield by replicate
avg.delta.RY <- aggregate(complete$deltaRY, list(rep=complete$rep), mean)

# 3.2.2 Average of monoculture yields by replicate
avg.M <- aggregate(complete$Mi, list(rep=complete$rep), mean)

# 3.2.3 Merge by replicate and rename columns
TPP <- merge(avg.delta.RY, avg.M, by="rep")
colnames(TPP) <- c("rep", "avg.delta.RY", "avg.M")

# 3.2.4 Calculate TIC
TPP$tic <- (4*TPP$avg.delta.RY[]*TPP$avg.M[])

# 3.3 Complete mixture DOM

# 3.3.1 
complete$dom.1=(complete$RYoi/complete$RYoi.tot)-complete$RYei
	groupvariable2=as.factor(complete[[1]])
	levels=levels(groupvariable2)
	numlevels=length(levels)
	variable1=complete$Mi
	variable2=complete$dom.1
	cov.dom=NULL
	for (i in 1:numlevels){
		covw=NULL
		leveli=levels[i]
		levelidata1=variable1[complete[[1]]==leveli]
		levelidata2=variable2[complete[[1]]==leveli]
		covw$rep=leveli
		covw$cov.dom=cov(levelidata1, levelidata2)
		covw$dom=4*covw$cov.dom
		cov.dom=rbind(cov.dom, covw)
	}

# 3.3.2
TPP <- as.data.frame(merge(TPP, as.data.frame(cov.dom), by="rep"))

# 3.4 Complete mixture TDC

# 3.4.1
complete$tdc.1=complete$RYoi-(complete$RYoi/complete$RYoi.tot)
  	groupvariable2=as.factor(complete[[1]])
  	levels=levels(groupvariable2)
  	numlevels=length(levels)
  	variable1=complete$Mi
  	variable2=complete$tdc.1
  	cov.tdc=NULL
  	for (i in 1:numlevels){
  		covw=NULL
  		leveli=levels[i]
  		levelidata1=variable1[complete[[1]]==leveli]
  		levelidata2=variable2[complete[[1]]==leveli]
  		covw$rep=leveli
  		covw$cov.tdc=cov(levelidata1, levelidata2)
  		covw$tdc=4*covw$cov.tdc
  		cov.tdc=rbind(cov.tdc, covw)         
    }

# 3.4.2   
TPP <- as.data.frame(merge(TPP, as.data.frame(cov.tdc), by = "rep"))
TPP$trt <- "comp.mix"

# 3.4.3
final <- rbind(end2, TPP)
final

#################################################################################################

# calculate selection, complementarity and net biodiversity effect
final$complementarity <- as.numeric(final$tic)
final$selection <- as.numeric(final$tdc)+as.numeric(final$dom)
final$net.bdef <- as.numeric(final$complementarity) + as.numeric(final$selection)

# perform sqrt transforms after Loreau & Hector 2001
final$complementarity.tran <- (abs(final$complementarity))^.5*abs(final$complementarity)/final$complementarity
final$selection.tran <- (abs(final$selection))^.5*abs(final$selection)/final$selection
final$net.bdef.tran <- (abs(final$net.bdef))^.5*abs(final$net.bdef)/final$net.bdef
   
# convert to numeric  
final$dom.cov <- as.numeric(final$cov.dom)
final$dom <- as.numeric(final$dom)
final$tdc.cov <- as.numeric(final$cov.tdc)
final$tdc <- as.numeric(final$tdc)
final$response.id <- eval(response.id)
final$response <- eval(response)
final$response.id <- factor(final$response.id)
final$response<- factor(final$response)

# data frame manipulations/organization for later use
final$trt <- final$trt
final$trt <- ifelse(final$trt=="nat.mix", paste("NM"), final$trt)
final$trt <- ifelse(final$trt=="inv.mix", paste("IM"), final$trt)
final$trt <- ifelse(final$trt=="comp.mix", paste("CM"), final$trt)
final$trt <- factor(final$trt, levels=c("NM", "IM", "CM"))
final$trt.rich <- 3
final$trt.rich <- ifelse(final$trt=="CM", 4, final$trt.rich)
final$trt.id <- final$trt
final$trt.id <- ifelse(final$trt=="NM", paste("3 species native"), final$trt.id)
final$trt.id <- ifelse(final$trt=="IM", paste("3 species invasive"), final$trt.id)
final$trt.id <- ifelse(final$trt=="CM", paste("4 species"), final$trt.id)
final$trt.id <- factor(final$trt.id, levels=c("3 species native", "3 species invasive", "4 species"))
final <- final[,c("response.id", "response", "trt", "trt.rich", "trt.id", "rep", "tic", "tdc", "tdc.cov", "dom", "dom.cov", "avg.delta.RY", "avg.M", "complementarity",  "selection", "net.bdef", "complementarity.tran", "selection.tran", "net.bdef.tran")]
rnd <- final
rnd[,c("tic", "tdc", "tdc.cov", "dom", "dom.cov", "avg.delta.RY", "avg.M", "complementarity",  "selection", "net.bdef", "complementarity.tran", "selection.tran", "net.bdef.tran")] <- apply(rnd[,c("tic", "tdc", "tdc.cov", "dom", "dom.cov", "avg.delta.RY", "avg.M", "complementarity",  "selection", "net.bdef", "complementarity.tran", "selection.tran", "net.bdef.tran")], 2, function(x) {round(x, 3)})

# write output to csv
#write.csv(rnd, paste("./tpp-output/", eval(response.id), ".csv", sep=""))

# name and bind to cumulative output file
name <- paste(eval(response.id), sep="")
assign(eval(name), final)
cumTPP <- as.data.frame(rbind(cumTPP, final))

#################################################################################################
# this code selects the data for anlaysis and melts it to perform one-way anovas on each response variable individually. it then writes the resulting statistical output to a .csv file and bind it to the cumulative statistics file
#################################################################################################

forPlots <- final[,c("response", "trt.rich", "trt.id", "rep", "complementarity.tran", "selection.tran", "net.bdef.tran")]
melt <- melt(forPlots, id=c("response", "trt.rich", "trt.id", "rep"))

library(plyr)
fits <- dlply(melt, .(variable), function(x) lm(value~trt.id, data=x))
labs <- data.frame(variable=levels(melt$variable), 
   DFnum=round(sapply(fits, function(x) anova(x)[1,1]), 0),
   DFdnm=round(sapply(fits, function(x) anova(x)[2,1]), 0),
   SSnum=round(sapply(fits, function(x) anova(x)[1,2]), 3),
   SSdnm=round(sapply(fits, function(x) anova(x)[2,2]), 3),
   MSnum=round(sapply(fits, function(x) anova(x)[1,3]), 3),
   MSdnm=round(sapply(fits, function(x) anova(x)[2,3]), 3),
   f=round(sapply(fits, function(x) anova(x)[1,4]), 2),
	p=sapply(fits, function(x) anova(x)[1,5]), 
   panel=paste(LETTERS[1:3]),
   trt.id=Inf, 
   trt.rich=Inf,
   value=-Inf)
labs$fvalue <- with(labs, paste("==", f, sep=""))
labs$pvalue <- with(labs, paste("==", round(p, 3), sep=""))
labs$pvalue <- ifelse(labs$p<=0.05, paste("<0.05"), labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.01, "<0.01", labs$pvalue)
labs$pvalue <- ifelse(labs$p<0.001, "<0.001", labs$pvalue)
labs$lab <- with(labs, paste("italic(F)", "[", DFnum, "*", "','", "*", DFdnm, "]", fvalue, "*", "','", "~~ italic(P)", pvalue, sep=""))
labs$p <- ifelse(labs$p<0.001, paste("<0.001"), labs$p)
colnames(labs)[8:9] <- c("F", "P")
labs$response <- eval(response)
stats <- labs
stats
#write.csv(stats, paste("./tpp-output/", eval(response), " Stats", ".csv", sep=""))
stats.name <- paste(eval(response), " Stats", sep="")
assign(eval(stats.name), stats)
stats.name
cumStats <- as.data.frame(rbind(cumStats, stats))

# reset objects in order to return error code if something fails in the next loop
rm(response, response.name, selwk, Mi, Yoi, RYoi.tot, avg.delta.RY, avg.M, TPP, end1, end2, final, native, invasive, complete, name, rnd, p1, p2, p3, p4, p5, p6, p7, p8, pAll, bdef.stats, bdef.tran.stats, tic.stats, tic.tran.stats, tdc.stats, tdc.tran.stats, dom.stats, dom.tran.stats, stats, fits, labs, melt, forPlots, plot.name, stats.name)
