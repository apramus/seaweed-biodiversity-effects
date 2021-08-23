# clear field, load/detach packages
rm(list=ls(all.names=T))
library(reshape)
library(ggplot2)
library(egg)

# load data and organize factors
cumTPP <- read.csv("./derived-data/partitioned-effects-on-consumer-responses.csv")
cumTPP$trt <- factor(cumTPP$trt, levels = c("NM", "IM", "CM"))
cumTPP$trt.id <- factor(cumTPP$trt.id, levels = c("3 species native", "3 species invasive", "4 species"))

# select vars for melting and melt to long format
vars <- cumTPP[,c("response", "trt.id", "complementarity.tran", "selection.tran", "net.bdef.tran" )]
melt <- melt(vars, id=c("trt.id", "response"))
melt
str(melt)

# rename/reorganize factors
melt$variable <- ifelse(melt$variable=="complementarity.tran", paste("Complementarity effect"), paste(melt$variable))
melt$variable <- ifelse(melt$variable=="selection.tran", paste("Selection effect"), paste(melt$variable))
melt$variable <- ifelse(melt$variable=="net.bdef.tran", paste("Net biodiversity effect"), paste(melt$variable))
melt$variable <- factor(melt$variable, levels = c("Complementarity effect", "Selection effect", "Net biodiversity effect"))
str(melt)

# subset by Invertebrate response 
melt.ca <- subset(melt, response == "Invertebrate abundance (#)")
melt.cb <- subset(melt, response == "Invertebrate biomass (g)")
melt.cr <- subset(melt, response == "Invertebrate richness (# of taxa)")
melt.pb <- subset(melt, response == "Macroalgal wet mass (g)")

# sub-subset by biodiversity effect component 
melt.ca.ce <- subset(melt.ca, variable == "Complementarity effect")
melt.ca.se <- subset(melt.ca, variable == "Selection effect")
melt.ca.be <- subset(melt.ca, variable == "Net biodiversity effect")
melt.cb.ce <- subset(melt.cb, variable == "Complementarity effect")
melt.cb.se <- subset(melt.cb, variable == "Selection effect")
melt.cb.be <- subset(melt.cb, variable == "Net biodiversity effect")
melt.cr.ce <- subset(melt.cr, variable == "Complementarity effect")
melt.cr.se <- subset(melt.cr, variable == "Selection effect")
melt.cr.be <- subset(melt.cr, variable == "Net biodiversity effect")
melt.pb.ce <- subset(melt.pb, variable == "Complementarity effect")
melt.pb.se <- subset(melt.pb, variable == "Selection effect")
melt.pb.be <- subset(melt.pb, variable == "Net biodiversity effect")

# perform one sample t test  "testing" the null that the net biodiversity and its component selection and complementarity effects do not differ from 0 (as negative values are interpreted as "no effect") for each treatment individually and stuff it into a data frame for later analysis
# this performed on the transformed biodiversity responses of each response variable

library(plyr)

# ca.ce
fits <- dlply(melt.ca.ce, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.ca.ce$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Invertebrate abundance (#)"
labs$variable <- "Complementarity effect"
t.tests <- labs

# ca.se
fits <- dlply(melt.ca.se, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.ca.se$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Invertebrate abundance (#)"
labs$variable <- "Selection effect"
t.tests <- rbind(t.tests, labs)

# ca.be
fits <- dlply(melt.ca.be, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.ca.be$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Invertebrate abundance (#)"
labs$variable <- "Net biodiversity effect"
t.tests <- rbind(t.tests, labs)

# cb.ce
fits <- dlply(melt.cb.ce, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.cb.ce$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Invertebrate biomass (g)"
labs$variable <- "Complementarity effect"
t.tests <- rbind(t.tests, labs)

# cb.se
fits <- dlply(melt.cb.se, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.cb.se$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Invertebrate biomass (g)"
labs$variable <- "Selection effect"
t.tests <- rbind(t.tests, labs)

# cb.be
fits <- dlply(melt.cb.be, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.cb.be$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Invertebrate biomass (g)"
labs$variable <- "Net biodiversity effect"
t.tests <- rbind(t.tests, labs)

# cr.ce
fits <- dlply(melt.cr.ce, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.cr.ce$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Invertebrate richness (# of taxa)"
labs$variable <- "Complementarity effect"
t.tests <- rbind(t.tests, labs)

# cr.se
fits <- dlply(melt.cr.se, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.cr.se$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Invertebrate richness (# of taxa)"
labs$variable <- "Selection effect"
t.tests <- rbind(t.tests, labs)

# cr.be
fits <- dlply(melt.cr.be, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.cr.be$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Invertebrate richness (# of taxa)"
labs$variable <- "Net biodiversity effect"
t.tests <- rbind(t.tests, labs)

# pb.ce
fits <- dlply(melt.pb.ce, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.pb.ce$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Macroalgal wet mass (g)"
labs$variable <- "Complementarity effect"
t.tests <- rbind(t.tests, labs)

# pb.se
fits <- dlply(melt.pb.se, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.pb.se$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Macroalgal wet mass (g)"
labs$variable <- "Selection effect"
t.tests <- rbind(t.tests, labs)

# pb.be
fits <- dlply(melt.pb.be, .(trt.id), function(x) t.test(x$value))
labs <- data.frame(trt.id=levels(melt.pb.be$trt.id), 
        t=round(sapply(fits, function(x) x$'statistic'[[1]]), 2),
        df=sapply(fits, function(x) x$'parameter'[[1]]),
        p=round(sapply(fits, function(x) x$'p.value'[[1]]), 3))
labs$response <- "Macroalgal wet mass (g)"
labs$variable <- "Net biodiversity effect"
t.tests <- rbind(t.tests, labs)

# reorganize for output and output as .csv for analysis
t.tests <- t.tests[,c("response", "variable", "trt.id", "t", "df", "p")]
rownames(t.tests) <- NULL
write.csv(t.tests, "./figures-and-tables/Table_S3. t-tests for partition components.csv")
