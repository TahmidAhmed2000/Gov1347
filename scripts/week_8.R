# Load packages
library(tidyverse)
library(caret)
library(statebins)
library(usmap)
library(stargazer)
library(cowplot)
library(sjPlot)
library(magrittr)
library(scales)



# Formula: Incumbent Vote Share = Poll average + GDP Q2 Growth + Approval Rating + turnoutpct_change

# regression 1: polls model: lm_polls <- lm(pv ~ polls, df) | predict_polls <- predict(lm_polls, newdata = data_2020, intervals = "prediction")
# regression 2: fundamentals model: lm_fund <- lm(pv ~ gdp_growth + approval rating + turnout, df),  predict_fund <- predict(lm_fund, newdata = data_2020, intervals = "prediction)
# ensemble: 0.8predict_polls + 0.2predict_fund
# lower bound: 0.7predict_polls[1] + 0.3predict_fund[1]
# upper bound: 0.7predict_polls[2] + 0.3predict_fund[2]

#> c(47.5, 51)
#[1] 47.5 51.0
#> c(47.5, 51)[1]
#[1] 47.5

#####################################################################################################################
set.seed(1347)
dem_states <- c("CO", "VA", "CA", "CT", "DE", "HI", "IL", "MD", "MA", "NJ", "NY", "OR", "RI", 
                "VT", "WA", "ME", "NM", "NH")
bg_states <- c("FL", "IA", "OH", "GA", "NC", "MI", "MN", "PA", "WI", 
               "NV", "AZ", "TX")
rep_states <- c("AK", "IN", "KS", "MO", "AL", "AR", "ID", "KY", "LA", "MS", "ND", "OK", "SD", "MT",
                "TN", "WV", "WY", "SC", "UT", "NE")


pvstate_r <- read_csv("data/popvote_bystate_1948-2016.csv")
poll_state_r <- read_csv("data/pollavg_bystate_1968-2016.csv")

pvstate_r$state <- state.abb[match(pvstate_r$state, state.name)]
poll_state_r$state <- state.abb[match(poll_state_r$state, state.name)]

new_poll_r <- read.csv("data/presidential_poll_averages_2020.csv") %>%
  filter(!grepl("-", state)) %>%
  filter(modeldate == "10/31/20") %>%
  filter(candidate_name == "Donald Trump") %>%
  rename(avg_pollyr = "pct_trend_adjusted") %>%
  group_by(state) 
new_poll_r$state <- state.abb[match(new_poll_r$state, state.name)]

new_poll_r <- new_poll_r %>%
  filter(state != "NA") %>%
  filter(state %in% rep_states)

# make data easier to join
pvstate2_r <- pvstate_r %>%
  select(! total)

# Historical poll support for republican less than 1 week out 
hist_poll_r <- poll_state_r %>%
  filter(party == "republican") %>%
  filter(weeks_left <= 1) %>%
  group_by(year, candidate_name, state) %>%
  mutate(avg_pollyr = mean(avg_poll)) %>%
  left_join(pvstate2_r) %>%
  filter(state %in% rep_states)


poll_glm_r <- glm(R_pv2p ~ avg_pollyr, data = hist_poll_r)
summary(poll_glm_r)

rep_poll <- data.frame(pred = predict(poll_glm_r, newdata = new_poll_r), rep_states) %>%
  rename(state = rep_states)

###########################################################

pvstate_d <- read_csv("data/popvote_bystate_1948-2016.csv")
poll_state_d <- read_csv("data/pollavg_bystate_1968-2016.csv")

pvstate_d$state <- state.abb[match(pvstate_d$state, state.name)]
poll_state_d$state <- state.abb[match(poll_state_d$state, state.name)]

new_poll_d <- read.csv("data/presidential_poll_averages_2020.csv") %>%
  filter(!grepl("-", state)) %>%
  filter(modeldate == "10/31/20") %>%
  filter(candidate_name == "Donald Trump") %>%
  rename(avg_pollyr = "pct_trend_adjusted") %>%
  group_by(state) 
