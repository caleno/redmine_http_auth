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
    end
  end

  module ClassMethods

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
  end

end
