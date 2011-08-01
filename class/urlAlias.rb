#! /usr/local/bin/ruby

class UrlAlias
    attr_accessor :id, :node, :linkPath, :nodePath
    def initialize(id, node, linkPath)
        @id = id
		@node = node
		@linkPath = linkPath.sub(/^\//, '').sub(/\/$/, '')
		@nodePath = 'node/' + @node.to_s
    end
    # Returns SQL
    def to_s
		return buildSql('url_alias', [@id, @nodePath, @linkPath, 'und'])
    end
end

