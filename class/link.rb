#! /usr/local/bin/ruby

class Link
	attr_accessor :linkText, :relativePath, :filePath, :children
	def initialize(linkText, relativePath, filePath, children)
		@linkText = linkText; @relativePath = relativePath; @filePath = filePath; @children = children
	end
	def hash
		@relativePath.intern.hash
	end
	def eql?(other)
		@relativePath === other.relativePath
	end
end

