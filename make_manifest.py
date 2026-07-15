#!/usr/bin/env python3

"""
Goal: Make MANIFEST file for paired 16s sequencing qiime analysis
Author: Patricia Zito 
Date: Jul 15, 2026

Inputs:
    metadata file (.tsv): in the same formatting as the moving pictures tutorial. 
        (See https://data.qiime2.org/2024.10/tutorials/moving-pictures/sample_metadata.tsv)

Outputs:
    MANIFEST file (.tsv). This file should contain 3x columns: 
        1. sampleid
        2. forward_absolute_filepath
        3. reverse_absolute_filepath
"""

######################### Required Libraries #########################
# native libraries
import os
import argparse
# have to be installed
import pandas as pd


######################### Defining Functions #########################
def get_sampleids(metadata_filepath, column_name):
    '''
    Goal: takes in a standard metadata file and returns a list of sample ids. 
    Input: metadata_filepath (string). Absolute path to metadata file.
    Output: sampleid_filtered (list of strings). Contains only sample ids (no descriptive rows).
    '''
    print("Getting Metadata File")
    metadata_df = pd.read_csv(os.path.abspath(metadata_filepath), sep="\t")
    sampleid_column = metadata_df[column_name]
    sampleid_filtered = sampleid_column[~sampleid_column.str.contains("#", # filter out descriptive rows
                                                                        na = False, 
                                                                        case = False)]
    print("Obtained metadata file: ", os.path.abspath(metadata_filepath))
    print("\n")
    return(sampleid_filtered)

def get_files_in_directory(path, file_type):
    '''
    Goal: Creates a list of all files of a certain type within a directory
    Input: 
        path (string). Indicates the path to the directory
        file_type (string). Indicates the extension of a certain file type (e.g. ".fastq" or ".csv").
    Output: dir_content (list of strings). Indicates 
    '''
    all_content = os.listdir(path)
    dir_content = [file for file in all_content if file_type in file]
    return(dir_content)
    
def make_manifest(sampleid, path):
    '''
    Goal: Make the manifest file
    Inputs: 
        sampleid (list of strings). This comes from the first column of the original metadata file.
        path (string). Indicates the path to sequence files. 
    Output: manifest_df (pandas dataframe) 
    '''
    manifest_list = []
    fastq_files = get_files_in_directory(path=path, file_type= ".fastq")
    for id in sampleid:
        print("SAMPLE ID = ", id)
        # initialize new filepaths for new sample
        forward_absolute_filepath = None
        reverse_absolute_filepath = None
        for file in fastq_files: # is there a better way of doing this?
            if id in file: 
                if "_R1_" in file:
                    forward_absolute_filepath = os.path.abspath(path) + "/" + file
                    print("FORWARD PATH: ", forward_absolute_filepath)
                elif "_R2_" in file:
                    reverse_absolute_filepath = os.path.abspath(path) + "/" + file
                    print("REVERSE PATH: ", reverse_absolute_filepath)
        if forward_absolute_filepath and reverse_absolute_filepath:
            sample_row = {"sampleid": id, 
                        "forward-absolute-filepath": forward_absolute_filepath, 
                        "reverse-absolute-filepath": reverse_absolute_filepath}
            manifest_list.append(sample_row)
        else: 
            print("\n")
            print("ERROR")
            print("sample", id, "paired .fastq files were not found inside", os.path.abspath(path))
            print("sample", id, "was not included in the final MANIFEST file")
    
    manifest_df = pd.DataFrame(manifest_list)
    return(manifest_df)    

######################### User Interface #########################
parser = argparse.ArgumentParser(
                    prog = "Make MANIFEST",
                    description = "Make MANIFEST file for paired 16s sequencing qiime analysis",
                    epilog = "honk twice if you want to finish your PhD!!!")

# metadata filepath
parser.add_argument("-m", "-metadata",
                    type = str,
                    required = True,
                    help = "metadata file.")

# metadata sample id column
parser.add_argument("-c", "-column_name",
                    type = str,
                    default = "sampleid",
                    help = "column name for sample ids in metadata file. " \
                    "Default: 'sampleid'.")

# sequences filepath 
parser.add_argument("-s", "-seqs_path",
                    type = str,
                    default = ".",
                    help = "path to the directory containing all paired .fastq sequence files (string). " \
                    ".fasta files are not supported. Default: current directory.")

# output filepath 
parser.add_argument("-o", "-output",
                    type = str,
                    default = "./MANIFEST",
                    help = "path to output MANIFEST (.tsv) file. " \
                    "Default: current directory.")

######################### Running #########################
# get user inputs 
args = parser.parse_args()

# run functions 
sampleids = get_sampleids(metadata_filepath= args.m, column_name = args.c)
manifest_df = make_manifest(sampleid= sampleids, path = args.s)

# export
manifest_df.to_csv(args.o, index = False, sep = '\t')
print("\n")
print("Saved MANIFEST to:", args.o)