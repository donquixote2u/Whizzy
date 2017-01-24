function checkWIFI()
CONNECTED=false
    ipAddr = wifi.sta.getip()
    if ( ( ipAddr ~= nil ) and ( ipAddr ~= "0.0.0.0" ) )then
         print("Wifi STA connected. IP:"..ipAddr)
         CONNECTED=true
         return
    else 
        wifiTrys = wifiTrys + 1
        if ( wifiTrys > NUMWIFITRYS ) then
           print("Sorry. Not able to connect")
           return
        else  -- try connection, set recheck timer
            tmr.register(checkwifi,5000,tmr.ALARM_SINGLE,checkWIFI)
            tmr.start(checkwifi)
            wifi.setmode( wifi.STATION )
            wifi.sta.config( SSID , APPWD)
            wifi.sleeptype(wifi.MODEM_SLEEP)
            print("Checking WIFI..." .. wifiTrys)
        end
    end
end
-- Wifi initialisation
checkwifi=tmr.create()
