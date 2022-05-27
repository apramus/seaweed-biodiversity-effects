## Data and code to analyze seaweed biodiversity effects across trophic levels

[![DOI](https://zenodo.org/badge/338374883.svg)](https://zenodo.org/badge/latestdoi/338374883)

This repository contains the data and code used for the article

* Ramus AP, Lefcheck JS, Long ZT (2022) Foundational biodiversity effects propagate through coastal food webs via multiple pathways. *Ecology* 

[//]: # (Issue:Page-Range. [doi link])

`The authors request that you cite the above article or the Zenodo repository when using these data or modified code to prepare a publication.`

The files contained by this repository are numbered sequentially in the order they appear in our data analysis and figure generation workflow, each of which is described below. To use our code, you will need the latest version of R installed with the `cowplot`, `dplyr`, `ecodist`, `egg`, `ggh4x`, `ggplot2`, `MASS`, `nlme`, `piecewiseSEM`, `plyr`, `reshape2`, `tidyverse`, and `vegan` libraries, including their dependencies. 

### [![0-ramus-thesis-data-cleaned.csv](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/0-ramus-thesis-data-cleaned.csv)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/0-ramus-thesis-data-cleaned.csv) 
The cleaned dataset used to generate all analyses and figures presented in the paper. These data represent the yields of individual component species in mixture, as well as the summed response of each treatment, for each response variable measured on a weekly basis over the course of the 12 week experiment. For complete methodology, see the corresponding article above or [Ramus & Long (2016) *J Ecol*](https://doi.org/10.1111/1365-2745.12509). A brief description of each variable is given below. 

[//]: # (These data represent the yield of individual component species in mixture and plot-level sum of each variable, in each treatment, measured on a weekly basis over the course of the 12 week experiment.)
[//]: # (As was analyzed in our previous work, these data represent the summed response of the component species in each treatment for each variable, measured on a weekly basis over the course of the 12 week experiment.)

Field | Variable | Description 
:---: | :--- | :--- 
1 | Data | Distinguishes plot-level ‘sum’ from its component ‘parts’ in mixtures (for subsetting)
2 | Species | Macroalgal species ‘sown’ in treatment
3 | ProBiomassInitial | Initial sown wet mass of macroalgae
4 | Deployed | Date deployed
5 | Sampled | Date sampled
6 | Quadrant | The quadrant (1-4) being sampled within the mesh screen of each block
7 | Week | Experimental duration in weeks (1-12)
8 | Block | Block identification number (1-35)
9 | Location | Location of block (1-35) within a randomized line, with 1 being the farthest South
10 | ProDivTrtType | Producer diversity treatment type (Mono or Poly)
11 | ProDivTrtRich | Producer diversity treatment richness, the number of producer species (1, 3, 4)
12 | ProDivTrtID | Producer diversity treatment identifier (Cf, Gt, Gv, Gg, NM, IM, CM)
13 | CfBiomass | Wet biomass of *Codium fragile* in grams
14 | GtBiomass | Wet biomass of *Gracilaria tikvahiae* in grams
15 | GvBiomass | Wet biomass of *Gracilaria vermiculophylla* in grams
16 | GgBiomass | Wet biomass of *Gymnogongrus griffithsiae* in grams
17 | ProBiomass | Total wet biomass of macroalgae in grams (sum of fields 13-16)
18 | Amphipods | Abundance of gammaridean amphipod crustaceans
19 | Bivalves | Abundance of bivalve molluscs
20 | Caprellids | Abundance of caprellid amphipod crustaceans
21 | Gastropods | Abundance of gastropod molluscs
22 | Isopods | Abundance of isopod crustaceans
23 | Megalopae | Abundance of decapod crustacean megalopae
24 | NonXanthids | Abundance of crab-like decapod crustaceans not belonging to the Xanthidae
25 | Polychaetes | Abundance of polychaete annelids
26 | Pycnogonids | Abundance of pycnogonid pantopod crustaceans
27 | Shrimps | Abundance of palaemonid and penaeid decapod crustaceans
28 | Xanthids | Abundance of xanthid decapod crustaceans
29 | Others | Abundance of ‘other’ heterotrophs that either were unidentifiable or did not fit into fields 18-28 (12 of 42309 individuals sampled)
30 | ConAbund | Consumer abundance, the total number of individual consumers (sum of fields 18-29)
31 | ConBiomass | Consumer biomass, the total dry mass of consumers in grams
32 | ConDivRich | Consumer richness, the total number of consumer taxa present (in fields 18-29)

Throughout the analysis below we focus on our most resolved data from the final four weeks of the experiment. 

### [![1-structural-equation-model.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/1-structural-equation-model.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/1-structural-equation-model.R)
Code to construct the structural equation model (Figure 1) and analyze the output. Also generates a summary table of the path coefficients (Table S1). We present our analysis here on unaggregated data. The code can also be toggled to analyze aggregated data (see Line 28). The results do not differ qualitatively. 

### [![2-treatment-effects-on-response-metrics.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/2-treatment-effects-on-response-metrics.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/2-treatment-effects-on-response-metrics.R)
Code to analyze the effects of macroalgal identity and richness on primary production and three complementary metrics of secondary production. This code performs one-way ANOVAs on untransformed, log transformed, nautral log transformed, and squart root transformed versions of each response variable individually and generates an ANOVA summary table of the results, plots histograms of the corresponding distributions, and generates Figure 2 presented in the paper. Also compares the means of monocultures and polycultures using t-tests and peforms Tukey's HSD post-hoc analysis for each consumer response variable, and generates a summary tables of the results.

### [![3-treatment-effects-on-invertebrate-community-composition.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/3-treatment-effects-on-invertebrate-community-composition.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/3-treatment-effects-on-invertebrate-community-composition.R) 
Code to analyze the effects of macroalgal identity and richness on invertebrate community composition. This code test for differences in composition among treatments using a PERMANOVA, generates an NMDS plot of the results corresponding to Figure 3 in the paper, and performs pairwise planned contrasts among treatments (Table S2).

### [![4a-net-biodiversity-complementarity-and-selection-effects.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4a-net-biodiversity-complementarity-and-selection-effects.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4a-net-biodiversity-complementarity-and-selection-effects.R) 
Code to analyze the effects of macroalgal identity and richness on the net biodiversity and its component complementarity and selection effects. This code partitions the net biodiversity effect into its component complementarity and selection effects for each response variable individually and writes the output to a .csv. It then performs one-way ANOVAs on each response variable, generates an ANOVA summary table of the results, and generates Figure 4 presented in the paper.

### [![4b-calculate-and-fit-partition.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4b-calculate-and-fit-partition.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4b-calculate-and-fit-partition.R) 
This code works as a 'manual loop' inside code 4a above, for lack of a better description. It calculates and partitions the net biodiversity effect into its component complementarity and selection effects following Loreau & Hector (2001) *Nature*. 

### [![4c-t-tests-on-partition-components.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4c-t-tests-on-partition-components.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4c-t-tests-on-partition-components.R) 
This code performs one sample *t*-tests to assess whether the net biodiversity and its component selection and complementarity effects in each treatment statistically differ from 0 (as negative values are interpreted as "no effect") and generates a summary table of the results (Table S3). These *t*-tests are performed on the square-root transformed biodiversity effect components for each consumer response variable.
