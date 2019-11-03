#!/bin/bash

#example return messages from FreeDns
#   "Updated example.com to 11.11.11.111 in 0.193 seconds"
#   "No IP change detected for example.com with IP 11.11.11.111, skipping update"
#   "Error 404 : Page not found"
#   "Couldn't find any matching DNS records via randomkey method!"

EXIT_STATUS=0

FREE_DNS_CONF="/etc/freedns.conf"
FREE_DNS_URL="https://freedns.afraid.org/dynamic/update.php?"

RESOLVER_URL="myip.opendns.com"
RESOLVER_SERVER="resolver1.opendns.com"

DNS_UPDATED='Updated'
DNS_UNCHANGED='No IP change detected for'

MYIP=$(dig +short "${RESOLVER_URL}" @"${RESOLVER_SERVER}")
MYIP_EXITCODE=$?

if [[ MYIP_EXITCODE -ne 0 ]]; then
    EXIT_STATUS=1
    echo "Error: MYIP_EXITCODE=[${MYIP_EXITCODE}], MYIP=[${MYIP}]"
else

    if [ -z "$MYIP" ]; then
        EXIT_STATUS=1
        echo "Error: No response from ${RESOLVER_URL}"

    else
        while IFS=" " read -r domain token; do
            STATUS="Error"
            MESSAGE=""

            #ignore comments
            if [[ "$domain" == *"#"* ]]; then
                continue

            elif [ -z "$domain" ]; then
                MESSAGE="Domain empty"

            elif [ -z "$token" ]; then
                MESSAGE="token empty"

            else
                OLDIP=$(dig +short "${domain}" @"${RESOLVER_SERVER}")
                OLDIP_EXITCODE=$?

                if [[ OLDIP_EXITCODE -ne 0 ]]; then
                    EXIT_STATUS=1
                    MESSAGE="OLDIP_EXITCODE=[${OLDIP_EXITCODE}], OLDIP=[${OLDIP}]"

                elif [[ "$MYIP" == "$OLDIP" ]]; then
                    STATUS="Unchanged"
                    MESSAGE="MYIP=[${MYIP}], OLDIP=[${OLDIP}]"

                else
                    FREEDNS_RETURN=$(curl -s --ssl-reqd "${FREE_DNS_URL}${token}")
                    FREEDNS_EXITCODE=$?

                    if [[ FREEDNS_EXITCODE -eq 0 ]]; then
                        # test for updated?
                        if [[ "$FREEDNS_RETURN" == "$DNS_UPDATED"* ]]; then
                            STATUS="Updated"

                        # test for unchanged?
                        elif [[ "$FREEDNS_RETURN" == "$DNS_UNCHANGED"* ]]; then
                            STATUS="Unchanged"
                        fi
                    else
                        EXIT_STATUS=1
                    fi
                    MESSAGE="FREEDNS_EXITCODE=[${FREEDNS_EXITCODE}], FREEDNS_RETURN=[${FREEDNS_RETURN}]"

                fi
            fi
            echo "${STATUS}: domain=[${domain}], token=[${token}], ${MESSAGE}"
        done <"$FREE_DNS_CONF"
    fi
fi
exit $EXIT_STATUS

