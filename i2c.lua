    -- user defined function: read from reg_addr content of dev_addr
    function read_i2c(dev_addr, reg_addr,len)
      i2c.start(id)
      i2c.address(id, dev_addr ,i2c.TRANSMITTER)
      i2c.write(id,reg_addr)
      i2c.stop(id)
      i2c.start(id)
      i2c.address(id, dev_addr,i2c.RECEIVER)
      c=i2c.read(id,len)
      i2c.stop(id)
      return c
    end

    function write_i2c(dev_addr, reg_addr, reg_val)
      i2c.start(id)
      i2c.address(id, dev_addr, i2c.TRANSMITTER)
      i2c.write(id, reg_addr)
      i2c.write(id, reg_val)
      i2c.stop(id)
    end
