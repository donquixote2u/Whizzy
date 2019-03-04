function wifiSuspend() -- turn off wireless now that send is done, will resume on reboot
    ws_cfg={}
    ws_cfg.duration=0              -- suspend indefinitely
    ws_cfg.suspend_cb=function()
      diag("WiFi suspend scheduled") 
      end
    -- suspend wifi after enough time for send response            
    wifi_timer:alarm(10000 , tmr.ALARM_SINGLE, function() wifi.suspend(ws_cfg) end )
 end
function buildHeader()
 REQ="POST "..URL
 REQ=REQ.." HTTP/1.1\r\nHost: api.thingspeak.com\r\n"
 REQ=REQ.."Connection: keep-alive\r\nkeep-alive: 1\r\nPragma: no-cache\r\n"
 REQ=REQ.."Cache-Control: no-cache\r\nContent-Type: application/"
 if(sendtype=="1") then
   Type="x-www-form-urlencoded"
 else
   Type="json"   
 end   
 REQ=REQ..Type.."\r\nContent-Length: "
end
function formatDiags()
 datablock=""
 for i=1,#msg do  -- format row of data from array of readings
     datablock=datablock..i.."="..msg[i]
     if(i<#msg) then
        datablock=datablock.."&"
     end   
 end -- end do
end
function sendDiags()
 diag("senddiags "..node.heap())
 sendtype="1"
 addr=DBGADDR
 URL="/Debug/Showdiags.php"
 diag(addr..URL)
 buildHeader()
 formatDiags()
 msg={}
 local exitConnect=sendReadings  -- set exit call to readings send after diags
 Connect(exitConnect)
end
function formatReadings()
 datablock="{\"write_api_key\":\""..TSKEY.."\",\"updates\":["
 for i=1,#Readings do  -- format row of data from array of readings
     datablock=datablock.."{\"delta_t\":"..(((#Readings-i)+1)*(INTERVAL/1000))..","
     for j = 1,4 do 
        local fn=j+2
        datablock=datablock.."\"field"..fn.."\":\""..Readings[i][j].."\""
        if (j<4) then
           datablock=datablock..","
        end   
     end
     datablock=datablock.."}"
     if(i<#Readings) then
        datablock=datablock..","
     end   
 end
 datablock=datablock.."]}"
end
function sendReadings()
 diag("sendreadings "..node.heap())
 sendtype="2"
 addr=TSADDR
 URL="/channels/105927/bulk_update.json"
 diag(addr..URL)
 buildHeader()
 formatReadings()
 local exitConnect=clearSend
 Connect(exitConnect)
end
function clearSend()
 Readings={}     -- clear sent data
 wifiSuspend()
 enInt()
end
function sendData()
  sendDiags()
end -- end sendData func
function Connect(arg)
 local exitConnect=arg 
 REQ=REQ..datablock:len().."\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n"
 REQ=REQ..datablock
 datablock=""      -- release string memory
 print("Req="..REQ.."\r\n");
 print("Sending data to "..addr..":"..node.heap())
  sk=net.createConnection(net.TCP, 0)
  sk:on("receive", function(socket, packet)
    print("received: "..packet)
    end)
  sk:on("connection", function(socket)
    pocket=socket
    print ("Posting request\r\n");
    pocket:send(REQ)
    REQ=""          -- release string memory
    end)
  sk:on("sent",function(socket)
   print("packet sent") 
   wifi_timer:alarm(10000 , tmr.ALARM_SINGLE, function() exitConnect() end )
  end)                -- end sk:on(sent)
  sk:connect(80,addr)
end     -- end connect func 
