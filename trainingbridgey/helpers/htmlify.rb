require 'sinatra/base'
require 'json'
require 'active_support/all'

module Sinatra
  module Htmlify
    def htmlify(params, p)
      "<h5 class='title'>Talent Point Bridger</h5> <p> #{user_name(params['thisUser'])} </p><h5 class='title'>Applicant Name</h5> <p>#{p[:FirstName]} #{p[:LastName]}</p><h5 class='title'>Email Address</h5>#{p[:EmailAddress]}</p><h5 class='title'>Mobile Number</h5>#{p[:MobileNumber]}</p><h5 class='title'>Requested Salary</h5><p>" + (p[:AnnualSalary] != "" ? "#{p[:AnnualSalary]} Annually</p><p>" : "" ) + (p[:DailyRate] != "" ? "#{p[:DailyRate]} Daily</p>" : "" ) + "<h5 class='title'>Address</h5><p>#{p[:Address][0]}</p><p>#{p[:Address][1]}</p><p>#{p[:Address][2]}</p><h5 class='title'>Postcode</h5> <p>#{p[:PostCode]}</p><h5 class='title'>Profile</h5> <p>#{p[:ProfileText]}</p><h5 class='title'>Comments</h5> <p>#{p[:Comment]}</p><h5 class='title'> Callback subject</h5> <p> #{p[:CallBackSubject]} </p> <h5 class='title'> Callback Date </h5> <p> #{p[:CallBackDate]}</p><h5 class='title'>Job Board</h5> <p>#{media_name(params['mediaType'])}</p><h5 class='title'> Status </h5> <p> #{status_name(params['status'])}</p><h5 class='title'> Skills </h5> <p> #{keywords_in_words(params)} </p>"
    end
  end
  helpers Htmlify
end
