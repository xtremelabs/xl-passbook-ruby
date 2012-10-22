Rails.application.routes.draw do
  namespace :v1 do
    post "devices/:device_id/registrations/:pass_type_id/:serial_number" => "devices#register", :constraints => { :pass_type_id => /[^\/]+/ }
    get "devices/:device_id/registrations/:pass_type_id" =>"devices#updatable", :constraints => { :pass_type_id => /[^\/]+/ }
    delete "devices/:device_id/registrations/:pass_type_id/:serial_number" => "devices#unregister", :constraints => { :pass_type_id => /[^\/]+/ }

    post "log" => "logs#log"
  end
end






