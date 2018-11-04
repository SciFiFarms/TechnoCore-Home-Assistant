FROM homeassistant/home-assistant:0.74.2
RUN apt-get update && apt-get install -y mosquitto-clients

# This should be 4.1.something now.
#RUN pip3 install -U ptvsd==3.0.0 # For debugging with VS Code. 
COPY config/ /config/

# Set up the CMD as well as the pre and post hooks.
COPY go-init /bin/go-init
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY exitpoint.sh /usr/bin/exitpoint.sh
ENTRYPOINT ["go-init"]
CMD ["-pre", "entrypoint.sh", "-main", "python -m homeassistant --config /config ", "-post", "exitpoint.sh"]

# TODO: Need to prevent start until MQTT is up:
# https://docs.docker.com/compose/startup-order/