class <%= class_name %> < ActiveRecord::Base
  #TODO WARNING: authentication_token and serial_number are subject to mass assign
  attr_accessible :serial_number, :authentication_token, :card_id
  before_create :add_authentication_token

  def add_authentication_token
    self.authentication_token = Base64.urlsafe_encode64(SecureRandom.base64(36))
    self.serial_number||= Base64.urlsafe_encode64(SecureRandom.base64(36))
  end

  def self.update_or_create params
    <%= plural_name.singularize %>_pass = find_by_card_id params[:card_id]
    <%= plural_name.singularize %>_pass ||=new
    params.slice(*column_names.map(&:to_sym)).each do |attr, val|
      <%= plural_name.singularize %>_pass.send :"#{attr}=", val
    end
    <%= plural_name.singularize %>_pass.save!
    <%= plural_name.singularize %>_pass
  end

  def update_pass pkpass
    update_json pkpass.json
  end

  def update_json pass_json
    pass_json['authenticationToken'] = authentication_token
    pass_json['serialNumber'] = serial_number
    #add more customization to your passbook's JSON right here
  end
end
