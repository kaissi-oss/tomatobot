class User < ActiveRecord::Base
  has_many :tasks

  validates :name, presence: true
  validates :slack_id, presence: true, uniqueness: true
  validates :dnd_mode, absence: true, if: "slack_token.nil?"
  validates :duration, presence: true, 
                       numericality: { greater_than: 0, 
                                       less_than_or_equal_to: 480 }

  before_save :update_url_key
  after_create :report_creation

private

  def update_url_key
    self.url_key = SecureRandom.urlsafe_base64
  end

  def report_creation
    SendAmplitudeEventWorker.perform_async(slack_id, "activate")
  end
end
