
library(hexSticker)
library(ggplot2)
library(distrr)
library(data.table)
library(themeustat)
library(themegib)

f <- Fhat_df_(invented_wages, x = "wage", weights = "sample_weights")
setDT(f)

p <- ggplot(f[Fhat < 0.996], aes(x = wage, y = Fhat))
p <- p + geom_step() + 
  geom_linerange(
    aes(x = wage, ymin = 0, ymax = Fhat), 
    data = f[wage <= 4800 & wage >= 4799],
    linetype = 2
  ) +
  geom_linerange(
    aes(x = wage, y = Fhat, xmin = 0, xmax = 4800),
    data = f[wage <= 4800 & wage >= 4799],
    linetype = 2
  ) +
  theme_void() + 
  theme_transparent() + 
  geom_linerange(aes(x = 0, ymin = -0.02, ymax = 1.02)) + 
  geom_linerange(aes(y = 0, xmin = -200, xmax = 12000))
p

p + theme(plot.background = element_rect(fill = "#DE66E0"))

sticker(
  p, package = "distrr", p_size = 10,
  s_x = 1, s_y = 0.75,
  s_width = 0.7, s_height = 0.7,
  p_color = "black",
  h_fill = "#DE66E0", h_color = "black",
  # p_family = "noto_sans_mono_light",
  p_family = "trade_gothic",
  filename = "inst/distrr-sticker.svg",
  dpi = 600
)


