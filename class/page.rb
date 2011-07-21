#! /usr/local/bin/ruby

class Page
    # A WebExpress Page maps to a number of different Drupal tables:
    #     - url_alias
    #     - menu_links
    #     - node
    #     - field_data_body
	#     - node_access
    attr_accessor :id, :title, :node, :menuLink, :urlAlias, :fieldDataBody, :nodeAccess

	# There are already entries in the Drupal database, so we need to set the correct id offset
	def getLastNodeId()
		return 50
	end
	def getLastMenuLinkId()
		return 500
	end
	def getLastUrlAliasId()
		return 50
	end

    # Construct the necessary database objects
    def initialize(title, content, path)
        @title = title
        @id = getLastNodeId() + 1
        @node = Node.new(@id, 'page', @title)
        menuLinkId = getLastMenuLinkId() + 1
        @menuLink = MenuLink.new(menuLinkId, 0, @title, @id, 0, 0, 1)
        @fieldDataBody = FieldDataBody.new(@id, 'page', content)
		urlAliasId = getLastUrlAliasId() + 1
		@urlAlias = UrlAlias.new(urlAliasId(), @id, path)
		@nodeAccess = NodeAccess.new(@id)
    end

    # Returns SQL
    def to_s
        return node.to_s + "\n"
		     + menuLink.to_s + "\n"
			 + fieldDataBody.to_s + "\n"
			 + urlAlias.to_s + "\n"
			 + nodeAccess.to_s + "\n"
    end
end

