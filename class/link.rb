#! /usr/local/bin/ruby

class Link
	attr_accessor :linkText, :relativePath, :filePath, :children
	def initialize(linkText, relativePath, filePath, children)
		@linkText = linkText; @relativePath = relativePath; @filePath = filePath; @children = children
	end
	def hash
		@relativePath.sub(/\/$/, '/index.html').intern.hash
	end
	def eql?(other)
		@relativePath.sub(/\/$/, '/index.html') == other.relativePath.sub(/\/$/, '/index.html')
	end
end

