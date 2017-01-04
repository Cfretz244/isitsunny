# Update the load path.
$ROOT = File.expand_path(File.dirname(__FILE__))
$:.unshift($ROOT)

require 'thin'
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
      @episodes.push(Episode.new(entry[1], entry[2], entry[3], ground(entry[4], entry[5])))
    end
  end

  def ground(time, day)
    # Use a special value for unknown episodes.
    return -1 if time.nil? || day.nil? || time.empty? || day.empty?

    # Calculate the day offset.
    base = DAY_OFFSET[day.downcase] * 86_400

    # Calculate the hour offset.
    split = time.index(':')
    hour = time[0...split].to_i * 3_600

    # Calculate the minute offset.
    minute = time[(split + 1)..-1].to_i * 60

    # Return the final value.
    base + hour + minute
  rescue
    # In case the file isn't formatted properly.
    -1
  end

  # Setup the base route.
  get '/' do
    erb :index
  end

  post '/' do
    # Grab the parameters in case they were set.
    @day = params[:day]
    @time = params[:time]
    erb :index
  end

end
