require 'mustache'

module Jmustache    

  # Category formating and parsing
  #
  module Categories

    def categories_most
      order_items(parse_categories, "most")
    end

    def categories_least
      order_items(parse_categories, "least")
    end

    def categories_alpha
      order_items(parse_categories, "alpa")
    end

    # Currently the categories are stored in a hash like so:
    # {"category" => [Post, Post, ..]}
    # The hash keys represent the categories but the key can be
    # a string if the category is singular.
    # An array if the category was assigned via an array and/or if there is more than one category on a post.
    #
    # Here we normalize the categories into a hash for usage:
    # {"category" => count, "category2" => count }
    #
    def parse_categories
      categories = {}
      cats = self.context[:site].categories

      self.context[:site].categories.each { |key, value|
        Array(key).each { |cat| 
          if categories[cat]
            categories[cat] += value.count
          else
            categories[cat] = value.count
          end
        }
      }
      categories.to_a
    end

  end # Categories

  module Tags
    
    def tags_most
      order_items(parse_tags, "most")
    end

    def tags_least
      order_items(parse_tags, "least")
    end

    def tags_alpha
      order_items(parse_tags, "alpa")
    end
    
    def parse_tags
      tags = {}
      self.context[:site].tags.each { |key, value|
        tags[key] = value.count
      }
      tags.to_a
    end
    
  end
  
  module Page

    def page
      self.context[:page]
    end

    def page_date
      page["date"].strftime("%d %B %Y")
    end

  end # Page


  module Posts

    def posts
      self.context[:site].posts.map{ |post| post.to_liquid }
    end

  end # Posts

  
  # The base Mustache "view".
  # This is a convenience view that provides optimized access to 
  # all the Jekyll data we are likely to use.
  #
  # You are free to use your own custom views that work 
  # on top of or in place of this view
  #
  class Base < Mustache
    include Jmustache::Categories
    include Jmustache::Posts
    include Jmustache::Page
    include Jmustache::Tags

    def output_this_for_me
      "$$$ base output @_@ $$$"
    end

    protected 
    
    # takes a hash of items and sorts them based on sortmode
    # {:name => count, .. }
    #
    def order_items(items, sort_mode="alpha")
      if sort_mode == "most"
        items.sort! {|x,y| y[1] <=> x[1] }
      elsif sort_mode == "least"
        items.sort! {|x,y| x[1] <=> y[1] }
      else  # alpha
        items.sort! {|x,y| x[0] <=> y[0] }
      end      

      items.map! {|c| {:name => c[0], :count => c[1]} }
    end
    
  end # Base
  
end

module Jekyll
  
  # A custom liquid tag block that tells the Jmustache plugin to parse
  # the block as a Mustache template.
  #
  #  Usage:
  #  In a liquid template, wrap some content in  a 'mustache' liquid block:
  #
  #  {% mustache Home %}
  #
  #    <h1>Posts</h1>
  #    <ul>
  #    <%# posts %>
  #      <li><a href="<% url%>"> <% title %></a></li>
  #    <%/ posts %>
  #    </ul>
  #
  #    <div id="blah"> ... </div>
  #
  #  {% endmustache %}
  #
  # Note: 
  #  The mustache tag takes an optional parameter ('Home' in the example above)
  #  This is the name of the mustache View class you want to provide to the template.
  #  If you don't pass a view, Jmustache with use Jmustache::Base as its base mustache view.
  #
  # Important:
  #  Always use the custom Mustache delimiters. 
  #  Normally Mustache uses {{ .. }} but since Liquid also uses these dilimeters
  #  and we still need liquid, we have to change and use custom Mustache delimiters.
  #
  class Mustacheify < Liquid::Block
    Syntax = /(\w+)/

    DEFAULTS = {
      "views_path" => "_mustache",
      "delimiters" => ["<%", "%>"]
    }
    
    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @view_class = $1
      end
      super
    end
      
    def render(context)
      config = DEFAULTS.merge(context.registers[:site].config["jekstache"] || {})
      reset_delimiters = "{{=#{config["delimiters"][0]} #{config["delimiters"][1]}=}}"
      
      puts "<Jmustache #{@view_class}>" 
      puts " - title: " + context["page.title"]
      puts context.class
      puts context["page"]
      
      Mustache.view_namespace = "Jmustache"
      Mustache.view_path = File.join(context.registers[:site].config['source'], config["views_path"])
      
      view = @view_class ? Mustache.view_class(@view_class) : Jmustache::Base
      view.template =  reset_delimiters + super
      
      view.render({
        :site => context.registers[:site], 
        :page => context["page"],
        :content => context["content"]
      })
    end

  end # Mustacheify

end # Jekyll

Liquid::Template.register_tag('mustache', Jekyll::Mustacheify)
