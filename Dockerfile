FROM nvidia/cuda

# prevent unity stuff from installing
RUN echo "Package: xserver-xorg*\nPin: release *\nPin-Priority: -1" >> /etc/apt/preferences
RUN echo "Package: unity*\nPin: release *\nPin-Priority: -1" >> /etc/apt/preferences
RUN echo "Package: gnome*\nPin: release *\nPin-Priority: -1" >> /etc/apt/preferences

# install general stuff
RUN apt-get update && apt-get install -y \
        build-essential \
        bzip2 \
        ca-certificates \
        checkinstall \
        dpkg-dev \
        git \
        python2.7-dev \
        swig \
        wget

# x11 support
RUN apt-get install -qqy x11-apps

# install opengl and dependencies for wxPython
RUN apt-get update && apt-get install -y \
        freeglut3 \
        freeglut3-dev \
        libgtk2.0-dev \
        libwxgtk2.8-dev \
        libwxgtk2.8-dbg \
        libwebkitgtk-dev \
        libjpeg-dev \
        libtiff-dev \
        libsdl1.2-dev \
        libcanberra-gtk-module \
        libgstreamer-plugins-base0.10-dev

# install conda and create environment with scientific packages
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-3.16.0-Linux-x86_64.sh && \
    /bin/bash /Miniconda3-3.16.0-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-3.16.0-Linux-x86_64.sh && \
    /opt/conda/bin/conda install --yes conda==3.18.3
RUN /opt/conda/bin/conda create --yes -n graal python=2.7 pip numpy scipy matplotlib cython pandas h5py ipython PIL
ENV PATH /opt/conda/envs/graal/bin:$PATH

# install python opengl bindings
RUN pip install pyopengl pyopengl-accelerate

# install wxPython 2.8 with opengl support
COPY dependencies/wxPython-src-2.8.12.1.tar.bz2 .
RUN tar -xvf wxPython-src-2.8.12.1.tar.bz2 && \
    cd wxPython-src-2.8.12.1 && \
    ./configure \
        --enable-utf8 \
        --enable-sound \
        --enable-unicode \
        --enable-geometry \
        --enable-optimize \
        --enable-monolithic \
        --enable-debug_flag \
        --enable-rpath='$ORIGIN/../lib' \
        --with-gtk=builtin \
        --with-opengl=builtin \
        --with-sdl=builtin \
        --with-expat=builtin \
        --with-libjpeg=builtin \
        --with-libpng=builtin \
        --with-libtiff=builtin \
        --with-regex=builtin \
        --with-zlib=builtin \
        --prefix="${PREFIX}" && \
    make
RUN cd dependencies/wxPython-src-2.8.12.1/wxPython && python setup.py build_ext --inplace
ENV PYTHONPATH /wxPython-src-2.8.12.1/wxPython:$PYTHONPATH

# prepare to install pycuda with opengl support
COPY dependencies/pycuda-2015.1.3.tar.gz .
COPY build_pycuda.sh .
RUN chmod 755 build_pycuda.sh

# graal
COPY GRAAL scratch/

