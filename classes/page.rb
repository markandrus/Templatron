#! /usr/local/bin/ruby

class Page
    # A WebExpress Page maps to a number of different Drupal tables:
    #     - url_alias
    #     - menu_links
    #     - node
    #     - field_data_body
    attr_accessor :id, :title, :node, :menuLink, :urlAlias, :fieldDataBody
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
    end
    # Returns SQL
    def to_s
        return node.to_s + "\n" + menuLink.to_s + "\n" + fieldDataBody.to_s + "\n" + urlAlias.to_s
    end
end

