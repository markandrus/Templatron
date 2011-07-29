#! /usr/local/bin/ruby

class MenuLink
    attr_accessor :id, :parentId, :linkText, :node, :hasChildren, :weight, :depth, :menuName, :path, :pathGeneric, :code, :isExternal
    def initialize(id, parentId, linkText, node, hasChildren, weight, depth)
        @menuName = 'main-menu'
        @id = id; @parentId = parentId; @linkText = linkText; @node = node; @hasChildren = hasChildren; @weight = weight; @depth = depth;
		@path = 'node/' + @node.to_s
		@pathGeneric = 'node/%'
		@code = 'a:0:{}'
		@isExternal = false
    end
    # Returns SQL
    def to_s
        return 'INSERT INTO `menu_links` VALUES (' + ([
            @menuName.to_s,
            @id.to_s,
            @parentId.to_s,
            @path, # 'node/' + @node.to_s,
            @pathGeneric, # 'node/%',
            @linkText,
            @code, # 'a:0:{}',
            'menu',
            '0',
			@isExternal ? '1' : '0',
            @hasChildren ? '1' : '0',
            '0',
            @weight.to_s,
            @depth.to_s,
            '1',
            @parentId == 0 ? @id.to_s : @parentId.to_s,
            @parentId != 0 ? @id.to_s : '0',
            '0', '0', '0', '0', '0', '0', '0', '0'
        ].map {|x| "'" + x + "'"}).join(', ') + ');';
    end
end

