class ApplicationMailer < ActionMailer::Base
  include Resque::Mailer
  default from: 'info@example.com'
  layout 'mailer'
end
