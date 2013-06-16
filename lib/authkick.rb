require "authkick/version"

module Authkick

  module ControllerMethods

    def self.included(base)
      base.helper_method :current_user
      base.helper_method :signed_in?
    end

    def current_user
      @current_user ||= begin
        user = session[:user_id] ? User.find_by(id: session[:user_id]) : nil
        if !user and cookies.encrypted[:user_id]
          user = User.find_by(id: cookies.encrypted[:user_id])
          if user
            reset_session
            session[:user_id] = user.id
          end
        end
        user
      end
    end

    def signed_in?
      !!current_user
    end

    def sign_in(user, opts = {})
      remember = opts.has_key?(:remember) ? opts[:remember] : 1.year
      reset_session
      session[:user_id] = user.id
      @current_user = user
      cookies.encrypted[:user_id] = {value: "#{user.id}", expires: remember.from_now, httponly: true} if remember
    end

    def sign_out
      @current_user = nil
      reset_session
      cookies.delete(:user_id)
    end

  end

end

ActionController::Base.send(:include, Authkick::ControllerMethods) if defined?(ActionController::Base)
