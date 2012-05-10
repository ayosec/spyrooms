#!/usr/bin/env ruby 

require "net/http"
require "pathname"
require "yaml"
require "json"
require "time"
require_relative "colors"

ConfigFire = Pathname.new("~/.campfire").expand_path

TerminalColumns = (ENV["COLUMNS"] || `tput cols`).to_i

module Spy
  extend self
  extend Colors

  class RequestFailed < Exception; end

  def get(path)
    http = Net::HTTP.new("#{@config["domain"]}.campfirenow.com", 443)
    http.use_ssl = true

    request = Net::HTTP::Get.new("/#{path}.json")
    request.basic_auth @config["token"], "-"
    response = http.request(request)

    if response.code.to_i != 200
      raise RequestFailed.new("Failed to get #{path}: #{response.msg}\n#{response.body}")
    end

    JSON.parse(response.body)
  end

  def load_config!
    unless ConfigFire.exist?
      STDERR.puts "#{ConfigFire} was not found. Create it with two keys:"
      STDERR.puts "token: AUTH_TOKEN"
      STDERR.puts "domain: DOMAIN"
      STDERR.puts "The AUTH_TOKEN value can be retrieved from https://DOMAIN.campfirenow.com/member/edit"
      exit 1
    end

    @config = YAML.load(ConfigFire.read)
  end

  def log(msg)
    STDERR.puts "[#{Time.now.strftime "%F %X"}] #{msg}"
  end

  def run!
    load_config!

    date = ""
    ARGV.each do |arg|
      case arg
      when %r{\Adate=(\d+/\d+/\d+)\Z}
        date = "/#$1"
      else
        STDERR.puts red("Ignore invalid argument #{arg}")
      end
    end

    log "Getting rooms..."
    get("rooms")["rooms"].each do |room|
      name, id = room.values_at("name", "id")

      log "Loading '#{name}' transcript..."
      transcript = get("room/#{id}/transcript#{date}")

      names = transcript["messages"].
        map {|message| message["user_id"]}.
        uniq.
        reject {|user_id| user_id.to_s.empty? }.
        map do |user_id|
          log "Loading data from user #{user_id}"
          get "users/#{user_id}"
        end.
        inject({}) do |hash, item|
          hash[item["user"]["id"]] = item["user"]["name"]
          hash
        end

      name_width = names.values.map {|name| name.length }.max

      available_colors = [ method(:green), method(:yellow), method(:cyan) ].cycle
      name_colors = {}
      names.each_key do |user_id|
        name_colors[user_id] = available_colors.next
      end

      # Print the transcript
      transcript["messages"].each do |message|

        # Ignore TimestampMessage messages
        next if message["type"] == "TimestampMessage"


        created_at = Time.parse(message["created_at"]).strftime("%F %X")

        name = "%#{name_width}s" % names[message["user_id"]]
        color = name_colors[message["user_id"]]

        prefix = " " * (created_at.size + name.size + 2)


        print magenta(created_at)
        print " "
        print color[name]
        print " "

        # wrap body
        lines = []
        max_width = TerminalColumns - prefix.size - 1
        message["body"].to_s.split("\n").each do |line|
          while line.size > max_width
            lines << line[0, max_width]
            line[0, max_width] = ""
          end
          lines << line
        end

        if message["type"] != "TextMessage"
          lines.unshift red("-- #{message["type"]} -- ")
        end

        puts color[lines.shift]
        lines.each do |line|
          puts prefix + color[line]
        end

      end
    end

  rescue RequestFailed => error
    STDERR.puts error.message
    exit 2
  end

end

Spy.run!
