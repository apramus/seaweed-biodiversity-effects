# seaweed-multiDivPart: additive partition of seaweed biodiversity effects across trophic levels

# Repo for Ramus & Long (In Review)

This repository contains the data and code used to replicate the analysis and figures presented in

Ramus AP, Long ZT (In Review) Effects of macroalgal species identity and richness on secondary production in benthic marine communities. *Journal* Issue:Pages. [doi link]

`The authors request that you cite the above article when using these data or modified code to prepare a publication.`

The files contained by this repository are numbered sequentially in the order they appear in our data analysis and figure generation workflow, each of which is described below. To use our code, you will need R installed with the cowplot, dplyr, ecodist, egg, ggplot2, MASS, plyr, reshape2, and vegan libraries, including their dependencies.

## `1-ramus-thesis-data-cleaned.csv`

  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell

The data used to generate all analyses and figures presented in the paper. 

Ramus AP, Long ZT (2016) Producer diversity enhances consumer stability in a benthic marine community. *Journal of Ecology* 104:572-579. https://doi.org/10.1111/1365-2745.12509

Similar to journal of ecology data

These data represent the 

time-averaged value of each variable measured monthly in each plot over the course of the 10 month experiment. 

See the paper 

For complete methodology and a detailed description of the experiment and methodologies used, see either the paper named above or 

A full description of the methodologies and variables is also available from http://www.bco-dmo.org/dataset/716208. 

For complete methodology, see Ramus et al., 2017 (doi:10.1073/pnas.1700353114). In summary:
The experiment was carried out on intertidal mud and sandflats located within the Zeke’s Island National Estuarine Research Reserve (33.95 N, 77.94 W), North Carolina, USA.
These data represent the yields of individual macroalgal species in treatment plots 
Measured weekly in each treatment block (plot) 
Of a 12 week experiment conducted in situ along 


time-averaged value of each variable measured monthly in each plot over the course of a 10 month experiment carried out on intertidal mud and sandflats located within the Zeke’s Island National Estuarine Research Reserve (33.95 N, 77.94 W), North Carolina, USA.

A brief description of each variable is given below. The suffix `.sr` denotes supporting responses only measured near the end of the experiment. 


1.	‘Data’ 	
2.	‘Species’ macroalga	
3.	ProBiomassInitial
4.	Deployed 
5.	Sampled
6.	Quadrant 
7.	Week
8.	Block
9.	Location
10.	ProDivTrtType
11.	ProDivTrtRich
12.	ProDivTrtID
13.	CfBiomass
14.	GtBiomass
15.	GvBiomass
16.	GgBiomass
17.	ProBiomass
18.	Amphipods
19.	Bivalves
20.	Caprellids
21.	Gastropods
22.	Isopods
23.	Megalopae
24.	NonXanthidCrabs
25.	Polychaetes
26.	Pycnogonids
27.	Shrimps
28.	XanthidCrabs
29.	Others
30.	ConAbund
31.	ConBiomass
32.	‘ConDivRich’ 

Field 2 | Name: Sampled | Definition: Date producer diversity treatment sampled
Field 3 | Name: Quadrant | Definition: The quadrant (1-4) sampled within each block
Field 4 | Name: Week | Definition: Experimental duration in weeks (1-12)
Field 5 | Name: Block | Definition: Block identification number (1-35)
Field 6 | Name: Location | Definition: Location of block (1-35) in randomized line, with 1 being the farthest South
Field 7 | Name: ProDivTrtType | Definition: Producer diversity treatment type (Mono or Poly)
Field 8 | Name: ProDivTrtRich | Definition: Producer diversity treatment richness, the number of producer species (1, 3, or 4)
Field 9 | Name: ProDivTrtID | Definition: Producer diversity treatment identifier (Cf, Gt, Gv, Gg, NM, IM, or CM)
Field 10 | Name: CfBiomass | Definition: Wet biomass of Cf in grams
Field 11 | Name: GtBiomass | Definition: Wet biomass of Gt in grams
Field 12 | Name: GvBiomass | Definition: Wet biomass of Gv in grams
Field 13 | Name: GgBiomass | Definition: Wet biomass of Gg in grams
Field 14 | Name: ProBiomass | Definition: Total wet biomass of producers (Fields 10-13) in grams
Field 15 | Name: Amphipods | Definition: Abundance of gammaridean amphipod crustaceans
Field 16 | Name: Bivalves | Definition: Abundance of bivalve molluscs
Field 17 | Name: Caprellids | Definition: Abundance of caprellid amphipod crustaceans
Field 18 | Name: Gastropods | Definition: Abundance of gastropod molluscs
Field 19 | Name: Isopods | Definition: Abundance of isopod crustaceans
Field 20 | Name: Megalopae | Definition: Abundance of decapod crustacean megalopae
Field 21 | Name: NonXanthids | Definition: Abundance of crab-like decapod crustaceans that were not xanthid crabs
Field 22 | Name: Polychaetes | Definition: Abundance of polychaete annelids
Field 23 | Name: Pycnogonids | Definition: Abundance of pycnogonid pantopod crustaceans
Field 24 | Name: Shrimps | Definition: Abundance of palaemonid and penaeid decapod crustaceans
Field 25 | Name: Xanthids | Definition: abundance of xanthid decapod crustaceans
Field 26 | Name: Others | Definition: abundance of other animals that were either unidentifiable or did not fit into any of the other taxonomic groups (i.e. Fields 15-25)
Field 27 | Name: ConAbund | Definition: Total abundance of consumers (i.e. the sum of Fields 15-26)
Field 28 | Name: ConBiomass | Definition: Total dry biomass of consumers in grams
Field 30 | Name: ConDivRich | Definition: Consumer richness, the number of consumer taxa, calculated from Fields 15-26 in R package ‘vegan’



