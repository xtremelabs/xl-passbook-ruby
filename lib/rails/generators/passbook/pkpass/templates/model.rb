class <%= class_name %> < ActiveRecord::Base
  attr_protected :serial_number, :authentication_token
  attr_accessible :card_id
  before_create :set_pass_fields

  def set_pass_fields
    self.authentication_token = Base64.urlsafe_encode64(SecureRandom.base64(36))
    self.serial_number||= Base64.urlsafe_encode64(SecureRandom.base64(36))
  end

  def self.update_or_create params
    <%= plural_name.singularize %>_pass = find_by_card_id params[:card_id]
    <%= plural_name.singularize %>_pass ||=new
    params.slice(*attr_accessible[:default].map(&:to_sym)).each do |attr, val|
      <%= plural_name.singularize %>_pass.send :"#{attr}=", val
    end
    <%= plural_name.singularize %>_pass.save!
    <%= plural_name.singularize %>_pass
  end

  def check_for_updates

  end

  def update_pass pkpass
    update_json pkpass.json
  end

  def update_json pass_json
    pass_json['authenticationToken'] = authentication_token
    pass_json['serialNumber'] = serial_number
    #don't forget to change the URL to whatever address your server is at
    pass_json['webServiceURL'] = "http://192.168.x.x:3000"
    #add more customization to your passbook's JSON right here
  end
end
