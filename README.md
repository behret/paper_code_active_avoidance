This repository contains all code that was used to produce the results of the following publication:

Population-level coding of avoidance learning in medial prefrontal cortex  
Ehret B., Boehringer R., Amadei E. A., Cervera M. R., Henning C., Galgali A., Mante V., Grewe, B. F.  
Nature Neuroscience 2024

The data associated with the publication can be downloaded here:

XXX

The data repository contains the source data for all figures as well as the processed data that can be used to rerun most analyses (a small subset requires access to raw data).
The raw data is too extensive to be published online, but is available upon request.

## Reproducing figures

1. Download data
2. Set the 3 paths at the beginning of params_2DAA.m 
3. Run the script run_plots.m.

## Rerunning analyses

1. Download data
2. Set the 3 paths at the beginning of params_2DAA.m 
3. Run the script run_analyses

Some of the analyses will take some time to run. 

## Processing of raw data

While the raw data is not available, we do provide the code that was used to process calcium imaging movies (movie_analysis) and the code that was used to align neural and behavioral data (data_organization) such that the reader can follow how the processed data published on Zenodo were created. 

Processed data contains the following variables:
- traces (neural activity traces for each subject and session)
- evs (experimental variables for each subject and session): stimulus information over all recorded time stepts (such as tone on/off)
- bvs (behavioral variables for each subject and session): behavioral information over all recorded time stepts (such as mouse position)
- tis (trial information for each subject and session): information about the 50 trials of a given session

For details on the data recorded in tis and evs see the spread sheet ev_ti_structure.xls in the data repository.