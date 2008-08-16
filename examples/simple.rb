#!/usr/bin/ruby
#
# Script to display "Hello World" on the LCD screen
#
# Author::    Nicholas J Humfrey  (mailto:njh@aelius.com)
# Copyright:: Copyright (c) 2008 Nicholas J Humfrey
# License::   Distributes under the same terms as Ruby
#

$:.unshift File.dirname(__FILE__)+'/../lib'

require 'matrixorbital/glk'

glk = MatrixOrbital::GLK.new(ARGV[0]||'/dev/ttyUSB0')
glk.clear_screen
glk.backlight = true
glk.brightness = 128
glk.puts "Hello World!"

