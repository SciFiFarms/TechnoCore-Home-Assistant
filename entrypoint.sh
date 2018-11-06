#!/usr/bin/env bash

#dogfish migrate &
#source /usr/share/mqtt-scripts/init.sh 
until mosquitto_pub -i test_connection -h mqtt -p 8883 -q 0 \
    -t test/network/up \
    -m "A message" \
    -u "$(cat /run/secrets/mqtt_username)" \
    -P "$(cat /run/secrets/mqtt_password)" \
    --cafile /run/secrets/ca
do
    echo "Couldn't reach MQTT. Sleeping."
    sleep 1
done
