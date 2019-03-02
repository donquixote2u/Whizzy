function testWifi(cfg)
    diag("test wifi"..wifiTries)
    if (wifiTries > 0) then -- 0 = first time thru, dont check status just try connect
       ipAddr = wifi.sta.getip()
       if ( ( ipAddr ~= nil ) and ( ipAddr ~= "0.0.0.0" ) )then
         print("Wifi STA connected. IP:"..ipAddr)
         wifiTries=0
         return cfg.success_cb()
       end
    end 
    if (wifi.suspend()==2) then
       diag("wifi resumed")
       wifi.resume()   -- in case wifi has been suspended  
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
    -- return cfg.retry_cb(cfg)
    wifi_timer:alarm(10000,tmr.ALARM_SINGLE, function() cfg.retry_cb(cfg) end )
end
