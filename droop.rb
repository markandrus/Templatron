#! /usr/local/bin/ruby

include 'classes/page.rb'
include 'classes/node.rb'
include 'classes/menuLink.rb'
include 'classes/fieldDataBody.rb'
include 'classes/urlAlias.rb'

# Method for downloading website
# wget --recursive --no-clobber --html-extension --domains $website $website

# There are already entries in the Drupal database, so we need to set the correct id offset
def getLastNodeId() { return 50 }
def getLastMenuLinkId() { return 500 }





# "INSERT INTO `node_access` VALUES ('" + @id.to_s + "', '0', 'all', '1', '0', '0');"
# url_alias

# Algorithm
#    go to index
#    for each `li` in `ul.menu`
#        title = `li a`.innerHTML
#        url = `li a`.url
#        page = Node.new(id, 'page', title)
#        goto url
#            if `ul.sectionhead + ul`
#                set hasChildren = true
#                for each `ul.sectionhead + ul li`
#                    create node
#                    create link    
#

mL = MenuLink.new(474, 0, 'Sample Content', 22, true, -48, 1);
sL = MenuLink.new(475, 474, 'Basic Page', 23, false, -50, 2);

puts mL.to_s
puts sL.to_s
