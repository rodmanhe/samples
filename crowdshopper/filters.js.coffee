class CrowdShopper.Filters

  constructor: (payload) ->
    @payload  = payload

  display: ->
    @addFilters()

  addFilters: ->
    self = @
    dynamicFilters = []
    resultsKeys = []

    flatten = (array) ->
      if array.length is 0 then return []
      array.reduce (lhs, rhs) -> lhs.concat rhs

    unique = (a) ->
      unique = []
      a.filter (item) -> unique.indexOf(item) == -1

    filters = ["price", "category", "brand", "color", "size"]
    resultsKeys = self.payload["results"].map (result) -> Object.keys(result)
    flattenedKeys = flatten(resultsKeys)
    uniqueKeys = unique(flattenedKeys)
    dynamicFilters = filters.filter (key) -> uniqueKeys.indexOf(key) > -1

    @eraseFilters(filters)
    for filter in dynamicFilters
      filter_name = filter.substring(0,1).toUpperCase() + filter.substring(1)
      self.renderFilterContainer(filter_name)
      self.setFilter(filter_name)

  eraseFilters: (filters) -> 
    for filter in filters
      $(".#{@pluralizeFilter(filter)}s-filter").remove()

  renderFilterContainer: (filter) ->
    html = "<div class='filter #{@pluralizeFilter(filter)}s-filter'>"
    html += "<h4><div class='filter-title'>#{filter}</div></h4>"
    html += "<div id='#{@pluralizeFilter(filter)}s-container'></div></div>"
    $("#find_products_form").append(html)

  setFilter: (filter) ->
    self = @
    payload = @payload
    context = { hash: self["processed#{filter}Filter"](payload) }
    $("##{@pluralizeFilter(filter)}s-container").html(HandlebarsTemplates["filters/#{filter.toLowerCase()}"](context))

  pluralizeFilter: (filter) ->
    filter = if filter.toLowerCase() is "category" then "categorie" else filter
    filter.toLowerCase()


  # processed Filters
  processedManufacturerFilter: (hash) ->
    # loop through brands
    manu_list = {}
    for result in hash["results"]
      if manu_list.hasOwnProperty(result["manufacturer"])
        manu_list[result["manufacturer"]] += 1
      else
        manu_list[result["manufacturer"]] = 1
    @replaceUndefined(manu_list)

  processedSizeFilter: (hash) ->
    # loop through brands
    size_list = {}
    for result in hash["results"]
      if size_list.hasOwnProperty(result["size"])
        size_list[result["size"]] += 1
      else
        size_list[result["size"]] = 1
    @replaceUndefined(size_list)

  processedPriceFilter: (hash) ->
    product_list = {}
    products = []
    resultsWithOffers = hash["results"].filter (result) -> result["numOffers"] > 0
    for result in resultsWithOffers
      for offer in result["offers"]
        products.push { sem3_id: result["sem3_id"], offer: offer }

    sortByKey = (array, key) ->
      array.sort (a, b) -> a[key] - b[key]

    maxValue = (array, key) ->
      Math.max (array.map (item) -> item[key])...

    minValue = (array, key) ->
      Math.min (array.map (item) -> item[key])...

    sortedProducts = sortByKey(products, "offer")
    maxOffer = maxValue(products, "offer")
    minOffer = minValue(products, "offer")
    factor = Math.ceil((maxOffer - minOffer) / 10)

    product_list =  [0..9].reduce (x, y) ->
      begRange = minOffer + (factor * y)
      endRange = (minOffer + (factor * (y+1))) - 0.01 
      offers = sortedProducts.filter (product) -> product if product.offer >= begRange and product.offer < endRange
      x["$#{begRange.toFixed(2)} - $#{endRange.toFixed(2)}"] = offers.length
      x
    , {}

  processedBrandFilter: (hash) ->
    # loop through brands
    brand_list = {}
    for result in hash["results"]
      if brand_list.hasOwnProperty(result["brand"])
        brand_list[result["brand"]] += 1
      else
        brand_list[result["brand"]] = 1
    @replaceUndefined(brand_list)

  processedCategoryFilter: (hash) ->
    # loop through categories
    category_list = {}
    for result in hash["results"]
      if category_list.hasOwnProperty(result["category"])
      else
        category_list[result["category"]] = {
          cat_id: result["cat_id"]
          count: 1
        }
    console.log category_list
    category_list

  processedColorFilter: (hash) ->
    # loop through colors
    color_list = {}
    for result in hash["results"]
      if color_list.hasOwnProperty(result["color"])
        color_list[result["color"]] += 1
      else
        color_list[result["color"]] = 1
    @replaceUndefined(color_list)
    

  replaceUndefined: (list) ->
    if list.hasOwnProperty("undefined") 
      list["other"] = list["undefined"]
      delete list["undefined"]
    list