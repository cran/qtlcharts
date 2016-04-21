# qtlcharts 0.6-6

- Fix proliferation of tool tips

- For use with Shiny, clear SVG before drawing


# qtlcharts 0.5-25

- Skip Rmd and html tests run on CRAN (so faster, and because the Rmd
  tests won't work on Solaris as they need pandoc).


# qtlcharts 0.5-23

- Changed license and author list in order to post the package on
  CRAN, http://cran.r-project.org

- `idotplot` and `iplot` now use the names of the input data as
  individual IDs if `indID` is missing or `NULL`.


# qtlcharts 0.5-18

- Fixed a bug in `iplotScanone` with `pxgtype="ci"`. In the case of
  phenotypes with missing values, the confidence intervals were
  incorrect.


# qtlcharts 0.5-14

- `iplotCorr` has argument `scatterplots` that, if controls whether
  scatterplots will be shown when clicking on pixels in the heatmap.
  (If `scatterplots=FALSE`, we skip the scatterplots.)


# qtlcharts 0.5-13

- `iplotMScanone` can plot just points (rather than curves) for the
  LOD scores and QTL effects in the lower and right-hand panels.

- Fix a bug in `iplotMScanone` (x-axis labels in right-hand plot
  weren't being shown)


# qtlcharts 0.5-10

- Included [bower](http://bower.io) information, about the javascript
  libraries, within the source package.


# qtlcharts 0.5-8

- Got the package working with
  [jsonlite](https://github.com/jeroenooms/jsonlite), as
  [htmlwidgets](http://www.htmlwidgets.org) has now switched from
  [RJSONIO](http://www.omegahat.net/RJSONIO/) to jsonlite, for
  converting R objects to [JSON](http://www.json.org/).


# qtlcharts 0.5-4

- Added `setScreenSize` function for controlling the default sizes of
  charts.


# qtlcharts 0.5-3

- Added `idotplot` function for plotting a quantitative variable in
  different categories.  (It's just like `iplotPXG`, but with data
  values not connected to a cross object.)

- Reorganized the [d3panels](http://kbroman.org/d3panels) code: just
  using `d3panels.min.js` and `d3panels.min.css` rather than linking
  to js code for individual panels.


# qtlcharts 0.5-1

- Refactored the entire package to use
  [htmlwidgets](http://www.htmlwidgets.org).
  A big advantage is that the charts now work nicely within
  [RStudio](http://www.rstudio.com/products/RStudio/).

- To save a plot to a file, you now need to assign the result of a plot
  function to an object and then use the
  [htmlwidgets](http://www.htmlwidgets.org) function `saveWidget`.

  ```r
  library(qtlcharts)
  library(qtl)
  data(hyper)
  hyper <- calc.genoprob(hyper, step=1)
  out <- scanone(hyper)
  chart <- iplotScanone(out, hyper)
  htmlwidgets::saveWidget(chart, file="hyper_scanone.html")
  ```

- It's now simpler to include interactive charts within an R Markdown
  document. You simply make the plots in a code chunk in the way that
  you would at the R prompt. There's no longer a need to worry about
  `print_qtlcharts_resources()` or `results="asis"`.

- Separated out the basic panel functions as a separate repository,
  [d3panels](http://kbroman.org/d3panels), to make it easier for them
  to be used separately from
  [R/qtlcharts](http://kbroman.org/qtlcharts).
