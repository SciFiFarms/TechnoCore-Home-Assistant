#!/usr/bin/env bash

#dogfish migrate &
#source /usr/share/mqtt-scripts/init.sh 
until mosquitto_pub -i test_connection -h mqtt -p 8883 -q 0 \
    -t test/network/up \
    -m "A message" \
    -u "$(cat /run/secrets/mqtt_username)" \
    -P "$(cat /run/secrets/mqtt_password)" \
    --cafile /run/secrets/ca 2> /dev/null
do
    echo "Couldn't reach MQTT. Will retry in 5 seconds."
    sleep 5
done

mkdir /run/frames
echo "https://$(cat /run/secrets/domain):6052" > /run/frames/esphome
echo "https://$(cat /run/secrets/domain)/docs" > /run/frames/docs
echo "https://$(cat /run/secrets/domain)/node_red" > /run/frames/node_red
echo "https://$(cat /run/secrets/domain)/portainer" > /run/frames/portainer
echo "https://$(cat /run/secrets/domain)/grafana" > /run/frames/grafana
echo "https://$(cat /run/secrets/domain)/grafana/explore?left=[\"now-6h\",\"now\",\"Loki\",{},{\"ui\":[true,true,true,\"none\"]}]" > /run/frames/logs
echo "https://$(cat /run/secrets/domain)/jupyter" > /run/frames/jupyter
echo "https://$(cat /run/secrets/domain)/health" > /run/frames/health
