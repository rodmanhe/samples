

class ExperianCustomer < ActiveRecord::Base
  belongs_to :user
  has_many :reports, class_name: 'ExperianCreditReport'

  def self.experian_call(params, url)
    `curl -X POST -H "Accept: application/json" \
    -u xxxxxx:xxxxxxxx '#{url}' \
    -d '#{experian_params(params)}' -k`
  end


  def self.auth_questions(auth_params, user)
    url = "https://XX.XXX.XX.XX:XXXX/ECP2P/api/user"
    result = experian_call(auth_params, url)
    result = JSON.parse(result)
    if result["success"] == true
      if user.experian_customer
        ec = user.experian_customer
        ec.update_attributes(auth_session: result["authSession"])
      else
        ExperianCustomer.create(auth_session: result["authSession"], user: user)
      end
      result = result["preciseIDServer"]["KBA"]["QuestionSet"]
    else
      false
    end
  end


  def self.authenticate_answers(answers)
    url = "https://XX.XXX.XX.XX:XXXX/ECP2P/api/user/answers"
    result = `curl -X POST -H "Accept: application/json" \
    -u xxxxxx:xxxxxxxx '#{url}' \
    -d '#{fix_answers(answers)}' -k`
    result = JSON.parse(result)
  end

  def self.get_consumer_credit_report(user)
    url = "https://XX.XXX.XX.XX:XXXX/ECP2P/api/report"
    result = experian_call(report_params(user), url)
    result = JSON.parse(result)
  end

  def fetch_and_share(initiating_customer)
    url = "https://XX.XXX.XX.XX:XXXX/ECP2P/api/share"
    result = self.class.experian_call(share_params(initiating_customer),url)
    result = JSON.parse(result)
  end

  def self.fix_answers(answers)
    result = ""
    len = answers.length
    count = 0
    answers.each do |key, value|
      count += 1
      key = "answer" unless key == :authSession
      result += "#{key}=#{value}#{len == count ? '' : '&'}"
    end
    result
  end

  def self.experian_params(post_params)
    result = ""
    len = post_params.length
    count = 0
    post_params.each do |key, value|
      count +=1
      result += "#{key}=#{value}#{len == count ? '' : '&'}"
    end
    result
  end

  state_machine :status, initial: :pending_authentication do
    event :authenticate do
      transition :pending_authentication => :authenticated
    end

    event :de_authenticate do
      transition all => :failed_authentication
    end

    event :share do
      transition :authenticated => :shared
    end

    state :pending_authentication do
      attr_accessor :ssn
      attr_accessor :firstName, :lastName, :currentAddress, :currentCity, :currentState, :currentZip
      validates :ssn, length: { is: 9 }, on: :new


      def verify_answers!(answers)
        result = self.class.authenticate_answers(answers)
        if result["success"] == true
          self.user_token = result["UserToken"]
          self.save!
          self.authenticate!
          true
        else
          false
        end
      end
    end

    state :authenticated do
      validates :user_token, presence: true
      def credit_report(user)
        result = self.class.get_consumer_credit_report(user)
        if result["success"] == true
          self.transactionID = result["transactionId"]
          save!
          share!
        else
          false
        end
      end
    end

    state :shared do
      validates :transactionID, presence: true
      def share_report!(agent)
        result = self.fetch_and_share(agent)
        if result["success"] == true
          self.shareId = result[ "shareId"]

          save! 
        else
          false
        end
      end
    end
  end

  def self.report_params(user)
    {
      productId: 1,
      consumerToken: user.experian_customer.user_token,
      purposeType: 3
    }
  end

  def share_params(user)
    { consumerToken: self.user_token,
      endUserToken: user.experian_customer.user_token,
      purposeType: 3,
      transactionId: self.transactionID
    }
  end
  
end
