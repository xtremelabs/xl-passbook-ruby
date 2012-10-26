if Passbook::Config.instance.enable_routes
  Rails.application.routes.draw do
    get "/v1/passes/:pass_type_id/:serial_number" => "Passbook::passes#get_pass", :constraints => { :pass_type_id => /[^\/]+/ }

    post "/v1/devices/:device_id/registrations/:pass_type_id/:serial_number" => "Passbook::registrations#create", :constraints => { :pass_type_id => /[^\/]+/ }
    delete "/v1/devices/:device_id/registrations/:pass_type_id/:serial_number" => "Passbook::registrations#delete", :constraints => { :pass_type_id => /[^\/]+/ }
    get "/v1/devices/:device_id/registrations/:pass_type_id" =>"Passbook::registrations#updatable", :constraints => { :pass_type_id => /[^\/]+/ }

    post "/v1/log" => "Passbook::logs#log"
  end
end






