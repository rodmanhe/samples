class Applicant < ActiveRecord::Base
  belongs_to :application
  belongs_to :tenant, class_name: 'User'
  belongs_to :applicant_data

  scope :for, ->(email){
    user = User.find_by(email: email)
    if user.present?
      where 'invite_email = ? OR tenant_id = ?', email, user.id
    else
      where invite_email: email
    end
  }

  scope :editable, ->{where status: [:invited, :drafted]}

  state_machine :status, initial: :invited do
    event :draft do
      transition [:invited, :drafted] => :drafted, if: ->(a){!a.tenant.nil?}
    end

    event :submit do
      transition :drafted => :submitted, if: ->(a){!a.tenant.nil?}
    end

    event :withdraw do
      transition all => :withdrawn
    end

    state :invited do
      validates :invite_email, presence: true, format: RubyRegex::Email
    end

    state :drafted do
      validates :tenant, presence: true
      validates :applicant_data, presence: true
    end

    after_transition to: :submitted do |applicant|
      applicant.prepare_roommate_invites_and_reminders
      applicant.tenant_reference_requests_and_reminders
    end

    after_transition to: :drafted do |applicant|
      applicant.tenant_submit_application_reminder
    end

    after_transition to: :withdrawn do |applicant|
      applicant.application.withdraw!
    end
  end

  # roomate invites
  def prepare_roommate_invites_and_reminders
    if applicant_data.invitations_sent
      list = applicant_data.invitations_sent.split(/[\s,]+/)
      list.each do |roommate_email|
        send_application_invite(roommate_email.strip)
      end
    end
  end

  def send_application_invite(r_email)
    if Applicant.where(invite_email: r_email).blank?
      roommate = application.applicants.create(invite_email: r_email)
      Usermailer.tenant_invite(roommate).deliver
      Resque.enqueue_in(24.hours, MyJob::TenantInviteReminder, roommate.id)
    end
  end

  # reference requests
  def tenant_reference_requests_and_reminders
    applicant_data.applicant_references.each do |reference|
      if reference.created?
        Usermailer.tenant_reference_request(reference).deliver
        Resque.enqueue_in(24.hours, MyJob::TenantReferenceRequestReminder, reference.id)
      end
    end
  end

  # application reminder
  def tenant_submit_application_reminder
    Resque.enqueue_in(24.hours, MyJob::TenantApplicationReminder, self.id)
  end

  def build_all_assocations
    build_applicant_data
    applicant_data.build_address
  end

end
