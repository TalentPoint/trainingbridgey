require 'sinatra/base'
require 'json'
require 'active_support/all'

module Sinatra
  module BridgeProcessor
    def process(p)
      {
        "ProfileText": profile_text(p),
        "FirstName": p["firstName"],
        "LastName": p["lastName"],
        "PostCode": p["postcode"],
        "Address": address(p),
        "EmailAddress": p["emailAddress"],
        "MobileNumber": p["mobileNumber"],
        "Comment": comment(p),
        "CallBackDate": p["date"],
        "CallBackSubject": p["callbackSubject"],
        "Media": media_id(p["mediaType"]),
        "CreatedUser": user_id(p["thisUser"]),
        "FAO": user_id(p["thisUser"]),
        "Status": status_id(p["status"]).to_i,
        "Keywords": keywords(p),
        "OriginalCvFileData": resume_file(p),
        "OriginalCvExtension": get_original_ext(p),
        "FormattedCvFileData": formatted_resume_file(p),
        "FormattedCvExtension": get_formatted_ext(p),
        "AnnualSalary": p["minimumAnnualSalary"].to_s,
        "DailyRate": p["minimumDailySalary"].to_s
      }
    end

    def user_name(user)
      user = user.split(",")
      user[1] + " " + user[2]
   end

    def media_name(media)
      media = media.split(",")
      media[1]
    end

    def status_name(status)
      status = status.split(",")
      status[1]
    end

    private

    def profile_text(p)
      (user_initials_and_date(p["thisUser"]) +  " " + p["whyLeaving"] +
        ". " + p["currentSituation"] +
        ". " + p["whatDoTheyWant"]   +
        ". " + p["otherNotes"]).gsub(/[\r\n\v]+/, '')
    end

    def user_id(user)
      user = user.split(",")
      user[0]
    end

    def media_id(media)
      media = media.split(",")
      media[0]
    end

    def status_id(status)
      status = status.split(",")
      status[0]
    end

    def user_initials_and_date(user)
      user = user.split(",")
      user[1][0] + user[2] + " - " + Date.today.to_s
   end

    def get_original_ext(p)
      if p['resume']
        name = p['resume']['filename']
        result = "." + name.split('.')[1]
      end
    end

    def get_formatted_ext(p)
      if p['formatted_resume']
        name = params['formatted_resume']['filename']
        result = "." + name.split('.')[1]
      end
      result
    end


    def formatted_resume_file(p)
      if p['formatted_resume']
        encode_from_file_location(p['formatted_resume']['tempfile'])
      end
    end

    def resume_file(p)
      if p['resume']
        encode_from_file_location(p['resume']['tempfile'])
      end
    end


    def address(p)
      [ p["address1"],
        p["address2"],
        p["address3"] ]
    end

    def comment(p)
       (p["defineRole"]              +
         ". " + p["isSuitable"]      +
         ". " + p["durationLooking"] +
         ". " + p["otherWork"]       +
         ". " + p["availability"]).gsub(/[\r\n\v]+/, '')
    end

    def keywords_in_words(p)
      if p["skills"]
        p["skills"].map{|x| "<p>" + x.split(',')[1] + "</p>"}.join('')
      end
    end

    def keywords(p)
      if p["skills"]
        result = p["skills"].map{|x| x.split(',')[0].to_i} 
        if p["callbackCode"]
          result << p["callbackCode"].to_i
        end
      else
        result = p["callbackCode"].to_i
      end
      result
    end

  end

  helpers BridgeProcessor
end
