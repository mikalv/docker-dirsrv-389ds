FROM centos:7

LABEL maintainer "Mikal Villa <mikalv@mikalv.net>" \
      name="389ds" \
      vendor="Mikal Villa <mikalv@mikalv.net>" \
      license="ASL v2"\
      build-date="20170409"

ARG arch=amd64

COPY confd /etc/confd

COPY scripts/install-and-run-389ds.sh /install-and-run-389ds.sh

RUN  yum -y install curl hostname httpd authconfig nss-tools && \
     yum -y install java-1.8.0-openjdk-headless  openssl procps-pg coreutils && \
     yum -y install 389-ds-base.x86_64 openldap-clients && \ 
     curl -qL https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-$arch -o /usr/local/bin/confd && \
     chmod +x /usr/local/bin/confd && \
     chmod +x /install-and-run-389ds.sh && \
     sed -i 's/checkHostname {/checkHostname {\nreturn();/g' /usr/lib64/dirsrv/perl/DSUtil.pm  && \
     rm -fr /usr/lib/systemd/system && \
     sed -i 's/updateSelinuxPolicy($inf);//g' /usr/lib64/dirsrv/perl/* && \
     sed -i '/if (@errs = startServer($inf))/,/}/d' /usr/lib64/dirsrv/perl/* && \
     mkdir /etc/dirsrv-tmpl && mv /etc/dirsrv/* /etc/dirsrv-tmpl && \
     yum -y clean all && rm -rf /var/cache/yum/*

VOLUME ["/etc/dirsrv","/var/lib/dirsrv","/var/log/dirsrv"]

EXPOSE 389 9830

CMD ["/install-and-run-389ds.sh"]
