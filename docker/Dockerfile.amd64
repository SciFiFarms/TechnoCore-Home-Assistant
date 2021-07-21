FROM homeassistant/home-assistant:2021.2.3
RUN apk add --no-cache  mosquitto-clients

# This should be 4.1.something now.
RUN pip3 install -U ptvsd==4.1.4 HiYaPyCo==0.4.14
RUN cd /tmp/ && \
    mkdir -p /config/custom_components/ && \
    mkdir -p /config/www/ && \
    mkdir -p /config/.storage/ && \
    rm -rf /tmp/

# Add dogfish
# This should be set to where the volume mounts to.
ARG PERSISTANT_DIR=/config/.storage/
COPY dogfish/ /usr/share/dogfish
COPY migrations/ /usr/share/dogfish/shell-migrations
RUN ln -s /usr/share/dogfish/dogfish /usr/bin/dogfish
RUN mkdir /var/lib/dogfish
# Need to do this all together because ultimately, the config folder is a volume, and anything done in there will be lost.
RUN mkdir -p ${PERSISTANT_DIR} && touch ${PERSISTANT_DIR}/migrations.log && ln -s ${PERSISTANT_DIR}/migrations.log /var/lib/dogfish/migrations.log

# Set up the CMD as well as the pre and post hooks.
COPY go-init /bin/go-init
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY exitpoint.sh /usr/bin/exitpoint.sh
COPY generate_home_assistant_configuration.py /usr/bin/
COPY configuration.yaml /etc/home-assistant/default-configuration.yaml
COPY config/ /config/
RUN mv /config/custom-configuration.yaml /config/.storage/custom-configuration.yaml && ln -s /config/.storage/custom-configuration.yaml /config/custom-configuration.yaml
ENTRYPOINT ["go-init"]
# TODO: It would be nice to figure out how to make it wait for attach here.
#CMD ["-pre", "entrypoint.sh", "-main", "python -m ptvsd --host 0.0.0.0 --port 5678 -m homeassistant --config /config ", "-post", "exitpoint.sh"]
CMD ["-main", "entrypoint.sh python -m homeassistant --config /config ", "-post", "exitpoint.sh"]

