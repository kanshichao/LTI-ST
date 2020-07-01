#!/bin/bash

OUT_DIR="output-bninception-cub"
if [[ ! -d "${OUT_DIR}" ]]; then
    echo "Creating output dir for training : ${OUT_DIR}"
    mkdir ${OUT_DIR}
fi
CUDA_VISIBLE_DEVICES=0 python3.6 tools/main.py --cfg configs/example_bninception.yaml

CUDA_VISIBLE_DEVICES=0 python3.6 tools/main.py --cfg configs/example_bninception_test.yaml --phase test
