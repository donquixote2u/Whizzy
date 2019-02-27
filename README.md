# Whizzy
ESP8266 Nodemcu control sw for solar/battery powered wind sensor.


** 23/2/19 WIP!  DO NOT USE **
**  9/2/19   changed for bulk  json update of  Thingspeak
 Wind Sensor Operation

Whizzy is a remote wind sensor, sending readings via wifi  and http to a collection point, currently set to Thingspeak.com.
The sensor is powered by batteries charged by solar panels for 24/7 operation.
	
The sensor is set to transmit at 20 min intervals, sleeping between intervals to reduce power.

The operational sequence is:

Monitor windspeed via a hall-effect sensor on a small turbine (anemometer rpm). 
(An average of recent instantaneous readings is kept)
Wind direction is calculated via an HMC5883L magnetometer translated to compass points.

