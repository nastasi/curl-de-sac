#!/bin/bash
#set -x
#
# Defaults
#
CONFIG_FILE="$HOME/.curl-de-sac_install"

apache_conf="/etc/apache2/sites-available/default"
# brisk_debug="0xffff"
web_path="/home/nastasi/web/curl-de-sacccc"
web_url="http://localhost/curl-de-sac"
dbg_level=998
# ftok_path="/home/nastasi/brisk-priv/ftok/brisk"
# proxy_path="/home/nastasi/brisk-priv/proxy/brisk"
# sys_user="www-data"
# legal_path="/home/nastasi/brisk-priv/brisk"
# prefix_path="/brisk/"
# brisk_conf="brisk_spu.conf.pho"
web_only="FALSE"
test_add="FALSE"
#
# functions
function usage () {
    echo
    echo "$1 -h"

    echo "$1 chk                          - run lintian on all ph* files."
#    echo "$1 pkg                          - build brisk packages."
    echo "$1 [-w <web_dir>] [-f <conffile>] [-p <outconf>]" # [-W] [-n 3|5] [-t <(n>=4)>] [-T <auth_tab>] [-G <cert_tab>] [-A <apache-conf>] [-a <auth_file_name>] [-U <usock_path>] [-u <sys_user>] [-d <TRUE|FALSE>] [-k <ftok_dir>] [-l <legal_path>] [-y <proxy_path>] [-P <prefix_path>] [-x]"
#    echo "$1 [-W] [-n 3|5] [-t <(n>=4)>] [-T <auth_tab>] [-G <cert_tab>] [-A <apache-conf>] [-a <auth_file_name>] [-f <conffile>] [-p <outconf>] [-U <usock_path>] [-u <sys_user>] [-d <TRUE|FALSE>] [-w <web_dir>] [-k <ftok_dir>] [-l <legal_path>] [-y <proxy_path>] [-P <prefix_path>] [-x]"
    echo "$1 [-w <web_dir>]"
    echo "  -h this help"
    echo "  -f use this config file"
    echo "  -p save preferences in the file"
    # echo "  -W web files only"
    # echo "  -A apache_conf                  - def. $apache_conf"
    # echo "  -n number of players            - def. $players_n"
    # echo "  -t number of tables             - def. $tables_n"
    # echo "  -T number of auth-only tables   - def. $tables_auth_n"
    # echo "  -G number of cert-only tables   - def. $tables_cert_n"
    # echo "  -a authorization file name      - def. \"$brisk_auth_conf\""
    echo "  -d set debug level                - def. $dbg_level"
    echo "  -w dir where place the web tree   - def. \"$web_path\""
    echo "  -U web url to retrieve test pages - def. \"$web_url\""
    # echo "  -k dir where place ftok files   - def. \"$ftok_path\""
    # echo "  -l dir where save logs          - def. \"$legal_path\""
    # echo "  -y dir where place proxy files  - def. \"$proxy_path\""
    # echo "  -P prefix path                  - def. \"$prefix_path\""
    # echo "  -C config filename              - def. \"$brisk_conf\""
    # echo "  -U unix socket path             - def. \"$usock_path\""
    # echo "  -u system user to run brisk dae - def. \"$sys_user\""
    echo "  -x copy tests as normal php       - def. \"$test_add\""
    echo
}

function get_param () {
    echo "X$2" | grep -q "^X$1\$"
    if [ $? -eq 0 ]; then
	# echo "DECHE" >&2
        echo "$3"
	return 2
    else
	# echo "DELA" >&2
        echo "$2" | cut -c 3-
        return 1
    fi
    return 0
}

function searchetc() {
    local dstart dname pp
    dstart="$1"
    dname="$2"

    pp="$dstart"
    while [ "$pp" != "/" ]; do
        if [ -d "$pp/$dname" ]; then
            echo "$pp/$dname"
            return 0
        fi
        pp="$(dirname "$pp")"
    done
    
    return 1
}

#
#  MAIN
#
if [ "$1" = "chk" ]; then
    set -e
    oldifs="$IFS"
    IFS='
'
    for i in $(find -name '*.pho' -o -name '*.phh' -o -name '*.php'); do
        php5 -l $i
    done

    taggit="$(git describe --tags | sed 's/^v//g')"
    tagphp="$(grep "^\$G_curl_de_sac_version = " web/Obj/curl-de-sac.phh | sed 's/^[^"]\+"//g;s/".*//g')"
    if [ "$taggit" != "$tagphp" ]; then
        echo
	echo "WARNING: taggit: [$taggit] tagphp: [$tagphp]"
        echo
    fi
    exit 0
