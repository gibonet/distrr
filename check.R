
# Push to github and gitlab -----------
# git push -u gitlab master
# git push -u origin master

# git checkout -b progressbar
# git branch
# git push --set-upstream gitlab progressbar
# git push --set-upstream origin progressbar

# devtools --------
library(devtools)

load_all()

document()

check_man()
check()

build()

install(upgrade = "never")

test()

# usethis ---------
library(usethis)

use_package_doc()

use_testthat()

use_test("dcc")
use_test("combn_char")


# covr::package_coverage() ------------
rstudioapi::restartSession()
library(covr)
cov <- package_coverage()
cov
# as.data.frame(cov)
# report()
report(cov, file = "distrr-report.html")


# pkgdown ---------
library(pkgdown)
build_site()


# Trials ----------

# dcc6 step by step
.data <- invented_wages
.variables <- c("gender", "education")
.total <- "TOTAL"
order_type <- extract_unique4

.funs_list <- list(n = ~dplyr::n())
.all <- TRUE

d <- prepare_data(
  .data = .data, 
  .variables = .variables, 
  .total = .total, 
  order_type = order_type
)

l <- d[["l"]]; data_new <- d[["data_new"]]; l_lev <- d[["l_lev"]]

joint_all <- joint_all_funs_(
  data_new, 
  .variables = .variables, 
  .funs_list = .funs_list, 
  .total = .total, .all = .all
)

joint_all_final <- finish_cube(
  joint_all = joint_all, 
  .variables = .variables,
  l_lev = l_lev, 
  l = l
)

attributes(joint_all_final)[[".variables"]] <- .variables

tmp <- dcc6(.data, .variables, .funs_list, .total, order_type, .all)

tmp <- dcc6_fixed(
  .data, .variables, .funs_list, .total, order_type, .all, 
  fixed_variable = "gender"
)

# dcc5 step by step
formals(dcc5)
dcc5(.data, .variables, jointfun_, .total)
dcc5(.data, .variables, jointfun_, .total, m = ~mean(wage))
dcc(.data, .variables, jointfun_)
dcc2(.data, .variables, jointfun_)

joint_all <- joint_all_(
  data_new, 
  .variables = .variables, 
  .fun = jointfun_, 
  .total = .total, 
  .all = .all
)
