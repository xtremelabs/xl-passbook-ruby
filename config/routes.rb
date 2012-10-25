if Passbook::Config.instance.enable_routes
  Rails.application.routes.draw do
    get "passes/:pass_type_id/:serial_number" => "passes#get_pass", :constraints => { :pass_type_id => /[^\/]+/ }

    post "devices/:device_id/registrations/:pass_type_id/:serial_number" => "registrations#create", :constraints => { :pass_type_id => /[^\/]+/ }
    delete "devices/:device_id/registrations/:pass_type_id/:serial_number" => "registrations#delete", :constraints => { :pass_type_id => /[^\/]+/ }
    get "devices/:device_id/registrations/:pass_type_id" =>"registrations#updatable", :constraints => { :pass_type_id => /[^\/]+/ }

    post "log" => "logs#log"
  end
end