fi

# before all check errors on the sources
$0 chk || exit 3

if [ "$1" = "pkg" ]; then
    if [ "$2" != "" ]; then
        tag="$2"
    else
        tag="$(git describe)"
    fi
    nam1="curl-de-sac_${tag}.tgz"
    echo "Build packages ${nam1}."
    read -p "Proceed [y/n]: " a
    if [ "$a" != "y" -a  "$a" != "Y" ]; then
        exit 1
    fi
    git archive --format=tar --prefix=brisk-${tag}/curl-de-sac/ $tag | gzip > ../$nam1
    cd -
    exit 0
fi

if [ -f "$CONFIG_FILE" ]; then
   source "$CONFIG_FILE"
fi

if [ "x$prefix_path" = "x" ]; then
   prefix_path="$web_path"
fi

action=""
while [ $# -gt 0 ]; do
    # echo aa $1 xx $2 bb
    conffile=""
    case $1 in
#        -A*) apache_conf="$(get_param "-A" "$1" "$2")"; sh=$?;;
        -f*) conffile="$(get_param "-f" "$1" "$2")"; sh=$?;;
        -p*) outconf="$(get_param "-p" "$1" "$2")"; sh=$?;;
#        -n*) players_n="$(get_param "-n" "$1" "$2")"; sh=$?;;
#        -t*) tables_n="$(get_param "-t" "$1" "$2")"; sh=$?;;
#        -T*) tables_auth_n="$(get_param "-T" "$1" "$2")"; sh=$?;;
#        -G*) tables_cert_n="$(get_param "-G" "$1" "$2")"; sh=$?;;
#        -a*) brisk_auth_conf="$(get_param "-a" "$1" "$2")"; sh=$?;;
        -d*) dbg_level="$(get_param "-d" "$1" "$2")"; sh=$?;;
        -w*) web_path="$(get_param "-w" "$1" "$2")"; sh=$?;;
        -U*) web_url="$(get_param "-U" "$1" "$2")" ; sh=$?;;
#        -k*) ftok_path="$(get_param "-k" "$1" "$2")"; sh=$?;;
#        -y*) proxy_path="$(get_param "-y" "$1" "$2")"; sh=$?;;
#        -P*) prefix_path="$(get_param "-P" "$1" "$2")"; sh=$?;;
#        -C*) brisk_conf="$(get_param "-C" "$1" "$2")"; sh=$?;;
#        -l*) legal_path="$(get_param "-l" "$1" "$2")"; sh=$?;;
#        -U*) usock_path="$(get_param "-U" "$1" "$2")"; sh=$?;;
#        -u*) sys_user="$(get_param "-u" "$1" "$2")"; sh=$?;;
#        system) action=system;;
#        -W) web_only="TRUE";;
        -x) test_add="TRUE";;
        -h) usage $0; exit 0;;
	*) usage $0; exit 1;;
    esac
    if [ ! -z "$conffile" ]; then
        if [ ! -f "$conffile" ]; then
            echo "config file [$conffile] not found"
   	    exit 1
        fi
        . "$conffile"
    fi
    shift $sh
done

#
#  Show parameters
#
echo "    outconf:    \"$outconf\""
# echo "    apache_conf:\"$apache_conf\""
# echo "    players_n:   $players_n"
# echo "    tables_n:    $tables_n"
# echo "    tables_auth_n: $tables_auth_n"
# echo "    tables_cert_n: $tables_cert_n"
# echo "    brisk_auth_conf: \"$brisk_auth_conf\""
echo "    dbg_level:  $dbg_level"
echo "    web_path:   \"$web_path\""
echo "    web_url:    \"$web_url\""
# echo "    ftok_path:  \"$ftok_path\""
# echo "    legal_path: \"$legal_path\""
# echo "    proxy_path: \"$proxy_path\""
# echo "    prefix_path:\"$prefix_path\""
# echo "    brisk_conf: \"$brisk_conf\""
# echo "    usock_path: \"$usock_path\""
# echo "    sys_user:   \"$sys_user\""
# echo "    web_only:   \"$web_only\""
# echo "    test_add:   \"$test_add\""

