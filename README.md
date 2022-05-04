[//]: # (seaweed-trophicDivPart: Additive partition of seaweed biodiversity effects across trophic levels)
[//]: # (Repo for Ramus & Long In Review)
[//]: # (Additive partition of seaweed biodiversity effects across trophic levels)
# Seaweed biodiversity effects across trophic levels
### Repo for Ramus et al. In Review
[![DOI](https://zenodo.org/badge/338374883.svg)](https://zenodo.org/badge/latestdoi/338374883)

This repository contains the data and code used to replicate the analysis and figures presented in

* Ramus AP, Lefcheck, JS, Long ZT (In Review) Foundational biodiversity effects propagate through coastal food webs via multiple pathways. *Journal* Issue:Page-Range. [doi link]

`The authors request that you cite the above article when using these data or modified code to prepare a publication.`

The files contained by this repository are numbered sequentially in the order they appear in our data analysis and figure generation workflow, each of which is described below. To use our code, you will need the latest version of R installed with the `cowplot`, `dplyr`, `ecodist`, `egg`, `ggh4x`, `ggplot2`, `MASS`, `nlme`, `piecewiseSEM`, `plyr`, `reshape2`, `tidyverse`, and `vegan` libraries, including their dependencies. 

## Data and Code
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
Code to construct the structural equation model (Figure 1) and analyze the output. Also generates a summary table of the path coefficients (Table S1). We present our analysis here on unaggregated data. The code can also be toggled to analyze aggregated data (see Line 26). The results do not differ qualitatively. 

### [![2-effects-on-primary-and-secondary-production.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/2-effects-on-primary-and-secondary-production.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/2-effects-on-primary-and-secondary-production.R)
Code to analyze the effects of macroalgal identity and richness on primary production and three complementary metrics of secondary production. This code performs one-way ANOVAs on untransformed, log transformed, nautral log transformed, and squart root transformed versions of each response variable individually and generates an ANOVA summary table of the results, plots histograms of the corresponding distributions, and generates Figure 2 presented in the paper. Also peforms Tukey's HSD post-hoc analysis for each consumer response variable and generates a summary table of the results (Data S1).

### [![3-effects-on-invertebrate-community-composition.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/3-effects-on-invertebrate-community-composition.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/3-effects-on-invertebrate-community-composition.R) 
Code to analyze the effects of macroalgal identity and richness on invertebrate community composition. This code test for differences in composition among treatments using a PERMANOVA, generates an NMDS plot of the results corresponding to Figure 3 in the paper, and performs pairwise planned contrasts among treatments (Table S2).

### [![4a-net-biodiversity-complementarity-and-selection-effects.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4a-net-biodiversity-complementarity-and-selection-effects.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4a-net-biodiversity-complementarity-and-selection-effects.R) 
Code to analyze the effects of macroalgal identity and richness on the net biodiversity and its component complementarity and selection effects. This code partitions the net biodiversity effect into its component complementarity and selection effects for each response variable individually and writes the output to a .csv. It then performs one-way ANOVAs on each response variable, generates an ANOVA summary table of the results, and generates Figure 4 presented in the paper.

### [![4b-calculate-and-fit-partition.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4b-calculate-and-fit-partition.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4b-calculate-and-fit-partition.R) 
This code works as a 'manual loop' inside code 4a above, for lack of a better description. It calculates and partitions the net biodiversity effect into its component complementarity and selection effects following Loreau & Hector (2001) *Nature*. 

### [![4c-t-test-on-partition-components.R](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4c-t-test-on-partition-components.R)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/4c-t-test-on-partition-components.R) 
This code performs one sample *t*-tests to assess whether the net biodiversity and its component selection and complementarity effects in each treatment statistically differ from 0 (as negative values are interpreted as "no effect") and generates a summary table of the results (Table S3). These *t*-tests are performed on the square-root transformed biodiversity effect components for each consumer response variable.

## Figures

![image](https://user-images.githubusercontent.com/11825056/166707019-eabaf3e2-8463-4577-8057-9fc6e493ac5d.png)
[![Figure_1.pdf](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_1.pdf)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_1.pdf) Final observed structural equation model relating experimentally manipulated macroalgal richness to properties of both the macroalgae and associated invertebrate consumer communities (see Appendix S1: Figure S2 for the null hypothesized model). Arrows represent directed effects (i.e., the flow of causality from one variable to another). Standardized regression coefficients are shown next to the arrows in units of standard deviation of the mean, such that they can be compared fairly across response variables of differing units. Arrow widths are scaled by the standardized coefficients (see Appendix S1: Table S1). Marginal (fixed effects only) and conditional (fixed + random effects) R2 values are also reported for each response variable. 

![image](https://user-images.githubusercontent.com/11825056/166707553-59cfcc84-74a5-4099-8573-4259025f0750.png)
[![Figure_2.pdf](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_2.pdf)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_2.pdf) Effects of macroalgal species identity and richness on metrics of primary and secondary production. Invertebrate (a) abundance, (b) dry biomass, and (c) taxonomic richness, and (d) macroalgal wet mass. Points are the time-averaged response of each replicate over the final 4 weeks (n = 5 for all treatments). Colors correspond to the seven experimental macroalgal treatments (see Data S1 for results of Tukey’s post-hoc analysis). Grey underlying boxplots represent the pooled response of all monocultures and polycultures, respectively. Result from one-way ANOVAs are shown near the margin of each panel.

![image](https://user-images.githubusercontent.com/11825056/166707615-becb6d86-9ad9-4d61-9444-6490efe9f21b.png)
[![Figure_3.pdf](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_3.pdf)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_3.pdf) NMDS plot showing the composition of the invertebrate consumer community that colonized each experimental macroalgal treatment. Colors correspond to the seven experimental macroalgal treatments. Points represent the n-dimensional response of each replicate and were calculated from the mean consumer abundance after time averaging over the final four weeks. Shaded hulls indicate the multidimensional space occupied by the invertebrate community in each treatment (see Appendix S1: Table S2 for results of pairwise planned contrasts). Results of PERMANOVA based on the unweighted species abundances in each treatment are shown near the lower left margin (n = 5 for all treatments).

![image](https://user-images.githubusercontent.com/11825056/166707686-4f541b12-ee01-44d5-a2d4-badd86769b31.png)
[![Figure_4.pdf](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_4.pdf)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_4.pdf) The net biodiversity effect partitioned into its component complementarity and selection effects for each response variable (rows) in multispecies treatments. Invertebrate abundance (a), biomass (b), and taxonomic richness (c), and macroalgal wet mass (d). Colors correspond to the three biodiversity effect components as indicated in the legend. Points were calculated from time-averaged response of each replicate over the final 4 weeks (n = 5 for all treatments) and all values were square root transformed with the original sign preserved (Loreau and Hector 2001). Axis scales for biodiversity effect components are equivalent for each response variable (within rows), but not across response variables (among rows). Responses above the black line at 0 are positive whereas those below are negative (see Appendix S1: Table S3 for results of t-tests).

## Supporting Information

### [![Appendix_S1.pdf](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Appendix_S1.pdf)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Appendix_S1.pdf) 
Supporting Information for Ramus, A. P., J. S. Lefcheck, and Z. T. Long. 2022. Foundational biodiversity effects propagate through coastal food webs via multiple pathways. 
Tables S1-S3
Figures S1-S2

[![Table_S1.csv](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Table_S1.csv)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Table_S1.csv) Estimates of regression coefficients and their standard errors (SE) from the structural equation model (Fig. 1). Standardized coefficients are shown in bold when significant (P < 0.05).

[![Table_S2.csv](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Table_S2.csv)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Table_S2.csv) Pairwise planned contrasts for the effects of macroalgal treatment on invertebrate community composition (Fig. 3). Significant (P < 0.05) results from pairwise tests between treatments are bolded.

[![Table_S3.csv](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Table_S3.csv)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Table_S3.csv) Results of t-tests analyzing whether components of the biodiversity effect (Fig. 4) differ from zero in each treatment. Probability values appear in bold when significant (P < 0.05).

![image](https://user-images.githubusercontent.com/11825056/166711735-d41205f2-fcb9-4213-a560-90c2282ae680.png)
[![Figure_S1.pdf](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_S1.pdf)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_S1.pdf) Schematic diagram of the experiment and sampling design. In (a), summary of the seven macroalgal treatments, representing 3 levels of macroalgal richness, following a substitutive design (i.e., total wet mass is held constant in each quadrant); (b) sampling procedure used over the course of the experiment for the weekly destructive sampling of the macroalgal treatments, replicated within each quadrant of each block; (c) picture showing an experimental block containing a 3 species nonnative treatment in each quadrant.

![image](https://user-images.githubusercontent.com/11825056/166711902-061fb6c1-a059-4f0b-957f-297bb1a3ebf3.png)
[![Figure_S2.pdf](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_S2.pdf)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Figure_S2.pdf) Conceptual representation and justification of linkages in our hypothesized causal model. We expected that: (a) macroalgal richness increases macroalgal wet mass (Bruno et al. 2005, 2006, Stachowicz et al. 2008, Boyer et al. 2009); (b, c, and d) macroalgal richness increases invertebrate richness, biomass, and/or abundance through provisioning of unique habitats and/or food resources (Siemann et al. 1998, Haddad et al. 2009, Borer et al. 2012, Ebeling et al. 2014, 2018, Hertzog et al. 2016, Schuldt et al. 2019); (e, f, and g) macroalgal wet mass increases invertebrate richness, biomass, and/or abundance through provisioning of habitat and/or food writ large (Scherber et al. 2010, Borer et al. 2012, Ebeling et al. 2014, 2018, Hertzog et al. 2016); (h) invertebrate richness increases invertebrate biomass (Duffy et al. 2003, 2005); (i) invertebrate abundance increases invertebrate richness (Ebeling et al. 2014, Hertzog et al. 2016, Schuldt et al. 2019); and (j) invertebrate abundance increases invertebrate biomass, as adding individuals necessarily must add biomass.

### [![Data_S1.csv](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Data_S1.csv)](https://github.com/apramus/seaweed-biodiversity-effects/blob/main/figures-and-tables/Data_S1.csv) 
Tukey’s post-hoc comparisons (HSD) for the effects of macroalgal treatment on plant and consumer response metrics (Fig. 2). Probability values are presented for pairwise comparisons between macroalgal treatments. Significant (P < 0.05) differences between treatment means appear in boldface.

