#! /usr/bin/env ruby

require 'nokogiri'
require 'stringex'
require 'uri'
require 'time'
require 'yaml'

class Bookmark
  attr_accessor :data, :categories

  def initialize(anchor_node)
    @data = {
      date:  Time.at(anchor_node["ADD_DATE"].to_i),
      link:  anchor_node["HREF"],
      title: anchor_node.content
    }
    extract_category(anchor_node)
  end

  def filename
    date = data[:date].strftime('%Y-%m-%d')
    "#{date}-#{slug}.markdown"
  end

  def slug
    URI.escape(data[:title].to_url).gsub(/\%[a-zA-Z0-9]+/, '').to_url
  end

  def front_matter
    YAML.dump({
      "layout"     => "bookmark",
      "title"      => data[:title],
      "date"       => data[:date].xmlschema,
      "link"       => data[:link],
      "categories" => categories
    })
  end

  def content
    "#{front_matter}\n---\n"
  end

  def write(posts_dir)
    path = File.expand_path(filename, posts_dir)
    File.open(path, "wb") do |f|
      f.write(content)
    end
  end

  def inspect
    "<Bookmark @data=#{@data.inspect}>"
  end

  def to_s
    inspect
  end

  private

  def extract_category(node)
    dt = next_highest_dt(node.parent.parent)
    @categories = dt.xpath(".//H3").children.map(&:to_s).first
  end

  def next_highest_dt(node)
    return node if node.name.to_s.downcase == "dt"
    next_highest_dt(node.parent)
  end
end

f = File.open(ARGV.first)
doc = Nokogiri::XML(f)
f.close

a_tags = doc.root.xpath("//A")
bookmarks = a_tags.map { |b| Bookmark.new(b) }

# Write to the 
bookmarks.each do |b|
  b.write(File.expand_path("_posts", Dir.pwd))
end
