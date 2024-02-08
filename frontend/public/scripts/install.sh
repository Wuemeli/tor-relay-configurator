#!/bin/bash

while [[ $# -gt 0 ]]; do
    case "$1" in
        --node-type)
            nodeType="$2"
            shift 2
            ;;
        --relay-name)
            relayName="$2"
            shift 2
            ;;
        --contact-info)
            contactInfo="$2"
            shift 2
            ;;
        --enable-ipv6)
            enableIPv6="$2"
            shift 2
            ;;
        --or-port)
            orPort="$2"
            shift 2
            ;;
        --dir-port)
            dirPort="$2"
            shift 2
            ;;
        --traffic-limit)
            trafficLimit="$2"
            shift 2
            ;;
        --max-bandwidth)
            maxBandwidth="$2"
            shift 2
            ;;
        --max-burst-bandwidth)
            maxBurstBandwidth="$2"
            shift 2
            ;;
        --enable-nyx-monitoring)
            enableNyxMonitoring="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

echo "Node Type: $nodeType"
echo "Relay Name: $relayName"
echo "Contact Info: $contactInfo"
echo "Enable IPv6: $enableIPv6"
echo "OR Port: $orPort"
echo "Dir Port: $dirPort"
echo "Traffic Limit: $trafficLimit"
echo "Max Bandwidth: $maxBandwidth"
echo "Max Burst Bandwidth: $maxBurstBandwidth"
echo "Enable Nyx Monitoring: $enableNyxMonitoring"

C_RED="\e[31m"
C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_DEFAULT="\e[39m"

function echoInfo() {
  echo -e "${C_CYAN}$1${C_DEFAULT}"
}

function echoError() {
  echo -e "${C_RED}$1${C_DEFAULT}"
}

function echoSuccess() {
  echo -e "${C_GREEN}$1${C_DEFAULT}"
}

function handleError() {
  echoError "-> ERROR"
  sudo /etc/init.d/tor stop
  echoError "An error occured on the last setup step."
  echoError "If you think there is a problem with this script please share information about the error and you system configuration for debugging: tor@flxn.de"
}

RELEASE=$(lsb_release -cs)
OS=$(lsb_release -is)

if [ "$OS" != "Debian" ] && [ "$OS" != "Ubuntu" ] && [ "$OS" != "Arch" ] && [ "$OS" != "CentOS" ]; then
  echoError "This script only supports Debian, Ubuntu, Arch and CentOS"
  exit 1
fi

echo -e $C_CYAN #cyan
cat << "EOF"

 _____            ___     _
|_   _|__ _ _ ___| _ \___| |__ _ _  _   __ ___
  | |/ _ \ '_|___|   / -_) / _` | || |_/ _/ _ \
  |_|\___/_|     |_|_\___|_\__,_|\_, (_)__\___/
                                 |__/

EOF

echo -e $C_DEFAULT #default
echo "              [Relay Setup]"
echo "This script will ask for your sudo password."
echo "----------------------------------------------------------------------"

echoInfo "Updating package list..."

