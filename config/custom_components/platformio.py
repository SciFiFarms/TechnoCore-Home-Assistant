import homeassistant.loader as loader
import json
import ssl
import socket
import hashlib
# TODO: Add logger
 

# The domain of your component. Should be equal to the name of your component.
DOMAIN = 'platformio'

# List of component names (string) your component depends upon.
DEPENDENCIES = ['mqtt']


#CONF_TOPIC = 'topic'
#DEFAULT_TOPIC = 'platformio/build/nodemcuv2'


def setup(hass, config):
    """Set up the Platformio MQTT component."""
    #mqtt = loader.get_component('mqtt', 'platformio')
    #topic = config[DOMAIN].get('topic', DEFAULT_TOPIC)
    entity_id = 'platformio.build'

    # Listener to be called when we receive a message.
    #def message_received(topic, payload, qos):
    #    """Handle new MQTT messages."""
    #    hass.states.set(entity_id, payload)

    # Subscribe our listener to a topic.
    #mqtt.subscribe(hass, topic, message_received)

    # Set the initial state.
    hass.states.set(entity_id, 'No messages')

    def get_ssl_fingerprint(addr="mqtt"):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        wrappedSocket = ssl.wrap_socket(sock)
        
        try:
            wrappedSocket.connect((addr, 8883)) #8883: the secure MQTT port.
        except:
            response = False
        else:
            der_cert_bin = wrappedSocket.getpeercert(True)
            pem_cert = ssl.DER_cert_to_PEM_cert(wrappedSocket.getpeercert(True))
            print(pem_cert)

            #Thumbprint
            thumb_sha1 = hashlib.sha1(der_cert_bin).hexdigest()
        wrappedSocket.close()
        return thumb_sha1

    # Service to publish a message on MQTT.
    def build(call):
        """Service to send a message."""
        mqtt = hass.components.mqtt
        hal_id = hass.states.get('input_text.id').state.rjust(4, "0")
        ssid = hass.states.get('input_text.ssid').state
        wifi_password = hass.states.get('input_text.wifi_password').state
        mqtt_host = hass.states.get('input_text.mqtt_host').state
        ssl_fingerprint = get_ssl_fingerprint()

        hal_config = {"name": "H.A.L. " + hal_id,
            "device_id": "hal" + hal_id,
            "wifi": {
                "ssid": ssid,
                "password": wifi_password
            },
            "mqtt": {
                "auth": True,
                "host": mqtt_host,
                "port": 1883,
                "base_topic": "hals/",
                "username": "$mqtt_username",
                "password": "$mqtt_password",
                "ssl": False,
                "ssl_fingerprint": ssl_fingerprint 
            },
            "ota": {
                "enabled": False
            },
            "settings": {
            }
        }
        mqtt.publish("platformio/build/nodemcuv2", json.dumps(hal_config, sort_keys=True))
        old_hal_id = hass.states.get('input_text.id').state
        hass.states.set('input_text.id', str(int(old_hal_id) + 1))


    # Register our service with Home Assistant.
    hass.services.register(DOMAIN, 'build', build)

    # Return boolean to indicate that initialization was successfully.
    return True