new_poll_d$state <- state.abb[match(new_poll_d$state, state.name)]

new_poll_d <- new_poll_d %>%
  filter(state != "NA") %>%
  filter(state %in% dem_states)

# make data easier to join
pvstate2_d <- pvstate_d %>%
  select(! total)

# Historical poll support for republican less than 1 week out 
hist_poll_d <- poll_state_d %>%
  filter(party == "republican") %>%
  filter(weeks_left <= 1) %>%
  group_by(year, candidate_name, state) %>%
  mutate(avg_pollyr = mean(avg_poll)) %>%
  left_join(pvstate2_d) %>%
  filter(state %in% dem_states)


poll_glm_d <- glm(R_pv2p ~ avg_pollyr, data = hist_poll_d)
summary(poll_glm_d)

dem_poll <- data.frame(pred = predict(poll_glm_d, newdata = new_poll_d, interval = "prediction"), dem_states) %>%
  rename(state = dem_states)

############################################################

pvstate_bg <- read_csv("data/popvote_bystate_1948-2016.csv")
poll_state_bg <- read_csv("data/pollavg_bystate_1968-2016.csv")

pvstate_bg$state <- state.abb[match(pvstate_bg$state, state.name)]
poll_state_bg$state <- state.abb[match(poll_state_bg$state, state.name)]

new_poll_bg <- read.csv("data/presidential_poll_averages_2020.csv") %>%
  filter(!grepl("-", state)) %>%
  filter(modeldate == "10/31/20") %>%
  filter(candidate_name == "Donald Trump") %>%
  rename(avg_pollyr = "pct_trend_adjusted") %>%
  group_by(state) 
new_poll_bg$state <- state.abb[match(new_poll_bg$state, state.name)]

new_poll_bg <- new_poll_bg %>%
  filter(state != "NA") %>%
  filter(state %in% bg_states)

# make data easier to join
pvstate2_bg <- pvstate_bg %>%
  select(! total)

# Historical poll support for republican less than 1 week out 
hist_poll_bg <- poll_state_bg %>%
  filter(party == "republican") %>%
  filter(weeks_left <= 1) %>%
  group_by(year, candidate_name, state) %>%
  mutate(avg_pollyr = mean(avg_poll)) %>%
  left_join(pvstate2_bg) %>%
  filter(state %in% bg_states)


poll_glm_bg <- glm(R_pv2p ~ avg_pollyr, data = hist_poll_bg)
summary(poll_glm_bg)

bg_poll <- data.frame(pred = predict(poll_glm_bg, newdata = new_poll_bg), bg_states) %>%
  rename(state = bg_states)
 
####################
pred_poll <- rbind(rep_poll, dem_poll, bg_poll) %>%
  mutate(winner = ifelse(pred > 50, "Republican", "Democrat"))

plot_usmap(data = pred_poll, regions = "states", values = "winner") +
  scale_fill_manual(breaks = c("Democrat", "Republican"),
                    values = c(muted("blue"), "red3")) +
  theme_void() +
  labs(fill = "Projected Winner",
       title = "Forecasted Winners in Each State")

#####################################################################################################################

######## cleaning econ data ############
econhistorical_df <- read_csv("data/gdp_bystate_historical.csv",
                              col_types = cols(
                                "2006:Q1" = col_double(),
                                "2008:Q1" = col_double(),
                                "2010:Q1" = col_double(),
                                "2012:Q1" = col_double(),
                                "2013:Q1" = col_double(),
                                "2017:Q1" = col_double(),
                                "2018:Q1" = col_double()))

econhistorical_df$state <- state.abb[match(econhistorical_df$GeoName, state.name)]
econhistorical_df <- econhistorical_df %>%
  filter(Description == "All industry total (percent change)") %>%
  filter(state != "NA") 

econhistorical_df <- econhistorical_df %>%
  pivot_longer(c("2005:Q2": "2020:Q2")) %>%
  filter(grepl('Q2', name))

