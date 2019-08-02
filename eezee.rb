
require 'zircon'
require 'colorize'
require 'byebug'
require 'json'
require 'date'
require 'timeout'
require 'gyazo'
require 'open4'
require 'brainz'
require 'bundler'
require 'sinatra'
require 'nokogiri'
require 'eezee_regexes'

require 'bigdecimal'

require 'json2table'

require 'rake'


EEZEE_PREFIX = "eezee "
ANSWERS = Hash.new { |hash, key| hash[key] = Hash.new }
CURRENT_DISCORD_MESSAGE = Hash.new

class ::Integer
  def direction
    self/self.abs
  end
end


class Number
  def initialize(string_representation_from_discord, source="discord")
    @source = source
    @string_representation_from_discord = string_representation_from_discord
  end

  def to_s
    """
      NUMBER
      STRING REPRESENTATION FROM #{@source.upcase}
      #{@string_representation_from_discord}

      RUBY #{RUBY_ENGINE} #{RUBY_VERSION} FLOAT
      #{@string_representation_from_discord.to_f}

      RUBY #{RUBY_ENGINE} #{RUBY_VERSION} BIG DECIMAL
      #{BigDecimal(@string_representation_from_discord)}

      RUBY #{RUBY_ENGINE} #{RUBY_VERSION} INTEGER
      #{@string_representation_from_discord.to_i}

      PYTHON #{"runtime X"} #{"version X"} INTEGER
      tbi by @gurrenm3 or @gurrenm4
      PYTHON #{"runtime X"} #{"version X"} FLOAT
      tbi by @gurrenm3 or @gurrenm4
    """
  end
end

class Function
  attr_accessor :input_variables, :output_variables, :string_from_discord

  def initialize
    self.input_variables = []
    self.output_variables = []
  end

  def evaluate
    case string_from_discord
    when "NeuralNetwork()"
      return NeuralNetwork().verbose_introspect(very_verbose=true)
    end
  end

  def compute(*args)
    if @compute_type
      case @compute_type
      when :convert_to_integer_then_sum
        return args.map(&:to_i).reduce(:+)
      when :sum
        return args.public_send(@compute_type)
      end 
    end

    return args
  end

  def compute_is(compute_type)
    @compute_type = compute_type
  end

  def to_s
    "Function"
  end

  def explain
    """
      This command creates a new function ƒ(x) = y

      ƒ

      Mac OS X: press option and f simultaniously
      Windows:
        On a computer running Microsoft Windows and using the Windows-1252 character encoding, the minuscule can be input using alt+159 or alt+0131.
        Look up at wikipedia and search for ƒ
      Linux:
        Copy & Paste ƒ (maybe a clipboard manager?) ofc you rule the world
    """
  end
end

class Method
  def source(limit=10)
    file, line = source_location
    if file && line
      IO.readlines(file)[line-1,limit]
    else
      nil
    end
  end
end

class NeuralNetwork
  # TODO: DelegateAllMissingMethodsTo @brainz

  def method_missing(method, *args, &block)
    @brainz.public_send(method, *args, &block)
  end

  def initialize
    @brainz = Brainz::Brainz.new
  end

  def verbose_introspect(very_verbose = false)
    var = <<~HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
      ```
      Brainz Rubygem (wrapper)
      Ruby object id: #{@brainz.object_id}
      ```

      ```
      Instance variables
      ```

      ```
      #{@brainz.instance_variables}
      ```
    HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD

    if very_verbose
      var = <<~HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
        ```
        Public methods (random sample of 3)
        ```

        ```
        #{(@brainz.public_methods - Object.new.public_methods).sample(3).join("\n")}
        ```
      HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
    end


    unless @brainz.network.nil?
      # var += <<~HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
      #   ```
      #   #{@brainz.network.input.to_s}
      #   #{@brainz.network.hidden.to_s}
      #   #{@brainz.network.output.to_s}
      #   ```
      # HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
    end

    return var
  end

  def to_s
    verbose_introspect
  end

