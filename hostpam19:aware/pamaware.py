#!/usr/bin/python3
import pam
p=pam.pam()
userName=input("Nom usuari: ")
userPasswd=input("Passwd: ")
p.authenticate(userName, userPasswd)
print('{} {}'.format(p.code,p.reason))
if p.code == 0:
    print("Usuari vàlid")
else:
    print("Usuari no vàlid")