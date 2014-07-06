# templaterenderer.rb - renders a ERB template
#
# This file is part of RubyTwitterStats 
# Copyright (C) 2014 nilsding
# Copyright (C) 2014 pixeldesu
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 'erb'

class TemplateRenderer
  
  ##
  # Initializes a new TemplateRenderer.
  # 
  # template: The template to use (i.e. not the file name)
  # parsed_tweets: The dict that gets returned by TweetParser::merge_parsed
  def initialize(template, parsed_tweets)
    @template = template
    @parsed = parsed_tweets
  end
  
  ##
  # Renders @template.
  def render
    mentions = mentions_erb
    hashtags = hashtags_erb
    clients = clients_erb
    erb = ERB.new @template
    erb.result binding
  end
  
  private
    ##
    # Returns an array with the mentions which can be easily used within ERB.
    def mentions_erb
      retdict = {
        enabled: CONFIG[:mentions][:enabled],
        top: [],
        nottop: []
      }
      
      if CONFIG[:mentions][:enabled]
        top = @parsed[:mentions].slice(0, CONFIG[:mentions][:top]) # top X mentions
        top.each do |mention|
          retdict[:top] << mention[1]
        end
        
        nottop = @parsed[:mentions].slice(CONFIG[:mentions][:top] + 1, CONFIG[:mentions][:notop]) # not in the top X
        unless nottop.nil?
          nottop.each do |mention|
            mention[1].delete(:example)
            retdict[:nottop] << mention[1]
          end
        end
      end
      
      retdict
    end
    
    ##
    # Returns an array with the hashtags which can be easily used within ERB.
    def hashtags_erb
      retdict = {
        enabled: CONFIG[:hashtags][:enabled],
        top: [],
        nottop: []
      }
      
      if CONFIG[:hashtags][:enabled]
        top = @parsed[:hashtags].slice(0, CONFIG[:hashtags][:top]) # top X hashtags
        top.each do |hashtag|
          retdict[:top] << hashtag[1]
        end
        
        nottop = @parsed[:hashtags].slice(CONFIG[:hashtags][:top] + 1, CONFIG[:hashtags][:notop]) # not in the top X
        unless nottop.nil?
          nottop.each do |hashtag|
            hashtag[1].delete(:example)
            retdict[:nottop] << hashtag[1]
          end
        end
      end
      
      retdict
    end
    
    ##
    # Returns an array with the clients which can be easily used within ERB.
    def clients_erb
      retdict = {
        enabled: CONFIG[:clients][:enabled],
        top: [],
        nottop: []
      }
      
      if CONFIG[:clients][:enabled]
        top = @parsed[:clients].slice(0, CONFIG[:clients][:top]) # top X clients
        top.each do |client|
          retdict[:top] << {
            name: client[1][:name],
            url: client[1][:url],
            count: client[1][:count],
            percentage: (client[1][:count] * 100 / @parsed[:tweet_count].to_f).round(2)
          }
        end
        
        nottop = @parsed[:clients].slice(CONFIG[:clients][:top] + 1, CONFIG[:clients][:notop]) # not in the top X
        unless nottop.nil?
          nottop.each do |client|
            client[1].delete(:example)
            retdict[:nottop] << {
              name: client[1][:name],
              url: client[1][:url],
              count: client[1][:count],
              percentage: (client[1][:count] * 100 / @parsed[:tweet_count].to_f).round(2)
            }
          end
        end
      end
      
      retdict
    end
end

# kate: indent-width 2