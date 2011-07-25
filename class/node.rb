#! /usr/local/bin/ruby

class Node
    attr_accessor :id, :type, :title
    def initialize(id, type, title)
        @id = id; @type = type; @title = title
    end
    # Returns SQL
    def to_s
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