if [ ! -z "$outconf" ]; then
  ( 
    echo "#"
    echo "#  Produced automatically by curl-de-sac::INSTALL.sh"
    echo "#"
    # echo "apache_conf=$apache_conf"
    # echo "players_n=$players_n"
    # echo "tables_n=$tables_n"
    # echo "tables_auth_n=$tables_auth_n"
    # echo "tables_cert_n=$tables_cert_n"
    # echo "brisk_auth_conf=\"$brisk_auth_conf\""
    echo "dbg_level=$dbg_level"
    echo "web_path=\"$web_path\""
    echo "web_url=\"$web_url\""
    # echo "ftok_path=\"$ftok_path\""
    # echo "proxy_path=\"$proxy_path\""
    # echo "legal_path=\"$legal_path\""
    # echo "prefix_path=\"$prefix_path\""
    # echo "brisk_conf=\"$brisk_conf\""
    # echo "usock_path=\"$usock_path\""
    # echo "sys_user=\"$sys_user\""
    # echo "web_only=\"$web_only\""
    # echo "test_add=\"$test_add\""
  ) > "$outconf"
fi

if [ 1 -eq 0 -a "$action" = "system" ]; then
    # no used
    scrname="$(echo "$prefix_path" | sed 's@^/@@g;s@/$@@g;s@/@_@g;')"
    echo
    echo "script name:  [$scrname]"
    echo "brisk path:   [$web_path]"
    echo "private path: [$legal_path]"
    echo "system user:  [$sys_user]"
    echo
    read -p "press enter to continue" sure
    cp bin/brisk-init.sh brisk-init.sh.wrk
    sed -i "s@^BPATH=.*@BPATH=\"${web_path}\"@g;s@^PPATH=.*@PPATH=\"${legal_path}\"@g;s@^SSUFF=.*@SSUFF=\"${scrname}\"@g;s@^BUSER=.*@BUSER=\"${sys_user}\"@g" brisk-init.sh.wrk

    su -c "cp brisk-init.sh.wrk /etc/init.d/${scrname}"

    rm brisk-init.sh.wrk
    echo
    echo "... DONE."
    echo "DON'T FORGET: after the first installation you MUST configure your run-levels accordingly"
    echo
    echo "Example: su -c 'update-rc.d $scrname defaults'"
    echo
    exit 0
fi

#  Pre-check
#
# check for etc path existence
dsta="$(dirname "$web_path")"
etc_path="$(searchetc "$dsta" Etc)"
if [ $? -ne 0 ]; then
    echo "Etc directory not found"
    exit 1
fi

IFS='
'
#
#  Installation
#
# ftokk_path="${ftok_path}k"


if [ "$web_only" != "TRUE" ]; then
   # here code una tantum
   :
fi
install -d ${web_path}
for i in $(find web -type d | grep '/' | sed 's/^....//g'); do
    install -d ${web_path}/$i 
done

for i in $(find web -name '.htaccess' -o -name '*.php' -o -name '*.phh' -o -name '*.pho' -o -name '*.css' -o -name '*.js' -o -name '*.mp3' -o -name '*.swf' -o -name 'terms-of-service*' | sed 's/^....//g'); do
    install -m 644 "web/$i" "${web_path}/$i"
done
if [ "$test_add" = "TRUE" ]; then
    for i in $(find webtest -name '.htaccess' -o -name '*.phh' -o -name '*.pho' -o -name '*.css' -o -name '*.js' -o -name '*.mp3' -o -name '*.swf' -o -name 'terms-of-service*' | sed 's/^........//g'); do
        install -m 644 "webtest/$i" "${web_path}/$i"
    done
    for i in $(find webtest -name '*.php' | sed 's/^........//g'); do
        install -m 755 "webtest/$i" "${web_path}/$i"
    done
fi

# # .js substitutions
# sed -i "s/PLAYERS_N *= *[0-9]\+/PLAYERS_N = $players_n/g" $(find ${web_path} -type f -name '*.js' -exec grep -l 'PLAYERS_N *= *[0-9]\+' {} \;)

# sed -i "s/^var G_send_time *= *[0-9]\+/var G_send_time = $send_time/g" $(find ${web_path} -type f -name '*.js' -exec grep -l '^var G_send_time *= *[0-9]\+' {} \;)

