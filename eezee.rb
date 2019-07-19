
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

EEZEE_PREFIX = "eezee "

class Number
  def initialize(string_representation_from_discord)
    @string_representation_from_discord = string_representation_from_discord
  end

  def to_s
    """
      NUMBER
      STRING REPRESENTATION FROM DISCORD
      #{@string_representation_from_discord}

      RUBY #{RUBY_ENGINE} #{RUBY_VERSION} FLOAT
      #{@string_representation_from_discord.to_f}

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
  attr_accessor :input_variables, :output_variables

  def initialize
    self.input_variables = []
    self.output_variables = []
  end

  def compute(*args)
    return args
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
    warn and return [:info, :no_marshaled_data_found].join(' > ') unless File.exists?("/var/gam-discord-bot.ruby-marshal")
    data = File.read("/var/gam-discord-bot.ruby-marshal")
    @melting_point_receivables = Marshal.load(data)
  end

  require 'facets'
  def dump()
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

  def on_message(message)
    if /\Ais eeZee ejected\?\Z/ === message
      if @ejected == true
        return "Yes, @eeZee is ejected"
      else
        return "No, @eeZee should still respond"
      end
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
    # if Zircon::Message === message
    #   message = message.body.to_s
    # end

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

    if /agi\.blue/ === message
      @last_raw_pipe.each do |row|
        `curl http://agi.blue/bot/post?q=#{CGI.escape(row)}&key=source&value=eezee`
      end

      return "#{@last_raw_pipe.count} entries created on https://agi.blue"
    end

    def url_regex
      /(.*)/
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
        "3: ƒ",
        "4: get wit.ai token comfortably",
        "5: console 2 + 2",
        "6: tbd",
        "7: tbd",
        "8: tbd",
        "9: tbd",
        "10: tbd"
      ]
      
      return array[$1.to_i - 1]
    end

    if /console (.*)/ =~ message
      return "Enjoy flight" if @took_off
      return eval($1).to_s
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
      return new_function_command
    end

    if /\Aƒ\(([^\)]*)\)\Z/ === message
      case @raw_last_pipe
      when Function
        return @raw_last_pipe.compute($1)
      end
    end

    if /\A関数\(([^\)]*)\)\Z/ === message
      case @raw_last_pipe
      when Function
        return @raw_last_pipe.compute($1)
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

    require 'wit'
    client = Wit.new(access_token: ENV["WIT_AI_TOKEN"])
    client.message(message)

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

    if message =~ /philosophy/
      return [
        """
        => first step in the correct direction
: build on String#scan and include lines before and after
: write a simple wrapper for String#scan and include first char before the match and last char after the match
eezee: divide & conquer :white_check_mark:
eezee: pls paste repl.it link
https://repl.it/repls/SpiffyKookyConfigfiles
repl.it
SpiffyKookyConfigfiles
Powerful and simple online compiler, IDE, interpreter, and REPL. Code, compile, and run code in 50+ programming languages: Clojure, Haskell, Kotlin (beta), QBasic, Forth, LOLCODE, BrainF, Emoticon, Bloop, Unlambda, JavaScript, CoffeeScript, Scheme, APL, Lua, Python 2.7, Ruby,...

@eeZee engage test mode
eezee: suggested input output pair search(\"test test test\", \"est\") => [\"test \"]
@eeZee :white_check_mark:
          """,

          """
            DEVELOP THIS BY USING ITSELF
            WIELD THE TOOL TO DESIGN ITSELF
          """,

          """
            LEAN

            DATA


            MEASURE

            PROGRAM


            BUILD

            TEST

            SHIP

            GOTO: LEAN
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

    if message =~ /show activity stream/
      return "https://sideways-snowman.glitch.me/"
    end

    if message =~ /hey\Z/i
      return "hey"
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
  end

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

  def execute_bash_in_currently_selected_project(hopefully_bash_command)
    if currently_selected_project_exists_locally?
      Dir.chdir(current_repo_dir) do
        Bundler.with_clean_env do
          stdout = ''
          stderr = ''
          process = Open4.bg(hopefully_bash_command, 0 => '', 1 => stdout, 2 => stderr)
          sleep 0.5


          texts_array = space_2_unicode_array(stdout.split("\n"))
          texts_array += space_2_unicode_array(stderr.split("\n"))

          return [texts_array[1][0...120]]
          # texts_array + screen_captures_of_visual_processes(process.pid)
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

  def screen_captures_of_visual_processes(root_unix_pid)
    sleep 8

    unix_pids = all_unix_process_ids(root_unix_pid)
    windows = unix_pids.map do |unix_pid|
      get_window_position_and_size(unix_pid)
    end.compact

    windows.map do |position_and_size|
      t = Tempfile.new(['screencapture-pid-', root_unix_pid.to_s, '.png'])
      `screencapture -R #{position_and_size.join(',')} #{t.path}`

      gyazo = Gyazo::Client.new access_token: 'b2893f18deff437b3abd45b6e4413e255fa563d8bd00d360429c37fe1aee560f'
      res = gyazo.upload imagefile: t.path
      res[:url]
    end
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

  # bot.start()

  get '/' do
    response_string = bot.on_message(params[:message])
    bot.dump()
    response_string
  rescue Exception => e
    e.message
  end
end
