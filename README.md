# CATwalk_Mapper
A snakemake workflow for mapping library reads to CATwalk products by Gavin Anderson.

One of the core problems encountered when employing a naive assembly algorithm is assessing the contents of the library file. This workflow's purpose is to construct a CATwalk product and map available fragments onto it. This allows users to visualize how many possible fragments could be encountered by CATwalk and extended from. 

The workflow for this pipeline consists of:
1. Downloading SRA and NCBI genomic data with NCBI CLI and SRAtools
2. Using CATwalk to assemble a product
3. Using BWA to index and map reads to the resulting product
4. Packaging the alignment files with SAMtools
5. Outputting the resulting coverage graph with PyGenomeTracks

This Snakemake workflow is built with compartmentalized Conda environments and custom-built scripts. The workflow is run by navigating to the root directory, installing snakemake, and typing "snakemake --cores 4 --use-conda" on the first run of the workflow.
