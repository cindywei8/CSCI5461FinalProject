All four published datasets and the software to implement SIMLR 
can be downloaded from https://static-content.springer.com/esm/art%3A10.1038%2Fnmeth.4207/MediaObjects/41592_2017_BFnmeth4207_MOESM290_ESM.zip

TWei_Code.zip contains code files for reproducing figures and results in the report. 

1. Unzip the file downloaded from the link. 
2. Go to Supplementary_Software/Matlab
3. Move all three folders and all files in the directory to TWei_Code. 
4. Run extract_SMat.m to generate SIMLR similarity matrices. 
5. Run SimilarityMatrixVisualization.py to produce Figure 2 in the report. 
6. Run Embeddings2d.m to produce Figure 3-6 and the NMI values in the report. 

AccMeasure.m: Measure percentage of accuracy  of clustering results. 
This program is used to match up obtained cluster labels and the ground truth cluster labels. Detailed documentations can be found here: https://www.mathworks.com/matlabcentral/fileexchange/32197-clustering-results-measurement
