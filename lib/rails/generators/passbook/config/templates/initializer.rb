Passbook::Config.instance.configure do |passbook|
  passbook.pass_config['<%= pass_type_id %>']={
                              "cert_path"=>'<%= cert_path %>',
                              "cert_password"=>'<%= cert_password %>',
                              "template_path"=>'<%= template_path %>'
                            }

  passbook.wwdr_intermediate_certificate_path= '<%= wwdr_certificate_path %>'
end
