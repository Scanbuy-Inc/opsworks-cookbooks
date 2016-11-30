alias checkup='while true; do clear; uptime; sleep 1; done;'
alias checklog='tailf /usr/share/tomcat7/logs/catalina.out'
alias checkip='curl http://169.254.169.254/latest/meta-data/public-ipv4'
alias flushram='free -m && sync && echo 3 > /proc/sys/vm/drop_caches && free -m'
