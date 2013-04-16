#!/bin/bash
#
###################################################################
#    Program : Simple Linux Security Checker (SLSC)               #
#    Author  : Hayden Wei <haidongrun@163.com>                    #
#    Version : 1.0.0                                              #
#    Date    : 2013-03-20                                         #
#    Copyright (C) 2013-2013 Hayden Wei.  All Rights Reserved.    #
###################################################################
#
#
. ./conf/config
. ./init
#---------------------------------
echo "-----------------------------------"
echo "Checking started..."

#----------------------------------------------------------------------------------------------
# Check /etc/passwd
#----------------------------------------------------------------------------------------------
echo "Checking /etc/passwd..."
echo -n "Check /etc/passwd!" >> ${LOGFILE}/tmp.log
RESULT=${OK}
if [ `ls -l /etc/passwd | grep -c "^-rw-r--r--"` -eq 0 ]; then
    echo -n "/etc/passwd的权限应该设置为'-rw-r--r--'!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
elif [ `ls -l /etc/passwd | grep -c "root root"` -eq 0 ]; then
    echo -n "/etc/passwd的所有者和群组都应该设置为root!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
fi
echo "" >> ${LOGFILE}/tmp.log
output ${RESULT}

#----------------------------------------------------------------------------------------------
# Check /etc/shadow
#----------------------------------------------------------------------------------------------
echo "Checking /etc/shadow..."
echo -n "Check /etc/shadow!" >> ${LOGFILE}/tmp.log
RESULT=${OK}
if [ `ls -l /etc/shadow | grep -c "^-..-------"` -eq 0 ]; then
    echo -n "/etc/shadow的权限应该设置为'-rw-------'或'-r--------'!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
elif [ `ls -l /etc/shadow | grep -c "root root"` -eq 0 ]; then
    echo -n "/etc/shadow的所有者和群组都应该设置为root!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
fi
echo "" >> ${LOGFILE}/tmp.log
output ${RESULT}

#----------------------------------------------------------------------------------------------
# Check /etc/group
#----------------------------------------------------------------------------------------------
echo "Checking /etc/group..."
echo -n "Check /etc/group!" >> ${LOGFILE}/tmp.log
RESULT=${OK}
if [ `ls -l /etc/group | grep -c "^-rw-r--r--"` -eq 0 ]; then
    echo -n "/etc/group的权限应该设置为'-rw-r--r--'!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
elif [ `ls -l /etc/group | grep -c "root root"` -eq 0 ]; then
    echo -n "/etc/group的所有者和群组都应该设置为root!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
fi
echo "" >> ${LOGFILE}/tmp.log
output ${RESULT}

#----------------------------------------------------------------------------------------------
# Check users without password
#----------------------------------------------------------------------------------------------
echo "Checking users without password..."
echo -n "Check users without password!" >> ${LOGFILE}/tmp.log
RESULT=${OK}
noPassUsers="" #存储没有密码的用户名
if [ "`awk -F ":" '$2 ~ /""/ { printf $1 }' /etc/shadow`" != "" ]; then
    echo -n "存在没有指定密码的用户!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
fi
echo "" >> ${LOGFILE}/tmp.log
output ${RESULT}

#----------------------------------------------------------------------------------------------
# Check users with root permission except ROOT
#----------------------------------------------------------------------------------------------
echo "Checking users with root permission..."
echo -n "Check users with root permission except ROOT!" >> ${LOGFILE}/tmp.log
RESULT=${OK}
roots=`awk -F ":" '$3 == "0" { printf $1 }'  /etc/passwd | grep -v "^root"`
if [ "${roots}" != "" ]; then
    echo -n "存在多个拥有root权限的用户!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
fi
echo "" >> ${LOGFILE}/tmp.log
output ${RESULT}

#----------------------------------------------------------------------------------------------
# Check default password minimum length
#----------------------------------------------------------------------------------------------
echo "Checking default password length..."
echo -n "Check PASS_MIN_LEN!" >> ${LOGFILE}/tmp.log
RESULT=${OK}
minLen=`grep PASS_MIN_LEN /etc/login.defs | grep -v "^#" | awk '{ printf $2 }'`
if [ ${minLen} -le 8 ]; then
    echo -n "Current password minimum length is ${minLen}, you'd better enlarge it!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
fi
echo "" >> ${LOGFILE}/tmp.log
output ${RESULT}

#----------------------------------------------------------------------------------------------
# Check umask
#----------------------------------------------------------------------------------------------
echo "Checking UMASK..."
echo -n "Check UMASK!" >> ${LOGFILE}/tmp.log
RESULT=${OK}
umaskValues=`grep umask /etc/profile | grep -v "^#" | awk '{ printf $2 }'`
umasks=${umaskValues:${#umaskValues}-3:3} #获取非root账号的umask值
if [ "${umasks}" != "077" ]; then
    echo -n "Current umask value is ${umasks}, you'd better change it to 077!" >> ${LOGFILE}/tmp.log
    RESULT=${WARNING}
fi
echo "" >> ${LOGFILE}/tmp.log
output ${RESULT}


#----------------------------------------------------------------------------------------------
# Create .html log file
#----------------------------------------------------------------------------------------------
#logToHtml ${LOGFILE}/tmp.log

echo "Checking completed..."
echo "-----------------------------------"

exit 0
