#!/bin/bash

set -e

# Uninstall tor
# systemctl stop tor
# apt-get remove tor -y

while [[ $# -gt 0 ]]; do
    case "$1" in
        --os)
            os="$2"
            shift 2
            ;;
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
        --obsf4-port)
            obsf4Port="$2"
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
        --block-bad-ips)
            blockBadIps="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

echo "OS: $os"
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
echo "Block Bad IPs: $blockBadIps"

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
  sudo systemctl stop tor
  echoError "An error occured on the last setup step."
}


echo -e $C_CYAN #cyan
cat << "EOF"

 _____            ___     _
|_   _|__ _ _ ___| _ \___| |__ _ _  _   
  | |/ _ \ '_|___|   / -_) / _` | || |_
  |_|\___/_|     |_|_\___|_\__,_|\_, (_)
                                 |__/

EOF

echo -e $C_DEFAULT
echo "              [Relay Setup]"
echo "This script maybe will ask for your sudo password."
echo "----------------------------------------------------------------------"

if ! [ -x "$(command -v sudo)" ]; then
  echoError "Error: sudo is not installed."
  echoError "Please install sudo and run this script again."
  exit 1
fi

if [ "$os" == "debian" ] || [ "$os" == "ubuntu" ]; then
  sudo apt-get update && echoSuccess "-> OK" || handleError
elif [ "$os" == "arch" ]; then
  sudo pacman -Sy && echoSuccess "-> OK" || handleError
elif [ "$os" == "centos" ]; then
  sudo yum -y update && echoSuccess "-> OK" || handleError
fi

echoInfo "Installing necessary packages..."

RELEASE=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d'=' -f2)

if [ "$os" == "debian" ] || [ "$os" == "ubuntu" ]; then
sudo apt-get -y install curl apt-transport-https wget gpg && echoSuccess "-> OK" || handleError
if [ "$os" == "debian" ]; then
echoInfo "Adding Torproject apt repository..."
  sudo touch /etc/apt/sources.list.d/tor.list && echoSuccess "-> touch OK" || handleError
  echo "deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $RELEASE main" | sudo tee /etc/apt/sources.list.d/tor.list && echoSuccess "-> tee1 OK" || handleError
  echo "deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $RELEASE main" | sudo tee /etc/apt/sources.list.d/tor.list && echoSuccess "-> tee2 OK" || handleError
  echoInfo "Adding Torproject GPG key..."
  wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null && echoSuccess "-> OK" || handleError
  sudo apt -y update && echoSuccess "-> OK" || handleError
  sudo apt -y install tor deb.torproject.org-keyring && echoSuccess "-> OK" || handleError
  fi 
  
  sudo apt-get -y update && echoSuccess "-> OK" || handleError
  sudo apt-get install tor psmisc dirmngr -y && echoSuccess "-> OK" || handleError
elif [ "$os" == "arch" ]; then
  sudo pacman -S --noconfirm tor curl && echoSuccess "-> OK" || handleError
elif [ "$os" == "centos" ]; then
  sudo yum -y install curl epel-release && echoSuccess "-> OK" || handleError
  sudo touch /etc/yum.repos.d/Tor.repo && echoSuccess "-> OK" || handleError
  echo "[tor]
name=Tor for Enterprise Linux $releasever - $basearch
baseurl=https://rpm.torproject.org/centos/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://rpm.torproject.org/centos/public_gpg.key
cost=100 " | sudo tee /etc/yum.repos.d/Tor.repo && echoSuccess "-> OK" || handleError
  sudo yum -y install tor && echoSuccess "-> OK" || handleError
fi

echoInfo "Setting Tor config..."

if [ "$nodeType" = "relay" ]
then
  echoInfo "Configuring Tor as a middle relay..."

  if [ "$os" == "debian" ] || [ "$os" == "ubuntu" ]; then
    sudo apt-get -y install tor && echoSuccess "-> OK" || handleError
  elif [ "$os" == "arch" ]; then
    sudo pacman -S --noconfirm tor && echoSuccess "-> OK" || handleError
  elif [ "$os" == "centos" ]; then
    sudo yum -y install tor && echoSuccess "-> OK" || handleError
  fi

cat << EOF | sudo tee -a /etc/tor/torrc > /dev/null
Nickname $relayName
ContactInfo $contactInfo [tor-relay.dev]
ORPort $orPort
DirPort $dirPort
ExitRelay   0
SocksPort   0   
ExitPolicy reject *:*
$(if [ "$trafficLimit" != "nolimit" ]; then echo "AccountingMax $trafficLimit"; fi)
$(if [ "$maxBandwidth" != "nolimit" ]; then echo "RelayBandwidthRate $maxBandwidth"; fi)
$(if [ "$maxBurstBandwidth" != "nolimit" ]; then echo "RelayBandwidthBurst $maxBurstBandwidth"; fi)
$(if [ "$trafficLimit" != "nolimit" ]; then echo "AccountingStart month  1  00:00"; fi)
EOF

fi

if [ "$nodeType" = "exit" ]
then
  echoInfo "Configuring Tor as an exit relay..."

  cat << EOF | sudo tee -a /etc/tor/torrc > /dev/null
