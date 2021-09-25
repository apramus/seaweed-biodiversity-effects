library(tidyverse)
library(piecewiseSEM)
library(nlme)

# Read in data
data <- read.csv("0-ramus-thesis-data-cleaned.csv")

# Summarize data
new_data <- data %>%
  
  # Only select community data
  filter(Data == "Sum") %>%
  
  # Remove lost replicates
  filter(ProBiomass > 0) %>%
  
  # Remove earlier samplings
  filter(Week > 8) %>%
  
  # Transform responses
  mutate(
    ProBiomass = log10(ProBiomass),
    ConBiomass = log10(ConBiomass + 0.002),
    ConDivRich = log10(ConDivRich + 1)) %>%

  group_by(Week, Block, Location) %>% # remove week to summarize across all weeks
  
  summarize(
    n = sum(ProDivTrtRich > 0),
    Macroalgal_richness = mean(ProDivTrtRich),
    Macroalgal_wet_mass = mean(ProBiomass, na.rm = T),
    Invertebrate_abundance = mean(ConAbund, na.rm = T),
    Invertebrate_biomass = mean(ConBiomass, na.rm = T),
    Invertebrate_richness = mean(ConDivRich, na.rm = T)
  ) 

# SEM
# model <- psem(
#   lme(Macroalgal_wet_mass ~ Macroalgal_richness, random = list(Week = ~1, Block = ~1), new_data),
#   lme(Invertebrate_biomass ~ Macroalgal_richness + Macroalgal_wet_mass + Invertebrate_richness, random = list(Week = ~1, Block = ~1), new_data),
#   lme(Invertebrate_richness ~ Macroalgal_richness + Macroalgal_wet_mass + Invertebrate_abundance, random = list(Week = ~1, Block = ~1), new_data),
#   Invertebrate_biomass %~~% Invertebrate_abundance
#   )

# add invert abund in predicting invert biomass
model <- psem(
  lme(Macroalgal_wet_mass ~ Macroalgal_richness, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invertebrate_biomass ~ Macroalgal_richness + Macroalgal_wet_mass + Invertebrate_richness + Invertebrate_abundance, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invertebrate_richness ~ Macroalgal_richness + Macroalgal_wet_mass + Invertebrate_abundance, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invertebrate_abundance ~ Macroalgal_richness + Macroalgal_wet_mass, random = list(Week = ~1, Block = ~1), new_data)
)

# Check model assumptions
lapply(model, plot) # a little wedging for the first model, prob ok

lapply(model, function(i) hist(resid(i))) # looks generally normal

# Get summary
summary(model)

# Model 2: reverse richness<-biomass linkages
model2 <- psem(
  lme(Macroalgal_wet_mass ~ Macroalgal_richness, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invertebrate_biomass ~ Macroalgal_richness + Macroalgal_wet_mass + Invertebrate_abundance, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invertebrate_richness ~ Macroalgal_richness + Macroalgal_wet_mass + Invertebrate_biomass + Invertebrate_abundance, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invertebrate_abundance ~ Macroalgal_richness + Macroalgal_wet_mass, random = list(Week = ~1, Block = ~1), new_data)
)

# Conduct model comparison
AIC(model, model2)

# Make path coefficients pretty and write to .csv write path coefficients to .csv
modsum <- summary(model)$coefficients
modsum$Estimate <- round(modsum$Estimate, 3)
modsum$Std.Error <- round(modsum$Std.Error, 3)
modsum$Crit.Value <- round(modsum$Crit.Value, 3)
modsum$P.Value <- round(modsum$P.Value, 3)
modsum$P.Value <- ifelse(modsum$P.Value<0.001, "<0.001", modsum$P.Value)
modsum$Std.Estimate <- round(modsum$Std.Estimate, 3)
modsum$Response <- gsub("_", " ", modsum$Response)
modsum$Predictor <- gsub("_", " ", modsum$Predictor)
colnames(modsum)[4:8] <- c("SE", "DF", "t-Value", "P-Value", "Std. Estimate")
modsum
write.csv(modsum, "./figures-and-tables/TableS1.csv")
