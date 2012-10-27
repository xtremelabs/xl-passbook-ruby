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
