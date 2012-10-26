Passbook::Config.instance.add_pkpass do |passbook|
  passbook.pass_config["<%= pass_type_id %>"]={
                              "cert_path"=>"<%= cert_path.blank? ? "#{Rails.root}/data/certificates/#{pass_type_id}.p12" : cert_path %>",
                              "cert_password"=>"<%= cert_password %>",
                              "template_path"=>"<%= template_path.blank? ? "#{Rails.root}/data/templates/#{pass_type_id}" : template_path %>",
                              "class"=>"<%= class_name %>"
                            }

end
