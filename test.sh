#!/bin/bash

if [ ! -f /root/user-added ]; then
  sleep 60
  reset
  echo "****************************************"
  echo "** Add new user:"
  echo "****************************************"
  read -p "-> Username: " userNameVar
  read -p "-> Full Name: " fullNameVar
  if [[ "$userNameVar" != "" && "$fullNameVar" != "" ]]; then
    useradd -s /bin/bash -d "/home/$userNameVar" -m -G sudo "$userNameVar" -c "$fullNameVar"
    if [[ "$?" == "0" ]]; then
      passRet=1
      while [ $passRet -ne 0 ]; do
        passwd "$userNameVar"
	passRet=$?
      done
      echo -n "$userNameVar">/root/user-added
    fi
  fi
else
  userNameVar=`cat /root/user-added`
fi

if [ -f /root/user-added ]; then
  if [ ! -f /root/desktop-installed ]; then
    wget -O - https://repo.fortinet.com/repo/ubuntu/DEB-GPG-KEY | apt-key add -
    echo "deb [arch=amd64] https://repo.fortinet.com/repo/ubuntu/ /bionic multiverse">/etc/apt/sources.list.d/forticlient.list
    apt-get update -y
    result="$?"
    if [[ "$result" == "0" ]]; then
      apt-get install ubuntu-desktop forticlient -y
      result="$?"
      systemctl set-default multi-user
      if [[ "$result" == "0" ]]; then
	# TODO: Handle failure
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
	export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	# Fix ?!?! Forticlient which is borked on 20.04
	nvm install --lts
	npm install electron@2.0.18
	mv /opt/forticlient/gui/FortiClient-linux-x64/libnode.so /opt/forticlient/gui/FortiClient-linux-x64/libnode.so.old
	mv /opt/forticlient/gui/FortiClient-linux-x64/libffmpeg.so /opt/forticlient/gui/FortiClient-linux-x64/libffmpeg.so.old
	cp $HOME/node_modules/electron/dist/libnode.so /opt/forticlient/gui/FortiClient-linux-x64/
	cp $HOME/node_modules/electron/dist/libffmpeg.so /opt/forticlient/gui/FortiClient-linux-x64/
	rm -rf $HOME/node_modules
        echo "1">/root/desktop-installed
      else
        echo "Desktop/forticlient install failed [$result]"
      fi
    else
      echo "Update desktop/forticlient install failed [$result]"
    fi
    if [[ "$?" == "0" ]]; then
      echo "1">/root/desktop-installed
    fi
  fi
fi

if [ -f /root/desktop-installed ]; then
  if [ ! -f /root/jetbrains-installed ]; then
    USER_AGENT=('User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36')
    
    URL=$(curl 'https://data.services.jetbrains.com//products/releases?code=TBA&latest=true&type=release' -H 'Origin: https://www.jetbrains.com' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H "${USER_AGENT[@]}" -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: https://www.jetbrains.com/toolbox/download/' -H 'Connection: keep-alive' -H 'DNT: 1' --compressed | grep -Po '"linux":.*?[^\\]",' | awk -F ':' '{print $3,":"$4}'| sed 's/[", ]//g')
    echo $URL
    
    FILE=$(basename ${URL})
    DEST=$PWD/$FILE
    
    echo ""
    echo -e "\e[94mDownloading Toolbox files \e[39m"
    echo ""
    wget -cO  ${DEST} ${URL} --read-timeout=5 --tries=0
    echo ""
    echo -e "\e[32mDownload complete!\e[39m"
    echo ""
    DIR="/opt/jetbrains-toolbox"
    echo ""
    echo  -e "\e[94mInstalling to $DIR\e[39m"
    echo ""
    if mkdir ${DIR}; then
      tar -xzf ${DEST} -C ${DIR} --strip-components=1
    fi
    
    chmod -R +rwx ${DIR}
    touch ${DIR}/jetbrains-toolbox.sh
    echo "#!/bin/bash" >> $DIR/jetbrains-toolbox.sh
    echo "$DIR/jetbrains-toolbox" >> $DIR/jetbrains-toolbox.sh
    
    ln -s ${DIR}/jetbrains-toolbox.sh /usr/local/bin/jetbrains-toolbox
    chmod -R +rwx /usr/local/bin/jetbrains-toolbox
    echo ""
    rm ${DEST}
    echo  -e "\e[32mDone.\e[39m"
    echo "1">/root/jetbrains-installed
    systemctl set-default graphical
  fi
fi
