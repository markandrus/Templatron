#! /usr/local/bin/ruby

require 'highline/import'

$aliasPool = []

# Build "New" UrlAlias with input from user
def newUrlAlias(linkText, linkPath, hasParent)
	str = ''
	if hasParent then str = "\t" end
	puts str + "Title:    " + linkText
	puts str + "URL:      " + linkPath
	if linkPath != '/' && (linkPath.length < 6 || (linkPath[0, 6] != 'http:/' && linkPath[0, 6] != 'https:')) then
		newLink = String.new(linkPath).split('/')
		if !newLink.nil? && !newLink.last.nil? then newLink = newLink.last.gsub(/\.shtml/, '') else newLink = '' end
		url = nil
		while !$aliasPool.index(url).nil? || url.nil?
			if !url.nil?
				puts "\n" + str + "ERROR: That URL alias is already in use. Please provide another"
			end
			url = ask(str + '> ') { |q| q.default = newLink != '' ? 'page/' + newLink : '' }
		end
		if url != '!!' then $aliasPool.push(url) end
	else
		url = linkPath
	end
	puts "\n"
	UrlAlias.new(getLastUrlAliasId(), 0, url.strip)
end

# Transform the pool of links into our SQL-generating `Page' objects
def transformLinkPool(linkPool, hasParent)
	(linkPool.map do |link|
		# Prompt for "New" UrlAlias
		newUrlAlias = newUrlAlias(link.linkText, link.relativePath, hasParent)
		# Process children first
		children = transformLinkPool(link.children, true)
		if !children.nil? && !children.empty? then puts "" end
		# Process parent
		content = ''
		if File.file?(link.filePath)
			content = scrape(link.filePath)
		end
		page = Page.new(link.linkText, content, link.relativePath, children)
		newUrlAlias.node = page.id
		page.newUrlAlias = newUrlAlias
		if newUrlAlias.linkPath == '!!' then
			nil
		else
			page
		end
	end).reject { |n| n.nil? }
end

def weightParentPages(pages)
	i = 0
	pages.each do |page|
		page.menuLink.weight = -50 + i
		i += 1
	end
end

def correctPseudoPages(pages)
	pages.each do |page|
		if page.initPath[0, 6] == 'http:/' || page.initPath[0, 6] == 'https:'
			page.isPseudo = true
		end
	end
end

def to_sql(linkPool)
	correctPseudoPages(weightParentPages(transformLinkPool(linkPool, false))).inject(
		File.read('etc/base.sql')
	) { |sql, page| sql += page.to_s }
end

