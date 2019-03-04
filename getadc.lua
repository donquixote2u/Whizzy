-- reads 2 analogue voltages (Batt/Solar) via i2c from attiny85 adc
function getadc()
att_adr=0x13 --attiny adc
period=5000   -- allow time to check 2 sensors before xmit
adc2delay=tmr.create()
adc3delay=tmr.create()
write_i2c(att_adr,0x00,2) -- write # of adc to be sampled into reg 0 to start sampling
tmr.register(adc2delay,period,tmr.ALARM_SINGLE,function()
     -- get reg 2 = adc3 = pv panels
    PvVolts=string.format("%02d",string.byte(read_i2c(att_adr, 2, 1)))/1.4 
    -- DEBUG 
    diag("PvVolts="..PvVolts)
    write_i2c(att_adr,0x00,3)
    -- don;t start next sample until first done
    tmr.register(adc3delay,period,tmr.ALARM_SINGLE,function()
        -- get reg 3 = adc2 = battery
        BattVolts=string.format("%02d",string.byte(read_i2c(att_adr, 3, 1)))/1.4
        -- DEBUG READ OF I2C registers
        -- for i=1,6,1 do
        --      byte=string.byte(read_i2c(att_adr, i, 1),1)
        --      print(string.format("%02X",byte))
        -- end
        -- DEBUG 
        diag("BattVolts="..BattVolts)
        end)
    tmr.start(adc3delay)    
    end)
tmr.start(adc2delay)
end
