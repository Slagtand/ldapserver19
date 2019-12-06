#! /bin/bash
# @marcgc ASIX M06 2019-2020
# startup.sh
# -------------------------------------

/opt/docker/install.sh && echo "Install Ok"
/sbin/nscd && echo "nscd Ok"
/sbin/nslcd -n && echo "nslcd  Ok"


