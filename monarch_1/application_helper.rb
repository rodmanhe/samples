def two_am_mailer
    users = User.where(approved: true)
    count = users.count

    past_week_array = EmailList.new(:past_week)
    past_month_array = EmailList.new(:past_month)

    users.each_with_index do |user, index|
      section = {}
      section = {
        :this_week => EmailList.new(:this_week).query,
        :past_week => past_week_array.list_for_user(index, count),
        :past_month => past_month_array.list_for_user(index, count)
      }
      UserMailer.send_new_list(section, user).deliver
    end
  end