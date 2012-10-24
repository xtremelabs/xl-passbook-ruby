module Passbook
  class LogsController < ApplicationController

    def log
      # if request && request.body
      #   request.body.rewind
      #   json_body = JSON.parse(request.body.read)
      #   File.open(File.expand_path(Rails.root) + "/log/devices.log", "a") do |f|
      #     f.write "[#{Time.now}] #{json_body["description"]}\n"
      #   end
      # end
        render :nothing => true, :status => 200
    end

  end #Class
end
