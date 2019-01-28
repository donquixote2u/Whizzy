--- Get data and send to host web server
-- model - https://api.thingspeak.com/update?api_key=TIWBBVWTOW0KPWL0&field4=0001
-- START HERE -- print("\r\n webclient entered")
TSADDR = "184.106.153.149"
TSKEY="TIWBBVWTOW0KPWL0"
Ws={} -- init table of stored latest windSpeed vals
Readings={} -- init table of stored readings
dofile("testWifi.lua")        -- get wifi connect routines in
-- wait 2 min to send data, send, then sleep
DELAY=120000
-- local delayed_call=tmr.create()
delayed_call=tmr.create()
cfg={}
cfg.success_cb=function() sendData() end
cfg.retry_cb=function(cfg) testWifi(cfg) end
delayed_call:register(DELAY,tmr.ALARM_SINGLE, function() testWifi(cfg) end )
delayed_call:start()
-- END --

function sendData()
local result=calcwsavg()
windSpeed=string.format("%04.1f",result)
windDir=read_compass()
local Row=#Readings + 1
Readings[Row]={windSpeed, windDir, PvVolts, BattVolts}		-- insert another row
if (PvVolts<3) then 	-- not enough solar to maintain charge,  so store and bulk-forward later
  return
else  
  disInt()   			-- disable interrupts, or they will be corrupted by net module 
  print("Sending data to "..TSADDR)
  sk=net.createConnection(net.TCP, 0)
  sk:on("receive", function(sck, payload)
    print("received:"..payload)
    end)
  sk:on("connection", function(sck)
    conn=sck
    print ("Posting "..Speed.."...\r\n");
    conn:send(REQ)
    end)
  sk:on("sent",function(sck)
    print("Closing connection")
    sk:close()
    wifi.sta.disconnect()
    enInt()
    -- turn off wireless now that send is done, will resume on reboot
    cfg={}
    cfg.duration=0              -- suspend indefinitely
    cfg.suspend_cb=function()
                print("WiFi suspended") 
                end
    wifi.suspend(cfg)
    shutdown=tmr.create()
    shutdown:register(INTERVAL-120000 , tmr.ALARM_SINGLE, function() node.restart() end )
    shutdown:start()
    end)				-- end sk:on(sent)
-- print("\r\n WindDir="..windDir)
--TSPARMS="update?api_key="..TSKEY.."&field3="..windSpeed.."&field4="..windDir.."&field5="..BattVolts.."&field6="..PvVolts
REQBODY0="POST /channels/105927/bulk_update.json"
REQBODY1= " HTTP/1.1\r\nHost: api.thingspeak.com\r\n"
REQBODY1a="Connection: keep-alive\r\nkeep-alive: 1\r\nPragma: no-cache\r\n"
REQBODY1b="Cache-Control: no-cache\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: "
REQBODY2="\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n"
-- REQ="GET /"..TSPARMS..REQBODY1..REQBODY2
JSONHD="{\"write_api_key\":\""..TSKEY.."\",\"updates:["
JSONTR="]}"
JSON=""
for i=1,#READINGS do
     JSON=JSON.."\"delta_t\":1200,"
     for j = 1,4 do 
        local fn=j+2
        JSON=JSON.."\"field"..fn.."\":\""..READINGS[i][j].."\","
     end
    JSON=JSON.."},"     
end
REQ=REQBODY0..REQBODY1..REQBODY1a..REQBODY1b..jsonLength..REQBODY2..JSON
print("Req="..REQ.."\r\n");
sk:connect(80,TSADDR)
end					-- end PvVolt test
end     -- end sendData func 

function calcwsavg()
if((Ws~=nil) and (#Ws>0)) then 
  table.sort(Ws)   -- sort elapsed times  and extract median
  Middle=math.ceil(#Ws/2)  -- get val from middle of array
  Median = Ws[Middle]
  -- print("Median="..Median.."\r\n")
else
  Median=0
end  
if ((Median < THRESHOLD) and (Median > 0)) then 
  local result = CALIBRATION / Median 
else
  Speed = 0  -- if huge elapsed, speed is 0
end
Ws={}   -- clear readings after send 
return result
end


