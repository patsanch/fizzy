#!/usr/bin/env bash

set -e

# fizzy-lb-101.df-iad-int.37signals.com
#
#   Service      Host                      Path    Target                                                                         State    TLS
#   fizzy        fizzy.37signals.com       /       fizzy-app-101.df-iad-int.37signals.com,fizzy-app-102.df-iad-int.37signals.com   running  yes
#   fizzy-admin  fizzy.37signals.com       /admin  fizzy-app-101.df-iad-int.37signals.com                                         running  yes
ssh app@fizzy-lb-101.df-iad-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy \
      --tls \
      --host=fizzy.37signals.com \
      --target=fizzy-app-101.df-iad-int.37signals.com \
      --read-target=fizzy-app-102.df-iad-int.37signals.com \
      --tls-acme-cache-path=/certificates

ssh app@fizzy-lb-101.df-iad-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy-admin \
      --host=fizzy.37signals.com \
      --path-prefix /admin \
      --strip-path-prefix=false \
      --target=fizzy-app-101.df-iad-int.37signals.com


# fizzy-lb-01.sc-chi-int.37signals.com
#
# Service      Host                                                                                                                                                                                                                   Path    Target                                                                        State    TLS
# fizzy        37s.fizzy.37signals.com,fizzy.37signals.com,dev.fizzy.37signals.com,fizzy.37signals.com,qa.fizzy.37signals.com,fizzy.37signals.com,37s.box-car.com,box-car.com,dev.box-car.com,box-car.com,qa.box-car.com,box-car.com  /       fizzy-app-101.df-iad-int.37signals.com,fizzy-app-02.sc-chi-int.37signals.com  running  yes
# fizzy-admin  fizzy.37signals.com,box-car.com                                                                                                                                                                                        /admin  fizzy-app-101.df-iad-int.37signals.com                                        running  yes                                                                                                                                                                                                 /admin  fizzy-app-101.df-iad-int.37signals.com                                        running  yes
ssh app@fizzy-lb-01.sc-chi-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy \
      --tls \
      --host={37s,dev,qa}.fizzy.37signals.com,fizzy.37signals.com,{37s,dev,qa}.box-car.com,box-car.com \
      --target=fizzy-app-101.df-iad-int.37signals.com \
      --read-target=fizzy-app-02.sc-chi-int.37signals.com \
      --tls-acme-cache-path=/certificates

ssh app@fizzy-lb-01.sc-chi-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy-admin \
      --host=fizzy.37signals.com,box-car.com \
      --path-prefix /admin \
      --strip-path-prefix=false \
      --target=fizzy-app-101.df-iad-int.37signals.com


# fizzy-lb-401.df-ams-int.37signals.com
#
#   Service      Host                      Path    Target                                                                          State    TLS
#   fizzy        fizzy.37signals.com       /       fizzy-app-101.df-iad-int.37signals.com,fizzy-app-402.df-ams-int.37signals.com   running  yes
#   fizzy-admin  fizzy.37signals.com       /admin  fizzy-app-101.df-iad-int.37signals.com                                          running  yes
ssh app@fizzy-lb-401.df-ams-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy \
      --tls \
      --host=fizzy.37signals.com \
      --target=fizzy-app-101.df-iad-int.37signals.com \
      --read-target=fizzy-app-402.df-ams-int.37signals.com \
      --tls-acme-cache-path=/certificates

ssh app@fizzy-lb-401.df-ams-int.37signals.com \
  docker exec fizzy-load-balancer \
    kamal-proxy deploy fizzy-admin \
      --host=fizzy.37signals.com \
      --path-prefix /admin \
      --strip-path-prefix=false \
      --target=fizzy-app-101.df-iad-int.37signals.com
