

# Obiettivo:
# - riscrivere le funzioni che nel pacchetto distrr sono nel file gibutils.R (0.0.4)
#   con il nuovo approccio di 'tidy evaluation' del pacchetto dplyr (>= 0.0.7)
#   (per esempio usando summarise e non più summarise_)
# - rlang negli Imports nel file DESCRIPTION, al posto di lazyeval

# group_by_(.data, .dots = character)
# gby_ <- function(.data, .variables){
#   .data |>
#     dplyr::group_by_(.dots = .variables)
# }
# gby_(mtcars, c("vs", "am"))
# gby_(mtcars, c("vs", "am", "mpg")) |>
#   summarise(wgroup = sum(cyl)) |>
#   gby_(c("vs", "am")) |>
#   mutate(wcum = cumsum(wgroup))

gby_ <- function(.data, .variables){
  .variables <- lapply(.variables, as.symbol)
  .data |>
    dplyr::group_by(!!! .variables)
}
# gby_(mtcars, c("cyl", "vs"))
# gby_(mtcars, c("cyl"))
# gby_(mtcars, c("cyl", "vs", "gear"))


select2_ <- function(.data, .variables){
  .variables <- lapply(.variables, as.symbol)
  .data |>
    dplyr::select(!!! .variables)
}
# mtcars |> dplyr::select(mpg, vs)
# mtcars |> select2_(c("mpg", "vs"))
# prepare_data, finish_cube, finish_cube2


arrange2_ <- function(.data, .variables){
  .variables <- lapply(.variables, as.symbol)
  .data |>
    dplyr::arrange(!!! .variables)
}
# mtcars |> arrange(mpg, vs)
# mtcars |> arrange2_(c("mpg", "vs"))
# finish_cube, finish_cube2


filter2_ <- function(.data, .dots = list()){
  dots <- compat_lazy_dots(.dots, rlang::caller_env())
  dplyr::filter(.data, !!! dots)
}
# filter2_(mtcars, .dots = "vs == 0 & am == 0")
# filter2_(mtcars, .dots = list("vs == 0 & am == 0"))
# filter2_(mtcars, .dots = list(~vs == 0 & am == 0))
# filter2_(mtcars, .dots = list(~vs == 0, ~am == 0))
# only_joint, remove_total


summarise2_ <- function(.data, ...){
  dots <- compat_lazy_dots(dots = list(), rlang::caller_env(), ...)
  dplyr::summarise(.data, !!! dots)
}
# mtcars |> summarise2_(n = ~n(), media = ~mean(mpg))
# jointfun_, joint_all_


summarise2_dots_ <- function(.data, .funs_list){
  dots <- compat_lazy_dots(dots = .funs_list, rlang::caller_env())
  dplyr::summarise(.data, !!! dots)
}
# mtcars |> 
#   summarise2_dots_(.funs_list = list(n = ~n(), m = ~mean(mpg)))
# joint_all_funs_, joint_all_funs2_


sumx_ <- function(.data, x){
  x <- rlang::sym(x)
  dplyr::summarise(.data, wsum = sum(!! x))
}
# sumx_(mtcars, "cyl")
# sumx_(mtcars, "mpg")


mutcumx_ <- function(.data, x){
  x <- rlang::sym(x)
  .data |>
    dplyr::mutate(wcum = cumsum(!! x), Fhat = cumsum(!! x) / sum(!! x))
}
# mutcumx_(mtcars, "cyl")


complete2_ <- function(.data, .variables){
  .variables <- lapply(.variables, rlang::sym)
  .data |>
    tidyr::complete(!!! .variables)
}

