# ==========================================
# STAGE 1: Heavy System Setup
# ==========================================
FROM nvidia/cuda:13.1.1-cudnn-devel-ubuntu24.04 AS base-system

ARG PYTHON_VERSION
ENV PYTHON_VERSION=${PYTHON_VERSION}

# ---- System Deps ----

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    ca-certificates \
    gnupg \
    wget \
    curl \
    patch \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && apt-get clean

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    binutils \
    build-essential \
    ccache \
    clang \
    clang \
    clang-format \
    clang-tidy \
    clang-tools \
    clangd \
    cmake \
    doxygen \
    dwarves \
    elfutils \
    ffmpeg \
    file \
    gcovr \
    gdb \
    gdbserver \
    gfortran \
    git \
    git-lfs \
    graphviz \
    lcov \
    libasan8 \
    libc++-dev \
    libc++abi-dev \
    libcairo2-dev \
    libclang-rt-dev \
    libffi-dev \
    libglib2.0-0t64 \
    libglib2.0-dev \
    libglvnd0 \
    libjpeg-dev \
    libpango1.0-dev \
    libpng-dev \
    libportaudio2 \
    libpq-dev \
    libsm6 \
    libsqlite3-dev \
    libssl-dev \
    libtiff-dev \
    libtool \
    libtsan2 \
    libubsan1 \
    libvulkan1 \
    libvulkan-dev \
    libwayland-client0 \
    libwebp-dev \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxext6 \
    libxkbcommon0 \
    libxml2-dev \
    libxrender1 \
    libxslt1-dev \
    linux-tools-generic \
    linux-tools-common \
    lld \
    lldb \
    llvm \
    ltrace \
    ninja-build \
    pahole \
    pkg-config \
    portaudio19-dev \
    python3-dev \
    python3-full \
    python3-pip \
    rsync \
    socat \
    strace \
    time \
    unzip \
    valgrind \
    vim \
    vulkan-tools \
    zip \
    zlib1g-dev \
    && git lfs install \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | \
    tee /etc/apt/trusted.gpg.d/lunarg.asc

RUN wget -qO /etc/apt/sources.list.d/lunarg-vulkan-noble.list \
    http://packages.lunarg.com/vulkan/lunarg-vulkan-noble.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    vulkan-sdk \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# ---- Python Environment ----

RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    ln -s /root/.local/bin/uv /usr/local/bin/uv && \
    ln -s /root/.local/bin/uvx /usr/local/bin/uvx

RUN mkdir -p /opt/uv-cache
RUN mkdir -p /venv

ENV PATH=/venv/bin:$PATH \
    UV_CACHE_DIR=/opt/uv-cache \
    VIRTUAL_ENV=/venv

RUN uv python install ${PYTHON_VERSION} && uv venv --python ${PYTHON_VERSION} ${VIRTUAL_ENV} && \
    uv pip install numpy cython mako setuptools wheel pip patchelf

ENV TORCH_CUDA_ARCH_LIST="8.6;8.9;12.0" \
    UV_HTTP_TIMEOUT=300 \
    CFLAGS="-Wno-error=deprecated-declarations -DCUDA_DISABLE_DEPRECATION_WARNINGS" \
    CXXFLAGS="-Wno-error=deprecated-declarations -DCUDA_DISABLE_DEPRECATION_WARNINGS" \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

# ---- CUDA / PyCUDA Compatibility Patch ----

# Setup PyCUDA Config
RUN echo 'def get_config():' \
         '    return {' \
         '        "CUDA_ROOT": "/usr/local/cuda",' \
         '        "CUDADRV_LIB_DIR": "/usr/local/cuda/lib64/stubs",' \
         '        "CUDADRV_LIB_NAME": "cuda"' \
         '    }' > /root/.aksetup-defaults.py

RUN uv pip install pycuda==2026.1

# ==========================================
# STAGE 2: Python dependencies setup
# ==========================================
FROM base-system AS python-dependencies

RUN uv pip install \
    torch torchvision torchaudio  \
    --index-url https://download.pytorch.org/whl/cu130 \
    --extra-index-url https://pypi.nvidia.com
RUN echo "PyTorch Installed."

RUN uv pip install \
    audio_separator \
    cached_path \
    conformer \
    dac \
    dacite \
    diffusers \
    dramatiq \
    f5-tts \
    insightface \
    jieba \
    kokoro_onnx \
    langgraph \
    llvmlite \
    lpips \
    minio \
    moviepy \
    numba \
    omegaconf \
    opencv-python \
    prometheus-client \
    protobuf \
    pydantic \
    pygit2 \
    pyright \
    s3tokenizer \
    scikit-build-core[pyproject] \
    ultralytics
RUN echo "AI/ML Python dependencies installation completed 1/2"

RUN uv pip install --no-build-isolation \
    color_matcher \
    ftfy \
    faiss-cpu \
    gguf \
    ipykernel \
    ipympl \
    ipywidgets \
    onnxruntime-gpu \
    pyloudnorm \
    sound device \
    torchcrepe \
    vector-quantize-pytorch
RUN echo "AI/ML Python dependencies installation completed 2/2"

# ==========================================
# STAGE 3: dev container setup
# ==========================================
FROM python-dependencies AS dev

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
