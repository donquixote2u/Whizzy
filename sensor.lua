--- on interrupt from Hall Effect Sensor pin, cal elapsed time since last int
function calcWindspeed()
-- DEBUG print("\r\ninterrupt triggered")
msNow=tmr.now();
if (msLast ~= 0) then		-- if a revious trigger since last calcs, do calcs
    local msElapsed = msNow-msLast;
    if (msElapsed > 250000) then -- if period not > 1/4 sec, bogus or hurricane!
     if (#Ws > 9) then
        table.remove(Ws,1)   -- if table has full 10 entries, shift off first
     end 
     -- DEBUG      
     diag("ms="..msElapsed.."\r\n")  
     table.insert(Ws,msElapsed)
     msLast=msNow; -- save reading as Last
   end
else -- last is 0 so initialise
   msLast=msNow; -- save reading as Last
end  -- end comparison against last 
end 

--enable interrupts
function enInt()     
    gpio.mode(SENSEPIN,gpio.INT)
    gpio.trig(SENSEPIN,'down',calcWindspeed)
end

--disable interrupts
function disInt()
     gpio.mode(SENSEPIN, gpio.INPUT)
end

function diag(txt)
if(#msg>98) then
  table.remove(msg,1) -- drop oldest msg table entry
end
table.insert(msg,txt)
print(txt)
end
-- start here ; set up sensor pin interrupts, comms, send data
msLast = 0		-- init last trigger time to 0
SENSEPIN = 1
Ws = {}  -- init table of latest elapsed times so median can be taken
msg={}   -- debug messages to be sent to web display   
enInt()
-- set up i2c bus for adc and compass reads
dofile("i2c.lua")
id=0    -- bus
sda=2   -- i2c data GPIO4
scl=3   -- i2c clock GPIO0
-- initialize i2c, set gpio4 as sda, gpio0 as scl
i2c.setup(id,sda,scl,i2c.SLOW)
dofile("readcompass.lua")   -- get compass read routines in
dofile("getadc.lua")        -- get adc read routines in
require("tsclient")      -- load and run thingspeak send
