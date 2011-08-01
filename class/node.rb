#! /usr/local/bin/ruby

class Node
    attr_accessor :id, :type, :title
    def initialize(id, type, title)
        @id = id; @type = type; @title = title
    end
    # Returns SQL
    def to_s
		return buildSql('node', {'nid' => @id, 'vid' => @id, 'title' => @title, 'type' => @type}) + "\n" +
			   buildSql('node_revision', {'nid' => @id, 'vid' => @id, 'title' => @title, 'log' => ''})
    end
end