if [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
  sudo apt-get -y update > /dev/null && echoSuccess "-> OK" || handleError
elif [ "$OS" == "Arch" ]; then
  sudo pacman -Sy > /dev/null && echoSuccess "-> OK" || handleError
elif [ "$OS" == "CentOS" ]; then
  sudo yum -y update > /dev/null && echoSuccess "-> OK" || handleError
fi

echoInfo "Installing necessary packages..."

if [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
  sudo apt-get -y install apt-transport-https psmisc dirmngr ntpdate > /dev/null && echoSuccess "-> OK" || handleError
elif [ "$OS" == "Arch" ]; then
  sudo pacman -S --noconfirm tor ntp > /dev/null && echoSuccess "-> OK" || handleError
elif [ "$OS" == "CentOS" ]; then
  sudo yum -y install epel-release tor ntp > /dev/null && echoSuccess "-> OK" || handleError
fi

echoInfo "Updating NTP..."
sudo ntpdate pool.ntp.org > /dev/null && echoSuccess "-> OK" || handleError

if [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
  echoInfo "Adding Torproject apt repository..."
  sudo touch /etc/apt/sources.list.d/tor.list && echoSuccess "-> touch OK" || handleError
  echo "deb https://deb.torproject.org/torproject.org $RELEASE main" | sudo tee /etc/apt/sources.list.d/tor.list > /dev/null && echoSuccess "-> tee1 OK" || handleError
  echo "deb-src https://deb.torproject.org/torproject.org $RELEASE main" | sudo tee --append /etc/apt/sources.list.d/tor.list > /dev/null && echoSuccess "-> tee2 OK" || handleError
  echoInfo "Adding Torproject GPG key..."
  curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | sudo apt-key add - && echoSuccess "-> OK" || handleError
  sudo apt-get -y update > /dev/null && echoSuccess "-> OK" || handleError
fi

if $INSTALL_NYX
then
  echoInfo "Installing Nyx..."

  if [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
    sudo apt-get -y install python3-distutils > /dev/null || echoError "-> Error installing python3-distutils"
    sudo apt-get -y install nyx > /dev/null && echoSuccess "-> OK" || sudo pip install nyx > /dev/null && echoSuccess "-> OK" || echoError "-> Error installing Nyx via apt or pip"
  elif [ "$OS" == "Arch" ]; then
    sudo pacman -S --noconfirm nyx > /dev/null && echoSuccess "-> OK" || echoError "-> Error installing Nyx via pacman"
  elif [ "$OS" == "CentOS" ]; then
    sudo yum -y install epel-release > /dev/null && sudo yum -y install nyx > /dev/null && echoSuccess "-> OK" || sudo pip install nyx > /dev/null && echoSuccess "-> OK" || echoError "-> Error installing Nyx via yum or pip"
  else
    echoError "Nyx installation is not supported on this platform."
  fi
fi

echoInfo "Installing Tor..."

if [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
  sudo apt-get -y install tor deb.torproject.org-keyring > /dev/null && echoSuccess "-> OK" || handleError
  sudo chown -R debian-tor:debian-tor /var/log/tor && echoSuccess "-> OK" || handleError
elif [ "$OS" == "Arch" ]; then
  sudo pacman -S --noconfirm tor > /dev/null && echoSuccess "-> OK" || handleError
elif [ "$OS" == "CentOS" ]; then
  sudo yum -y install tor > /dev/null && echoSuccess "-> OK" || handleError
fi

echoInfo "Setting Tor config..."

if [ "$nodeType" = "relay" ]
then

  echoInfo "Configuring Tor as a middle relay..."

  cat << EOF | sudo tee -a /etc/tor/torrc > /dev/null
Nickname $relayName
ContactInfo $contactInfo [tor-relay.co]
ORPort $orPort
DirPort $dirPort
EOF

elif [ "$nodeType" = "exit" ]
then
  echoInfo "Configuring Tor as an exit relay..."

  cat << EOF | sudo tee -a /etc/tor/torrc > /dev/null
Nickname $relayName
ContactInfo $contactInfo [tor-relay.co]
ORPort $orPort
DirPort $dirPort
ExitPolicy accept *:*
TrafficRate $trafficLimit
RelayBandwidthRate $maxBandwidth
RelayBandwidthBurst $maxBurstBandwidth
EOF

elif [ "$nodeType" = "bridge" ]
then
  echoInfo "Configuring Tor as a bridge..."

  cat << EOF | sudo tee -a /etc/tor/torrc > /dev/null
BridgeRelay 1
Nickname $relayName
ContactInfo $contactInfo [tor-relay.co]
ORPort $orPort
DirPort $dirPort
Exitpolicy reject *:*
EOF

fi
if [ "$nodeType" = "exit" ]
then
  echoInfo "Downloading Exit Notice to /etc/tor/tor-exit-notice.html..."
  echo -e "\e[1mPlease edit this file and replace YOUR_EMAIL_ADDRESS with your e-mail address!"
  echo -e "\e[1mAlso note that this is the US version. If you are not in the US please edit the file and remove the US-Only sections!\e[0m"
  sudo wget -q -O /etc/tor/tor-exit-notice.html "https://raw.githubusercontent.com/flxn/tor-relay-configurator/master/misc/tor-exit-notice.html" && echoSuccess "-> OK" || handleError
fi

function disableIPV6() {
  sudo sed -i -e '/INSERT_IPV6_ADDRESS/d' /etc/tor/torrc
  sudo sed -i -e 's/IPv6Exit 1/IPv6Exit 0/' /etc/tor/torrc
  sudo sed -i -e '/\[..\]/d' /etc/tor/torrc
  echoError "IPv6 support has been disabled!"
  echo "If you want to enable it manually find out your IPv6 address and add this line to your /etc/tor/torrc"
  echo "ORPort [YOUR_IPV6_ADDRESS]:YOUR_ORPORT (example: \"ORPort [2001:123:4567:89ab::1]:9001\")"
  echo "or for a bridge: ServerListenAddr obfs4 [..]:YOUR_OBFS4PORT"
  echo "Then run \"sudo systemctl restart tor\""
}

if $CHECK_IPV6
then
  echoInfo "Testing IPV6..."
  IPV6_GOOD=false
  sudo ping6 -c2 2001:858:2:2:aabb:0:563b:1526 && sudo ping6 -c2 2620:13:4000:6000::1000:118 && sudo ping6 -c2 2001:67c:289c::9 && sudo ping6 -c2 2001:678:558:1000::244 && sudo ping6 -c2 2607:8500:154::3 && sudo ping6 -c2 2001:638:a000:4140::ffff:189 && IPV6_GOOD=true
  if [ ! IPV6_GOOD ]
  then
    sudo systemctl stop tor
    echoError "Could not reach Tor directory servers via IPV6"
    disableIPV6
  else
    echoSuccess "Seems like your IPV6 connection is working"

    IPV6_ADDRESS=$(ip -6 addr | grep inet6 | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)
    if [ -z "$IPV6_ADDRESS" ]
    then
      echoError "Could not automatically find your IPv6 address"
      echo "If you know your global (!) IPv6 address you can enter it now"
      echo "Please make sure that you enter it correctly and do not enter any other characters"
      echo "If you want to skip manual IPv6 setup leave the line blank and just press ENTER"
      read -p "IPv6 address: " IPV6_ADDRESS

      if [ -z "$IPV6_ADDRESS" ]
      then
        disableIPV6
      else
        sudo sed -i "s/INSERT_IPV6_ADDRESS/$IPV6_ADDRESS/" /etc/tor/torrc
        echoSuccess "IPv6 Support enabled ($IPV6_ADDRESS)"
      fi
    else
      sudo sed -i "s/INSERT_IPV6_ADDRESS/$IPV6_ADDRESS/" /etc/tor/torrc
      echoSuccess "IPv6 Support enabled ($IPV6_ADDRESS)"
    fi
  fi
fi

sleep 10

echoInfo "Reloading Tor config..."
if [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
  sudo systemctl reload tor > /dev/null && echoSuccess "-> OK" || handleError
elif [ "$OS" == "Arch" ]; then
  sudo systemctl reload tor > /dev/null && echoSuccess "-> OK" || handleError
elif [ "$OS" == "CentOS" ]; then
  sudo systemctl reload tor > /dev/null && echoSuccess "-> OK" || handleError
fi

echo ""
echoSuccess "=> Setup finished"
echo ""
echo "Be sure to setup automatic security updates for your system."
echo "Also be sure that your Firewall is forwarding the ORPORT: $orPort and DIRPORT: $dirPort to your server."
echo "Tor will now check if your ports are reachable. This may take up to 20 minutes."
echo "Check /var/log/tor/notices.log for an entry like:"
echo "\"Self-testing indicates your ORPort is reachable from the outside. Excellent.\""
echo ""
