class Candidate < ApplicationRecord
  has_one_attached :curriculum
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :phone_country_code, presence: true
  validates :email, presence: true

  validate :has_curriculum
  validate :correct_document_mime_type

  # enum position: { "Real estate agent": 1, "Office secretary": 2, "HR manager": 3, "Branch manager": 4 }
  enum position: { "Real estate agent": 1 }

  private

  def has_curriculum
    if !curriculum.attached?
      errors.add(:curriculum, 'Please, attach your CV')
    end
  end

  def correct_document_mime_type
    if curriculum.attached? && !curriculum.content_type.in?(%w(application/msword application/pdf application/vnd.openxmlformats-officedocument.wordprocessingml.document))
      errors.add(:curriculum, 'Must be a PDF or a DOC file')
    end
  end

end
