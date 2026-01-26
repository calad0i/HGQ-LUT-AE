#!/bin/bash

eval "$(micromamba shell hook --shell bash)"
micromamba activate hgqt-ae

cd $(dirname "${BASH_SOURCE[0]}")

if [ ! -d dataset ]; then
    mkdir dataset
fi

echo "Downloading CERNBox dataset..."
# aria2c -x 16 -s 16 -o dataset/cernbox.h5 "https://cernbox.cern.ch/s/jvFd5MoWhGs1l5v/download"
curl -L -o dataset/cernbox.h5 "https://cernbox.cern.ch/s/jvFd5MoWhGs1l5v/download"

echo "Downloading TGC dataset..."
# aria2c -x 16 -s 16 -o dataset/tgc_dataset.h5 "https://huggingface.co/datasets/Calad/fake-TGC/resolve/main/fake_TGC_0.041_pruned.h5?download=true"
curl -L -o dataset/tgc_dataset.h5 "https://huggingface.co/datasets/Calad/fake-TGC/resolve/main/fake_TGC_0.041_pruned.h5?download=true"

echo "Downloading and preprocessing JSC PLF dataset..."
source dataset/jsc_plf_dataset.sh