econhistorical_df <- econhistorical_df %>%
  separate(name, c("year", "quarter")) %>%
  rename(GDP_growth_qt = value) %>%
  select(state, year, GDP_growth_qt) %>%
  filter(year != "2020")

econhistorical_df$year <- as.double(econhistorical_df$year) 


#######################  Cleaning turnout data ########################

turnout_df <- read_csv("data/turnout_1980-2016.csv") %>% 
  mutate(turnout_pct = str_remove(turnout_pct, "%"),
         turnout_pct = as.numeric(turnout_pct),
         turnout_pct = ifelse(turnout_pct < 1, turnout_pct * 100, turnout_pct))

turnout_df$state <- state.abb[match(turnout_df$state, state.name)]

turnout_df <- turnout_df %>%
  filter(state != "NA") %>%
  mutate(turnoutpct_change = turnout_pct - lag(turnout_pct, order_by = year)) %>%
  group_by(year)

#######################  Cleaning approval data ########################
approval_df   <- read_csv("data/approval_gallup_1941-2020.csv")

approval_df <- approval_df %>%
  filter(president == "Dwight D. Eisenhower" |
           president == "Richard Nixon" |
           president == "Gerald Ford" |
           president == "Ronald Reagan" |
           president == "George H. W. Bush" |
           president == "George W. Bush") %>%
  mutate(net_app = approve - disapprove) %>%
  select(poll_enddate, president, net_app) %>%
  separate(poll_enddate, c("year", "month", "day")) %>%
  filter(month == 10) %>%
  mutate(net_approve = mean(net_app))

approval_df$year = as.double(approval_df$year)


######################## Historical Data ##########################

hist_full_data_r <- poll_state_bg %>%
  filter(party == "republican") %>%
  filter(weeks_left <= 1) %>%
  group_by(year, candidate_name, state) %>%
  mutate(avg_pollyr = mean(avg_poll)) %>%
  left_join(pvstate2_bg) %>%
  left_join(econhistorical_df) %>%
  left_join(turnout_df) %>%
  left_join(approval_df) %>%
  filter(state %in% rep_states)


econ_2020 <- read_csv("data/gdp_bystate_2020.csv") 
app_2020 <- read_csv("data/approval_bystate_2020.csv")
new_data <- read.csv("data/presidential_poll_averages_2020.csv") %>%
  filter(!grepl("-", state)) %>%
  filter(modeldate == "10/31/20") %>%
  filter(candidate_name == "Donald Trump") %>%
  rename(avg_pollyr = "pct_trend_adjusted") 

new_data$state <- state.abb[match(new_data$state, state.name)] 
list1 <- 1:52
list2 <- rep(18,length(list1))
new_data$turnoutpct_change <- list2


new_data_r <- new_data %>%
  filter(state != "NA") %>%
  group_by(state) %>%
  filter(state %in% rep_states) %>%
  left_join(econ_2020)%>%
  left_join(app_2020, by ="state") %>%
  mutate(net_app = approve - disapprove)



fund_glm_r <- glm(R_pv2p ~ GDP_growth_qt + turnoutpct_change + net_app, data = hist_full_data_r)
summary(fund_glm_r) 

fund_pred_r <- data.frame(pred = predict(fund_glm_r, newdata = new_data_r), rep_states) %>%
  mutate(winner = ifelse(pred > 50, "Republican", "Democrat")) %>%
  rename(state = rep_states)

hist_full_data_d <- poll_state_bg %>%
  filter(party == "republican") %>%
  filter(weeks_left <= 1) %>%
  group_by(year, candidate_name, state) %>%
  mutate(avg_pollyr = mean(avg_poll)) %>%
  left_join(pvstate2_bg) %>%
  left_join(econhistorical_df) %>%
  left_join(turnout_df) %>%
  left_join(approval_df) %>%
  filter(state %in% dem_states)

