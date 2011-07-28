#! /usr/local/bin/ruby

# There are already entries in the Drupal database, so we need to set the correct id offset
# NOTE: The last* values I chose are arbitrary, but should be large enough not to collide with
#		anything in the Drupal database
$lastNodeId = 100
$lastMenuLinkId = 600
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
    # A WebExpress Page maps to a number of different Drupal tables:
    #     - url_alias
    #     - menu_links
    #     - node
    #     - field_data_body
	#     - node_access
    attr_accessor :id, :children, :title, :node, :menuLink, :urlAlias, :fieldDataBody, :nodeAccess, :newUrlAlias

    # Construct the necessary database objects
    def initialize(title, content, path, children)
        @title = title
        @id = getLastNodeId()
        @node = Node.new(@id, 'page', @title)
        menuLinkId = getLastMenuLinkId()
		@children = children
        @menuLink = MenuLink.new(menuLinkId, 0, @title, @id, !@children.empty?, 0, 1)
		i = 0;
		if !@children.nil? && !@children.empty? then
			@children.each do |child|
				child.menuLink.parentId = menuLinkId
				child.menuLink.depth += 1
				child.menuLink.weight = -50 + i
				i += 1
			end
		end
        @fieldDataBody = FieldDataBody.new(@id, 'page', content)
		urlAliasId = getLastUrlAliasId()
		@urlAlias = UrlAlias.new(urlAliasId, @id, path)
		@nodeAccess = NodeAccess.new(@id)
    end

    # Returns SQL
    def to_s
		childrenSql = ''
		@children.each do |child|
			childrenSql += child.to_s + "\n"
		end
        return node.to_s + "\n" + menuLink.to_s + "\n" + fieldDataBody.to_s + "\n" + newUrlAlias.to_s + "\n" + urlAlias.to_s + "\n" + nodeAccess.to_s + "\n" + childrenSql + "\n"
    end
end

