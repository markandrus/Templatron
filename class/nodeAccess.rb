#! /usr/local/bin/ruby

class NodeAccess
	attr_accessor :id
	def initialize(id)
		@id = id
	end
	# Returns SQL
	def to_s
		return buildSql('node_access', [@id, 0, 'all', 1, 0, 0])
	end
end

