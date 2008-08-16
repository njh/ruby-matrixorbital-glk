#!/usr/bin/ruby
#
# Script to display information about the connected LCD Module
#
# Author::    Nicholas J Humfrey  (mailto:njh@aelius.com)
# Copyright:: Copyright (c) 2008 Nicholas J Humfrey
# License::   Distributes under the same terms as Ruby
#

$:.unshift File.dirname(__FILE__)+'/../lib'

require 'matrixorbital/glk'


glk = MatrixOrbital::GLK.new(ARGV[0]||'/dev/ttyUSB0')
puts "Serial Port:    #{glk.path}"
puts "Baud Rate:      #{glk.baudrate}"
puts "LCD Type:       #{glk.lcd_type}"
puts "LCD Dimensions: #{glk.lcd_dimensions.join('x')}"
puts "LCD Firmware:   #{glk.firmware_version}"
