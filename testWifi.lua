function testWifi(cfg)
    if (wifiTries > 0) then -- 0 = first time thru, dont check status just try connect
       ipAddr = wifi.sta.getip()
       if ( ( ipAddr ~= nil ) and ( ipAddr ~= "0.0.0.0" ) )then
         print("Wifi STA connected. IP:"..ipAddr)
         wifiTries=0
         return cfg.success_cb()
       end
    end   
    wifiTries = wifiTries + 1
    wifi.setmode( wifi.STATION )
    station_cfg={}
    station_cfg.ssid=SSID
    station_cfg.pwd=APPWD
    station_cfg.save=false
    wifi.sta.config(station_cfg) -- auto connects
    wifi.sleeptype(wifi.MODEM_SLEEP)
    print("Checking WIFI..." .. wifiTries)
    return cfg.failure_cb(cfg)
end
