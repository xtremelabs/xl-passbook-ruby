# Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc. ("Apple")
#             in consideration of your agreement to the following terms, and your use,
#             installation, modification or redistribution of this Apple software
#             constitutes acceptance of these terms.  If you do not agree with these
#             terms, please do not use, install, modify or redistribute this Apple
#             software.
#
#             In consideration of your agreement to abide by the following terms, and
#             subject to these terms, Apple grants you a personal, non - exclusive
#             license, under Apple's copyrights in this original Apple software ( the
#             "Apple Software" ), to use, reproduce, modify and redistribute the Apple
#             Software, with or without modifications, in source and / or binary forms;
#             provided that if you redistribute the Apple Software in its entirety and
#             without modifications, you must retain this notice and the following text
#             and disclaimers in all such redistributions of the Apple Software. Neither
#             the name, trademarks, service marks or logos of Apple Inc. may be used to
#             endorse or promote products derived from the Apple Software without specific
#             prior written permission from Apple.  Except as expressly stated in this
#             notice, no other rights or licenses, express or implied, are granted by
#             Apple herein, including but not limited to any patent rights that may be
#             infringed by your derivative works or by other works in which the Apple
#             Software may be incorporated.
#
#             The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
#             WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
#             WARRANTIES OF NON - INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
#             PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION
#             ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
#
#             IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
#             CONSEQUENTIAL DAMAGES ( INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#             SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#             INTERRUPTION ) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION
#             AND / OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER
#             UNDER THEORY OF CONTRACT, TORT ( INCLUDING NEGLIGENCE ), STRICT LIABILITY OR
#             OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Copyright ( C ) 2012 Apple Inc. All Rights Reserved.


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
