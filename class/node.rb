#! /usr/local/bin/ruby

class Node
    attr_accessor :id, :type, :title
    def initialize(id, type, title)
        @id = id; @type = type; @title = title
    end
    # Returns SQL
    def to_s
=begin
		return ('INSERT INTO `node` VALUES (' + ([
			@id.to_s,
			@id.to_s,
			@type,
			'und',
			@title,
			'26', '1',
			'1303944939', # timestamp?
			'1303944939', # timestamp?
			'0', '0', '0', '0', '0'
		].map {|x| "'" + x + "'"}).join(', ') + ');' + 'INSERT INTO `node` VALUES (' + ([
			@id.to_s,
			@id.to_s,
			'26',
			@title,
			'',
			'1303944939', # timestamp?
			'1',
			'0', '0', '0'
		].map {|x| "'" + x + "'"}).join(', ') + ');');
=end
		return ('INSERT INTO `node` (nid, vid, title, type) VALUES (' + ([
			@id.to_s,
			@id.to_s,
			@title,
			@type
		].map {|x| "'" + x + "'"}).join(', ') + ");\n" + 'INSERT INTO `node_revision` (nid, vid, title, log) VALUES (' + ([
			@id.to_s,
			@id.to_s,
			@title,
			''
		].map {|x| "'" + x + "'"}).join(', ') + ');');
    end
end

