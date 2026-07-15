"""
Goal: Make MANIFEST file for 16s qiime analysis

Inputs:
    metadata file (.tsv): in the same formatting as the moving pictures tutorial. 
        (See https://data.qiime2.org/2024.10/tutorials/moving-pictures/sample_metadata.tsv)

Outputs:
    MANIFEST file (.tsv). This file should contain 3x columns: 
        1. sampleid
        2. forward_absolute_filepath
        3. reverse_absolute_filepath
"""

import os
import re 
import sys
import pandas as pd

def get_sampleids(metadata_path, sample_id_column_name): # if different sampleid column name
    '''
    Goal: takes in a standard metadata file and returns a list of sample ids. 
    Input: metadata_path (string). Absolute path to metadata file.
    Output: sampleid_filtered (list of strings). Contains only sample ids (no descriptive rows).
    '''
    metadata_df = pd.read_csv("/Users/pzito/Desktop/nextflow_toy_data/metadata_20130417.tsv", sep="\t")
    sampleid_column = metadata_df[sample_id_column_name]
    sampleid_filtered = sampleid_column[~sampleid_filtered.str.contains("#", # filter out descriptive rows
                                                                        na = False, 
                                                                        case = False)]
    return(sampleid_filtered)

def get_fastq_in_directory(path):
    all_content = os.listdir(path)
    seqs_content = [file for file in all_content if ".fastq.gz" or ".fastq" in file]
    return(seqs_content)

def get_absolute_filepaths(sampleid, path):
    manifest_list = []
    fastq_files = get_fastq_in_directory(path)
    for id in sampleid:
        print("SAMPLE ID = ", id)
        # initialize new filepaths for new sample
        forward_absolute_filepath = None
        reverse_absolute_filepath = None
        for file in fastq_files: # better way of doing this
            if id in file: 
                if "_R1_" in file:
                    forward_absolute_filepath = path + "/" + file
                    print("FORWARD PATH: ", forward_absolute_filepath)
                elif "_R2_" in file:
                    reverse_absolute_filepath = path + "/" + file
                    print("REVERSE PATH: ", reverse_absolute_filepath)
        if forward_absolute_filepath and reverse_absolute_filepath:
            sample_row = {"sampleid": id, 
                        "forward_absolute_filepath": forward_absolute_filepath, 
                        "reverse_absolute_filepath": reverse_absolute_filepath}
            manifest_list.append(sample_row)
        else: 
            print("Sample", id, "files were not found inside ", path)
    
    return(manifest_list)
    


# does the user provide a path?