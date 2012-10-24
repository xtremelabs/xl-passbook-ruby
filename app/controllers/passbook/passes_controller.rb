module Passbook
  class PassesController < ApplicationController
    def get_pass
      pass = pass_type_id_to_class(params[:pass_type_id]).find_by_serial_number params[:serial_number]
      return render(:json => {}, :status => 401) if pass.blank?
      pass.update_from_api if pass.respond_to? :update_from_api
      return render(:json => {}, :status => 304) if !request.headers['if-modified-since'].blank? && pass.updated_at<=Time.zone.parse(request.headers['if-modified-since'])
      get_pkpass pass
    end

    def pass_type_id_to_class pass_type_id
      Passbook::Config.instance.pass_config[pass_type_id]['class']
    end

    def get_pkpass pass=nil
      pass ||=pass_type_id_to_class(params[:pass_type_id]).update_or_create params
      render :pkpass => pass
    end
  end
end
