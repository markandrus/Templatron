#! /usr/local/bin/ruby

require 'rubygems'
begin
	require 'RMagick'
	include Magick
	def makeMasthead(title, outputPng)
		title.strip!
		text = Draw.new
		text.font = 'Gotham-Rounded-Light'
		text.pointsize = 28 
		text.gravity = SouthWestGravity
		hdr = Image.new(650, 53) { self.background_color = 'none' }
		text.annotate(hdr, 0, 0, 0, 0, title) { self.fill = 'white' }
		hdr.write(outputPng)
		return true
	end
rescue LoadError
	puts "WARNING: You do not have RMagick installed. This script will not be able to generate `masthead.png' for the new site."
	def makeMasthead(title, outputPng)
		return false
	end
end

