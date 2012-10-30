
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




module Passbook
  class PassesController < ApplicationController
    def get_pass
      pass = Passbook.pass_type_id_to_class(params[:pass_type_id]).find_by_serial_number params[:serial_number]
      return render(:json => {}, :status => 401) if pass.blank?
      pass.check_for_updates if pass.respond_to? :check_for_updates
      return render(:json => {}, :status => 304) if !request.headers['if-modified-since'].blank? && pass.updated_at<=Time.zone.parse(request.headers['if-modified-since'])
      get_pkpass pass
    end

    def get_pkpass pass=nil
      pass ||=Passbook.pass_type_id_to_class(params[:pass_type_id]).update_or_create params
      render :pkpass => pass
    end
  end
end
