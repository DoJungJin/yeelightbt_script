# Yeelightbt script
When using yeelight bluetooth besidelamp on HomeAssistant, This Script may help you.
I am newbie code writing, main skills are copy & paste.

## Description
> dependencies

https://github.com/rytilahti/python-yeelightbt
(thanks rytilahti.)

> HomeAssistant Light Template Example yaml

### 0. Something may help

#### 1. mired value <---> kelvin value
yeelight color temp ranges : 1700K ~ 6500K
HA mired ranges : 153 ~ 500

`1000000 / 1700 = 588 mired`
`1000000 / 6500 = 153 mired`

#### 2. Light Value <---> HA Light Value
yeelight light ranges : 0 ~ 100
HA light ranges : 0 ~ 255

### 1. Shell Command

Use {{value}} for input when call 'shell_command.lamp_turnon'

      lamp_turnon: '/config/yeelight.sh power on'
      lamp_turnoff: '/config/yeelight.sh power off'
      lamp_set_bright: '/config/yeelight.sh bright {{value}}'
      lamp_set_temp: '/config/yeelight.sh temp {{value}}'

### 2. Template Light Sensor

Yeelight.sh file will return Light Value as JSON Type.
(not using jq, just used echo -e)

    - platform: command_line
      name: besidelamp_state
      command: '/config/yeelight.sh state'
      value_template: '{{ value_json }}'
      json_attributes:
        - power
        - bright
        - temp
      command_timeout: 5
      scan_interval: 1
	  
### 3. Template Light

As I commented above, should convert value from Yeelight to HomeAssistant.
(brightness / color_temp)

Also, Despite yeelightbt python script can controll color value.
By the way, I don't need change color. So not added below code.

      - platform: template
        lights:
          beside_lamp:
            friendly_name: "무드등"
            level_template: "{{ ((state_attr('sensor.besidelamp_state', 'bright') | float) * 255 / 100) | int }}"
            value_template: "{{ is_state_attr('sensor.besidelamp_state', 'power', 'on') }}"
            temperature_template: "{{ (1000000 / (state_attr('sensor.besidelamp_state', 'temp') | float)) |  int }}"
            turn_on:
              service: shell_command.lamp_turnon
            turn_off:
              service: shell_command.lamp_turnoff
            set_level:
              service: shell_command.lamp_set_bright
              data_template:
                value: "{{ ((brightness | float / 255) * 100) | int }}"
            set_temperature:
              service: shell_command.lamp_set_temp
              data_template:
                value: "{{ (1000000 / (color_temp | float)) | int }}"
    
