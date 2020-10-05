## download packages
library(tidyverse)
library(ggplot2)
library(stargazer)

#read data sets
popvote_df    <- read_csv("data/popvote_1948-2016.csv")
economy_df    <- read_csv("data/econ.csv")
approval_df   <- read_csv("data/approval_gallup_1941-2020.csv")
poll_df       <- read_csv("data/pollavg_1968-2016.csv")

### Trump's Approval Ratings Trends
approval_Trump <- approval_df %>%
  filter(president == "Donald Trump")

approval_Trump %>%
  ggplot(aes(poll_enddate, approve)) + geom_line() +
  labs(title = "Trump's Approval Ratings Over the Years",
       x = "Year",
       y = "Approval Rating",
       caption = "Source: Gallup") +
  theme_classic()

ggsave("figures/Trumpapproval.png")



####################### Prediction Model ########################

# The pm data set consists of second-quarter GDP, unemployment, approval
# ratings, polling approval ratings, incumbency status and popular vote data
# sets filtered for only incumbent party candidates
pm_df <- popvote_df %>%
  filter(incumbent_party) %>%
  select(year, candidate, party, pv, pv2p, incumbent) %>%
  left_join(
    approval_df %>% 
      group_by(year, president) %>% 
      slice(1) %>% 
      mutate(net_approve=approve-disapprove) %>%
      select(year, incumbent_pres=president, net_approve, poll_enddate),
    by="year"
  ) %>%
  left_join(
    economy_df %>%
      filter(quarter == 2) %>%
      select(GDP_growth_qt, year),
    by="year"
  ) %>%
  left_join(poll_df %>% 
            filter(weeks_left == 6) %>% 
            group_by(year,party)) 

# pm model 
pm_model <- lm(pv2p ~ net_approve + GDP_growth_qt + avg_support + incumbent, data = pm_df)
summary(pm_model)

stargazer(pm_model,
          title = "2020 Election Prediction Model",
          header = FALSE,
          covariate.labels = c("Net Approval", "GDP Growth Rate", "Average Support (Polls)", "Incumbent Party"),
          dep.var.labels = "Two-Party Vote Share",
          omit.stat = c("f", "rsq"),
          notes.align = "l",
          font.size = "tiny",
          column.sep.width = "1pt")

###### In-Sample Fit

#r-squared value: 0.843
summary(pm_model)$r.squared

# the mean squared error: 1.415
mse <- mean((pm_model$fitted.values - pm_model$model$pv2p)^2)
sqrt(mse)

###### Out-Of-Sample Error

#leaving one out validation: -2.561
outsamp_mod  <- lm(pv2p ~ net_approve + GDP_growth_qt + avg_support + incumbent,
                   pm_df[pm_df$year != 2016,])
outsamp_pred <- predict(outsamp_mod, pm_df[pm_df$year == 2016,])
outsamp_true <- pm_df$pv2p[pm_df$year == 2016] 
outsamp_pred - outsamp_true


#cross validation: 2.803
outsamp_errors <- sapply(1:1000, function(i){
  years_outsamp <- sample(pm_df$year, 8)
  outsamp_mod <- lm(pv2p ~ net_approve + GDP_growth_qt + avg_support + incumbent,
                    pm_df[!(pm_df$year %in% years_outsamp),])
  outsamp_pred <- predict(outsamp_mod,
                          newdata = pm_df[pm_df$year %in% years_outsamp,])
  outsamp_true <- pm_df$pv2p[pm_df$year %in% years_outsamp]
  mean(outsamp_pred - outsamp_true)
})

#mean out of sample error
mean(abs(outsamp_errors), na.rm = T)

######################### Model Predictions ##########################

#2020 second quarter GDP data
GDP_SecondQuarter_2020 <- economy_df %>%
  subset(year == 2020 & quarter == 2) %>%
  select(GDP_growth_qt)

#2020 Best Polls looking at Q2 and Q3
url_poll_2020 = "https://raw.githubusercontent.com/cassidybargell/election_analytics/gh-pages/data/polls_2020.csv"
poll_2020 <- read_csv(url(url_poll_2020))
poll_2020_mean <- poll_2020 %>%
  filter(fte_grade == "A+", candidate_name == "Donald Trump") %>%
  slice(-(77:216)) %>%
  summarize(avg_support = mean(pct))

#most recent approval ratings in 2020
net_approval_2020 = 41-56

#data set for 2020
dat_2020 <- data.frame(net_approve = net_approval_2020, 
                       GDP_growth_qt = GDP_SecondQuarter_2020,
                       avg_support = poll_2020_mean,
                       incumbent = TRUE)

# pm model 2020 prediction for Trump: 49.789
prediction_2020 = predict(pm_model, newdata = dat_2020)
prediction_2020

#prediction interval
predict(pm_model, newdata = dat_2020, interval="prediction")






