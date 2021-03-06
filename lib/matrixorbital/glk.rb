#!/usr/bin/ruby
#
# A ruby gem to interface Matrix Orbital's GLK series of LCD Screens.
#
# Author::    Nicholas J Humfrey  (mailto:njh@aelius.com)
# Copyright:: Copyright (c) 2008 Nicholas J Humfrey
# License::   Distributes under the same terms as Ruby
#

module MatrixOrbital

class GLK < File
  attr_reader :baudrate
  
  # Connect to an LCD screen.
  # All of the parametes are optional.
  # By default the LCD screen type will be detected automatically.
  def initialize(serialport='/dev/ttyS0', baudrate=19200, manual_lcd_type=nil)
  
    # Does the device exist?
    unless File.exists? serialport
      raise "Serial port '#{serialport}' does not exist."
    end
  
    # Use the lcd_type given, or ask the module
    unless manual_lcd_type.nil?
      @lcd_type = manual_lcd_type
    end

    # Store the baudrate
    
    # Configure the serial port
    # FIXME: use pure ruby
    @baudrate = baudrate
    system("stty -F #{serialport} raw speed #{baudrate} cs8 -ixon -echo cbreak -isig -parenb > /dev/null") or
      raise "Failed to set parameters on the serial port."

    # Now, open the serial port
    super(serialport, "rb+")

    # Disable buffering
    self.sync = true
    
    # Flush the input buffer
    
  end

  # This command sets the I2C write address of the module between 0x00 
  # and 0xFF. The I2C write address must be an even number and the read 
  # address is automatically set to one higher. For example if the I2 C write 
  # address is set to 0x50, then the read address is 0x51.
  def i2c_slave_address=(address)
    raise "I2C slave address is out of range" if (value<0 or value>255)
    send_command( 0x33, address )
  end

  # This command sets the lcd's RS-232 port to the specified <em>baudrate</em>.
  # The change takes place immediately.
  def lcd_baudrate=(lcd_baudrate)
    case lcd_baudrate
      when 9600 then
        send_command( 0x39, 0xCF )
      when 14400 then
        send_command( 0x39, 0x8A )
      when 19200 then
        send_command( 0x39, 0x67 )
      when 28800 then
        send_command( 0x39, 0x44 )
      when 38400 then
        send_command( 0x39, 0x33 )
      when 57600 then
        send_command( 0x39, 0x22 )
      when 76800 then
        send_command( 0x39, 0x19 )
      when 115200 then
        send_command( 0x39, 0x10 )
      else
        raise "Invalid/unsupported baud rate: #{lcd_baudrate}"
    end
  end


  # Turn flow control on or off.
  def flow_control=(state)
    if state
      raise "Flow control is unsupported"
      #  send_command( 0x3A )
    else
      send_command( 0x3B )
    end
  end

  
  # Turn the LCD backlight on/off immediately and stay on/off.
  def backlight=(state)
    if state
      # FIXME: backlight hard coded to stay on permanently
      send_command( 0x42, 0 )
    else
      send_command( 0x46 )
    end
  end
  
  # This command moves the text insertion point to the top left of the 
  # display area, based on the current font metrics.
  def cursor_home
    send_command( 0x48 )
  end

  # This command sets the text insertion point to the [col] and [row] 
  # specified. The insertion point is positioned using the base size of 
  # the current font (this command does not position the insertion 
  # point at a specific pixel).
  #
  # Example:
  #
  #  lcd.cursor_position = [10,4]
  #
  def cursor_position=(params)
    col,row = params
    send_command( 0x47, col, row )
  end

  # This command positions the insertion point at a specific pixel (X,Y), 
  # which references the top left corner of the font insertion point.
  #
  # Example:
  #
  #  lcd.cursor_coordinate = [100,40]
  #
  def cursor_coordinate=(params)
    x,y = params
    send_command( 0x79, x, y )
  end
  
  # This command sets the display's contrast to <em>value</em>, 
  # where <em>value</em> is a value between 0 to 255. 
  # Lower values cause 'on' elements in the display area to appear 
  # lighter, while higher values cause 'on' elements to appear darker.
  def contrast=(value)
    raise "Contrast value is out of range" if (value<0 or value>255)
    send_command( 0x50, value )
  end
  
  # Like the <em>contrast=</em> method, only this command saves the 
  # value so that it is not lost after power down.
  def save_contrast(value)
    raise "Contrast value is out of range" if (value<0 or value>255)
    send_command( 0x91, value )
  end
  
  # This command sets the display's brightness to <em>value</em>, 
  # where <em>value</em> is a value between 0 to 255. 
  def brightness=(value)
    raise "Brightness value is out of range" if (value<0 or value>255)
    send_command( 0x99, value )
  end
  
  # Like the <em>brightness=</em> method, only this command saves the 
  # value so that it is not lost after power down.
  def save_brightness(brightness)
    raise "Brightness value is out of range" if (value<0 or value>255)
    send_command( 0x98, brightness )
  end
  
  # This command enabled and disables autoscrolling.
  # When auto scrolling is on, it causes the display to shift the entire 
  # display's contents up to make room for a new line of text when the text 
  # reaches the end of the scroll row defined in the font metrics (the bottom 
  # right character position)
  def autoscroll=(state)
    if state
      send_command( 0x51 )
    else
      send_command( 0x52 )
    end
  end

  # This command clears any unread key presses.
  def clear_key_buffer
    send_command( 0x45 )
  end
  
  # When auto transmit key presses is turned on all key presses are sent 
  # immediately to the host system without the use of the <em>poll_keypad</em> 
  # method. This is the default mode on power up. 
  #
  # When auto transmit key presses is turned off up to 10 key presses are 
  # buffered until the unit is polled by the host system.
  def auto_transmit_key_presses=(state)
    if state
      send_command( 0x41 )
    else
      send_command( 0x4F )
    end
  end
  
  # This command returns any buffered key presses as an array of key codes. 
  # When the display receives this command, it will immediately return any 
  # buffered key presses which may have not been read already.
  def poll_key_press
    send_command( 0x26 ) 
    
    keys = []
    begin
      # Read in key preses, while the Most Significant Bit is set
      key = getc
      keys << (key & 0x7F) if (key != 0x00)
    end while (key & 0x80)
    
    return keys
  end
  
  
  # This command sets the time (in miliseconds) between key press and key read.
  # All key types with the exception of latched piezo switches will 'bounce' 
  # for a varying time, depending on their physical characteristics.
  def debounce_time=(ms)
    time = (ms.to_f / 6.554).to_i
    raise "Debounce time is out of range" if (value<0 or value>255)
    send_command( 0x63, value )
  end
  
  # This command sets the drawing color for subsequent graphic commands 
  # that do not have the drawing color passed as a parameter. The parameter 
  # <em>color</em> is the value of the color where white is <em>false<em>
  # and black <em>true<em>.
  def drawing_color=(color)
    send_command( 0x63, color ? 0 : 1 )
  end

  # This command clears the display and resets the text insertion position to 
  # the top left position of the screen defined in the font metrics.
  def clear_screen
    send_command( 0x58 )
  end

  # This command will draw a bitmap that is located in the on board memory.
  # The bitmap is referenced by the bitmaps reference identification number, 
  # which is established when the bitmap is uploaded to the display module. 
  # The bitmap will be drawn beginning at the top left, 
  # from the specified <em>x</em>,<em>y</em> coordinates.
  def draw_bitmap(refid, x, y)
    send_command( 0x62, refid, x, y )
  end
  
  # This command will draw a pixel at <em>x</em>, <em>y</em> using 
  # the current drawing color.
  def draw_pixel(x, y)
    send_command( 0x70, x, y )
  end
  
  # This command will draw a line from <em>x1</em>, <em>y1</em>
  # to <em>x2</em>, <em>y2</em> using the current drawing color. 
  # Lines may be drawn from any part of the display to any other part. 
  # However, it may be important to note that the line may in-terpolate 
  # differently right to left, or left to right. 
  # This means that a line drawn in white from right to left may not 
  # fully erase the same line drawn in black from left to right.
  def draw_line(x1, y1, x2, y2)
    send_command( 0x6C, x1, y1, x2, y2 )
  end
  
  # This command will draw a line with the current drawing color from 
  # the last line end (x2,y2) to <em>x</em>, <em>y</em>.
  # This command uses the global drawing color.
  def draw_line_continue(x, y)
    send_command( 0x65, x, y )
  end
  
  # This command draws a rectangular box in the specified <em>color</em>. 
  # The top left corner is specified by <em>x1</em>, <em>y1</em> and 
  # the bottom right corner by <em>x2</em>, <em>y2</em>.
  def draw_rect(color, x1, y1, x2, y2)
    send_command( 0x72, color, x1, y1, x2, y2 )
  end
  
  # This command erases a single bitmap file from the LCD's internal memory.
  def delete_bitmap(refid)
    send_command( 0xAD, 0x01, refid )
  end
  
  # This command erases a single font file from the LCD's internal memory.
  def delete_font(refid)
    send_command( 0xAD, 0x00, refid )
  end

  # Set the current font to the specified font refernce identifer.
  # The font ID is es-tablished when the font is saved to the display.
  def font=(refid)
    send_command( 0x31, refid )
  end
  
  # This command completely erases the display's non-volatile memory. It 
  # removes all fonts, font metrics, bitmaps, and settings (current font, 
  # cursor position, communication speed, etc.).
  def wipe_filesystem
    send_command( 0x21, 0x59, 0x21 )
  end
  
  # This command will return the number of bytes that are 
  # remaining in the on board memory.
  def filesystem_space
    send_command( 0xAF )
  
    #my count = getint()
    
    #count |= ( & 0xFF) << 0;
    #count |= (getchar() & 0xFF) << 8;
    #count |= (getchar() & 0xFF) << 16;
    #count |= (getchar() & 0xFF) << 24;
    #
    #return count;
  end
  
  # This command will return a directory of the contents of the file system.
  # It returns an array of directory entires, where each entry is a hash.
  def filesystem_directory
    send_command( 0xB3 )
  
    #my lsb = getchar()
    
    #my @bytes = getbytes( 4 )
  
    #my count = 0;
    #count |= (@bytes[0] & 0xFF) << 0;
    #count |= (@bytes[1] & 0xFF) << 8;
    #count |= (@bytes[2] & 0xFF) << 16;
    #count |= (@bytes[3] & 0xFF) << 24;
    
    #return count;
    
    #return lsb;
  end
  
  # This command draws a solid rectangle in the specified <em>color</em>. 
  # The top left corner is specified by <em>x1</em>, <em>y1</em> and the bottom 
  # right corner by <em>x2</em>, <em>y2</em>. Since this command involves 
  # considerable processing overhead, we strongly recommend the use of flow 
  # control, particularly if the command is to be repeated frequently.
  def draw_solid_rect(color, x1, y1, x2, y2)
    send_command( 0x78, color, x1, y1, x2, y2 )
  end

  # This command turns Off general purpose output <em>num</em>.
  def gpo_off(num)
     send_command( 0x56, num )
  end

  # This command turns On general purpose output <em>num</em>.
  def gpo_on(num)
    send_command( 0x57, num )
  end
  


  # Send a raw command to the display, where <em>args<em> is an
  # array of integer bytes to be sent to the lcd module.
  def send_command(command, *args)
    args.unshift(0xFE, command)
    self.print( args.pack('C*') )
  end
  
  # Send text string to display and STDOUT too
  def puts_stdout(*args)
    $stdout.puts(*args)
    self.puts(*args)
  end


  # Turn LED number <em>num</em> off.
  #
  # The command is only supported on LCD modules with 
  # on-board LEDS (such as the GLK19264-7T-1U)
  def led_off(num)
    gpo_base = led_gpo_base(num)
    gpo_on( gpo_base )
    gpo_on( gpo_base+1 )
  end
  
  # Turn LED number <em>num</em> on - Red.
  #
  # The command is only supported on LCD modules with 
  # on-board LEDS (such as the GLK19264-7T-1U)
  def led_red(num)
    gpo_base = led_gpo_base(num)
    gpo_off( gpo_base )
    gpo_on( gpo_base+1 )
  end
  
  # Turn LED number <em>num</em> on - Green.
  #
  # The command is only supported on LCD modules with 
  # on-board LEDS (such as the GLK19264-7T-1U)
  def led_green(num)
    gpo_base = led_gpo_base(num)
    gpo_on( gpo_base )
    gpo_off( gpo_base+1 )
  end
  
  # Turn LED number <em>num</em> on - Yellow.
  #
  # The command is only supported on LCD modules with 
  # on-board LEDS (such as the GLK19264-7T-1U)
  def led_yellow(num)
    gpo_base = led_gpo_base(num)
    gpo_off( gpo_base )
    gpo_off( gpo_base+1 )
  end
  

  # Returns the firmware version of the LCD module that you are 
  # communicating with as a dotted integer (for example '5.4').
  def firmware_version
    return @firmware_version unless @firmware_version.nil?

    # Request firmware version number
    send_command( 0x36 )

    # Read back one byte
    value = getc
    major = (value & 0xF0) >> 4
    minor = value & 0x0F
    return @firmware_version = "#{major}.#{minor}"
  end


  TYPEMAP = {
    0x10 => 'GLC12232',
    0x13 => 'GLC24064',
    0x15 => 'GLK24064-25',
    0x22 => 'GLK12232-25',
    0x24 => 'GLK12232-25-SM',
    0x26 => 'GLK24064-16-1U',
    0x27 => 'GLK19264-7T-1U',
    0x28 => 'GLK12232-16',
    0x29 => 'GLK12232-16-SM',
    0x72 => 'GLK240128-25'
  }

  # Return the Product Idenfier for the LCD module (for example 'GLK24064-25').
  # This can be determined automatically or passed as a parameter to new().
  def lcd_type
    return @lcd_type unless @lcd_type.nil?

    # Request LCD module type
    send_command( 0x37 )

    # Read back one byte
    type = getc
    if TYPEMAP.has_key?(type)
      @lcd_type = TYPEMAP[type]
    else
      @lcd_type = "Unknown-#{type}"
    end
  end   
  
  # Returns the dimensions (in pixels) of the LCD module you are talking 
  # to as an array, width followed by height.
  def lcd_dimensions
    # Parse the LCD type to work out the dimensions
    if (lcd_type =~ /^(GLC|GLK)(\d{3})(\d{2})-|$/)
      return [$2,$3]
    else
      raise "Can't get screen dimensions: unknown LCD module"
    end
  end

private

  # Private method to get the base GPO bit for specified LED number
  def led_gpo_base(num)
    case num.to_i
      when 0
        1
      when 1
        3
      when 2
        5
      else
        raise 'Invalid LED number'
    end
  end

end # GLK
end # MatrixOrbital