# # .ph[pho] substitutions
sed -i "s@^define *( *'WEB_URL', *'[^']\+' *)@define('WEB_URL', '$web_url')@g;s@define *( *'DBG_LEVEL', *[0-9]\+ *)@define('DBG_LEVEL', $dbg_level)@g" $(find ${web_path} -type f -name '*.ph*')

# sed -i "s/define *( *'BIN5_PLAYERS_N', *[0-9]\+ *)/define('BIN5_PLAYERS_N', $players_n)/g" $(find ${web_path} -type f -name '*.ph*' -exec grep -l "define *( *'BIN5_PLAYERS_N', *[0-9]\+ *)" {} \;)

# sed -i "s@define *( *'FTOK_PATH',[^)]*)@define('FTOK_PATH', \"$ftok_path\")@g" $(find ${web_path} -type f -name '*.ph*' -exec grep -l "define *( *'FTOK_PATH',[^)]*)" {} \;)

# sed -i "s@define *( *'SITE_PREFIX',[^)]*)@define('SITE_PREFIX', \"$prefix_path\")@g;
# s@define *( *'SITE_PREFIX_LEN',[^)]*)@define('SITE_PREFIX_LEN', $prefix_path_len)@g" ${web_path}/Obj/sac-a-push.phh

# sed -i "s@define *( *'USOCK_PATH',[^)]*)@define('USOCK_PATH', \"$usock_path\")@g" ${web_path}/spush/brisk-spush.phh

# sed -i "s@define *( *'TABLES_N',[^)]*)@define('TABLES_N', $tables_n)@g;
# s@define *( *'TABLES_AUTH_N',[^)]*)@define('TABLES_AUTH_N', $tables_auth_n)@g;
# s@define *( *'TABLES_CERT_N',[^)]*)@define('TABLES_CERT_N', $tables_cert_n)@g;
# s@define *( *'BRISK_DEBUG',[^)]*)@define('BRISK_DEBUG', $brisk_debug)@g;
# s@define *( *'LEGAL_PATH',[^)]*)@define('LEGAL_PATH', \"$legal_path\")@g;
# s@define *( *'PROXY_PATH',[^)]*)@define('PROXY_PATH', \"$proxy_path\")@g;
# s@define *( *'BRISK_CONF',[^)]*)@define('BRISK_CONF', \"$brisk_conf\")@g;" ${web_path}/Obj/brisk.phh

# sed -i "s@define *( *'BRISK_AUTH_CONF',[^)]*)@define('BRISK_AUTH_CONF', \"$brisk_auth_conf\")@g" ${web_path}/Obj/auth.phh

# sed -i "s@var \+cookiepath \+= \+\"[^\"]*\";@var cookiepath = \"$prefix_path\";@g" ${web_path}/commons.js

# sed -i "s@\( \+cookiepath *: *\)\"[^\"]*\" *,@\1 \"$prefix_path\",@g" ${web_path}/xynt-streaming.js

# document_root="$(grep DocumentRoot "${apache_conf}"  | grep -v '^[ 	]*#' | awk '{ print $2 }')"
# sed -i "s@^\(\$DOCUMENT_ROOT *= *[\"']\)[^\"']*\([\"']\)@\1$document_root\2@g" ${web_path}/spush/*.ph*

# # config file installation or diff
# if [ -f "$etc_path/$brisk_conf" ]; then
#     echo "Config file $etc_path/$brisk_conf exists."
#     echo "=== Dump the diff. ==="
#     # diff -u "$etc_path/$brisk_conf" "${web_path}""/Obj/brisk.conf-templ.pho"
#     diff -u <(cat "$etc_path/$brisk_conf" | egrep -v '^//|^#' | grep '\$[a-zA-Z_ ]\+=' | sed 's/ \+= .*/ = /g' | sort | uniq) <(cat "${web_path}""/Obj/brisk.conf-templ.pho" | egrep -v '^//|^#' | grep '\$[a-zA-Z_ ]\+=' | sed 's/ \+= .*/ = /g' | sort | uniq )
#     echo "===   End dump.    ==="
# else
#     echo "Config file $etc_path/$brisk_conf not exists."
#     echo "Install a template."
#     cp  "${web_path}""/Obj/brisk.conf-templ.pho" "$etc_path/$brisk_conf"
# fi

if [ -f WARNING.txt ]; then
    echo ; echo "    ==== WARNING ===="
    echo
    cat WARNING.txt
    echo
fi
exit 0
