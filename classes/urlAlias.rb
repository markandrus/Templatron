#! /usr/local/bin/ruby

class UrlAlias
    attr_accessor :id, :node, :linkPath
    def initialize(id, node, linkPath)
        @id = id; @node = node; @linkPath = linkPath
    end
    # Returns SQL
    def to_s
        return 'INSERT INTO `url_alias` VALUES (' + ([
            @id.to_s,
            'node/' + @node.to_s,
            @linkPath,
            'und',
        ].map {|x| "'" + x + "'"}).join(', ') + ');';
    end
end

