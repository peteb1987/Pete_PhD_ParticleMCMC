#!/bin/bash
qsub -l lr=1 -m be -t 1-25 ge_script.sh