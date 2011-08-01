#! /usr/local/bin/ruby

class MenuLink
    attr_accessor :id, :parentId, :linkText, :node, :hasChildren, :weight, :depth, :menuName, :path, :pathGeneric, :code, :isExternal
    def initialize(id, parentId, linkText, node, hasChildren, weight, depth)
        @menuName = 'main-menu'
        @id = id
		@parentId = parentId
		@linkText = linkText
		@node = node
		@hasChildren = hasChildren
		@weight = weight
		@depth = depth
		@path = 'node/' + @node.to_s
		@pathGeneric = 'node/%'
		@code = 'a:0:{}'
		@isExternal = false
    end
    # Returns SQL
    def to_s
		return buildSql('menu_links', [@menuName, @id, @parentId, @path, @pathGeneric, @linkText, @code, 'menu', 0, @isExternal ? 1 : 0, @hasChildren ? 1 : 0, 0, @weight, @depth, 1, @parentId == 0 ? @id : @parentId, @parentId != 0 ? @id : 0, 0, 0, 0, 0, 0, 0, 0, 0])
    end
end

