#! /bin/bash
# @marcgc ASIX M06 2019-2020
# startup.sh
# -------------------------------------

/opt/docker/install.sh && echo "Install Ok"
/sbin/nscd && echo "nscd Ok"
/sbin/nslcd -F && echo "nslcd  Ok"
/usr/sbin/smbd && echo "smb Ok"
/usr/sbin/nmbd -F && echo "nmb  Ok"
/bin/bash

