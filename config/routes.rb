ActionController::Routing::Routes.draw do |map|
  map.httpauthlogin 'httpauth-login', :controller => 'account', :action => 'login_force_httpauth'
  
  map.httpauthselfregister 'httpauth-selfregister/:action',
    :controller => 'registration', :action => 'autoregistration_form'

  map.connect 'login-local', :controller => 'account', :action => 'login', :force_local => 'true'

end
