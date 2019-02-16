-- Get data and send to host web server
-- rev 2 uses bulk update json file, as updates may be deferred if charge volts low
-- https://au.mathworks.com/help/thingspeak/bulkwritejsondata.html-- START HERE
-- print("\r\n webclient entered")
TSADDR = "184.106.153.149"
TSKEY="TIWBBVWTOW0KPWL0"
Ws={} -- init table of stored latest windSpeed vals
Readings={} -- init table of stored readings
dofile("testWifi.lua")        -- get wifi connect routines in
-- wait 10s to send data, send, then sleep
DELAY=10000
wifi_timer=tmr.create()
data_timer=tmr.create()
data_timer:alarm(DELAY,tmr.ALARM_SINGLE, function() getData() end )
-- END --

function calcwsavg()
if((Ws~=nil) and (#Ws>0)) then 
  table.sort(Ws)   -- sort elapsed times  and extract median
  Middle=math.ceil(#Ws/2)  -- get val from middle of array
  Median = Ws[Middle]
  -- DEBUG   print("Median="..Median.."\r\n")
else
  Median=0
end  
if ((Median < THRESHOLD) and (Median > 0)) then 
  result = CALIBRATION / Median 
else
  result = 0  -- if huge elapsed, speed is 0
end
Ws={}   -- clear readings after send 
return result
end

function getData()
getadc()    -- get PV, Batt voltages
local Speed=calcwsavg()        -- get avg windspeed
if ((Speed~=0) and (Speed ~= nil)) then
   windSpeed=string.format("%04.1f",Speed)
else   
   windSpeed=0
end
windDir=read_compass()
DELAY=(2*period)+500 -- allow time for completion of reads
data_timer:alarm(DELAY,tmr.ALARM_SINGLE, function() saveData() end )
end

function saveData()
local Row=#Readings + 1     -- save readings for sending 
Readings[Row]={windSpeed, windDir, BattVolts, PvVolts }        -- insert another row
if ((PvVolts>3) or (#Readings>3)) then     -- if charge voltage ok, send data else skip
   disInt()            -- disable interrupts, or they will be corrupted by net module 
   cfg={}
   cfg.success_cb=function() sendData() end
   cfg.retry_cb=function(cfg) testWifi(cfg) end
   wifi_timer:alarm(1000,tmr.ALARM_SINGLE, function() testWifi(cfg) end )
end -- end PvVolt test, now set timer to recall data send
data_timer:alarm(INTERVAL-DELAY,tmr.ALARM_SINGLE, function() getData() end )
end

function sendData()
REQBODY0="POST /channels/105927/bulk_update.json"
REQBODY1= " HTTP/1.1\r\nHost: api.thingspeak.com\r\n"
REQBODY1a="Connection: keep-alive\r\nkeep-alive: 1\r\nPragma: no-cache\r\n"
REQBODY1b="Cache-Control: no-cache\r\nContent-Type: application/json\r\nContent-Length: "
REQBODY2="\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n"
JSONHD="{\"write_api_key\":\""..TSKEY.."\",\"updates\":["
JSONTR="]}"
JSON=""
for i=1,#Readings do  -- format row of data from array of readings
     JSON=JSON.."{\"delta_t\":"..(((#Readings-i)+1)*(INTERVAL/1000))..","
     for j = 1,4 do 
        local fn=j+2
        JSON=JSON.."\"field"..fn.."\":\""..Readings[i][j].."\""
        if (j<4) then
           JSON=JSON..","
        end   
     end
     JSON=JSON.."}"
     if(i<#Readings) then
        JSON=JSON..","
     end   
end
JSON=JSONHD..JSON..JSONTR
jsonLength=JSON:len()
REQ=REQBODY0..REQBODY1..REQBODY1a..REQBODY1b..jsonLength..REQBODY2..JSON
print("Req="..REQ.."\r\n");
print("Sending data to "..TSADDR)
  sk=net.createConnection(net.TCP, 0)
  sk:on("receive", function(sck, payload)
    print("received:"..payload)
    end)
  sk:on("connection", function(sck)
    conn=sck
    print ("Posting request\r\n");
    conn:send(REQ)
    end)
  sk:on("sent",function(sck)
    -- print("Closing connection")
    -- sk:close()
    -- wifi.sta.disconnect()
    -- turn off wireless now that send is done, will resume on reboot
    cfg={}
    cfg.duration=0              -- suspend indefinitely
    cfg.suspend_cb=function()
      enInt()
      Readings={}     -- clear sent data
      print("WiFi suspended") 
      end
    -- suspend wifi after enough time for send response            
    wifi_timer:alarm(10000 , tmr.ALARM_SINGLE, function() wifi.suspend(cfg) end )
    end)				-- end sk:on(sent)
sk:connect(80,TSADDR)
end     -- end sendData func 