new_data_d <- new_data %>%
  filter(state != "NA") %>%
  group_by(state) %>%
  filter(state %in% dem_states) %>%
  left_join(econ_2020) %>%
  left_join(app_2020, by ="state") %>%
  mutate(net_app = approve - disapprove)

fund_glm_d <- glm(R_pv2p ~ GDP_growth_qt + turnoutpct_change, data = hist_full_data_d)
summary(fund_glm_d)

fund_pred_d <- data.frame(pred = predict(fund_glm_d, newdata = new_data_d), dem_states) %>%
  mutate(winner = ifelse(pred > 50, "Republican", "Democrat")) %>%
  rename(state = dem_states)

hist_full_data_bg <- poll_state_bg %>%
  filter(party == "republican") %>%
  filter(weeks_left <= 1) %>%
  group_by(year, candidate_name, state) %>%
  mutate(avg_pollyr = mean(avg_poll)) %>%
  left_join(pvstate2_bg) %>%
  left_join(econhistorical_df) %>%
  left_join(turnout_df) %>%
  left_join(approval_df) %>%
  filter(state %in% bg_states)

new_data_bg <- new_data %>%
  filter(state != "NA") %>%
  group_by(state) %>%
  filter(state %in% bg_states) %>%
  left_join(econ_2020) %>%
  left_join(app_2020, by ="state") %>%
  mutate(net_app = approve - disapprove)

fund_glm_bg <- glm(R_pv2p ~ GDP_growth_qt + turnoutpct_change, data = hist_full_data_bg)
summary(fund_glm_bg)

fund_pred_bg <- data.frame(pred = predict(fund_glm_bg, newdata = new_data_bg), bg_states) %>%
  mutate(winner = ifelse(pred > 50, "Republican", "Democrat")) %>%
  rename(state = bg_states)

pred_fund <- rbind(fund_pred_r, fund_pred_d, fund_pred_bg)

plot_usmap(data = pred_fund, regions = "states", values = "winner") +
  scale_fill_manual(breaks = c("Democrat", "Republican"),
                    values = c(muted("blue"), "red3")) +
  theme_void() +
  labs(fill = "Projected Winner",
       title = "Forecasted Winners in Each State")


########################################## Ensemble Model ###########################

pred_ensemble <- pred_poll %>%
  left_join(pred_fund, by = "state") %>%
  mutate(pred = 0.99*pred.x + 0.01*pred.y) %>%
  mutate(winner = ifelse(pred > 50, "Republican", "Democrat"))
  
plot_usmap(data = pred_ensemble, regions = "states", values = "winner") +
  scale_fill_manual(breaks = c("Democrat", "Republican"),
                    values = c(muted("blue"), "red3")) +
  theme_void() +
  labs(fill = "Projected Winner",
       title = "Forecasted Winners in Each State")




#########################3
predict(fund_glm_r, new_data_r, se.fit = TRUE, interval = "prediction", level = 0.90)
predict(poll_glm_r, new_poll_r, se.fit = TRUE, interval = "prediction", level = 0.90)


predict(fund_glm_r, new_data_r, interval = "prediction", level = 0.95, se.fit = TRUE) 
predict(poll_glm_r, new_poll_r, interval = "prediction", level = 0.95, se.fit = TRUE)
  
predict(fund_glm_r, new_data_r, interval = "prediction", level = 0.95, type = "link", se.fit = TRUE)



pred_ensemble$lwr[pred_ensemble$state == s] <- CI_prediction_fit - (1.96 * CI_prediction_se)
pred_ensemble$uppr[pred_ensemble$state == s] <- CI_prediction_fit + (1.96 * CI_prediction_se)


pred_fund[2]

as.matrix(as.data.frame(pred = predict(fund_glm_r, new_data_r, interval = "prediction", level = 0.95, se.fit = TRUE), rep_states))

mat <- as.matrix(as.data.frame(predict(fund_glm_r, new_data_r, interval = "prediction", level = 0.95, se.fit = TRUE)))

