# iplotRF: interactive plot of pairwise recombination fractions
# Karl W Broman

HTMLWidgets.widget({

    name: "iplotRF",
    type: "output",

    initialize: (widgetdiv, width, height) ->
        d3.select(widgetdiv).append("svg")
          .attr("class", "qtlcharts")
          .attr("width", width)
          .attr("height", height)

    renderValue: (widgetdiv, x) ->
        svg = d3.select(widgetdiv).select("svg")

        # clear svg and remove tool tips
        svg.selectAll("*").remove()
        widgetid = d3.select(widgetdiv).attr('id')
        d3.selectAll("div.d3-tip.#{widgetid}").remove()

        chartOpts = x.chartOpts ? {}
        chartOpts.width = chartOpts?.width ? svg.attr("width")
        chartOpts.height = chartOpts?.height ? svg.attr("height")

        svg.attr("width", chartOpts.width)
        svg.attr("height", chartOpts.height)

        iplotRF(widgetdiv, x.rfdata, x.genodata, chartOpts)

    resize: (widgetdiv, width, height) ->
        d3.select(widgetdiv).select("svg")
          .attr("width", width)
          .attr("height", height)

})
