
## install via `install.packages("name")`
library(tidyverse)
library(ggplot2)

####----------------------------------------------------------#
#### The relationship between economy and PV ####
####----------------------------------------------------------#

economy_df <- read_csv("data/econ.csv") 
popvote_df <- read_csv("data/popvote_1948-2016.csv") 

dat <- popvote_df %>% 
  filter(incumbent_party == TRUE) %>%
  select(year, winner, pv2p) %>%
  left_join(economy_df %>% filter(quarter == 2))

## fit a model of Q2 Inflation effects on Incumbent Party PV
lm_econinf <- lm(pv2p ~ inflation, data = dat)
summary(lm_econinf)

cor(dat$inflation, dat$pv2p)

dat %>%
  ggplot(aes(x=inflation, y=pv2p,
             label=year)) + 
  geom_text(size = 2) +
  geom_smooth(method="lm", formula = y ~ x) +
  labs(title = "Q2 Inflation Effects on Incumbent Party PV",
       subtitle = "Y = 53.60 - 0.02 * X",
       caption = "Figure 1") +
  xlab("Q2 Inflation (X)") +
  ylab("Incumbent party PV (Y)") +
  theme_bw() 

ggsave("figures/voteshar&inflation.png", height = 4, width = 8)

### Out of Sample Validation for inflation
## model testing: leave-one-out
outsamp_modinf  <- lm(pv2p ~ inflation, dat[dat$year != 2016,])
outsamp_predinf <- predict(outsamp_modinf, dat[dat$year == 2016,])
outsamp_trueinf <- dat$pv2p[dat$year == 2016] 

## model testing: cross-validation (one run)
years_outsampinf <- sample(dat$year, 8)
modinf <- lm(pv2p ~ inflation,
          dat[!(dat$year %in% years_outsampinf),])

outsamp_predinf <- predict(modinf,
                        newdata = dat[dat$year %in% years_outsampinf,])

mean(outsamp_predinf - dat$pv2p[dat$year %in% years_outsampinf])

## model testing: cross-validation (1000 runs) inflation
outsamp_errorsinf <- sapply(1:1000, function(i){
  years_outsampinf <- sample(dat$year, 8)
  outsamp_modinf <- lm(pv2p ~ inflation,
                    dat[!(dat$year %in% years_outsampinf),])
  outsamp_predinf <- predict(outsamp_modinf,
                          newdata = dat[dat$year %in% years_outsampinf,])
  outsamp_trueinf <- dat$pv2p[dat$year %in% years_outsampinf]
  mean(outsamp_predinf - outsamp_trueinf)
})

mean(abs(outsamp_errorsinf))

hist(outsamp_errorsinf,
     xlab = "",
     main = "mean out-of-sample residual\n(1000 runs of cross-validation)")
ggsave("figures/hist_infvs.png", height = 4, width = 8)


## Prediction for 2020 (inflation)
Inflation_new <- economy_df %>%
  subset(year == 2020 & quarter == 2) %>%
  select(inflation)
predict(lm_econinf, Inflation_new, interval="prediction")


## fit a model of Q2 Unemployment effects on Incumbent Party PV
lm_econune <- lm(pv2p ~ unemployment, data = dat)
summary(lm_econune)

### Out of Sample Validation with unemployment
## model testing: leave-one-out
outsamp_modune  <- lm(pv2p ~ unemployment, dat[dat$year != 2016,])
outsamp_predune <- predict(outsamp_modune, dat[dat$year == 2016,])
outsamp_trueune <- dat$pv2p[dat$year == 2016] 

## model testing: cross-validation (one run)
years_outsampune <- sample(dat$year, 8)
modune <- lm(pv2p ~ unemployment,
          dat[!(dat$year %in% years_outsampune),])

outsamp_predune <- predict(modune,
                        newdata = dat[dat$year %in% years_outsampune,])

mean(outsamp_predune - dat$pv2p[dat$year %in% years_outsampune])

## model testing: cross-validation (1000 runs) inflation
outsamp_errorsune <- sapply(1:1000, function(i){
  years_outsampune <- sample(dat$year, 8)
  outsamp_modune <- lm(pv2p ~ unemployment,
                    dat[!(dat$year %in% years_outsampune),])
  outsamp_predune <- predict(outsamp_modune,
                          newdata = dat[dat$year %in% years_outsampune,])
  outsamp_trueune <- dat$pv2p[dat$year %in% years_outsampune]
  mean(outsamp_predune - outsamp_trueune)
})

mean(abs(outsamp_errorsune))

hist(outsamp_errorsune,
     xlab = "",
     main = "mean out-of-sample residual with Unemployment\n(1000 runs of cross-validation)")

## Prediction for 2020 (unemployment)
Unemployment_new <- economy_df %>%
  subset(year == 2020 & quarter == 2) %>%
  select(unemployment)
predict(lm_econune, Unemployment_new, interval="prediction")


## Unemployment graph
dat %>%
  ggplot(aes(x=unemployment, y=pv2p,
             label=year)) + 
  geom_text(size = 2) +
  geom_smooth(method="lm", formula = y ~ x) +
  labs(title = "Q2 Unemployment Effects on Incumbent Party PV",
       subtitle = "Y = 53.63 - 0.02 * X",
       caption = "Figure 2") +
  xlab("Q3 Unemployment (X)") +
  ylab("Incumbent party PV (Y)") +
  theme_bw() 

## fit a model of Q2 RDI effects on Incumbent Party PV
lm_econrdi <- lm(pv2p ~ RDI, data = dat)
summary(lm_econrdi)

dat %>%
  ggplot(aes(x=RDI, y=pv2p,
             label=year)) + 
  geom_text(size = 2) +
  geom_smooth(method="lm", formula = y ~ x) +
  labs(title = "Q2 Real Disposable Income Effects on Incumbent Party PV",
       subtitle = "Y = 53.63 - 0.02 * X",
       caption = "Figure 3") +
  xlab("Q3 Real Disposable Income (X)") +
  ylab("Incumbent party PV (Y)") +
  theme_bw() 



