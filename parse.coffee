cheerio = require("cheerio")
fs = require("fs")
_ = require('underscore')
json2csv = require('json2csv')

results = []

_.each ['primaries','resales','comps'], (category) =>
  fs.readFile "reports/#{category}.html", "utf8", (err, data) =>
    return console.log(err) if err
    $ = cheerio.load(data)
    $("td.wp100").each (i, e) ->
      interiorTableRows = $(@).find('table>tr')
      instance =
        category:   category
        city:       $(@).find('div.title-label').text()
        address:    $(@).find('div.title-addr').text()
        list:       $(@).find('div.title-price').text()

      tableItems =
        section: [0, 4]
        olp: [2, 5]
        rms: [3, 1]
        beds: [4, 1]
        ld: [4, 5]
        fb: [5, 1]
        hb: [6, 1]
        sqft: [8, 3]
        dom: [8, 5]

      _.each tableItems, (v,k) ->
        instance[k] = interiorTableRows.eq(v[0]).find('td').eq(v[1]).text()

      instance.list = parseInt(instance.list.slice(13,100).replace(',',''))
      instance.olp = parseInt(instance.olp.slice(1,100).replace(',',''))
      instance.rms = parseInt(instance.rms)
      instance.beds = parseInt(instance.beds)
      instance.fb = parseInt(instance.fb)
      instance.hb = parseInt(instance.hb)
      instance.sqft = parseInt(instance.sqft)
      instance.dom = parseInt(instance.dom)

      results.push instance
      if results.length is 69
        fs.writeFile('results.json', JSON.stringify(results, null, 2))
        json2csv
          data: results
          fields: _.keys results[0]
        , (err, csv) ->
          console.log err  if err
          console.log fs.writeFile 'results.csv', csv
