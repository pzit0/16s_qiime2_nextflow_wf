Author: Patricia Zito
Date: Jul 15, 2026

Successfully ran in lab server machine. 

## Whole Analysis Overview
```mermaid
graph LR
boxa([Raw .fastq sequence files]) --> boxb[qiime 2 demultiplexing] 
boxb --> boxc[Demultiplexed .fastq files]
boxc --> boxd{dada2 QC parameters}
boxd --> boxe[Nextflow qiime2 analysis workflow]
boxc --> boxe
boxc --> boxf[Make MANIFEST file with make_manifest.py]
boxf --> boxe
boxe --> boxg([Results])
```

## Nextflow Workflow Overview
```mermaid
flowchart LR
    subgraph "parameters inside params.config"
    v0["metadata.tsv"]
    v1["MANIFEST"]
    v2["params.p6_classifiers"]
    v3["params.contrast"]
    v6["forward_primer"]
    v7["reverse_primer"]
    v11["forward_left"]
    v12["forward_right"]
    v13["reverse_left"]
    v14["reverse_right"]
    v28["max_depth"]
    v29["steps"]
    v30["metrics"]
    v33["tax_level"]
    v41["sampling_depth"]
    v44["sig_threshold"]
    v45["tax_level"]
    end
    v4(["P1_IMPORT"])
    v8(["P2_FILTER"])
    subgraph "results"
    v9["trimmed.qzv"]
    v16["denoising_stats.qza"]
    v17["representative_sequences.qzv"]
    v18["denoising_stats.qzv"]
    v21["representative_sequences.mafft.qza"]
    v22["representative_sequences.masked.mafft.qza"]
    v23["unrooted_tree.qza"]
    v24["unrooted_tree"]
    v25["rooted_tree"]
    v32["rarefaction_curve.qzv"]
    v35["abs_taxonomy_${database}.qzv"]
    v36["abs_taxonomy_${database}.barplot.qzv"]
    v37["rel_taxonomy_${database}_lv${tax_level}.qza"]
    v38["abs_taxonomy_${database}_lv${tax_level}"]
    v39["rel_taxonomy_${database}_lv${tax_level}"]
    v43["core_metrics_${contrast}_results"]
    v47["ancombc_${database}_${contrast}.qza"]
    v48["da_barplot_${database}_${contrast}.qzv"]
    v49["ancombc_${database}_${contrast}_lv${tax_level}.qza"]
    v50["da_barplot_${database}_${contrast}_lv${tax_level}.qzv"]
    end
    v15(["P3_DENOISE"])
    v20(["P4_PHYLOTREE"])
    v31(["P5_RAREFACTION"])
    v34(["P6_TAXONOMY"])
    v42(["P7_DIVERSITY"])
    v46(["P8_ANCOMBC"])
    v5(("demuxed.qza"))
    v10(("trimmed.qza"))
    v19(("representative_sequences.qza"))
    v26(("denoised_table.qza"))
    v27(("rooted_tree.qza"))
    v0 --> v31
    v0 --> v34
    v0 --> v42
    v0 --> v46
    v1 --> v4
    v2 --> v34
    v3 --> v42
    v3 --> v46
    v4 --> v5
    v6 --> v8
    v7 --> v8
    v5 --> v8
    v8 --> v9
    v8 --> v10
    v11 --> v15
    v12 --> v15
    v13 --> v15
    v14 --> v15
    v10 --> v15
    v15 --> v18
    v15 --> v17
    v15 --> v16
    v15 --> v34
    v15 --> v42
    v15 --> v46
    v15 --> v19
    v15 --> v26
    v19 --> v20
    v20 --> v25
    v20 --> v24
    v20 --> v23
    v20 --> v22
    v20 --> v21
    v20 --> v27
    v28 --> v31
    v29 --> v31
    v30 --> v31
    v26 --> v31
    v27 --> v31
    v31 --> v32
    v33 --> v34
    v34 --> v46
    v34 --> v39
    v34 --> v38
    v34 --> v37
    v34 --> v36
    v34 --> v35
    v41 --> v42
    v27 --> v42
    v42 --> v43
    v44 --> v46
    v45 --> v46
    v46 --> v50
    v46 --> v49
    v46 --> v48
    v46 --> v47
```

