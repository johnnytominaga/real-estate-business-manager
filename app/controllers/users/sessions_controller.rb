class Users::SessionsController < Devise::SessionsController

    ####################
    #    Redirects     #
    ####################



    protected

    #Login Path (if already logged in)
    def after_sign_in_path_for(resource)
      # Here you can write logic based on roles to return different after sign in paths
      stored_location_for(resource) ||
      if resource.role_id == "admin"
        root_path #Will redirect to pages#agent
      elsif resource.role_id == "manager"
        root_path #Will redirect to pages#agent
      elsif resource.role_id == "editor"
        root_path #Will redirect to pages#editor
      elsif resource.role_id == "agent"
        root_path #Will redirect to pages#agent
      end
    end


    #Logout Path
    def after_sign_out_path_for(resource_or_scope)
        root_url
    end

end
