#!/bin/zsh

HTTP_CODE="$(curl -sI http://router.ellis:9091/transmission/rpc | head -1 | cut -f2 -d' ')"
echo "HTTP Code: $HTTP_CODE"

case $HTTP_CODE in
    (403)
        curl 'http://router.ellis/tomato.cgi' \
            -H 'Authorization: Basic YWRtaW46PzBAJHd0UkpHP1cwJ303XVMlZjJHV0FeRw==' \
            -H 'Sec-GPC: 1' \
            -H 'Origin: http://router.ellis' \
            -H 'Referer: http://router.ellis/nas-bittorrent.asp' \
            --data-raw '_ajax=1&_service=bittorrent-restart&_http_id=TID340f974f42f89f81' \
            --compressed \
            --insecure
        echo "Restarted Transmission"
        ;;
    (*)
        echo "Nothing done"
        ;;
esac