Nickname $relayName
ContactInfo $contactInfo [tor-relay.dev]
ORPort $orPort
DirPort $dirPort
ExitPolicy accept *:*
$(if [ "$blockBadIps" = "true" ]; then curl -s https://tornull.org/tornull-bl.txt | sudo tee -a /etc/tor/torrc > /dev/null; fi)
$(if [ "$trafficLimit" != "nolimit" ]; then echo "AccountingMax $trafficLimit"; fi)
$(if [ "$maxBandwidth" != "nolimit" ]; then echo "RelayBandwidthRate $maxBandwidth"; fi)
$(if [ "$maxBurstBandwidth" != "nolimit" ]; then echo "RelayBandwidthBurst $maxBurstBandwidth"; fi)
$(if [ "$trafficLimit" != "nolimit" ]; then echo "AccountingStart month  1  00:00"; fi)
EOF
fi

if [ "$nodeType" = "bridge" ]
then
  echoInfo "Configuring Tor as a bridge..."

  if [ "$os" == "debian" ] || [ "$os" == "ubuntu" ]; then
    sudo apt install -t obfs4proxy -y && echoSuccess "-> OK" || handleError
    if [ "$os" == "debian" ]; then
      sudo apt install -t bullseye-backports -y && echoSuccess "-> OK" || handleError
      sudo setcap cap_net_bind_service=+ep /usr/bin/obfs4proxy
    fi
  elif [ "$os" == "arch" ]; then
    sudo pacman -S --noconfirm git && echoSuccess "-> OK" || handleError
    git clone https://aur.archlinux.org/obfs4proxy.git && echoSuccess "-> OK" || handleError
    cd obfs4proxy && makepkg -irs && echoSuccess "-> OK" || handleError   
  elif [ "$os" == "centos" ]; then
    sudo yum install -y git golang policycoreutils-python-utils && echoSuccess "-> OK" || handleError
    export GOPATH=$(mktemp -d)
    go get gitlab.com/yawning/obfs4.git/obfs4proxy && echoSuccess "-> OK" || handleError
    sudo cp $GOPATH/bin/obfs4proxy /usr/local/bin/ && echoSuccess "-> OK" || handleError
    sudo chcon --reference=/usr/bin/tor /usr/local/bin/obfs4proxy && echoSuccess "-> OK" || handleError
  fi

  cat << EOF | sudo tee -a /etc/tor/torrc > /dev/null
BridgeRelay  1
ServerTransportPlugin obfs4 exec /usr/bin/obfs4proxy
ServerTransportListenAddr obfs4  0.0.0.0:$obsf4Port
ExtORPort auto
Nickname $relayName
ContactInfo $contactInfo [tor-relay.dev]
ORPort $orPort
DirPort $dirPort
Exitpolicy reject *:*
$(if [ "$trafficLimit" != "nolimit" ]; then echo "AccountingMax $trafficLimit"; fi)
$(if [ "$maxBandwidth" != "nolimit" ]; then echo "RelayBandwidthRate $maxBandwidth"; fi)
$(if [ "$maxBurstBandwidth" != "nolimit" ]; then echo "RelayBandwidthBurst $maxBurstBandwidth"; fi)
$(if [ "$trafficLimit" != "nolimit" ]; then echo "AccountingStart month  1  00:00"; fi)
EOF
fi

if [ "$nodeType" = "exit" ]
then
  echoInfo "Downloading Exit Notice to /etc/tor/tor-exit-notice.html..."
  echo -e "\e[1mPlease edit this file and replace YOUR_EMAIL_ADDRESS with your e-mail address!"
  echo -e "\e[1mAlso note that this is the US version. If you are not in the US please edit the file and remove the US-Only sections!\e[0m"
  sudo wget -q -O /etc/tor/tor-exit-notice.html "https://tor-relay.dev/scripts/tor-exit-notice.html" && echoSuccess "-> OK" || handleError
fi

sleep 10

echoInfo "Enabling and starting Tor..."
sudo systemctl enable --now tor.service && echoSuccess "-> OK" || handleError
sudo systemctl restart tor.service && echoSuccess "-> OK" || handleError
sudo systemctl restart tor@default && echoSuccess "-> OK" || handleError

if [ "$os" == "centos" ]; then
  sudo semanage port -a -t tor_port_t -p tcp $orPort && echoSuccess "-> OK" || handleError
  sudo semanage port -a -t tor_port_t -p tcp $obsf4Port && echoSuccess "-> OK" || handleError
fi


if [ "$enableNyxMonitoring" = "true" ]
then
  echoInfo "Installing Nyx..."

  if [ "$os" == "debian" ] || [ "$os" == "ubuntu" ]; then
    sudo apt-get install nyx -y
  elif [ "$os" == "arch" ]; then
    sudo pacman -S --noconfirm nyx 
  elif [ "$os" == "centos" ]; then
    sudo yum -y install nyx
  fi
fi

echo ""
echoSuccess "=> Setup finished"
echo ""
echo "Be sure to setup automatic security updates for your system."
echo "Also be sure that your Firewall is forwarding the ORPORT: $orPort and DIRPORT: $dirPort (Dirport is not needed for bridges and middle relays)"
echo "Tor will now check if your ports are reachable. This may take up to 20 minutes."
echo "Check /var/log/syslog or run # journalctl -e -u tor@default and see if this message appears:"
echo "\"Self-testing indicates your ORPort is reachable from the outside. Excellent.\""
echo "If not, please check your firewall settings and your router settings."
echo "IPv6 will get detected automatically and added. If you want to disable IPv6, please edit the torrc file."
echo ""