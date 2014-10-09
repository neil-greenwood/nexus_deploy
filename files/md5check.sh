#!/bin/bash

key=$1

[ ! -f "$key" ] && echo "sth done: There is no md5 file to check: $key" && exit 1
[ ! -f "${key%.*}" ] && echo "sth done: There is no source file to check: ${key%.*}" && exit 1
[ ! "${key##*.}" == "md5" ]  && echo "usage:$0 file.tar.gz.md5" && exit 1

mdsum=(`md5sum -- "${key%.*}"`);
mdsum_md5=(`head -n1 "$key"`);

[ "${mdsum}" == "" ] || [ "${mdsum_md5}" == "" ] && echo "Propably program error, check spaces or special characters in filenames. md5sum:"$mdsum" file:"$mdsum_md5;

if [ "${mdsum}" == "${mdsum_md5}" ];
    then echo "    done: CHECKED all ok"
else echo -e "    done: WARNING MD5 sums are not equal!\t(${key})" && echo $mdsum && head -n1 $key && exit 1
fi
