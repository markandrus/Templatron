#! /usr/local/bin/ruby

class NodeAccess
	attr_accessor :id
	def initialize(id)
		@id = id
	end
	# Returns SQL
	def to_s
		return 'INSERT INTO `node_access` VALUES (' + ([
			@id.to_s,
			'0', 'all', '1', '0', '0'
		].map {|x| "'" + x + "'"}).join(', ') + ');';
	end
end

