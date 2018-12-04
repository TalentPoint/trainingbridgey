require 'sinatra/base'
require_relative 'helpers/bridge_processing'
require_relative 'helpers/email_sender'
require_relative 'helpers/file_encoder'
require_relative 'helpers/htmlify'
require 'csv'
require 'net/http'
require 'ostruct'
require 'uri'
require 'sinatra/simple_auth'
require 'sinatra/activerecord'
require './environments'
require 'sendgrid-ruby'
include SendGrid

class Bridgey < Sinatra::Base
  helpers Sinatra::BridgeProcessor
  helpers Sinatra::EmailSender
  helpers Sinatra::FileEncoder
  helpers Sinatra::Htmlify
  register Sinatra::SimpleAuth

  enable :sessions
  set :password, ENV['TALENTPOINT_PASSWORD']
  set :home, '/'

  get '/' do
    protected!
    @user_data = CSV.read(helper_dir + '/../public/csv/users.csv')
    @media_data = CSV.read(helper_dir + '/../public/csv/media.csv')
    @status_data = CSV.read(helper_dir + '/../public/csv/status.csv')
    @callback_data = CSV.read(helper_dir + '/../public/csv/callbacks.csv')
    @status_files = Dir[helper_dir + '/../public/csv/skills/*'].sort
    @status_files_names = chop_contents(@status_files)
    @status_file_data = extract_keywords(@status_files)
    erb :index
  end

  post '/process' do
    response = retrieve_request
    if response['Status'] == 'CREATED'
      add_to_database
      send_email_to_instructor(@mapped_data, params)
      erb :success
    elsif response['Status'] == 'DUPLICATES'
      @id_number = response['Duplicates'][0]
      erb :duplicates
    elsif response['Status'] == 'FAILED'
      @message = response['Message']
      erb :error
    else
      @message = "Something has gone wrong with Itris. They have not returned a valid response."
      erb :error
    end
  end

  get '/reports' do
    protected!
    @today = Applicant.where("date = ?", Date.today)
    @status = true
    erb :reports
  end

  get '/reports/yesterday' do
    protected!
    @today = Applicant.where("date = ?", last_working_day)
    @status = false
    erb :reports
  end

  get '/reports/leaders' do
    protected!
    @leaderboard = Hash.new
    @status = "today"
    @applicants = Applicant.where("date = ?", Date.today)
    @applicants.each do |applicant|
      if !@leaderboard.key?(applicant.bridger)
        @leaderboard[applicant.bridger] = @applicants.where(bridger: applicant.bridger).count
      end
    end
    @leaderboard = @leaderboard.sort_by(&:last).reverse
    erb :leaders
  end

  get '/reports/leaders/yesterday' do
    protected!
    @leaderboard = Hash.new
    @status = "yesterday"
    @applicants = Applicant.where("date = ?", last_working_day)
    @applicants.each do |applicant|
      if !@leaderboard.key?(applicant.bridger)
        @leaderboard[applicant.bridger] = @applicants.where(bridger: applicant.bridger).count
      end
    end
    @leaderboard = @leaderboard.sort_by(&:last).reverse
    erb :leaders
  end

  get '/reports/leaders/thismonth' do
    protected!
    @leaderboard = Hash.new
    @status = "thismonth"
    @applicants = Applicant.where(:date => Date.today.at_beginning_of_month..Date.today)
    @applicants.each do |applicant|
      if !@leaderboard.key?(applicant.bridger)
        @leaderboard[applicant.bridger] = @applicants.where(bridger: applicant.bridger).count
      end
    end
    @leaderboard = @leaderboard.sort_by(&:last).reverse
    erb :leaders
  end

  get '/reports/leaders/lastmonth' do
    protected!
    @leaderboard = Hash.new
    @month_name = Date.today.last_month.strftime("%B")
    @status = "lastmonth"
    @applicants = Applicant.where(:date => Date.today.at_beginning_of_month.last_month..Date.today.at_end_of_month.last_month)
    @applicants.each do |applicant|
      if !@leaderboard.key?(applicant.bridger)
        @leaderboard[applicant.bridger] = @applicants.where(bridger: applicant.bridger).count
      end
    end
    @leaderboard = @leaderboard.sort_by(&:last).reverse
    erb :leaders
  end

  get '/reports/jobboards' do
    protected!
    @jobboards = Hash.new
    @status = "today"
    @applicants = Applicant.where("date = ?", Date.today)
    @applicants.each do |applicant|
      if !@jobboards.key?(applicant.jobboard)
        @jobboards[applicant.jobboard] = @applicants.where(jobboard: applicant.jobboard).count
      end
    end
    @jobboards = @jobboards.sort_by(&:last).reverse
    erb :jobboards
  end

  get '/reports/jobboards/yesterday' do
    protected!
    @jobboards = Hash.new
    @status = "yesterday"
    @applicants = Applicant.where("date = ?", last_working_day)
    @applicants.each do |applicant|
      if !@jobboards.key?(applicant.jobboard)
        @jobboards[applicant.jobboard] = @applicants.where(jobboard: applicant.jobboard).count
      end
    end
    @jobboards = @jobboards.sort_by(&:last).reverse
    erb :jobboards
  end

  get '/reports/jobboards/thismonth' do
    protected!
    @jobboards = Hash.new
    @status = "thismonth"
    @applicants = Applicant.where(:date => Date.today.at_beginning_of_month..Date.today)
    @applicants.each do |applicant|
      if !@jobboards.key?(applicant.jobboard)
        @jobboards[applicant.jobboard] = @applicants.where(jobboard: applicant.jobboard).count
      end
    end
    @jobboards = @jobboards.sort_by(&:last).reverse
    erb :jobboards
  end

  get '/reports/jobboards/lastmonth' do
    protected!
    @jobboards = Hash.new
    @status = "lastmonth"
    @applicants = Applicant.where(:date => Date.today.at_beginning_of_month.last_month..Date.today.at_end_of_month.last_month)
    @applicants.each do |applicant|
      if !@jobboards.key?(applicant.jobboard)
        @jobboards[applicant.jobboard] = @applicants.where(jobboard: applicant.jobboard).count
      end
    end
    @jobboards = @jobboards.sort_by(&:last).reverse
    erb :jobboards
  end
  get '/login/?' do
    erb :login
  end

  post '/login/?' do
    auth!(params[:password])
  end

  private

  def last_working_day
    dayint = Date.today.strftime('%w')
    if dayint == "0"
      return 2.days.ago
    elsif dayint == "1"
      return 3.days.ago
    else
      return Date.yesterday
    end
  end

  def retrieve_request
    @mapped_data = process(params)
    @html_data = htmlify(params, @mapped_data)
    request = sender_wrapper(@mapped_data)
    JSON.parse(request.body)
  end

  def sender_wrapper(data)
    if ENV['RACK_ENV'] == "production"
       sender(@mapped_data.to_json)
    else
       fakesender
    end
  end

  def add_to_database()
    Applicant.create(bridger: user_name(params["thisUser"]),
                     jobboard: media_name(params["mediaType"]),
                     status: status_name(params["status"]),
                     date: Date.today)
  end

  def chop_contents(folders)
    folders.map do |folder|
      folder.split('/skills/')[1]
            .split('.')[0]
    end
  end

  def chop_one(file)
    file.split('/skills/')[1].split('.')[0]
  end

  def extract_keywords(status_files)
    status_files.map { |file| CSV.read(file) }
  end

  def fakesender
    hash = { "body":
      '{ "Status": "CREATED" }'
    }
    os = OpenStruct.new(hash)
  end

  def sender(data)
    url = URI.parse(ENV['ITRIS_ENDPOINT'])
    req = setup_connection(url, data)
    res = Net::HTTP.start(url.hostname, url.port) do |http|
      http.request(req)
    end
    res
  end

  def setup_connection(url, data)
    req = Net::HTTP::Post.new(url)
    req.body = data
    req['Authorization'] = ENV['ITRIS_KEY']
    req['Content-Type'] = 'Application/JSON; Charset=UTF-8'
    req
  end

end



class Applicant < ActiveRecord::Base
end
