function sendData()
REQ="POST /Debug/Showdiags.php"
REQ=REQ.." HTTP/1.1\r\nHost: api.thingspeak.com\r\n"
REQ=REQ.."Connection: keep-alive\r\nkeep-alive: 1\r\nPragma: no-cache\r\n"
REQ=REQ.."Cache-Control: no-cache\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: "
DBGDTA=""
for i=1,#msg do  -- format row of data from array of readings
     DBGDTA=DBGDTA..i.."="..msg[i]
     if(i<#msg) then
        DBGDTA=DBGDTA.."&"
     end   
end
dtaLength=DBGDTA:len()
REQ=REQ..dtaLength.."\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n"
REQ=REQ..DBGDTA
addr=DBGADDR
Connect()
end -- end sendData func
function Connect()
debug("Req="..REQ.."\r\n");
debug("Sending data to "..addr)
  sk=net.createConnection(net.TCP, 0)
  sk:on("receive", function(socket, packet)
    debug("received:"..packet)
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
      debug("WiFi suspended") 
      end
    -- suspend wifi after enough time for send response            
    wifi_timer:alarm(10000 , tmr.ALARM_SINGLE, function() wifi.suspend(ws_cfg) end )
    end)                -- end sk:on(sent)
sk:connect(80,addr)
end     -- end connect func 


