#!/bin/sh

# Obtener temperatura del router RT-AC66U_B1 y enviar vía telegram una alerta según la variable $AlertaTemperatura

# Variables generales
TemperaturaActual=$(cat /proc/dmu/temperature | awk 'NR==1{print $4}' | cut -c1,2)
AlertaTemperatura=80
ArchivoBloqueo="/tmp/bloqueo-temperatura.tmp"

# Variables Telegram
TokenTG=$(cat .env | grep "TELEGRAM_TOKEN" | awk -F"=" '{print $2}')
IDTG=$(cat .env | grep "TELEGRAM_ID" | awk -F"=" '{print $2}')
AvisoTG="RT-AC66U_B1 [Temperatura]"

function telegram() {
	Icono=$1
	Mensaje=$2
	URLTG="https://api.telegram.org/bot$TokenTG/sendMessage?parse_mode=html&disable_web_page_preview=True"
	curl -s -X POST $URLTG -d chat_id=$IDTG -d text="$Icono <b>$AvisoTG</b> %0A $Mensaje" >/dev/null
}

if [ $TemperaturaActual -gt $AlertaTemperatura ]
then
	if [ -f $ArchivoBloqueo ]
	then
    		exit 0
	else
		telegram "🔥" "La temperatura del router ha alcanzado los $TemperaturaActualºC"
		touch $ArchivoBloqueo
		echo $TemperaturaActual > $ArchivoBloqueo
	fi
else
	TemperaturaBajando=$(expr $TemperaturaActual + 4)
	if [ -f $ArchivoBloqueo ] && [ $(cat $ArchivoBloqueo) -gt $TemperaturaBajando ]
	then
		telegram "❄️" "La temperatura del router ha bajado hasta los $TemperaturaBajandoºC"
		rm $ArchivoBloqueo
	else
		exit 0
	fi
fi
