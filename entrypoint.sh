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
# TODO: I think this should always use /run/secrets/domain, and throw an error 
#       if it's not yet set.
if cat /run/secrets/domain | grep "Not yet set.\n"
then
    echo "https://$DOCKER_HOSTNAME:6052" > /run/frames/esphomeyaml
    echo "https://$DOCKER_HOSTNAME/docs" > /run/frames/docs
    echo "https://$DOCKER_HOSTNAME/node_red" > /run/frames/node_red
    echo "https://$DOCKER_HOSTNAME/portainer" > /run/frames/portainer
    echo "https://$DOCKER_HOSTNAME/grafana" > /run/frames/grafana
    echo "https://$DOCKER_HOSTNAME/logs" > /run/frames/logs
    echo "https://$DOCKER_HOSTNAME/jupyter" > /run/frames/jupyter
    echo "https://$DOCKER_HOSTNAME/status" > /run/frames/status
else 
    echo "https://$(cat /run/secrets/domain):6052" > /run/frames/esphomeyaml
    echo "https://$(cat /run/secrets/domain)/docs" > /run/frames/docs
    echo "https://$(cat /run/secrets/domain)/node_red" > /run/frames/node_red
    echo "https://$(cat /run/secrets/domain)/portainer" > /run/frames/portainer
    echo "https://$(cat /run/secrets/domain)/grafana" > /run/frames/grafana
    echo "https://$(cat /run/secrets/domain)/logs" > /run/frames/logs
    echo "https://$(cat /run/secrets/domain)/jupyter" > /run/frames/jupyter
    echo "https://$(cat /run/secrets/domain)/status" > /run/frames/status
fi
