#!/bin/bash

for op in $OPERATIONS;
do
  # Ejecutamos script de metricas por cada operacion
  output=`bash $METRIC_SCRIPT $op`
  if [ ! -z "${output}" ]; then
    #Parseamos la salida del script y juntamos en una misma variable las de todas las operaciones
    etime_avg=`echo $output | awk -F 'Average:' '{print $2}' | awk -F 'Highest:' '{print $1}'`
    etime_high=`echo $output | awk -F 'Average:' '{print $2}' | awk -F 'Highest:' '{print $2}'`

    semaas_values=$semaas_values,`echo "\"${op}HighestTime\":${etime_high},\"${op}AverageTime\":${etime_avg}"`
  else
    echo "ERROR OBTENIENDO METRICAS DE LA OPERACION $op"
    exit 1
  fi
done
# Quitamos caracteres sobrantes y lo pasamos al formato que espera semaas
semaas_values=`echo $semaas_values | sed 's/,//' |  tr -d " \t\n\r" `
semaas_values=`echo "{$semaas_values}" `

echo "$semaas_values"
currDate="`date +%s%N`"


echo "rhds,seemas_values=telegraf_operations stats=$etime_avg,$etime_high"
