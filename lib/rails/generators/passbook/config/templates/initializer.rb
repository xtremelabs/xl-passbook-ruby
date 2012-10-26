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
