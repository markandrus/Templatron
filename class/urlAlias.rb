#! /usr/local/bin/ruby

class UrlAlias
    attr_accessor :id, :node, :linkPath, :nodePath
    def initialize(id, node, linkPath)
        @id = id; @node = node; @linkPath = linkPath.sub(/^\//, '').sub(/\/$/, '')
		@nodePath = 'node/' + @node.to_s
    end
    # Returns SQL
    def to_s
        return 'INSERT INTO `url_alias` VALUES (' + ([
            @id.to_s,
            @nodePath,		# 'node/' + @node.to_s,
            @linkPath,
            'und',
        ].map {|x| "'" + x + "'"}).join(', ') + ');';
    end
end