end

def NeuralNetwork()
  NeuralNetwork.new
end

class GitterDumbDevBot
  def initialize
    @currently_selected_project = "lemonandroid/gam"
    @variables_for_chat_users = Hash.new
    @players = Hash.new do |dictionary, identifier|
      dictionary[identifier] = Hash.new
    end
    @melting_point_receivables = ["puts 'hello word'"]
    @probes = []
    @melted_liquids = []
    @sent_messages = []


    # SEC-IMPORTANT

    @took_off = true
  end

  def unsafe!
    @took_off = false
  end

  def load()
    return if ENV["RACK_ENV"] == 'production'

    warn and return [:info, :no_marshaled_data_found].join(' > ') unless File.exists?("/var/gam-discord-bot.ruby-marshal")
    data = File.read("/var/gam-discord-bot.ruby-marshal")
    @melting_point_receivables = Marshal.load(data)
  end

  def dump()
    return if ENV["RACK_ENV"] == 'production'
    require 'facets'

    data = Marshal.dump(@melting_point_receivables)
    File.rewrite("/var/gam-discord-bot.ruby-marshal") do |_previous_file_content_string|
      data
    end
  end

  def twitch_username_from_url(url)
    url.match(/\/(\w*)\Z/)[1]
  end

  def record_live_stream_video_and_upload_get_url(url:, duration_seonds:)
    twitch_username = twitch_username_from_url(url)
    twitch_broadcaster_id = JSON.parse(`curl -H 'Authorization: Bearer #{ENV['EZE_TWITCH_TOKEN']}' \
    -X GET 'https://api.twitch.tv/helix/users?login=#{twitch_username}'`)["data"][0]["id"]
    created_clip_json_response = `curl -H 'Authorization: Bearer #{ENV['EZE_TWITCH_TOKEN']}' \
    -X POST 'https://api.twitch.tv/helix/clips?broadcaster_id=#{twitch_broadcaster_id}'`

    created_clip_json_response = JSON.parse(created_clip_json_response)

    id = created_clip_json_response["data"][0]["id"]
    return "https://clips.twitch.tv/#{id}"

    # return `curl -H 'Authorization: Bearer #{ENV['EZE_TWITCH_TOKEN']}' \
    # -X GET '#{url}'`
  end

  def get_string_of_x_bytes_by_curling_url(url:, byte_count:)
    str = `curl #{url}`
    sub_zero_string = str.each_char.reduce("") do |acc, chr| # haha, sub sero string
      unless acc.bytesize === byte_count
        acc += chr
      else
        break acc
      end
    end

    "`#{sub_zero_string.unpack('c*')}`"
  end

  require 'net/http'
  def on_message(message, message_id)
    if message === "get last message id"
      return CURRENT_DISCORD_MESSAGE[:mesage_id]
    end
    
    CURRENT_DISCORD_MESSAGE[:mesage_id] = message_id

    require 'wit'
    client = Wit.new(access_token: ENV["WIT_AI_TOKEN"])
    response = client.message(message)

    if !response.nil? && !response["entities"].empty? && response["entities"]["intent"][0]["value"] === "question-about-eezee-probe"
      answer_api_response = `curl -XGET 'https://api.wit.ai/samples?entity_ids=intent&entity_values=explain-eezee-probe&limit=10' \
      -H "Authorization: Bearer $WIT_AI_TOKEN"`

      if !answer_api_response.nil? && JSON.parse(answer_api_response).any?
        return JSON.parse(answer_api_response).sample["text"]
      end
    end

    if !response.nil? && !response["entities"].empty? && response["entities"]["intent"][0]["value"] === "explain-eezee-probe"
      answer_api_response = `curl -XGET 'https://api.wit.ai/samples?entity_ids=intent&entity_values=explain-eezee-probe&limit=10' \
      -H "Authorization: Bearer $WIT_AI_TOKEN"`

      if !answer_api_response.nil? && JSON.parse(answer_api_response).any?
        return JSON.parse(answer_api_response).sample["text"]
      end
    end

    message_for_discord = response.inspect.gsub(/<@(\d+)>/, '<@ \1>')

    url = "https://botcompany.de/1024081/raw?_pass=#{ENV['BOTCOMPANY']}&server=next-gen+bots&channel=#{602625635633856513}&post=#{CGI.escape(message_for_discord)}"
   
    uri = URI(url)
    Net::HTTP.get(uri)

    # if /run asm #{url_regex}/ === message
    #   asm = `curl #{$1}`
    #   t = Tempfile.new(['asm', '.asm'])
    #   t.write(asm)

    #   `nasm -f macho64 #{t.path}`
    #   `ld -macosx_version_min 10.7.0 -lSystem -o hello #{t.path.ext('o')}`
    #   byebug
    #   return `./hello`
    # end

    if /\Aget cpu instructions set\Z/ === message
      return `sysctl -a | grep cpu.feat`
    end

    if /\Ais eeZee ejected\?\Z/ === message
      if @ejected == true
        return "Yes, @eeZee is ejected"
      else
        return "No, @eeZee should still respond"
      end
    end

    if /explain context/ === message
      return """
      it: the overall subject
      this: the most nearest subject
      that: the subject a bit farer then this (dimension for farer could be time, location, logic, etc)
      """
    end

    return "" if @ejected


    if (commands = message.split("|")).count > 1

      result = nil
      commands.each do |command|
        result = self.on_message(command.rstrip)

        @last_pipe = result
      end

      return result.inspect[0...500]
    end

    return "" if message.empty?

    def wrap_code_for_discord(string_of_code)
      <<~DISCORD_MESSAGE
        ```
          #{string_of_code}
        ```
      DISCORD_MESSAGE
    end
    if /quick maths/ =~ message
      require 'screencap'

      f = Screencap::Fetcher.new("https://projecteuler.net/problem=#{(0...630).to_a.sample}")


      # return wrap_code_for_discord(f.phantomjs_code[0..500])

      screenshot = f.fetch(div: '.problem_content')

      tempfile = Tempfile.new

      `convert -flatten #{screenshot.path} #{tempfile.path}`

      return upload_gyazo(tempfile.path)
    end

    if /server byebug/ =~ message
      byebug
    end

    if /show abstract syntax tree of regexes/  === message
      return ::RegexRulesCollector.new.to_s
    end

    if /show all regex root level nodes count/ === message
      return ::RegexRulesCollector.new.root_level_if_nodes.count.to_s
    end

    if /search "(\w*)"/i  === message
      fail "INSECURE" if not $1 =~ /\A\w*\Z/i
      return `echo '#{@last_pipe}' | grep '#{$1}'`[0...100]
    end

    if /agi\.blue/ === message && !@raw_last_pipe.nil?
      @last_raw_pipe.each do |row|
        `curl http://agi.blue/bot/post?q=#{CGI.escape(row)}&key=source&value=eezee`
      end

      return "#{@last_raw_pipe.count} entries created on https://agi.blue"
    end

    if /clone eezee 10 times/ === message
      ``
      return "climbing the sourcerer.io ruby leaderboard"
    end

    if /show all regex root level nodes/ === message 
      def wrap(text)
        """
        ```
        #{text}
        ```
        """
      end

      def raw_pipe(result)
        @last_raw_pipe = result
      end

      result1 = nil
      if @last_raw_pipe
        result1 = RegexRulesCollector.new(@last_raw_pipe).flat_root_level_if_nodes
      else
        result1 = RegexRulesCollector.new.flat_root_level_if_nodes
      end

      result2 = raw_pipe(result1)

      return wrap(result)
    end

    if /\A((?:10)|(?:[1-9]))\Z/ === message
      array = [
        "1: get random eezee bot with wit.ai integration",
        "2: 関数",
        "3: chat-variable bot0 `NeuralNetwork()`",
        "4: get-chat-variable bot0",
        "5: console 2 + 2 (only works in insecure mode)",
        "6: docker ruby `2 + 2`",
        "7: docker python `2 + 2`",
        "8: docker go `2 + 2` (dysfunctional)",
        "9: docker elixir `IO.puts(2 + 2)`",
        "10: docker julia `2 + 2`"
      ]
      
      return array[$1.to_i - 1]
    end

    if /take off/ =~ message
      @took_off = true
    end

    if /\A(\d+(?:\.\d+)?)\Z/ === message
      return Number.new(message).to_s
    end

    if message === "get random eezee bot with wit.ai integration"
      return "pls integrate a github gist listing github urls of eezees with working bot integration"
    end

    def new_function_command
      @raw_last_pipe = Function.new
      return @raw_last_pipe.explain
    end

    if message === "ƒ"
      case @raw_last_pipe
      when Function
        return @raw_last_pipe.evaluate().to_s[0...500]
      else
        return new_function_command
      end
    end

    if message =~ /ƒ\s*=\s*(.*)/i
      case @raw_last_pipe
      when Function
        @raw_last_pipe.string_from_discord = $1
      end
    end

    if message === "visualize ƒ"
      response = execute_bash_in_currently_selected_project("ruby /Users/lemonandroid/Documents/GitHub/polynomials/examples/plot_only_mutual_data.rb \"#{@raw_last_pipe.string_from_discord}\"")
      return response
    end

    if /\Aƒ\(([^\)]*)\)\Z/ === message
      case @raw_last_pipe
      when Functionƒ
        return @raw_last_pipe.compute(*$1.split(',')).to_s
      end
    end

    if /\A関数\(([^\)]*)\)\Z/ === message
      case @raw_last_pipe
      when Function
        return @raw_last_pipe.compute(*$1.split(',')).to_s
      end
    end

    if /\Aƒ compute is sumZ/ === message
      case @raw_last_pipe
      when Function
        @raw_last_pipe.compute_is(:sum)
      end
    end

    if /\A関数 compute is sum\Z/ === message
      case @raw_last_pipe
      when Function
        @raw_last_pipe.compute_is(:sum)
      end
    end


    if /\Aƒ compute is convert to integer and sum/ === message
      case @raw_last_pipe
      when Function
        @raw_last_pipe.compute_is(:convert_to_integer_then_sum)
      end
    end

    if /\A関数 compute is convert to integer and sum\Z/ === message
      case @raw_last_pipe
      when Function
        @raw_last_pipe.compute_is(:convert_to_integer_then_sum)
      end
    end

    if message === "関数"
      return new_function_command
    end

    if message === "get wit.ai token"
      return "client HGLIOLWCVEFT2ZIIBLO3KRCA2QYQPGPZ" + " " + "server GZLSZCIOQNZEPPONMS255EYOCR5APVN3"
    end

    if message === "get wit.ai token comfortably"
      return """
        echo '
          export WIT_AI_TOKEN=\"HGLIOLWCVEFT2ZIIBLO3KRCA2QYQPGPZ\"
          export WIT_AI_TOKEN_SERVER=\"GZLSZCIOQNZEPPONMS255EYOCR5APVN3\"
        ' > ~/.bash_profile
      """
    end

    message.gsub!(EEZEE_PREFIX, '')

    removed_colors = [:black, :white, :light_black, :light_white]
    colors = String.colors - removed_colors

    if message =~ /AGILE FLOW/
      return "https://pbs.twimg.com/media/D_ei8NdXkAAE_0l.jpg:large"
    end

    if message =~ /bring probes to melting point/
      @melting_point_receivables.push(@probes)
      @probes = []
      return "all of them? melt all the precious probes you idiot?"
    end

    if message =~ /show source/
      return "https://github.com/LemonAndroid/eezee9"
    end

    if message =~ /philosophy/
      return [
#         """
#         => first step in the correct direction
# : build on String#scan and include lines before and after
# : write a simple wrapper for String#scan and include first char before the match and last char after the match
# eezee: divide & conquer :white_check_mark:
# eezee: pls paste repl.it link
# https://repl.it/repls/SpiffyKookyConfigfiles
# repl.it
# SpiffyKookyConfigfiles
# Powerful and simple online compiler, IDE, interpreter, and REPL. Code, compile, and run code in 50+ programming languages: Clojure, Haskell, Kotlin (beta), QBasic, Forth, LOLCODE, BrainF, Emoticon, Bloop, Unlambda, JavaScript, CoffeeScript, Scheme, APL, Lua, Python 2.7, Ruby,...

# @eeZee engage test mode
# eezee: suggested input output pair search(\"test test test\", \"est\") => [\"test \"]
# @eeZee :white_check_mark:
#           """,

          """
            DEVELOP THIS BY USING ITSELF
            WIELD THE TOOL TO DESIGN ITSELF
          """,

          """
            DS-INSPIRED WORKFLOW EXPERIMENT

            1: DATA


            2: MEASURE

            3: PROGRAM


            4: BUILD

            5: TEST

            6: SHIP

            7: GOTO: 1
          """

      ].sample
    end

    if message =~ /probe (.*) (.*)/
      action = :log

      resource = $1
      probe_identifier = $2

      if probe_identifier =~ /(\d+)s/
        duration_seconds = $1.to_i
      end

      if probe_identifier =~ /(\d+)bytes/
        byte_count = $1.to_i
      end

      case resource
      when /twitch.tv/
        twitch_url = resource
        action = :twitch
      when /http/
        action = :plain_curl
        url = resource
      end

      case action
      when :twitch
        probe = record_live_stream_video_and_upload_get_url(url: twitch_url, duration_seonds: duration_seconds)
        @probes.push(probe)
        return probe
      when :plain_curl
        probe = get_string_of_x_bytes_by_curling_url(url: url, byte_count: byte_count)
        @probes.push(probe)
        return probe
      end
    end


    # Example ∫-30,-20ƒ(x) = -10x+ -10

    #                          CO1   CO2


    #                          Coefficients

    # IMPORTANT IDEA: Show what variables correspond to in a visual example
    regex = /∫\s*(\-?\d+)\s*,\s*(\-?\d+)\s*[ƒf]\(x\)\s*=(.*)/ 
    require 'polynomials'

    if message =~ regex
      polynomial = Polynomials::Polynomial.parse($3)

      # Terms is a Hash that has the exponents of the terms as keys
      # https://github.com/LemonAndroid/polynomials/blob/newEra/lib/polynomials/polynomial.rb#L19
      coefficient_1 = polynomial.terms[1].coefficient
      coefficient_2 = polynomial.terms[0].coefficient

      integral_F_end_value_2 = ( 
        ((coefficient_1 / 2.0) * ($2.to_f**2)) + (coefficient_2.to_f * $2.to_f)
      )
      integral_F_start_value_1 = ( 
        ((coefficient_1 / 2.0) * ($1.to_f**2)) + (coefficient_2.to_f * $1.to_f) 
      )

      return <<~MATH_EXPLANATION_AND_RESULT
      step 1: F(x) = (#{coefficient_1} / 2) * x^2 + (#{coefficient_2} * x)
      step 2: F(#{$2}) - F(#{$1})
      step 3: #{integral_F_end_value_2} - #{integral_F_start_value_1}

      #{Number.new((integral_F_end_value_2-integral_F_start_value_1).to_s, "ruby").to_s}

      MATH_EXPLANATION_AND_RESULT
    end

    if /what is an integral?/ === message
      return "what-is-an-integral.agi.blue"
    end

    if /how is an integral computed?/ === message
      return "how-is-an-integral-computed.agi.blue"
    end

    if /what's the explanation for the computation of an integral?/ === message
      return "whats-the-explanation-for-the-computation-of-an-integral.agi.blue"
    end

    if message =~ /show activity stream/
      return "https://sideways-snowman.glitch.me/"
    end

    if message =~ /hey\Z/i
      return "hey" if rand < 0.01
    end

    if message =~ /\Avisualize ƒ\Z/i
      `ruby examples/plot_only_mutual_data.rb "2x^2 + 2x + 2"`
    end

    if message =~ /\Athrow bomb\Z/i
      return """
        ```
          Local variables (5 first)
          #{local_variables.sample(5)}

          Instance variables (5 first)
          #{instance_variables.sample(5)}

          Public methods (5 first)
          #{public_methods.sample(5)}

          ENV (120 first chars)
          #{ENV.inspect[0...120]}

          \`ifconfig\` (120 first chars)
          #{`ifconfig`[0...120]}
        ```
      """
    end

    if message =~ /\Abring to melting point #{melting_point_receiavable_regex}\Z/i
      if($1 === "last used picture")
        Nokogiri::HTML(`curl -L http://gazelle.botcompany.de/lastInput`)

        url = doc.css('a').first.url

        @melting_point_receivables.push(url)
      end
      @melting_point_receivables.push($1)
    end

    if message =~ /get-liquids-after-melting-point/
      @sent_messages.push(
        [@melted_liquids.inspect, @melted_liquids.inspect[0...100]]
      )
      return @sent_messages[-1][1]
    end

    if message =~ /probe last message full version size/
      return @sent_messages[-1][0].bytesize.to_s + 'bytes'
    end

    if message =~ /\Amelt\Z/
      # First step, assigning a variable
      @melting_point = @melting_point_receivables.sample

      def liquidify_via_string(object)
        object.to_s.unpack("B*")
      end
      liquid = liquidify_via_string(@melting_point)

      @melted_liquids.push(liquid)

      return "Melted liquid which is now #{liquid.object_id} (ruby object id)"
      # Next step, doing something intelligent with the data
      # loosening it up somehow
      # LIQUIDIFYING IT
      # CONVERTING IT ALL TO BYTES
      # PRESERVING VOLUME, just changing it's "Aggregatzustand"
    end

    if message =~ /\Aget-melting-point\Z/
      return @melting_point
    end

    if message =~ /\Aget-melting-point-receivables\Z/
      return @melting_point_receivables.inspect
    end

    if message =~ /\Awhat do you think?\Z/i
      return "I think you're a stupid piece of shit and your dick smells worse than woz before he invented the home computer."
    end

    if message =~ /\Apass ball to @(\w+)\Z/i
      @players[$1][:hasBall] = :yes
    end

    if message =~ /\Awho has ball\Z/i
      return @players.find { |k, v| v[:hasBall] == :yes }[0]
    end

    if message =~ /\Aspace\Z/
      exec_bash_visually_and_post_process_strings(
        '/Users/lemonandroid/gam-git-repos/LemonAndroid/gam/managables/programs/game_aided_manufacturing/test.sh'
      )
    end

    if message =~ /\Aget-chat-variable (\w*)\Z/i
       return [
        space_2_unicode("Getting variable value for key #{$1}"),
        space_2_unicode(@variables_for_chat_users[$1].verbose_introspect(very_verbose=true))
       ].join
    end

    if message =~ /\Aget-method-definition #{variable_regex}#{method_call_regex}\Z/
      return @variables_for_chat_users[$1].method($2.to_sym).source
    end

    if message =~ /\A@LemonAndroid List github repos\Z/i
      return "https://api.github.com/users/LemonAndroid/repos"
    end

    if message =~ /\AList 10 most recently pushed to Github Repos of LemonAndroid\Z/i
      texts = ten_most_pushed_to_github_repos
      texts.each do |text|
        return text
      end
    end

    if message =~ /get-strategy-chooser-url/i
      return "https://strategychooser.webflow.io/"
    end

    if message =~ /show qanda/
      return "https://unique-swing.glitch.me"
    end

    if message =~ /show blue/
      return "https://agi.blue"
    end

    if message =~ /show red/
      return "https://agi.red"
    end

    if message =~ /show black/
      return "https://agi.black"
    end

    if message =~ /\Aeject\Z/
      @ejected = true
      return "@eeZee was ejected"
    end

    if message =~ /\A@LemonAndroid work on (\w+\/\w+)\Z/i
      @currently_selected_project = $1
      return space_2_unicode("currently selected project set to #{@currently_selected_project}")
    end

    if message =~ /@LemonAndroid currently selected project/i
      return space_2_unicode("currently selected project is #{@currently_selected_project}")
    end

    if message =~ /\Als\Z/i
      texts = execute_bash_in_currently_selected_project('ls')
      texts.each do |text|
        return text
      end
    end

    if message === "exit"
      return "https://tenor.com/view/goal-flash-red-gif-12361214"
    end 

    return "Enjoy flight" if message =~ /console/ && @took_off
    return "" if @took_off

    if /console (.*)/ =~ message
      return eval($1).to_s
    end

    if /\Adocker ruby `(.*)`/ === message
      return `docker run -ti --rm andrius/alpine-ruby ruby -e "#{$1}"`
    end

    if /\Adocker python `(.*)`/ === message
      return `docker run --rm -ti jfloff/alpine-python python -c "#{$1}"`
    end

    if /\Adocker go `(.*)`/ === message
      return "yet to be implemented"
      # return `docker run --rm -ti jfloff/alpine-python python -c "#{$1}"`
    end

    if /\Adocker elixir `(.*)`/ === message
      return `docker run --rm -it --user=root bitwalker/alpine-elixir elixir -e "#{$1}"`
    end

    if /\Adocker julia `(.*)`/ === message
      return `docker run --rm -it -v $(pwd):/source cmplopes/alpine-julia julia -E "#{$1}"`
    end


    if /raw #{url_regex}/ === message
      url = $1
      case url
      when /github.com/
        url.gsub!(/github.com/, 'raw.githubusercontent.com')
        url.gsub!(/blob\//, '')
      end

      result = `curl #{url}`
      @last_raw_pipe = result
      return result[0...250]
    end
  end

  def url_regex
    /(.*)/
  end
  # require 'nokogiri'
  # require 'open-uri'
  # def bounties
  #     bounties_json = JSON.parse(`curl https://api.bountysource.com/search/bounty_search?callback=CORS&page=1&per_page=250`)
  #     bounties_json['data']['issues'].map do |issue|
  #       issue["title"]
  #     end
  # end

  def exec_bash_visually_and_post_process_strings(test)
    texts = execute_bash_in_currently_selected_project(test)
    return texts.map do |text|
       space_2_unicode(text)
    end.join("\n")
  end

  def variable_regex
    /(\w[_\w]*)/
  end

  def method_call_regex
    /\.#{variable_regex}/
  end

  def melting_point_receiavable_regex
    /(.*)/
  end

  def start
    client = Zircon.new(
      server: 'irc.gitter.im',
      port: '6667',
      channel: 'qanda-api/Lobby',
      username: 'LemonAndroid',
      password: '067d08cd7a80e2d15cb583a055ad6b5fe857b271',
      use_ssl: true
    )

    client.on_message do |message|
      response = on_message(message.body.to_s)

      unless response.empty?
        client.privmsg(
          "qanda-api/Lobby",
          space_2_unicode_array([response]).join('')
        )
      end
    end

    client.run!
  end

  def all_unix_process_ids(unix_id)
    descendant_pids(unix_id) + [unix_id]
  end

  def descendant_pids(root_unix_pid)
    child_unix_pids = `pgrep -P #{root_unix_pid}`.split("\n")
    further_descendant_unix_pids = \
      child_unix_pids.map { |unix_pid| descendant_pids(unix_pid) }.flatten

    child_unix_pids + further_descendant_unix_pids
  end

  def apple_script_window_position_and_size(unix_pid)
    <<~OSA_SCRIPT
      tell application "System Events" to tell (every process whose unix id is #{unix_pid})
        get {position, size} of every window
      end tell
    OSA_SCRIPT
  end

  def get_window_position_and_size(unix_pid)
    possibly_window_bounds = run_osa_script(apple_script_window_position_and_size(unix_pid))

    if possibly_window_bounds =~ /\d/
      possibly_window_bounds.scan(/\d+/).map(&:to_i)
    else
      return nil
    end
  end

  def run_osa_script(script)
    `osascript -e '#{script}'`
  end

  def in_gam_dir
    if currently_selected_project_exists_locally?
      Dir.chdir(current_repo_dir) do
        Bundler.with_clean_env do
          yield
        end
      end
    else
      return space_2_unicode_array(
        [
          "Currently selected project (#{@currently_selected_project}) not cloned",
          "Do you want to clone it to the VisualServer with the name \"#{`whoami`.rstrip}\"?"
        ]
      )
    end
  end

  def legacy_execute_bash_in_currently_selected_project(hopefully_bash_command)
    in_gam_dir do
      execute_bash_in_currently_selected_project(hopefully_bash_command)
    end
  end

  def execute_bash_in_currently_selected_project(hopefully_bash_command)
    byebug
    ANSWERS[CURRENT_DISCORD_MESSAGE[:mesage_id]][:debug] = binding.inspect

    stdout = ''
    stderr = ''
    process = Open4.bg(hopefully_bash_command, 0 => '', 1 => stdout, 2 => stderr)
    sleep 0.5


    ANSWERS[CURRENT_DISCORD_MESSAGE[:mesage_id]][:debug2] = binding.inspect

    texts_array = space_2_unicode_array(stdout.split("\n"))
    texts_array += space_2_unicode_array(stderr.split("\n"))

    # return [texts_array[1][0...120]]
    return (texts_array + screen_captures_of_visual_processes(process.pid)).join("\n")

    # return screen_captures_of_visual_processes(process.pid)
  end

  def screen_captures_of_visual_processes(root_unix_pid)
    sleep 8

    unix_pids = all_unix_process_ids(root_unix_pid)
    windows = unix_pids.map do |unix_pid|
      get_window_position_and_size(unix_pid)
    end.compact

    windows.map do |position_and_size|
      t = Tempfile.new(['screencapture-pid-', root_unix_pid.to_s, '.png'])
      `screencapture -R #{position_and_size.join(',')} #{t.path}`

      upload_gyazo(t.path)
    end
  end

  def upload_gyazo(local_file_path)
    gyazo = Gyazo::Client.new access_token: 'b2893f18deff437b3abd45b6e4413e255fa563d8bd00d360429c37fe1aee560f'
    res = gyazo.upload imagefile: local_file_path
    res[:url]
  end

  def current_repo_dir
    File.expand_path("~/gam-git-repos/#{@currently_selected_project}")
  end

  def currently_selected_project_exists_locally?
    system("stat #{current_repo_dir}")
  end

  def ten_most_pushed_to_github_repos
    output = `curl https://api.github.com/users/LemonAndroid/repos`

    processed_output = JSON
    .parse(output)
    .sort_by do |project|
      Date.parse(project["pushed_at"])
    end
    .last(10)
    .map do |project|
      project["full_name"]
    end

    space_2_unicode_array(processed_output)
  end

  def space_2_unicode_array(texts)
    texts.map { |text| space_2_unicode(text) }
  end

  def space_2_unicode(text)
    text.gsub(/\s/, "\u2000")
  end
end

begin
  bot = GitterDumbDevBot.new

  if ENV['UNSAFE_MODE'] === '1'
    bot.unsafe!
  end

  bot.load()

  get '/answer' do
    hash = ANSWERS[params[:message_id]]
    Json2table::get_html_table(hash.to_json)
  end


  get '/' do
    if /sinatra-console (.*)/ =~ params[:message]
      return eval($1).to_s
    end

    ANSWERS[params[:msgID]][:message_from_discord] = params[:message]
    response_string = bot.on_message(params[:message], params[:msgID])
    bot.dump()
    ANSWERS[params[:msgID]][:answer_for_discord] = response_string
    response_string
  # rescue Exception => e
    # e.message
  end
end
