--- Get data and send to host web server
-- model - https://api.thingspeak.com/update?api_key=TIWBBVWTOW0KPWL0&field4=0001
-- START HERE -- print("\r\n webclient entered")
TSADDR = "184.106.153.149"
TSKEY="TIWBBVWTOW0KPWL0"
Ws={} -- init table of stored latest windSpeed vals
dofile("checkwifi.lua")        -- get wifi connect routines in
-- wait INTERVAL to send data, send, then sleep
tmr.alarm(2, INTERVAL, 1, function() Send() end )
-- END --

function Send()
print("\r\n Send called")
wifiTrys     = 0      -- Counter of trys to connect to wifi
checkWIFI()  
 if(CONNECTED~=true) then -- if not connected, resubmit call
  tmr.alarm( 1, 5000, 0, Send )
 else  
    sendData()  -- wifi connected, so send data
 end
end 
function sendData()
if((Ws~=nil) and (#Ws>0)) then 
  table.sort(Ws)   -- sort elapsed times  and extract median
  Middle=math.ceil(#Ws/2)  -- get val from middle of array
  Median = Ws[Middle]
  -- print("Median="..Median.."\r\n")
else
  Median=0
end  
if ((Median < THRESHOLD) and (Median > 0)) then 
  Speed = CALIBRATION / Median 
else
  Speed = 0  -- if huge elapsed, speed is 0
end
Ws={}   -- clear readings after send 
msElapsed = 0   -- reset elapsed time so not retransmitted later
disInt()    -- disable interrupts, or they will be corrupted by net module 
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
    -- go to sleep, wake up 30 secs before report due
    local DELAY2 = ((INTERVAL/2)*1000)
    -- local DELAY = 1000000  -- sleep 1 sec, 
    node.dsleep(DELAY2,4) -- sleep wake with radio disabled
    print("woke up!")
    node.restart()
    end)
--sk:on("disconnection", function(sck)
--    collectgarbage();
--    end)  
windSpeed=string.format("%04.1f",Speed)
windDir=read_compass()
print("\r\n WindDir="..windDir)
TSPARMS="update?api_key="..TSKEY.."&field3="..windSpeed.."&field4="..windDir.."&field5="..BattVolts.."&field6="..PvVolts;
REQBODY1= " HTTP/1.1\r\nHost: api.thingspeak.com\r\n";
REQBODY2="Accept: */*\r\n".."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n"
REQ="GET /"..TSPARMS..REQBODY1..REQBODY2;
-- print("Req="..REQ.."\r\n");
sk:connect(80,TSADDR)
end     -- end sendData func 

