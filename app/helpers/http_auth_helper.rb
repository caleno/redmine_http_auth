module HttpAuthHelper
  unloadable
  
  def user_attributes
    ['login', 'mail', 'firstname', 'lastname']
  end

  def use_email?
    Setting.plugin_redmine_http_auth['lookup_mode'] == 'mail'
  end

  def set_default_attributes(user)
    user_attributes.each do |attr|
      user.send(attr + "=", (get_attribute_value attr))
    end
  end

  def set_readonly_attributes(user)
    user_attributes.each do |attr|
      user.send(attr + "=", (get_attribute_value attr)) if readonly_attribute? attr
    end
  end

  def remote_user
    request.env[Setting.plugin_redmine_http_auth['server_env_var']]
  end

  def readonly_attribute?(attribute_name)
    if remote_user_attribute? attribute_name
      true
    else
      return true if jit_provision? and not Setting.plugin_redmine_http_auth['jitprovision_' + attribute_name].blank?

      conf = Setting.plugin_redmine_http_auth['readonly_attribute']
      if conf.nil? || !conf.has_key?(attribute_name)
        false
      else
        conf[attribute_name] == "true"
      end
    end
  end

  private
  def remote_user_attribute?(attribute_name)
    (attribute_name == "login" && !use_email?) || (attribute_name == "mail" && use_email?)
  end

  def get_attribute_value(attribute_name)
    if remote_user_attribute? attribute_name
      remote_user
    else
      jit_data = jit_provision_data()
      return jit_data[attribute_name] if jit_data.has_key?(attribute_name)

      conf = Setting.plugin_redmine_http_auth['attribute_mapping']
      if conf.nil? || !conf.has_key?(attribute_name)
        nil
      else
        request.env[conf[attribute_name]]
      end
    end
  end

  def jit_provision?
    return Setting.plugin_redmine_http_auth['jitprovision'] == 'true'
  end

  def jit_provision_data
    # Function to get autoprovisioned data.
    return {} if not jit_provision? #JIT provisioning not enabled.
    ret = {}
    ['firstname', 'lastname', 'mail'].each do |name|
      env_name = Setting.plugin_redmine_http_auth['jitprovision_' + name]
      next if env_name.empty?
      next if not request.env.has_key?(env_name)
      ret[name] = request.env[env_name]
    end
    return ret
  end


end
