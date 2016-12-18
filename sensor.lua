--- on interrupt from Hall Effect Sensor pin, cal elapsed time since last int
function calcWindspeed()
print("\r\ninterrupt triggered")
msNow=tmr.now();
if (msLast ~= 0) then
    local Period = msNow-msLast;
    if (Period > 250000) then -- if period not > 1/4 sec, bogus or hurricane!
     msElapsed=Period;
     print("ms="..msElapsed.."\r\n")
     if (#Ws > 9) then
        table.remove(Ws,1)   -- if table has full 10 entries, shift off first
     end   
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

-- start here ; set up sensor pin interrupts, comms, send data
msLast = 0
msElapsed = 0
SENSEPIN = 1
Ws = {}  -- init table of latest elapsed times so median can be taken
enInt()
tmr.alarm( 2 , 2500 , 0 ,  function() require("tsclient") end)
