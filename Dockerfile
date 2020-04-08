FROM phusion/baseimage:latest
MAINTAINER Jesus Macias Portela<jesus.maciasportela@telefonica.com>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

# Activar SSH
RUN rm -fr /etc/service/sshd/down

# Update root password
# CHANGE IT # to something like root:ASdSAdfÑ3
RUN echo "root:root" | chpasswd

# Enable ssh for root
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
# Enable this option to prevent SSH drop connections
RUN printf "ClientAliveInterval 15\\nClientAliveCountMax 8" >> /etc/ssh/sshd_config

#Install Ansible
RUN apt-get update && apt-get install -y software-properties-common build-essential python python3-pip python-dev python3-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev
RUN apt-get install -y python-setuptools python-dev libffi-dev libssl-dev git sshpass tree git vim jq zsh wget
RUN pip3 install --upgrade pip
RUN pip3 install cryptography shyaml passlib netaddr
RUN pip3 install --upgrade setuptools wheel
RUN pip3 install --upgrade pyyaml jinja2 pycrypto
RUN pip3 install --upgrade pywinrm
RUN pip3 install ansible==2.9.6
RUN ansible --version | grep "python version"

#Powerline Font
RUN cd /root \
    && wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf \
    && wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf \
    && mkdir /root/.fonts/ \
    && mv PowerlineSymbols.otf /root/.fonts/ \
    && mkdir -p /root/.config/fontconfig/conf.d \
    && mv 10-powerline-symbols.conf /root/.config/fontconfig/conf.d/

#Install Oh my ZSH
RUN wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | bash -l
RUN chsh -s `which zsh`

#Oh my ZSH plugin
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions

#Customize Oh my ZSH
COPY zshrc /root/.zshrc

#Ansible vault password
RUN echo "onlife20" > /root/.vault_pass.txt

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
