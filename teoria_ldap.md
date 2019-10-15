# LDAP

Primer hem de diferenciar entre **autenticació** (*qui sóc*) i **autorització** (*què puc fer*)

**LDAP** és una BBDD no relacional:

* Jeràrquica

* Pot ser distribuida.

* Optimitzada per a les lectures

* Té forma d'arbre

## Estructura

L'arbre de l'estructura s'anomena **DIT**.

```
                                +----------------+
                                |  dc=org        |
                                +----------------+
                                         |
                                +----------------+
          Entitats              |  dc=edt        |
                                +----------------+
                                   |          |
                             +-----+          +-------+
     Unitats      +----------------+                +------------------+
     organitzatives                |                |                  |
                  |  ou=usuaris    |                |   ou=maquines    |
                  +----------------+                +------------------+
      Usuaris                      |
              +---------------------+
    +----------------+       +----------------+
    |  uid=pedro     |       |   uid=anna     |
    |  sn=lopez      |       |   sn=gomez     |
    |  ...           |       |   ...          |
    +----------------+       +----------------+

```

* Es clasifica per entitats (*cada "caixa"*).

* Cada **entitat** té les seves dades, anomenades **atributs**.


