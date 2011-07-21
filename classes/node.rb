#! /usr/local/bin/ruby

class Node
    attr_accessor :id, :type, :title
    def initialize(id, type, title)
        @id = id; @type = type; @title = title
    end
    # Returns SQL
    def to_s
        return 'INSERT INTO `node` VALUES (' + ([
            @id.to_s,
            @id.to_s,
            @type,
            'und',
            @title,
            '1', '1',
            '0', # timestamp?
            '0', # timestamp?
            '0', '0', '0', '0', '0'
        ].map {|x| "'" + x + "'"}).join(', ') + ');';
    end
end

