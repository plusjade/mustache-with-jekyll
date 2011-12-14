require 'mustache'

module Jekstache    

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

  
  class Base < Mustache
    include Jekstache::Categories
    include Jekstache::Posts
    include Jekstache::Page
    include Jekstache::Tags

    def output_this_for_me
      "$$$ base output yazole $$$"
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
  
  # This is a custom liquid tag block that tells Jekstache to parse
  # the contents through Mustache
  #
  class Templateize < Liquid::Block
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
      
      puts "<Jekstache #{@view_class}>" 
      puts " - title: " + context["page.title"]
      puts context.class
      puts context["page"]
      
      Mustache.view_namespace = "Jekstache"
      Mustache.view_path = File.join(context.registers[:site].config['source'], config["views_path"])
      
      view = @view_class ? Mustache.view_class(@view_class) : Jekstache::Base
      view.template =  reset_delimiters + super
      
      view.render({
        :site => context.registers[:site], 
        :page => context["page"],
        :content => context["content"]
      })
    end

  end # Templateize

end # Jekyll

Liquid::Template.register_tag('jekstache', Jekyll::Templateize)
