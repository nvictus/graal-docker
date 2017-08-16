#!/bin/bash
tar -xvf pycuda-2015.1.3.tar.gz && \
cd pycuda-2015.1.3 && \
python configure.py && \
sed -i "s/CUDA_ENABLE_GL = False/CUDA_ENABLE_GL = True/g" siteconf.py && \
cp /usr/local/nvidia/lib64/libcuda.so.352.79 /opt/conda/envs/graal/lib/libcuda.so && \
make && \
pip install -e .