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
    Prod_Rich = mean(ProDivTrtRich),
    Prod_Wet_Mass = mean(ProBiomass, na.rm = T),
    Invert_Abund = mean(ConAbund, na.rm = T),
    Invert_Biomass = mean(ConBiomass, na.rm = T),
    Invert_Rich = mean(ConDivRich, na.rm = T)
  ) 

# SEM
# model <- psem(
#   lme(Prod_Wet_Mass ~ Prod_Rich, random = list(Week = ~1, Block = ~1), new_data),
#   lme(Invert_Biomass ~ Prod_Rich + Prod_Wet_Mass + Invert_Rich, random = list(Week = ~1, Block = ~1), new_data),
#   lme(Invert_Rich ~ Prod_Rich + Prod_Wet_Mass + Invert_Abund, random = list(Week = ~1, Block = ~1), new_data),
#   Invert_Biomass %~~% Invert_Abund
#   )

# add invert abund in predicting invert biomass
model <- psem(
  lme(Prod_Wet_Mass ~ Prod_Rich, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invert_Biomass ~ Prod_Rich + Prod_Wet_Mass + Invert_Rich + Invert_Abund, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invert_Rich ~ Prod_Rich + Prod_Wet_Mass + Invert_Abund, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invert_Abund ~ Prod_Rich + Prod_Wet_Mass, random = list(Week = ~1, Block = ~1), new_data)
)

# Check model assumptions
lapply(model, plot) # a little wedging for the first model, prob ok

lapply(model, function(i) hist(resid(i))) # looks generally normal

# Get summary
summary(model)

# Model 2: reverse richness<-biomass linkages
model2 <- psem(
  lme(Prod_Wet_Mass ~ Prod_Rich, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invert_Biomass ~ Prod_Rich + Prod_Wet_Mass + Invert_Abund, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invert_Rich ~ Prod_Rich + Prod_Wet_Mass + Invert_Biomass + Invert_Abund, random = list(Week = ~1, Block = ~1), new_data),
  lme(Invert_Abund ~ Prod_Rich + Prod_Wet_Mass, random = list(Week = ~1, Block = ~1), new_data)
)

# Conduct model comparison
AIC(model, model2)

# Make path coefficients pretty and write to .csv write path coefficients to .csv
modsum <- summary(model)$coefficients
modsum$Estimate <- round(modsum$Estimate, 3)
modsum$Std.Error <- round(modsum$Std.Error, 3)
modsum$Crit.Value <- round(modsum$Crit.Value, 3)
modsum$P.Value <- round(modsum$P.Value, 3)
modsum$Std.Estimate <- round(modsum$Std.Estimate, 3)
write.csv(modsum, "./figures-and-tables/Table_1. Path coefficients.csv")
