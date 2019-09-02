class SessionsController < Clearance::SessionsController
  private

# authenticate takes in params and returns a user that can be signed in
# Calling super allows us to use the original authenticate method so we can pass in modified params
  def authenticate(_)
    super(session_params)
  end

  def session_params
    { session: session_params_with_email }
  end

# Takes original values and creates a hash containing both password and email
  def session_params_with_email
    params.require(:session).
    permit(:password).
    merge(email: user.email)
  end

# User where email = email_or_username or username = email or email_or_username
# We want the first result (.first) but it's possible that a user doesn't exist, in which case we would get a null value
# To handle this, we create a null object (Guest) to handle cases in which the user doesn't exist.
# The Guest object is created in the Guest.rb model. It is an empty string so when we call user.email it doesn't fail, but since it's passing an empty email it shouldn't find an appropriate email to authenticate
  def user
    User.where(email: email_or_username).or(User.where(username: email_or_username)).first || Guest.new
  end

#
  def email_or_username
    params[:session][:email_or_username]
  end
end
