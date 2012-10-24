module Passbook
  class RegistrationsController < ApplicationController
    def create
      puts "Handling registration request..."
      # validate that the request is authorized to deal with the pass referenced
      pass = Passbook.pass_type_id_to_class(params[:pass_type_id]).where(:serial_number => params[:serial_number]).where(:authentication_token => authentication_token).first
      unless pass.blank?
        puts 'Pass and authentication token match.'

        # Validate that the device has not previously registered
        # Note: this is done with a composite key that is combination of the device_id and the pass serial_number
        uuid = params[:device_id] + "-" + params[:serial_number]
        if Registration.where(:uuid => uuid).count < 1
          # No registration found, lets add the device
          # push_token = params[:push_token]
          Registration.create!(:uuid => uuid,
                              :device_id => params[:device_id],
                              :pass_type_id => params[:pass_type_id],
                              :push_token => push_token,
                              :serial_number => params[:serial_number])

          # Return a 201 CREATED status
          # status 201
          render :json => {}, :status => 201
        else
          # The device has already registered for updates on this pass
          # Acknowledge the request with a 200 OK response
          # status 200
          render :json => {}, :status => 200
        end

      else
        # The device did not statisfy the authentication requirements
        # Return a 401 NOT AUTHORIZED response
        # status 401
        render :json => {}, :status => 401
      end
    end


    def delete
      puts "Handling unregistration request..."
      puts authentication_token
      if Passbook.pass_type_id_to_class(params[:pass_type_id]).where(:serial_number => params[:serial_number], :authentication_token => authentication_token).first
        puts 'Pass and authentication token match.'

        # Validate that the device has previously registered
        # Note: this is done with a composite key that is combination of the device_id and the pass serial_number
        uuid = params[:device_id] + "-" + params[:serial_number]
        registration = Registration.find_by_uuid(uuid)
        unless registration.blank?
          Registration.delete registration.id
          render :json => {}, :status => 200
        else
          puts 'Registration does not exist.'
          render :json => {}, :status => 401
        end
      else
        # Not authorized
        render :json => {}, :status => 401
      end
    end

    def updatable
      puts "Handling updates request..."
      # Check first that the device has registered with the service
      if Registration.where(:device_id => params[:device_id]).count > 0

        # The device is registered with the service

        # Find the registrations for the device
        registered_serial_numbers = Registration.where(:device_id => params[:device_id], :pass_type_id => params[:pass_type_id]).collect{|r| r[:serial_number]}

        # The passesUpdatedSince param is optional for scoping the update query
        if params[:passesUpdatedSince] && params[:passesUpdatedSince] != ""
          registered_passes = Passbook.pass_type_id_to_class(params[:pass_type_id]).where(:serial_number => registered_serial_numbers).where('updated_at IS NULL OR updated_at >= ?', params[:passesUpdatedSince])
        else
          registered_passes = Passbook.pass_type_id_to_class(params[:pass_type_id]).where(:serial_number => registered_serial_numbers)
        end

        # Are there passes that this device should recieve updates for?
        if registered_passes.count > 0
          # Found passes that could be updated for this device
          # Build the response object
          update_time = registered_passes.map(&:updated_at).max
          updatable_passes_payload = {:lastUpdated => update_time}
          updatable_passes_payload[:serialNumbers] = registered_passes.collect{|rp| rp[:serial_number]}

          render :json => updatable_passes_payload.to_json, :status => 200
        else
          render :json => {}, :status=>204
        end

      else
        # This device is not currently registered with the service
        render :json => {}, :status=> 404
      end
    end

    private

    def authentication_token
      if request.env && request.env['HTTP_AUTHORIZATION']
        request.env['HTTP_AUTHORIZATION'].split(" ").last
      end
    end


    # Convienience method for parsing the pushToken out of a JSON POST body
    def push_token
      return params[:pushToken] if params.include?(:pushToken)
      if request && request.body
        request.body.rewind
        json_body = JSON.parse(request.body.read)
        if json_body['pushToken']
          json_body['pushToken']
        end
      end
    end

  end
end
