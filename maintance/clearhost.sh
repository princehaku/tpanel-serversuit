#!/bin/bash
if [[ $(id -u) -ne 0 ]]; then
   echo "You Must Be Root"
   exit 0
fi

base_dir="/opt/net.techest/tpanel/"
etc_dir=$base_dir"etc/"
server_dir=$base_dir"server/"

echo "please input domain name (without www)"
read -p "domain:" temp
if [[ "$temp" != "" ]]; then
   domain_name=$temp
fi
echo "+--------------------------------------+"
echo "+              clear vhost             +"
echo "+--------------------------------------+"
rm -rf /Users/$user_name/htdocs/$domain_name
rm -rf ${etc_dir}nginx.d/$domain_name.conf
rm -rf ${etc_dir}fpm.d/$domain_name.conf
echo "+--------------------------------------+"
echo "+              ALL    DONE             +"
echo "+--------------------------------------+"
