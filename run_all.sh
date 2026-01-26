#!/bin/bash

n_thread=$1

if [ -z "$n_thread" ]; then
  echo "Number of threads not provided. Using default of 4." >&2
  n_thread=4
fi

eval "$(micromamba shell hook --shell bash)"
micromamba activate hgqt-ae

echo "Software inference, Verilog generation and Functional Simulation with Verilator."
echo "This may take a while..."
echo "==============================="
echo "JSC OpenML"
echo "==============================="
# python3 src/jsc_hlf/run_train.py -i dataset/openml_cache.h5 -o models/jsc_hlf/openml -m hgqt
python3 src/jsc_hlf/run_test.py -d dataset/openml_cache.h5 -i models/jsc_hlf/openml -o models/jsc_hlf/openml/verilog -j 5 -lc 2

echo "==============================="
echo "JSC CERNBox"
echo "==============================="
# python3 src/jsc_hlf/run_train.py -i dataset/cernbox.h5 -o models/jsc_hlf/cernbox --cern-box -m hgqt
python3 src/jsc_hlf/run_test.py -d dataset/cernbox.h5 -i models/jsc_hlf/cernbox -o models/jsc_hlf/cernbox/verilog --cern-box -j 5 -lc 2

echo "==============================="
echo "JSC PLF, 3 feature, 32 particles"
echo "==============================="
# python3 src/jsc_plf/run_train.py -i dataset/jsc_plf -o models/jsc_plf/32-3 -n 32 --ptetaphi -m hgqt
python3 src/jsc_plf/run_test.py -d dataset/jsc_plf -i models/jsc_plf/32-3 -o models/jsc_plf/32-3/verilog -n 32 --ptetaphi -lc 3 -j 1

echo "==============================="
echo "JSC PLF, 16 feature, 32 particles"
echo "==============================="
# python3 src/jsc_plf/run_train.py -i dataset/jsc_plf -o models/jsc_plf/32-16 -n 32 -m hgqt
python3 src/jsc_plf/run_test.py -d dataset/jsc_plf -i models/jsc_plf/32-16 -o models/jsc_plf/32-16/verilog -n 32 -lc 3.1 -j 1

echo "==============================="
echo "JSC PLF, 16 feature, 64 particles"
echo "==============================="
# python3 src/jsc_plf/run_train.py -i dataset/jsc_plf -o models/jsc_plf/64-16 -n 64 -m hgqt
python3 src/jsc_plf/run_test.py -d dataset/jsc_plf -i models/jsc_plf/64-16 -o models/jsc_plf/64-16/verilog -n 64 -lc 3.1 -j 1

echo "==============================="
echo "TGC (Hybrid Model)"
echo "==============================="
# python3 src/tgc/run_train.py -i dataset/tgc_dataset.h5 -o models/tgc -m hgqt-h
python3 src/tgc/run_test.py -d dataset/tgc_dataset.h5 -i models/tgc -o models/tgc/verilog -j 3

echo "Starting Vivado Synthesis..."

prj_dirs=$(find models -type d -name verilog -exec ls {} \;)

ls -d models/*/verilog/* models/*/*/verilog/* | parallel -j $n_thread --bar --eta 'cd {} && vivado -mode batch -source build_vivado_prj.tcl > synth.log'

echo "Vivado Synthesis Completed."

echo "================================"
echo "JSC HLF OpenML Results:"
da4ml report models/jsc_hlf/openml/verilog/* -c comb_metric latency 'latency(ns)' LUT DSP FF 'Fmax(MHz)'

echo "================================"
echo "JSC HLF CERNBox Results:"
da4ml report models/jsc_hlf/cernbox/verilog/* -c comb_metric latency 'latency(ns)' LUT DSP FF 'Fmax(MHz)'

echo "================================"
echo "JSC PLF 32 Particles 3 Features Results:"
da4ml report models/jsc_plf/32-3/verilog/* -c comb_metric latency 'latency(ns)' LUT DSP FF 'Fmax(MHz)'

echo "================================"
echo "JSC PLF 32 Particles 16 Features Results:"
da4ml report models/jsc_plf/32-16/verilog/* -c comb_metric latency 'latency(ns)' LUT DSP FF 'Fmax(MHz)'

echo "================================"
echo "JSC PLF 64 Particles 16 Features Results:"
da4ml report models/jsc_plf/64-16/verilog/* -c comb_metric latency 'latency(ns)' LUT DSP FF 'Fmax(MHz)'

echo "================================"
echo "TGC Results:"
da4ml report models/tgc/verilog/* -c comb_metric latency 'latency(ns)' LUT DSP FF 'Fmax(MHz)' -s latency 
