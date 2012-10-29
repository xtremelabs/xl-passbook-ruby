
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




Passbook::Config.instance.configure do |passbook|
  # Templates are preloaded in production and dynamically loaded in development by default
  # You can control the behaviour by setting the 'preload_templates'
  #
  # passbook.preload_templates = true


  # Enables the routes necessary for passes to be able to:
  # 1) register with the server
  # 2) log errors
  # 3) list pkpasses to be updated
  # 4) let passbook request for update
  passbook.enable_routes = true


  passbook.wwdr_intermediate_certificate_path= "<%= wwdr_certificate_path.blank? ? "#{Rails.root}/data/certificates/wwdr.pem":wwdr_certificate_path %>"
end