## Project Folder Structure:
```
(base) leelab@IBIO-JH5DN34:/media/leelab/HDD_Array/PZito/16s/2013_04_17-nf$ tree .
.
├── demultiplexed_seqs
│   ├── 20130417_LisleVerte_copepod_6_L001_R1_001.fastq.gz
│   ├── 20130417_LisleVerte_copepod_6_L001_R2_001.fastq.gz
│   ├── 20130417_LisleVerte_water_4_L001_R1_001.fastq.gz
│   ├── 20130417_LisleVerte_water_4_L001_R2_001.fastq.gz
│   ├── 20130417_Racine_copepod_1_L001_R1_001.fastq.gz
│   ├── 20130417_Racine_copepod_1_L001_R2_001.fastq.gz
│   ├── 20130417_Racine_water1_5_L001_R1_001.fastq.gz
│   ├── 20130417_Racine_water1_5_L001_R2_001.fastq.gz
│   ├── 20130417_Racine_water2_2_L001_R1_001.fastq.gz
│   ├── 20130417_Racine_water2_2_L001_R2_001.fastq.gz
│   ├── 20130417_Racine_water3_3_L001_R1_001.fastq.gz
│   ├── 20130417_Racine_water3_3_L001_R2_001.fastq.gz
│   └── MANIFEST
├── metadata_20130417.tsv
├── results
│   ├── abs_taxonomy_silva-full.barplot.qzv
│   ├── abs_taxonomy_silva-full_lv6
│   │   ├── abs_taxonomy_silva-full_lv6.tsv
│   │   └── feature-table.biom
│   ├── abs_taxonomy_silva-full_lv6.qza
│   ├── abs_taxonomy_silva-full.qza
│   ├── abs_taxonomy_silva-full.qzv
│   ├── ancombc_silva-full_host_adapted_salinity_lv6.qza
│   ├── ancombc_silva-full_host_adapted_salinity.qza
│   ├── ancombc_silva-full_sample_type_lv6.qza
│   ├── ancombc_silva-full_sample_type.qza
│   ├── core_metrics_host_adapted_salinity_results
│   │   ├── bray_curtis_distance_matrix.qza
│   │   ├── bray_curtis_emperor.qzv
│   │   ├── bray_curtis_pcoa_results.qza
│   │   ├── evenness_significance.qzv
│   │   ├── evenness_vector.qza
│   │   ├── faith_pd_significance.qzv
│   │   ├── faith_pd_vector.qza
│   │   ├── jaccard_distance_matrix.qza
│   │   ├── jaccard_emperor.qzv
│   │   ├── jaccard_pcoa_results.qza
│   │   ├── observed_features_vector.qza
│   │   ├── rarefied_table.qza
│   │   ├── shannon_vector.qza
│   │   ├── unweighted_unifrac_distance_matrix.qza
│   │   ├── unweighted_unifrac_emperor.qzv
│   │   ├── unweighted_unifrac_host_adapted_salinity.qzv
│   │   ├── unweighted_unifrac_pcoa_results.qza
│   │   ├── weighted_unifrac_distance_matrix.qza
│   │   ├── weighted_unifrac_emperor.qzv
│   │   └── weighted_unifrac_pcoa_results.qza
│   ├── core_metrics_sample_type_results
│   │   ├── bray_curtis_distance_matrix.qza
│   │   ├── bray_curtis_emperor.qzv
│   │   ├── bray_curtis_pcoa_results.qza
│   │   ├── evenness_significance.qzv
│   │   ├── evenness_vector.qza
│   │   ├── faith_pd_significance.qzv
│   │   ├── faith_pd_vector.qza
│   │   ├── jaccard_distance_matrix.qza
│   │   ├── jaccard_emperor.qzv
│   │   ├── jaccard_pcoa_results.qza
│   │   ├── observed_features_vector.qza
│   │   ├── rarefied_table.qza
│   │   ├── shannon_vector.qza
│   │   ├── unweighted_unifrac_distance_matrix.qza
│   │   ├── unweighted_unifrac_emperor.qzv
│   │   ├── unweighted_unifrac_pcoa_results.qza
│   │   ├── unweighted_unifrac_sample_type.qzv
│   │   ├── weighted_unifrac_distance_matrix.qza
│   │   ├── weighted_unifrac_emperor.qzv
│   │   └── weighted_unifrac_pcoa_results.qza
│   ├── da_barplot_silva-full_host_adapted_salinity_lv6.qzv
│   ├── da_barplot_silva-full_host_adapted_salinity.qzv
│   ├── da_barplot_silva-full_sample_type_lv6.qzv
│   ├── da_barplot_silva-full_sample_type.qzv
│   ├── demuxed.qza
│   ├── denoised_table.qza
│   ├── denoising_stats.qza
│   ├── denoising_stats.qzv
│   ├── rarefaction_curve.qzv
│   ├── rel_taxonomy_silva-full_lv6
│   │   ├── feature-table.biom
│   │   └── rel_taxonomy_silva-full
│   ├── rel_taxonomy_silva-full_lv6.qza
│   ├── representative_sequences.mafft.qza
│   ├── representative_sequences.masked.mafft.qza
│   ├── representative_sequences.qza
│   ├── representative_sequences.qzv
│   ├── rooted_tree
│   │   └── tree.nwk
│   ├── rooted_tree.qza
│   ├── trimmed.qza
│   ├── trimmed.qzv
│   ├── unrooted_tree
│   │   └── tree.nwk
│   └── unrooted_tree.qza
├── scripts
│   ├── main_test.nf
│   ├── make_manifest.py
│   ├── nextflow.config
│   ├── P1_import.nf
│   ├── P2_filter.nf
│   ├── P3_denoise.nf
│   ├── P4_phylotree.nf
│   ├── P5_rarefaction.nf
│   ├── P6_taxonomy.nf
│   ├── P7_diversity.nf
│   ├── P8_ancombc.nf
│   └── params.config
└── work
```

## Usage Example: 
```
# importing raw fastq files
qiime tools import --type EMPPairedEndSequences --input-path raw_reads_2013_04_17/reads/ --output-path raw_reads_2013_04_17/raw_reads_2013_04_17.qza

# demultiplexing 
qiime demux emp-paired --m-barcodes-file raw_reads_2013_04_17/metadata_20130417.tsv --m-barcodes-column barcode --i-seqs raw_reads_2013_04_17/raw_reads_2013_04_17.qza --o-per-sample-sequences demultiplexed/demultiplexed_2013_04_17 --o-error-correction-details demultiplexed/demultiplexing_details.qza --verbose

# make manifest file
python3 scripts/make_manifest.py -m metadata20130417.tsv -s demultiplexed_seqs -o demultiplexed_seqs/MANIFEST

# run the pipeline
nextflow scripts/main.nf --with-report -profile lab_server

# tarball it
tar -cvf 2013_04_17-nf.results.tar.gz results/
```
