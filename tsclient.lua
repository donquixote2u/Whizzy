-- Get data and send to host web server
-- rev 2 uses bulk update json file, as updates may be deferred if charge volts low
-- https://au.mathworks.com/help/thingspeak/bulkwritejsondata.html-- START HERE
-- print("\r\n webclient entered")
TSADDR = "184.106.153.149"
TSKEY="TIWBBVWTOW0KPWL0"
Ws={} -- init table of stored latest windSpeed vals
Readings={} -- init table of stored readings
dofile("testWifi.lua")        -- get wifi connect routines in
dofile("ide.lua")           -- load web ide
-- wait 10s to send data, send, then sleep
DELAY=10000
wifi_timer=tmr.create()
--ide_timer=tmr.create()
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
print("\r\ngetData:"..node.heap())
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
   if (PvVolts>3) then     -- if charge voltage ok, send data else skip
       cfg.success_cb=function() ide()  end -- run web ide
   else
       cfg.success_cb=function()
       dofile(sendData)
       wifi_timer:alarm(2000,tmr.ALARM_SINGLE, function() sendData() end )
    end    
   -- end
   cfg.retry_cb=function(cfg) testWifi(cfg) end
   -- cfg.retry_cb=function() testWifi(cfg) end
   wifi_timer:alarm(1000,tmr.ALARM_SINGLE, function() testWifi(cfg) end )
end -- end PvVolt test, now set timer to recall data send
data_timer:alarm(INTERVAL-DELAY,tmr.ALARM_SINGLE, function() getData() end )
end
