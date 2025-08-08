#!/bin/bash
wget -qO- https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
apt update
apt install spotify-client -y
