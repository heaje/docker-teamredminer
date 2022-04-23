FROM ubuntu:20.04
WORKDIR /root
ARG DEBIAN_FRONTEND
RUN apt update && apt install -y curl dialog initramfs-tools libnuma1 mesa-opencl-icd wget && apt clean

# OpenCL Legacy is not required at least with a Vega 56.
# If required for different AMD cards, remove "--no-dkms" and add ",legacy" after "rocr".
# Note that installing the legacy OpenCL will install a LOT more packages and take a lot
# longer to install.
ARG AMDGPU_PRO_VERSION
RUN wget https://repo.radeon.com/amdgpu-install/21.50.2/ubuntu/focal/amdgpu-install_${AMDGPU_PRO_VERSION}_all.deb \
    && apt install -y ./amdgpu-install_${AMDGPU_PRO_VERSION}_all.deb \
    && apt update \
    && amdgpu-install -y --no-dkms --no-32 --accept-eula --opencl=rocr --usecase=opencl \
    && apt clean

ARG TRM_VERSION
RUN curl -L https://github.com/todxx/teamredminer/releases/download/${TRM_VERSION}/teamredminer-${TRM_VERSION}-linux.tgz | tar xvz \
    && mv teamredminer-${TRM_VERSION}-linux /teamredminer \
    && rm -rf teamredminer-${TRM_VERSION}-linux

#RUN useradd miner -u 2000 --user-group --system --no-create-home \
#    && chown -R miner:miner /teamredminer \
#    && chmod -R 755 /teamredminer

#User miner
ENTRYPOINT ["/teamredminer/teamredminer"]	
LABEL amd_version=${AMDGPU_PRO_VERSION} trm_version=${TRM_VERSION}
