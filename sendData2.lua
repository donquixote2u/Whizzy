function sendData()
print("\r\nsendData:"..node.heap())
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
  sk:on("receive", function(socket, packet)
    print("received:"..packet)
    end)
  sk:on("connection", function(socket)
    pocket=socket
    print ("Posting request\r\n");
    pocket:send(REQ)
    end)
  sk:on("sent",function(socket)
    -- print("Closing connection")
    -- sk:close()
    -- wifi.sta.disconnect()
    -- turn off wireless now that send is done, will resume on reboot
    ws_cfg={}
    ws_cfg.duration=0              -- suspend indefinitely
    ws_cfg.suspend_cb=function()
      enInt()
      Readings={}     -- clear sent data
      print("WiFi suspended") 
      end
    -- suspend wifi after enough time for send response            
    wifi_timer:alarm(10000 , tmr.ALARM_SINGLE, function() wifi.suspend(ws_cfg) end )
    end)                -- end sk:on(sent)
sk:connect(80,TSADDR)
end     -- end sendData func 


