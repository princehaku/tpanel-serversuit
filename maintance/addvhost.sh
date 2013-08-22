#!/bin/bash
if [[ $(id -u) -ne 0 ]]; then
   echo "You Must Be Root"
   #exit 0
fi

base_dir="/opt/net.techest/tpanel/"
etc_dir=$base_dir"etc/"
server_dir=$base_dir"server/"

echo "please input domain name (without www)"
read -p "domain:" temp
if [[ "$temp" != "" ]]; then
   domain_name=$temp
fi
echo "please input user login name"
read -p "username:" temp
if [[ "$temp" != "" ]]; then
   user_name=$temp
fi
echo "+--------------------------------------+"
echo "+               adding user            +"
echo "+--------------------------------------+"
user_pwd=$(md5sum </proc/uptime | cut -d " " -f 1)
user_pwd=${user_pwd:0:5}
useradd -m $user_name -p $(mkpasswd $user_pwd)
mkdir -p /home/$user_name/logs
chown $user_name:$user_name /home/$user_name/ -R
chmod 750 /home/$user_name -R
echo "your password is $user_pwd"

echo "+--------------------------------------+"
echo "+              adding vhost            +"
echo "+--------------------------------------+"
mkdir -p /home/$user_name/$domain_name
# init fpm poll

# init nginx port
cat >> ${etc_dir}nginx.d/$domain_name.conf << EOF
EOF

echo "+--------------------------------------+"
echo "+              finish                  +"
echo "+--------------------------------------+"
