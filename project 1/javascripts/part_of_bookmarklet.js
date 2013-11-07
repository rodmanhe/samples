getElementPath = function(element) {
    pClass = element.attr("class")
    pId = element.attr("id")
    pTag = element.prop("tagName")
    elementContainer = ""

    elementContainer += (typeof pTag === "undefined")   ? "" : pTag.toLowerCase()
    elementContainer += (typeof pId === "undefined")    ? "" : "#"+pId
    elementContainer += (typeof pClass === "undefined") ? "" : "."+pClass.replace(" ", ".") 

    return elementContainer
};

// find container for price
if(prices[0]) {
amount = number_regex.exec(prices[0].text);
// foundin = $("*:not(:has(*))").text() == amount
array_of_prices = $("*:contains('"+amount+"')")
    .filter(":not(script)")
    .filter(":not(noscript)")
    .filter(":not(del)")
    .filter(":not(strike)")
    .filter(function (index) { 
        return $(this).children().length < 1; 
    })
if (array_of_prices.length > 1) {
  foundin_obj = array_of_prices.first()
} else if (array_of_prices.length == 1) {
  foundin_obj = array_of_prices
} else if (array_of_prices.length == 0) {
  foundin_obj = $("*:contains('"+amount+"')")
    .filter(":not(script)")
    .filter(":not(noscript)")
    .filter(":not(del)")
    .filter(":not(strike)").last()
}

child = getElementPath(foundin_obj)
parent = getElementPath(foundin_obj.parent())
foundin = parent+" "+child

}  

getFoundIn: function($img) {
  target = $img.parent()
  if (target.is("a")) {
    img_types = ['jpg', 'jpeg', 'png', 'tif', 'giff']
    target_href = target.attr("href")
    if (target_href == "" || target_href == "#" ) {
      url = location.href
      origin = true
    } else if (target_href.substring(0,1) == "/") {
      url = location.href
      origin = true
    } else {
      href = target_href.split(".")
      href_end = href[href.length-1]
      // anchor is just image blown up
      if (img_types.indexOf(href_end) !== -1) {
        url = location.href
        origin = true
      } else {
        // anchor is product page link
        url = target.attr("href")
        origin = false
      }
    }
    
  } else {
    // no anchor.  This is the product page
    url = location.href
    origin = true
    // get div that contains price
  }

  fin = {
    url: url,
    origin: origin
  }
  return fin
},  