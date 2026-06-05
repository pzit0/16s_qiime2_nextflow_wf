#!/bin/bash -ue
qiime tools import 		--type 'SampleData[PairedEndSequencesWithQuality]' 		--input-path 16s_reads 		--output-path demuxed.qza
