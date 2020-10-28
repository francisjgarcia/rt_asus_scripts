#!/bin/sh

# Script para avisar de una nueva actualizacion de firmware del router RT-AC66U_B1

# Variables Telegram
TokenTG=$(cat .env | grep "TELEGRAM_TOKEN" | awk -F"=" '{print $2}')
IDTG=$(cat .env | grep "TELEGRAM_ID" | awk -F"=" '{print $2}')
AvisoTG="RT-AC66U_B1 [Firmware]"

### Variables version
Firmware=$(nvram get webs_state_info)
Download=$(echo $Firmware | awk -F"_" '{print $2"."$3"_"$4}')

function telegram {
	Icono=$1
	Mensaje=$2
	URLTG="https://api.telegram.org/bot$TokenTG/sendMessage?parse_mode=html&disable_web_page_preview=True"
        curl -s -X POST $URLTG -d chat_id=$IDTG -d text="$Icono <b>$AvisoTG</b> %0A $Mensaje" >/dev/null
}

telegram "💾" "La nueva version <b><a href='https://sourceforge.net/projects/asuswrt-merlin/files/RT-AC68U/Release/RT-AC68U_$Download.zip'>$Firmware</a></b> del firmware ya está disponible para el router RT-AC66U_B1."
