FROM nvidia/cuda

# prevent unity stuff from installing
RUN echo "Package: xserver-xorg*\nPin: release *\nPin-Priority: -1" >> /etc/apt/preferences
RUN echo "Package: unity*\nPin: release *\nPin-Priority: -1" >> /etc/apt/preferences
RUN echo "Package: gnome*\nPin: release *\nPin-Priority: -1" >> /etc/apt/preferences

# install general stuff
RUN apt-get update && apt-get install -y \
        software-properties-common \
        apt-transport-https \
        build-essential \
        ca-certificates \
        checkinstall \
        python2.7-dev \
        dpkg-dev \
        bzip2 \
        git \
        swig \
        wget \
        curl \
        vim

# install sublime text
RUN wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add - && \
    echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
RUN apt-get update && apt-get install sublime-text

# install x11 support
RUN apt-get install -qqy x11-apps

# install opengl and dependencies for wxPython
RUN add-apt-repository --yes ppa:nilarimogard/webupd8
RUN apt-get update && apt-get install -y \
        gtk2.0 \
        libgtk2.0-dev \
        libwxbase2.8-0 \
        libwxbase2.8-dbg \
        libwxbase2.8-dev \
        libwxgtk-media2.8-0 \
        libwxgtk-media2.8-dbg \
        libwxgtk-media2.8-dev \
        libwxgtk2.8-0 \
        libwxgtk2.8-dev \
        libwxgtk2.8-dbg \
        libsdl1.2-dev \
        libjpeg-dev \
        libtiff-dev \
        freeglut3 \
        freeglut3-dev

# install conda and build environment
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh && \
    bash Miniconda2-latest-Linux-x86_64.sh -p /miniconda2 -b && \
    rm Miniconda2-latest-Linux-x86_64.sh
ENV PATH /miniconda2/bin:$PATH
ENV LD_LIBRARY_PATH /miniconda2/lib:/usr/local/lib:/usr/lib:/lib:$LD_LIBRARY_PATH
ADD environment.yml /
RUN conda config --set always_yes yes --set changeps1 no && \
    conda config --add channels conda-forge && \
    conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --get && \
    conda update -q conda && \
    conda info -a && \
    conda env update -q -n root --file environment.yml && \
    conda clean --tarballs --index-cache --lock

# build and install wxPython 2.8 with openGL support
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
        --with-gtk=builtin \
        --with-opengl=builtin \
        --with-sdl=builtin \
        --with-expat=builtin \
        --with-libjpeg=builtin \
        --with-libpng=builtin \
        --with-libtiff=builtin \
        --with-regex=builtin \
        --with-zlib=builtin \
    && make
RUN cd wxPython-src-2.8.12.1/wxPython && python setup.py build_ext --inplace
ENV PYTHONPATH /wxPython-src-2.8.12.1/wxPython:$PYTHONPATH

# install pycuda with openGL support
COPY dependencies/pycuda-2017.1.1.tar.gz .
RUN tar -xvf pycuda-2017.1.1.tar.gz && \
    cd pycuda-2017.1.1 && \
    python configure.py && \
    sed -i "s/CUDA_ENABLE_GL = False/CUDA_ENABLE_GL = True/g" siteconf.py && \
    make && \
    pip install -e .

# graal
COPY GRAAL /GRAAL
