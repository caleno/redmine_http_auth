module HTTPAuthAccountPatch
  unloadable

  def self.included(base)
    base.send(:include, ClassMethods)
    base.class_eval do
      #avoid infinite recursion in development mode on subsequent requests
      alias_method :login,
        :login_without_httpauth if method_defined? 'login_without_httpauth'
      #chain our version of find_current_user implementation into redmine core
      alias_method_chain(:login, :httpauth)

      # Logout
      alias_method :logout, :logout_without_httpauth if method_defined? 'logout_without_httpauth'
      alias_method_chain(:logout, :httpauth)
    end
  end

  module ClassMethods
    include HttpAuthHelper

    def login_force_httpauth
      # This is similar to the login page, except that it only supports http auth

      url = Setting.plugin_redmine_http_auth['login_link']
      if url.blank?
        # No login handler defined. Assume that the webserver is
        # configured to trigger authentication.
        return redirect_back_or_default(:controller => 'my', :action => 'page')
      end

      return_param = Setting.plugin_redmine_http_auth['login_return_parameter']
      if !return_param.blank?
        # Great! We can tell the login handler where to go after login.
        # Find out where that would be.
        back_url = CGI.unescape(params[:back_url].to_s)
        if back_url.blank?
          # Use the default.
          back_url = url_for(:controller => 'my', :action => 'page')
        end

        if url.include?('?')
          sep = '&'
        else
          sep = '?'
        end

        url += sep + CGI.escape(return_param) + '=' + CGI.escape(back_url)
      end

      logger.debug('httpauth redirecting to: ' + url)
      redirect_to(url)
    end


    def login_with_httpauth

      url = Setting.plugin_redmine_http_auth['login_link']
      return login_without_httpauth() if url.blank? # No URL configured - always show standard login page.

      return login_without_httpauth() if params['force_local'] # Local login.

      # Trigger httpauth authentication.
      return login_force_httpauth()
    end

    def logout_with_httpauth

      logout_user

      return redirect_to(home_url) if remote_user().nil? # http_auth not in use.

      url = Setting.plugin_redmine_http_auth['logout_link']
      return redirect_to(home_url) if url.blank? # No URL configured - not much we can do.

      # Trigger full logout.

      return_param = Setting.plugin_redmine_http_auth['logout_return_parameter']
      if !return_param.blank?
        # We can tell the logout handler where to go after logout.

        if url.include?('?')
          sep = '&'
        else
          sep = '?'
        end

        url += sep + CGI.escape(return_param) + '=' + CGI.escape(home_url)
      end

      logger.debug('httpauth logout redirecting to: ' + url)
      redirect_to(url)
    end

  end

end
