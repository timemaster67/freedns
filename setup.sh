#!/bin/bash
cd "$( dirname "${BASH_SOURCE[0]}" )"

SYSTEMD_UNIT="free_dns"
mv ${SYSTEMD_UNIT}.conf /etc/
mv ${SYSTEMD_UNIT}.service /etc/systemd/system/
mv ${SYSTEMD_UNIT}.timer /etc/systemd/system/
mv ${SYSTEMD_UNIT} /usr/local/sbin/

systemctl daemon-reload
systemctl enable ${SYSTEMD_UNIT}.service
systemctl enable ${SYSTEMD_UNIT}.timer