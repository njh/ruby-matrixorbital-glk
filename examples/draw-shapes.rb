#!/usr/bin/ruby
#
# Example script to draw shapes to the screen
#
# Author::    Nicholas J Humfrey  (mailto:njh@aelius.com)
# Copyright:: Copyright (c) 2008 Nicholas J Humfrey
# License::   Distributes under the same terms as Ruby
#

$:.unshift File.dirname(__FILE__)+'/../lib'

require 'matrixorbital/glk'

glk = MatrixOrbital::GLK.new(ARGV[0]||'/dev/ttyUSB0')

# Clear the screen and turn it on
glk.clear_screen
glk.backlight = true
glk.brightness =128


# Draw a triangle
glk.draw_line(1,30,30,1)
glk.draw_line_continue(59,30)
glk.draw_line_continue(1,30)


# Draw a circle
theta=0.0
radius=20
xcenter,ycenter = [90,30]
while(theta<(2*Math::PI))
  x=xcenter+(radius*Math::sin(theta))
  y=ycenter+(radius*Math::cos(theta))
  glk.draw_pixel(x,y)
  theta+=0.025
end


# Draw some rectangles
for i in (0..4)
  pos = i*10
  glk.draw_rect(1, pos+120, pos, pos+140, pos+20)
end


# Draw a solid rectange
glk.draw_solid_rect( 1, 10, 40, 30, 60 )

# Change colour
glk.drawing_color(0)
glk.drawing_pixel(15,45)

