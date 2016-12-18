-- read and convert HMX5883L magnetometer 
dofile("i2c.lua")
compass_adr=0x1E --HMC5883L
id=0    -- bus
sda=2   -- i2c data GPIO4
scl=3   -- i2c clock GPIO0
point={N,NE,E,SE,S,SW,W,NW}    
-- initialize i2c, set gpio4 as sda, gpio0 as scl
i2c.setup(id,sda,scl,i2c.SLOW)
-- set mode register to 00 = continuous update    
write_i2c(compass_adr,0x02,0x00)
--  wait 100ms before trying to read compass (min 67ms)
-- tmr.alarm( 1 , 100, 0 , read_compass ) 
   
function reg2int(reg1, reg2)-- convert 2 hex bytes to 16 bit signed int
num=bit.lshift(reg1,8)+reg2
if num>2047 then num=num-65536 end
return num        
end

function read_compass()
-- get contents of all 6 data registers
result = read_i2c(compass_adr, 0x03, 6)
-- show contents in hex, convert to signed 16-bit integers
print("read:")
for i=1,6,1 do print(string.format("%02X",string.byte(result,i))) end
x=reg2int(string.byte(result, 1),string.byte(result, 2))
z=reg2int(string.byte(result, 3),string.byte(result, 4))
y=reg2int(string.byte(result, 5),string.byte(result, 6))
print("heading:"..x..";"..z..";"..y)
tmp=y-x
bearing="unresolved"
--tmp=round((2*math.atanf(y,x)-3),0)
-- LOGIC TO RESOLVE COMPASS BEARING BELOW
if (x<-100) then -- NNE->SSW thru S,E
    if(y<-220) then -- ESE->SSW thru S
        if(y>-300) then bearing="135" -- SSE->ESE=SE
        else bearing="180" end		 -- S
   else             --y>-220, ESE->NNE
        if(y>60) then bearing="45"	--  NE
        else bearing="90" end   -- ENE->ESE=E
   end              -- end y:220   
else            -- x>=-100  NNE->SSW thru N,W         
    if(y>-100) then -- WNW->NNE
       if(x<100) then bearing="0"-- NNW-NNE=N
       else bearing="315" end -- WNW-NNW=NW
    else        -- y<=-100 WNW-SSW
        if(x<0) then bearing="225"   --WSW-SSW=SW
        else bearing="270" end        --WSW-WNW=W
    end
end                          
-- print("Direction:"..bearing)
return bearing
end


 
