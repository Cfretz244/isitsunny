# Update the load path.
$ROOT = File.expand_path(File.dirname(__FILE__))
$:.unshift($ROOT)

require 'thin'
require 'time'
require 'byebug'
require 'sinatra'

class Sunny < Sinatra::Application

  # Setup basic configurations.
  set :port, 80
  set :bind, '0.0.0.0'
  set :static, true
  set :public_folder, File.join($ROOT, 'assets')

  # Setup an episode class to store csv information.
  Episode = Struct.new(:season, :num, :title, :offset)

  # Numbers for days of the week.
  DAY_OFFSET = {
    'sunday' => 0,
    'monday' => 1,
    'tuesday' => 2,
    'wednesday' => 3,
    'thursday' => 4,
    'friday' => 5,
    'saturday' => 6
  }

  def initialize(*args)
    # Properly initialize ourselves.
    super

    # Iterate across all lines in the CSV.
    @episodes = Array.new
    File.foreach(File.join($ROOT, 'episodes.csv')).with_index do |line, index|
      # Skip the headers.
      next if index == 0

      # Break the line up into individual columns.
      entry = line.chomp.split(',')
      next if entry.compact.size != 6
      @episodes.push(Episode.new(entry[1], entry[2], entry[3], ground("#{entry[4]} #{entry[5]}")))
    end
    puts @episodes.inspect
  end

  def ground(date)
    # Use a special value for unknown episodes.
    return -1 if date.strip.empty?

    # Attempt to parse the date.
    parsed = DateTime.parse(date)

    # Calculate the day offset.
    base = parsed.wday * 86_400

    # Calculate the hour offset.
    hour = parsed.hour * 3_600

    # Calculate the minute offset.
    minute = parsed.minute * 60

    # Return the final value.
    base + hour + minute
  rescue
    # In case the file isn't formatted properly.
    -1
  end

  def time_string(timestamp, closest)
    # Start string generation.
    diff_str = String.new
    diff = (timestamp - closest.offset).abs

    # Decide if this already happened.
    diff_str += closest.offset >= timestamp ? 'Happens' : 'Happened'

    # Add in the hour component, if one exists.
    hours = diff / 3_600
    diff_str += " #{'in ' if closest.offset > timestamp}#{hours} hour#{'s' if hours > 1}" if hours > 0
    diff -= hours * 3_600

    # Add in the minute component, if one exists.
    minutes = diff / 60
    if hours > 0 && minutes > 0
      diff_str += ' and'
    elsif minutes > 0 && closest.offset > timestamp
      diff_str += ' in'
    end
    diff_str += " #{minutes} minute#{'s' if minutes > 1}" if minutes > 0

    # Punctuate the message and insert "ago" if this is in the past, or fallback to "now" if
    # no other alternative.
    diff_str += hours > 0 || minutes > 0 ? "#{' ago' if closest.offset < timestamp}" : ' now.'
  end

  # Setup the base route.
  get '/' do
    erb :index
  end

  post '/' do
    # Set user defined parameters for the template if they were provided.
    @provided_day = params[:day]
    @provided_time = params[:time]

    # Get a definite values to work with.
    effective_day = !@provided_day.empty? && @provided_day || params[:actualDay]
    effective_time = !@provided_time.empty? && @provided_time || params[:actualTime]

    # Construct a string to attempt to parse.
    final_date = "#{effective_time} #{effective_day}"

    # Attempt to parse the date and ground it to an abstract week.
    stamp = ground(final_date)

    # Put something fun on the screen if the user provided garbage.
    if stamp < 0
      @provided_day = '???'
      @provided_time = '???'
    end

    # Find the episodes that are closest to the given time.
    closest = @episodes.sort_by { |ep| (stamp - ep.offset).abs }
    closest.shift until closest.first.offset >= 0 unless stamp < 0
    @match = closest.first

    # Create a time diff string.
    @diff_str = time_string(stamp, @match)

    erb :index
  end

end
