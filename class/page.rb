#! /usr/local/bin/ruby

# There are already entries in the Drupal database, so we need to set the correct id offset
# NOTE: The last* values I chose are arbitrary, but should be large enough not to collide with
#		anything in the Drupal database
$lastNodeId = 100
$lastMenuLinkId = 700
$lastUrlAliasId = 100
def getLastNodeId()
	$lastNodeId += 1
	return $lastNodeId - 1
end
def getLastMenuLinkId()
	$lastMenuLinkId += 1
	return $lastMenuLinkId - 1
end
def getLastUrlAliasId()
	$lastUrlAliasId += 1
	return $lastUrlAliasId - 1
end

class Page
    attr_accessor :id, :children, :title, :node, :menuLink, :urlAlias, :fieldDataBody, :fieldDataRightImage, :nodeAccess, :newUrlAlias, :initPath, :isPseudo
    def initialize(title, content, path, children, rightImage)
		@isPseudo = false
		@initPath = path
        @title = title
        @id = getLastNodeId()
        @node = Node.new(@id, 'page', @title)
        menuLinkId = getLastMenuLinkId()
		@children = children
        @menuLink = MenuLink.new(menuLinkId, 0, @title, @id, !@children.empty?, 0, 1)
		if !@children.nil? && !@children.empty? then
			@children.inject(0) do |i, child|
				child.menuLink.parentId = menuLinkId
				child.menuLink.depth += 1
				child.menuLink.weight = -50 + i
				i += 1
			end
		end
        @fieldDataBody = FieldDataBody.new(@id, 'page', content)
        if !rightImage.nil?
			@fieldDataRightImage = FieldDataRightImage.new(@id, 'page', rightImage['filePath'], rightImage['alt'], rightImage['title'])
		end
		urlAliasId = getLastUrlAliasId()
		@urlAlias = UrlAlias.new(urlAliasId, @id, path)
		@nodeAccess = NodeAccess.new(@id)
    end
	def pseudo_to_s
		@menuLink.path = @initPath
		@menuLink.pathGeneric = '0'
		@menuLink.code = 'a:1:{s:10:"attributes";a:1:{s:5:"title";s:0:"";}}'
		@menuLink.isExternal = true
		return @menuLink.to_s + "\n"
	end
    def to_s
		if @isPseudo then return pseudo_to_s end
		childrenSql = ''
		@children.each do |child|
			childrenSql += child.to_s + "\n"
		end
        return [@node.to_s,
				@menuLink.to_s,
				@fieldDataBody.to_s,
				@fieldDataRightImage.to_s,
				@urlAlias.to_s,
				@newUrlAlias.to_s,
				@nodeAccess.to_s,
				childrenSql].join("\n")
    end
end

