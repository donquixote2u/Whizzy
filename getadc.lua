-- reads 2 analogue voltages (Batt/Solar) via CD4051 switch
CTLPIN=7        -- set GPIO13 as CD4051 (adc) enable/disable)
ADRPIN=6        -- set GPIO12 as adc channel select (0 or 1)
gpio.mode(CTLPIN, gpio.OUTPUT) -- set ctlpin output,high=disabled
gpio.write(CTLPIN,1)           -- start with adc disabled 
gpio.mode(ADRPIN, gpio.OUTPUT) -- set adrpin as output
     
if adc.force_init_mode(adc.INIT_ADC) then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end

function read_adc(adcinput) 
    gpio.write(CTLPIN,0)  -- enable adc 
    gpio.write(ADRPIN,adcinput)  -- select adr (0 or 1)
    local volts=adc.read(0)     -- read 4051 output
    gpio.write(CTLPIN,1)        -- disable adc 
    return volts
end

