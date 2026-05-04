class CandidatesController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :set_candidate, only: [:show]
  load_and_authorize_resource
  skip_authorize_resource only: [:new, :create]

  def new
    @candidate = Candidate.new
  end

  def create
    @candidate = Candidate.new(candidate_params)
    if @candidate.save
      CandidateMailer.new_candidate(@candidate.id).deliver_now
      flash[:info] = "Thanks for applying! We'll review your application get back to you shortly."
      redirect_to new_candidate_path

    else
      flash.now[:alert] = @candidate.errors.full_messages.to_sentence
      render action: "new"

    end

  end

  def index
  end

  def show
  end

  private

  def candidate_params
    params.require(:candidate).permit(:first_name, :last_name, :email, :position, :phone_number, :phone_country_code, :curriculum)
  end

end
