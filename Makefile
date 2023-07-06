.PHONY: thirdparty

SHELL := /bin/bash

openfoam-dir := thirdparty/openfoam/etc/bashrc
ithacafv-dir := thirdparty/ithaca-fv/etc/bashrc

CORES?=1

models: ml rom

install:
	npm install

install-nvidia-docker:
	@DISTRIBUTION=$$(. /etc/os-release;echo $${ID}$${VERSION_ID}); \
	echo $$DISTRIBUTION; \
	curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg; \
	curl -s -L https://nvidia.github.io/libnvidia-container/experimental/$$DISTRIBUTION/libnvidia-container.list | \
	sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
	sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list; \
	sudo apt-get update; \
	sudo apt-get install -y nvidia-container-toolkit; \
	sudo nvidia-ctk runtime configure --runtime=docker; \
	sudo systemctl restart docker

requirements-debian:
	sudo apt-get install build-essential autoconf autotools-dev cmake gawk gnuplot flex libfl-dev libreadline-dev zlib1g-dev openmpi-bin libopenmpi-dev mpi-default-bin mpi-default-dev libgmp-dev libmpfr-dev libmpc-dev nodejs openscad libgl1-mesa-glx xvfb \
	&& pip3 install -r requirements.txt

thirdparty:
	cd thirdparty && CORES=${CORES} ./make.sh && cd .. && pip3 install -r requirements.txt && npm i

tools:
	npm install --prefix applications/steady/online

ml:
	source $(openfoam-dir) && cd OF && ./Allrun.ml ${CORES}

rom:
	source $(openfoam-dir) && source $(ithacafv-dir) && cd OF && ./Allrun.rom ${CORES}

clean:
	source $(openfoam-dir) && cd OF && ./Allclean
