
#  Copyright 2012 Xtreme Labs

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.




if Passbook::Config.instance.enable_routes
  Rails.application.routes.draw do
    get "/v1/passes/:pass_type_id/:serial_number" => "passbook/passes#get_pass", :constraints => { :pass_type_id => /[^\/]+/ }

    post "/v1/devices/:device_id/registrations/:pass_type_id/:serial_number" => "passbook/registrations#create", :constraints => { :pass_type_id => /[^\/]+/ }
    delete "/v1/devices/:device_id/registrations/:pass_type_id/:serial_number" => "passbook/registrations#delete", :constraints => { :pass_type_id => /[^\/]+/ }
    get "/v1/devices/:device_id/registrations/:pass_type_id" =>"passbook/registrations#updatable", :constraints => { :pass_type_id => /[^\/]+/ }

    post "/v1/log" => "passbook/logs#log"
  end
end







