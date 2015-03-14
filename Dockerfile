FROM debian:latest
MAINTAINER Yannick Croissant <yannick.croissant@gmail.com>

# Packages
RUN apt-get update && \
    apt-get -y install openssh-server python make g++ wget build-essential git curl zsh vim sudo

# SSH
RUN mkdir -p /var/run/sshd && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config

# User
RUN adduser --uid 1027 --ingroup users --disabled-password --shell /bin/zsh country && \
    echo "country ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER country

# SSH Key
RUN mkdir -p $HOME/.ssh && \
    curl https://github.com/yannickcr.keys >> $HOME/.ssh/authorized_keys && \
    chmod 600 $HOME/.ssh/authorized_keys && \
    chmod 700 $HOME/.ssh

# ZSH
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# Dotfiles
RUN git clone https://github.com/yannickcr/dotfiles $HOME/.dotfiles && \
    mv $HOME/.dotfiles/unix/.oh-my-zsh/themes/country.zsh-theme $HOME/.oh-my-zsh/themes/country.zsh-theme && \
    mv $HOME/.dotfiles/unix/.gitconfig $HOME/.gitconfig && \
    mv $HOME/.dotfiles/unix/.ls_colors $HOME/.ls_colors && \
    mv $HOME/.dotfiles/unix/.zshrc $HOME/.zshrc && \
    rm -rf $HOME/.dotfiles

# NVM
RUN git clone https://github.com/creationix/nvm.git $HOME/.nvm && \
    cd $HOME/.nvm && \
    git checkout `git describe --abbrev=0 --tags` && \
    echo "source $HOME/.nvm/nvm.sh" >> $HOME/.zshrc && \
    echo "nvm use stable" >> $HOME/.zshrc

# Workspace
RUN mkdir -p $HOME/workspace

# Switch
USER root

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd"]
CMD ["-D"]
