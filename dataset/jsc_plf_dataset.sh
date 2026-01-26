#!/bin/bash

cd $(dirname "${BASH_SOURCE[0]}")

curl -L -o hls4ml_LHCjet_150p_train.tar.gz "https://zenodo.org/records/3602260/files/hls4ml_LHCjet_150p_train.tar.gz?download=1"
curl -L -o hls4ml_LHCjet_150p_val.tar.gz "https://zenodo.org/records/3602260/files/hls4ml_LHCjet_150p_val.tar.gz?download=1"

# aria2c -x 16 -s 16 -o hls4ml_LHCjet_150p_train.tar.gz https://zenodo.org/records/3602260/files/hls4ml_LHCjet_150p_train.tar.gz?download=1
# aria2c -x 16 -s 16 -o hls4ml_LHCjet_150p_val.tar.gz https://zenodo.org/records/3602260/files/hls4ml_LHCjet_150p_val.tar.gz?download=1

tar -xvzf hls4ml_LHCjet_150p_train.tar.gz
tar -xvzf hls4ml_LHCjet_150p_val.tar.gz

mkdir -p jsc_plf

python3 jsc_plf_dataset.py -i ./train/ -o jsc_plf/150c-train.h5 -j 4
python3 jsc_plf_dataset.py -i ./val/ -o jsc_plf/150c-test.h5 -j 4

rm -rf ./train/
rm -rf ./val/