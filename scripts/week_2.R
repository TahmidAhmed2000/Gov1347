
## install via `install.packages("name")`
library(tidyverse)
library(ggplot2)
library(janitor)

####----------------------------------------------------------#
#### The relationship between economy and PV ####
####----------------------------------------------------------#

## Load data
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

## Plot inflation graph
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

## histogram with inflation
hist(outsamp_errorsinf,
     xlab = "Figure 2",
     main = "mean out-of-sample residual with inflation\n(1000 runs of cross-validation)")

## Prediction for 2020 (inflation)
Inflation_new <- economy_df %>%
  subset(year == 2020 & quarter == 2) %>%
  select(inflation)
predict(lm_econinf, Inflation_new, interval="prediction")


## fit a model of Q2 Unemployment effects on Incumbent Party PV
lm_econune <- lm(pv2p ~ unemployment, data = dat)
summary(lm_econune)
cor(dat$unemployment, dat$pv2p)

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

## histogram with unemployment 
hist(outsamp_errorsune,
     xlab = "Figure 4",
     main = "mean out-of-sample residual with unemployment\n(1000 runs of cross-validation)")

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
       subtitle = "Y = 51.88 - 0.02 * X",
       caption = "Figure 3") +
  xlab("Q2 Unemployment (X)") +
  ylab("Incumbent party PV (Y)") +
  theme_bw() 

ggsave("figures/voteshare&unemployment.png", height = 4, width = 8)


## fit a model of Q2 RDI effects on Incumbent Party PV
lm_econrdi <- lm(pv2p ~ RDI, data = dat)
summary(lm_econrdi)
data_rdi <- dat %>% slice(4:18)
cor(data_rdi$RDI, data_rdi$pv2p)

## plot RDI graph
dat %>%
  ggplot(aes(x=RDI, y=pv2p,
             label=year)) + 
  geom_text(size = 2) +
  geom_smooth(method="lm", formula = y ~ x) +
  labs(title = "Q2 Real Disposable Income Effects on Incumbent Party PV",
       subtitle = "Y = 54.94 - 0.0004 * X",
       caption = "Figure 5") +
  xlab("Q2 Real Disposable Income (X)") +
  ylab("Incumbent party PV (Y)") +
  theme_bw() 

ggsave("figures/voteshare&rdi.png", height = 4, width = 8)

### Out of Sample Validation with RDI
## model testing: leave-one-out
outsamp_modrdi  <- lm(pv2p ~ RDI, dat[dat$year != 2016,])
outsamp_predrdi <- predict(outsamp_modrdi, dat[dat$year == 2016,])
outsamp_truerdi <- dat$pv2p[dat$year == 2016] 

## model testing: cross-validation (one run)
years_outsamprdi <- sample(dat$year, 8)
modrdi <- lm(pv2p ~ unemployment,
             dat[!(dat$year %in% years_outsamprdi),])

outsamp_predrdi <- predict(modrdi,
                           newdata = dat[dat$year %in% years_outsamprdi,])

mean(outsamp_predrdi - dat$pv2p[dat$year %in% years_outsamprdi])

## model testing: cross-validation (1000 runs) RDI
outsamp_errorsrdi <- sapply(1:1000, function(i){
  years_outsamprdi <- sample(dat$year, 8)
  outsamp_modrdi <- lm(pv2p ~ unemployment,
                       dat[!(dat$year %in% years_outsamprdi),])
  outsamp_predrdi <- predict(outsamp_modrdi,
                             newdata = dat[dat$year %in% years_outsamprdi,])
  outsamp_truerdi <- dat$pv2p[dat$year %in% years_outsamprdi]
  mean(outsamp_predrdi - outsamp_truerdi)
})

mean(abs(outsamp_errorsrdi))

## histogram with RDI 
hist(outsamp_errorsrdi,
     xlab = "Figure 6",
     main = "mean out-of-sample residual with RDI\n(1000 runs of cross-validation)")

## Prediction for 2020 (unemployment)
RDI_new <- economy_df %>%
  subset(year == 2020 & quarter == 2) %>%
  select(RDI)
predict(lm_econrdi, RDI_new, interval="prediction")


