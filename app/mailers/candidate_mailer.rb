class CandidateMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.lead_mailer.new_lead.subject
  #
  def new_candidate(candidate)
    @candidate = Candidate.find(candidate)
    @candidate_country = Country[@candidate.phone_country_code]
    @candidate_country_code = @candidate_country.country_code
    @candidate_phone = '+' + @candidate_country_code +" "+ @candidate.phone_number

    mail to: ["ricardo@example.com", "careers@example.com"],
          reply_to: @candidate.email,
          bcc: "johnny@example.com",
          subject: "New job application - #{@candidate.position}: #{@candidate.first_name} #{@candidate.last_name} | #{@candidate.phone_country_code} - #{@candidate.phone_number}"
  end


end
