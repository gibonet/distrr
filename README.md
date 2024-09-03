
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/distrr)](https://cran.r-project.org/package=distrr)
[![R-CMD-check](https://github.com/gibonet/distrr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gibonet/distrr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# distrr

# Overview

distrr provides some tools to estimate and manage empirical
distributions. In particular, one of the main features of distrr is the
creation of data cubes of estimated statistics, that include all the
combinations of the variables of interest. The package makes strong
usage of the tools provided by
[dplyr](https://cran.r-project.org/package=dplyr), which is a grammar of
data manipulation.

The main functions to create a data cube are `dcc5()` and `dcc6()`
(`dcc` stands for data cube creation).

The data cube creation is like:

    data |>
      group_by(some variables) |>
      summarise(one or more estimated statistic)

in [dplyr](https://cran.r-project.org/package=dplyr) terms, but the
operation is done for each possible combination of the variables used
for grouping. The result will be a data frame in “tidy form”. See some
examples in the Usage section below.

# Installation

    # From CRAN
    install.packages("distrr")


    # Or the development version from GitHub:
    # install.packages("remotes")
    remotes::install_github("gibonet/distrr")

# Usage

Consider the `invented_wages` dataset:

``` r
library(distrr)
str(invented_wages)
#> tibble [1,000 × 5] (S3: tbl_df/tbl/data.frame)
#>  $ gender        : Factor w/ 2 levels "men","women": 1 2 1 2 1 1 1 2 2 2 ...
#>  $ sector        : Factor w/ 2 levels "secondary","tertiary": 2 1 2 2 1 1 2 1 2 1 ...
#>  $ education     : Factor w/ 3 levels "I","II","III": 3 2 2 2 2 1 3 1 2 2 ...
#>  $ wage          : num [1:1000] 8400 4200 5100 7400 4300 4900 5400 2900 4500 3000 ...
#>  $ sample_weights: num [1:1000] 105 32 36 12 21 46 79 113 34 32 ...
```

If we want to count the number of observations and estimate the average
wage by gender, with [dplyr](https://cran.r-project.org/package=dplyr)
we can do:

``` r
library(dplyr)
invented_wages |>
  group_by(gender) |>
  summarise(n = n(), av_wage = mean(wage)) |>
  ungroup()
#> # A tibble: 2 × 3
#>   gender     n av_wage
#>   <fct>  <int>   <dbl>
#> 1 men      547   5435.
#> 2 women    453   4441.
```

We can estimate the same statistics but grouped by education by changing
the argument inside `group_by`:

``` r
invented_wages |>
  group_by(education) |>
  summarise(n = n(), av_wage = mean(wage)) |>
  ungroup()
#> # A tibble: 3 × 3
#>   education     n av_wage
#>   <fct>     <int>   <dbl>
#> 1 I           172   3774.
#> 2 II          719   5099.
#> 3 III         109   6139.
```

and estimate the statistics by gender and education including both
variables in `group_by`:

``` r
invented_wages |>
  group_by(gender, education) |>
  summarise(n = n(), av_wage = mean(wage)) |>
  ungroup()
#> `summarise()` has grouped output by 'gender'. You can override using the
#> `.groups` argument.
#> # A tibble: 6 × 4
#>   gender education     n av_wage
#>   <fct>  <fct>     <int>   <dbl>
#> 1 men    I            60   4627.
#> 2 men    II          409   5278.
#> 3 men    III          78   6886.
#> 4 women  I           112   3317.
#> 5 women  II          310   4865.
#> 6 women  III          31   4261.
```

With `dcc5` we can perform all the steps above with one call:

``` r
invented_wages |> 
  dcc5(.variables = c("gender", "education"), av_wage = ~mean(wage))
#>   |                                                                              |                                                                      |   0%  |                                                                              |===================================                                   |  50%  |                                                                              |======================================================================| 100%
#> # A tibble: 12 × 4
#>    gender education     n av_wage
#>  * <fct>  <fct>     <int>   <dbl>
#>  1 Totale Totale     1000   4985.
#>  2 Totale I           172   3774.
#>  3 Totale II          719   5099.
#>  4 Totale III         109   6139.
#>  5 men    Totale      547   5435.
#>  6 men    I            60   4627.
#>  7 men    II          409   5278.
#>  8 men    III          78   6886.
#>  9 women  Totale      453   4441.
#> 10 women  I           112   3317.
#> 11 women  II          310   4865.
#> 12 women  III          31   4261.
```

The resulting data frame contains a column for each grouping variable,
and the estimations of all the combinations of the variables:

- by gender
- by education
- by gender and education
- plus the same statistics for all the dataset, without any grouping
  (this can be set with the argument `.all`, which by default is
  `TRUE`).

Note that in the result there are some rows where the variables take the
value `"Totale"`. When a variable has this value, it means that the
subset of the data considered in that row contains all the values of the
variable. For example, the first row of the result of `dcc5` contains
the estimations for all the dataset. The value `"Totale"` can be changed
with the argument `.total`.

The same result of `dcc5` can be produced by `dcc6`, with a slightly
different approach.

``` r
# Set a list of function calls
list_of_funs <- list(
  n = ~n(),
  av_wage = ~mean(wage),
  weighted_av_wage = ~weighted.mean(wage, sample_weights)
)

# Set the grouping variables
vars <- c("gender", "education")

# And create the data cube with dcc6
invented_wages |> 
  dcc6(.variables = vars, .funs_list = list_of_funs, .total = "TOTAL")
#>   |                                                                              |                                                                      |   0%  |                                                                              |===================================                                   |  50%  |                                                                              |======================================================================| 100%
#> # A tibble: 12 × 5
#>    gender education     n av_wage weighted_av_wage
#>  * <fct>  <fct>     <int>   <dbl>            <dbl>
#>  1 TOTAL  TOTAL      1000   4985.            4645.
#>  2 TOTAL  I           172   3774.            3527.
#>  3 TOTAL  II          719   5099.            4917.
#>  4 TOTAL  III         109   6139.            5885.
#>  5 men    TOTAL       547   5435.            5323.
#>  6 men    I            60   4627.            4681.
#>  7 men    II          409   5278.            5129.
#>  8 men    III          78   6886.            6173.
#>  9 women  TOTAL       453   4441.            3614.
#> 10 women  I           112   3317.            3227.
#> 11 women  II          310   4865.            4225.
#> 12 women  III          31   4261.            4388.
```

Compared to the results obtained with `dcc5`, we added the weighted
average of wages and changed the `"Totale"` value to `"TOTAL"`.
