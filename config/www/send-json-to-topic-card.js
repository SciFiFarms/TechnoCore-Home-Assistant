import "/local/ace-widget/ace-widget.js"
class SendJsonToTopicCard extends Polymer.Element {
  static get template() {
    // Highlighting of html is only supported if the string literal is "html`...".
    // Thus Polymer.html doesn't work. Needs VS Code extension "es6-string-html".
    var html = Polymer.html;
    return html`
      <style>
        ha-card {
          padding: 16px;
        }
        ha-card[header] {
          padding-top: 0;
        }
      </style>
      <ha-card header$="[[_config.title]]">
        <paper-dropdown-menu label="H.A.L to send JSON to:">
          <paper-listbox
            slot="dropdown-content"
            attr-for-selected="device"
            selected="{{_hal}}"
          >
            <template is="dom-repeat" items="{{_hals}}">
              <paper-item device\$="[[item]]">
                [[item]]
              </paper-item>
            </template>
          </paper-listbox>
        </paper-dropdown-menu>

        <ace-widget 
          value="{{_json}}" 
          baseUrl="/local/ace-builds/src-noconflict/" 
          mode="ace/mode/json" 
          placeholder="No HAL selected." 
          initial-focus=""
          ></ace-widget>

        <p class='action'>
          <paper-button raised on-click='_submitForm'>
            Send Config
          </paper-button>
        </p>
      </ha-card>
    `;
  }

  static get properties() {
    return {
      hass: Object,
      _config: Object,
      _hal: {
        type: String,
        observer: "_halChanged"
      },
      _hals: Array,
      _json: String
    };
  }

  _halChanged() {
    // Parsing and then stringifying so that newlines and indents get added.
    // zed editor might have the ability to auto indent to work around this.
    // https://stackoverflow.com/questions/39656560/auto-indent-text-in-ace-editor
    this._json = JSON.stringify(JSON.parse(this._hass['states'][this._hal]['attributes']['config']), undefined, 2);
  }

  getCardSize() {
    return 4;
  } 

  setConfig(config) {
    this._config = config;
  }

  set hass(hass) {
    this._hass = hass;
    
    // Update the list of H.A.L.s
    this._hals = 'group.all_hals' in hass['states'] ? hass['states']['group.all_hals']['attributes']['entity_id'] : ["None"];
    this.setProperties({
      _hals: this._hals
    });
  }

  async _submitForm() {
    this._hass.callService('mqtt', 'publish', {
      topic: 'hals/' + this._hass['states'][this._hal]['attributes']['device_id'] + '/$implementation/config/set',
      payload: this._json
    });
  }
}
customElements.define("send-json-to-topic-card", SendJsonToTopicCard);
