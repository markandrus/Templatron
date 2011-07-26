#! /usr/local/bin/ruby

require 'rubygems'
require 'RMagick'
include Magick

def makeMasthead(title, outputGif)
	text = Draw.new
	text.font = 'Gotham-Rounded-Light'
	text.pointsize = 28 
	text.gravity = SouthWestGravity
	hdr = ImageList.new
	hdr.new_image(650, 53, GradientFill.new(0, 0, 0, 0, '#7c0000', '#7c0000'))
	hdr.transparent_color = '#7c0000'
	text.annotate(hdr, 0, 0, 0, 0, title) {
		self.fill = 'white'
	}
	hdr.transparent('#7c0000').write(outputGif)
end

