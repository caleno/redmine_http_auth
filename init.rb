require 'redmine'
require 'http_auth_patch'
require 'http_auth_account_patch'
 
Redmine::Plugin.register :redmine_http_auth do
  name 'HTTP Authentication plugin'
  author 'Adam Lantos'
  url 'http://github.com/AdamLantos/redmine_http_auth' if respond_to?(:url)
  description 'A plugin for doing HTTP authentication'
  version '0.3.0-dev-redmine-2.x'
  menu :account_menu, :login_httpauth, { :controller => 'httpauth-login' }, 
    :before => :login, :caption => :login_httpauth_title,
    :if => Proc.new { User.current.anonymous? && Setting.plugin_redmine_http_auth['enable'] == 'true' && Setting.plugin_redmine_http_auth['enable_login_link'] == 'true'}

  settings :partial => 'settings/redmine_http_auth_settings',
    :default => {
      'enable' => 'true',
      'enable_login_link' => 'true',
      'server_env_var' => 'REMOTE_USER',
      'lookup_mode' => 'login',
      'auto_registration' => 'false',
      'keep_sessions' => 'false',
      'login_link' => '',
      'login_return_parameter' => '',
      'logout_link' => '',
      'logout_return_parameter' => '',
      'jitprovision' => 'false',
      'jitprovision_firstname' => '',
      'jitprovision_lastname' => '',
      'jitprovision_mail' => '',
    }
end



RedmineApp::Application.config.after_initialize do
  unless ApplicationController.include? (RedmineHttpAuth::HTTPAuthPatch)
    ApplicationController.send(:include, RedmineHttpAuth::HTTPAuthPatch)
  end
  unless AccountController.include? (HTTPAuthAccountPatch)
  require_dependency 'account_controller'
  AccountController.send(:include, HTTPAuthAccountPatch)
end
