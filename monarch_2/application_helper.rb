# supermodel grab all model names in database
	def update_list
    models = ActiveRecord::Base.connection.tables.collect{|t| t.underscore.singularize.camelize}
    models.each do |m|
      if Supermodel.find(:all, conditions: {name: m}).count == 0
        Supermodel.create(name: m, visible: false)
      end
    end
    client_models = ["Role", "Page", "Announcement", "Event", "Partial", "User"]
    client_models.each do |cm|
      instance = Supermodel.find_by_name(cm)
      instance.update_attributes(visible: true)
    end
  end