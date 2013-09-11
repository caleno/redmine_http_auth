RedmineApp::Application.routes.draw do
  match 'httpauth-login', :controller => 'account', :action => 'login_force_httpauth'
  match 'httpauth-selfregister/:action', :controller => 'registration', :action => 'autoregistration_form'
  match 'login-local', :controller => 'account', :action => 'login', :force_local => 'true'
end


