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
library(performance)
library(gt)

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

####################################################################
set.seed(1347)
# Define groups of states
dem_states <- c("CO", "VA", "CA", "CT", "DE", "HI", "IL", "MD", "MA", "NJ", "NY", "OR", "RI", 
                "VT", "WA", "ME", "NM", "NH")
bg_states <- c("FL", "IA", "OH", "GA", "NC", "MI", "MN", "PA", "WI", 
               "NV", "AZ", "TX")
rep_states <- c("AK", "IN", "KS", "MO", "AL", "AR", "ID", "KY", "LA", "MS", "ND", "OK", "SD", "MT",
                "TN", "WV", "WY", "SC", "UT", "NE")

# Read popular vote and state poll data
pvstate_r <- read_csv("data/popvote_bystate_1948-2016.csv")
poll_state_r <- read_csv("data/pollavg_bystate_1968-2016.csv")

pvstate_r$state <- state.abb[match(pvstate_r$state, state.name)]
poll_state_r$state <- state.abb[match(poll_state_r$state, state.name)]

# create new data 
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

# use data to join later
pvstate2_r <- pvstate_r %>%
  select(! total)

# Historical poll support for republican less than 1 week out in republican states
hist_poll_r <- poll_state_r %>%
  filter(party == "republican") %>%
  filter(weeks_left <= 1) %>%
  group_by(year, candidate_name, state) %>%
  mutate(avg_pollyr = mean(avg_poll)) %>%
  left_join(pvstate2_r) %>%
  filter(state %in% rep_states)

# Run linear model
poll_lm_r <- lm(R_pv2p ~ avg_pollyr, data = hist_poll_r)
summary(poll_lm_r)

# Get red state predicitons
rep_poll <- data.frame(pred = predict(poll_lm_r, newdata = new_poll_r, interval="prediction"), rep_states) %>%
  rename(state = rep_states)

####################################################################
# Did the same thing for democratic states as I realized it is easier if I do everything the same again. It's also more organized for me. 
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

pvstate2_d <- pvstate_d %>%
  select(! total)

hist_poll_d <- poll_state_d %>%
  filter(party == "republican") %>%
  filter(weeks_left <= 1) %>%
  group_by(year, candidate_name, state) %>%
  mutate(avg_pollyr = mean(avg_poll)) %>%
  left_join(pvstate2_d) %>%
  filter(state %in% dem_states)

poll_lm_d <- lm(R_pv2p ~ avg_pollyr, data = hist_poll_d)
summary(poll_lm_d)

dem_poll <- data.frame(pred = predict(poll_lm_d, newdata = new_poll_d, interval = "prediction"), dem_states) %>%
  rename(state = dem_states)

####################################################################
# Repeat for battleground states

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

pvstate2_bg <- pvstate_bg %>%
  select(! total)

hist_poll_bg <- poll_state_bg %>%
  filter(party == "republican") %>%
  filter(weeks_left <= 1) %>%
  group_by(year, candidate_name, state) %>%
  mutate(avg_pollyr = mean(avg_poll)) %>%
  left_join(pvstate2_bg) %>%
  filter(state %in% bg_states)

poll_lm_bg <- lm(R_pv2p ~ avg_pollyr, data = hist_poll_bg)
summary(poll_lm_bg)

bg_poll <- data.frame(pred = predict(poll_lm_bg, newdata = new_poll_bg, interval = "prediction"), bg_states) %>%
  rename(state = bg_states)
 
####################################################################
# Combine predictions for all states from poll models
pred_poll <- rbind(rep_poll, dem_poll, bg_poll) %>%
  mutate(winner = ifelse(pred.fit > 50, "Republican", "Democrat"))

# Plot map of predictions using poll model
plot_usmap(data = pred_poll, regions = "states", values = "winner") +
  scale_fill_manual(breaks = c("Democrat", "Republican"),
                    values = c(muted("blue"), "red3")) +
  theme_void() +
  labs(fill = "Political Party",
       title = "2020 Presidential Election Prediction Map using Poll Model")

ggsave("figures/poll_final.png")

####################################################################
# cleaning historical economic data
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

# Pivot to get only Quarter 2 data
econhistorical_df <- econhistorical_df %>%
  pivot_longer(c("2005:Q2": "2020:Q2")) %>%
  filter(grepl('Q2', name))

# Cleaned data frame
econhistorical_df <- econhistorical_df %>%
  separate(name, c("year", "quarter")) %>%
  rename(GDP_growth_qt = value) %>%
  select(state, year, GDP_growth_qt) %>%
  filter(year != "2020")

econhistorical_df$year <- as.double(econhistorical_df$year) 


####################################################################
# Cleaning turnout data
turnout_df <- read_csv("data/turnout_1980-2016.csv") %>% 
  mutate(turnout_pct = str_remove(turnout_pct, "%"),
         turnout_pct = as.numeric(turnout_pct),
         turnout_pct = ifelse(turnout_pct < 1, turnout_pct * 100, turnout_pct))

turnout_df$state <- state.abb[match(turnout_df$state, state.name)]

# Get percent change from turnout
turnout_df <- turnout_df %>%
  filter(state != "NA") %>%
  mutate(turnoutpct_change = turnout_pct - lag(turnout_pct, order_by = year)) %>%
  group_by(year)

####################################################################
# Cleaning approval data
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

####################################################################
# Join historical fundamental data to get full historical data
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

####################################################################
# Joining 2020 data to get new data
econ_2020 <- read_csv("data/gdp_bystate_2020.csv") 
app_2020 <- read_csv("data/approval_bystate_2020.csv")
new_data <- read.csv("data/presidential_poll_averages_2020.csv") %>%
  filter(!grepl("-", state)) %>%
  filter(modeldate == "10/31/20") %>%
  filter(candidate_name == "Donald Trump") %>%
  rename(avg_pollyr = "pct_trend_adjusted") 

# Added my own turnout percent change for 2020
new_data$state <- state.abb[match(new_data$state, state.name)] 
list1 <- 1:52
list2 <- rep(18,length(list1))
new_data$turnoutpct_change <- list2

####################################################################
# Clean 2020 data for republican fundamental model
new_data_r <- new_data %>%
  filter(state != "NA") %>%
  group_by(state) %>%
  filter(state %in% rep_states) %>%
  left_join(econ_2020)%>%
  left_join(app_2020, by ="state") %>%
  mutate(net_app = approve - disapprove)

# Run republican fundamental model
fund_lm_r <- lm(R_pv2p ~ GDP_growth_qt + turnoutpct_change + net_app, data = hist_full_data_r)
summary(fund_lm_r) 

fund_pred_r <- data.frame(pred = predict(fund_lm_r, newdata = new_data_r, interval = "prediction"), rep_states) %>%
  rename(state = rep_states)


####################################################################
# Repeat for democratic fundamental model
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

fund_lm_d <- lm(R_pv2p ~ GDP_growth_qt + turnoutpct_change, data = hist_full_data_d)
summary(fund_lm_d)

fund_pred_d <- data.frame(pred = predict(fund_lm_d, newdata = new_data_d, interval = "prediction"), dem_states) %>%
  rename(state = dem_states)

####################################################################
# Repeat for battleground states fundamental model
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

fund_lm_bg <- lm(R_pv2p ~ GDP_growth_qt + turnoutpct_change, data = hist_full_data_bg)
summary(fund_lm_bg)

fund_pred_bg <- data.frame(pred = predict(fund_lm_bg, newdata = new_data_bg, interval = "prediction"), bg_states) %>%
  rename(state = bg_states)

####################################################################
# Combine fundamental models for all states
pred_fund <- rbind(fund_pred_r, fund_pred_d, fund_pred_bg) %>%
  mutate(winner = ifelse(pred.fit > 50, "Republican", "Democrat"))

# Plot predictions from fundamental model
plot_usmap(data = pred_fund, regions = "states", values = "winner") +
  scale_fill_manual(breaks = c("Democrat", "Republican"),
                    values = c(muted("blue"), "red3")) +
  theme_void() +
  labs(fill = "Poltical Party",
       title = "2020 Presidential Election Prediction Map using Fundamental Model")

ggsave("figures/fundamental_final.png")

####################################################################
# Create ensemble model using weights
pred_ensemble <- pred_poll %>%
  left_join(pred_fund, by = "state") %>%
  mutate(pred = .96*pred.fit.x + .04*pred.fit.y) %>%
  mutate(pred.lwr = .96*pred.lwr.x + 0.04*pred.lwr.y) %>%
  mutate(pred.upr = .96*pred.upr.x + 0.04*pred.upr.y) %>%
  mutate(winner = ifelse(pred > 50, "Republican", "Democrat")) %>%
  select(pred, pred.lwr, pred.upr, winner, state)

# Save data to csv file
write_csv(pred_ensemble, "data/pred_ensemble.csv")

# Plot results of ensemble model
plot_usmap(data = pred_ensemble, regions = "states", values = "winner") +
  scale_fill_manual(breaks = c("Democrat", "Republican"),
                    values = c(muted("blue"), "red3")) +
  theme_void() +
  labs(fill = "Political Party",
       title = "2020 Presidential Election Prediction Map using Ensemble Model",
       subtitle = "Weighting = 0.96*Poll + 0.04*Fundamental")

ggsave("figures/ensemble_final.png")


####################################################################
# Visualize confidence intervals of final prediction
ggplot(pred_ensemble, aes(x = pred, y = state, color = winner)) + 
  geom_point() + 
  scale_color_manual(values = c("blue", "red"), name = "", 
                     labels = c("Democratic", "Republican")) + 
  geom_errorbar(aes(xmin = pred.lwr, xmax = pred.upr)) +
  # scale_color_gradient(low = "blue", high = "red") + 
  theme_minimal_grid() + 
  theme(axis.text.y = element_text(size = 7),
        legend.position = "none") + 
  ylab("") + 
  xlab("Predicted Trump Vote Share %") + 
  geom_vline(xintercept = 50, lty = 2) +
  labs(title = "2020 Election 95% Prediction Intervals",
       subtitle = "Weighting: 0.96 * Polls + 0.04 * Fundamental")

ggsave("figures/predictability_final.png")


####################################################################

# Validation for Red state models
summary(poll_lm_r) #0.42
rmse(poll_lm_r) #5.29

summary(fund_lm_r) #0.005
rmse(fund_lm_r) #5.35

# Validation for Blue State Model
summary(poll_lm_d) #0.51
rmse(poll_lm_d) #4.48

summary(fund_lm_d) #0.18
rmse(fund_lm_d) # 4.24

# Validation for BG State Model
summary(poll_lm_bg) #0.46
rmse(poll_lm_bg) #2.73

summary(fund_lm_bg) #0.03
rmse(fund_lm_bg) # 3.67

# red state tibble
validate_r <- tribble(
  ~"Type of model", ~"R Square",  ~"RMSE",
  "Poll", 0.42,  5.29,
  "Fundamental", 0.005,  5.35,
)
 
validate_r <- validate_r %>%
   gt() %>%
   tab_header(
     title = "In-Sample Validation for Red States",
     )
validate_r


# blue state tibble
validate_d <- tribble(
  ~"Type of model", ~"R Square",  ~"RMSE",
  "Poll", 0.51,  4.48,
  "Fundamental", 0.18,  4.24,
)

# red state tibble
validate_d <- validate_d %>%
  gt() %>%
  tab_header(
    title = "In-Sample Validation for Blue States",
  )
validate_d


# battleground state tibble
validate_bg <- tribble(
  ~"Type of model", ~"R Square",  ~"RMSE",
  "Poll", 0.46,  2.73,
  "Fundamental", 0.03,  3.67,
)

validate_bg <- validate_bg %>%
  gt() %>%
  tab_header(
    title = "In-Sample Validation for Battleground States",
  )
validate_bg

set.seed(1347)
####################################################################
# Out-of-sample validation for democratic poll model

## model testing: leave-one-out
outsamp_modrdi  <- lm(R_pv2p ~ avg_pollyr, hist_poll_d[hist_poll_d$year != 2016,])
outsamp_predrdi <- predict(outsamp_modrdi, hist_poll_d[hist_poll_d$year == 2016,])
outsamp_truerdi <- hist_poll_d$R_pv2p[hist_poll_d$year == 2016] 
mean(outsamp_predrdi - outsamp_truerdi)

## model testing: cross-validation (one run)
years_outsamprdi <- sample(hist_poll_d$year, 8)
modrdi <- lm(R_pv2p ~ avg_pollyr,
             hist_poll_d[!(hist_poll_d$year %in% years_outsamprdi),])

outsamp_predrdi <- predict(modrdi,
                           newdata = hist_poll_d[hist_poll_d$year %in% years_outsamprdi,])

mean(outsamp_predrdi - hist_poll_d$R_pv2p[hist_poll_d$year %in% years_outsamprdi])

## model testing: cross-validation (1000 runs) 
outsamp_errorsrdi <- sapply(1:1000, function(i){
  years_outsamprdi <- sample(hist_poll_d$year, 8)
  outsamp_modrdi <- lm(R_pv2p ~ avg_pollyr,
                       hist_poll_d[!(hist_poll_d$year %in% years_outsamprdi),])
  outsamp_predrdi <- predict(outsamp_modrdi,
                             newdata = hist_poll_d[hist_poll_d$year %in% years_outsamprdi,])
  outsamp_truerdi <- hist_poll_d$R_pv2p[hist_poll_d$year %in% years_outsamprdi]
  mean(outsamp_predrdi - outsamp_truerdi)
})

mean(abs(outsamp_errorsrdi))

## histogram 
hist(outsamp_errorsrdi,
     xlab = "Figure 6",
     main = "mean out-of-sample residual\n(1000 runs of cross-validation)")


####################################################################
### Out of Sample Validation with Republican poll model

## model testing: leave-one-out
outsamp_modune  <- lm(R_pv2p ~ avg_pollyr, hist_poll_r[hist_poll_r$year != 2016,])
outsamp_predune <- predict(outsamp_modune, hist_poll_r[hist_poll_r$year == 2016,])
outsamp_trueune <- hist_poll_r$R_pv2p[hist_poll_r$year == 2016] 
mean(outsamp_predune - outsamp_trueune)

## model testing: cross-validation (one run)
years_outsampune <- sample(hist_poll_r$year, 8)
modune <- lm(R_pv2p ~ avg_pollyr,
             hist_poll_r[!(hist_poll_r$year %in% years_outsampune),])

outsamp_predune <- predict(modune,
                           newdata = hist_poll_r[hist_poll_r$year %in% years_outsampune,])

mean(outsamp_predune - hist_poll_r$R_pv2p[hist_poll_r$year %in% years_outsampune])

## model testing: cross-validation (1000 runs) 
outsamp_errorsune <- sapply(1:1000, function(i){
  years_outsampune <- sample(hist_poll_r$year, 8)
  outsamp_modune <- lm(R_pv2p ~ avg_pollyr,
                       hist_poll_r[!(hist_poll_r$year %in% years_outsampune),])
  outsamp_predune <- predict(outsamp_modune,
                             newdata = hist_poll_r[hist_poll_r$year %in% years_outsampune,])
  outsamp_trueune <- hist_poll_r$R_pv2p[hist_poll_r$year %in% years_outsampune]
  mean(outsamp_predune - outsamp_trueune)
})

mean(abs(outsamp_errorsune))

## histogram  
hist(outsamp_errorsune,
     xlab = "Figure 4",
     main = "mean out-of-sample residual\n(1000 runs of cross-validation)")

####################################################################
### Out of Sample Validation with Battleground poll model

## model testing: leave-one-out
outsamp_modinf  <- lm(R_pv2p ~ avg_pollyr, hist_poll_bg[hist_poll_bg$year != 2016,])
outsamp_predinf <- predict(outsamp_modinf, hist_poll_bg[hist_poll_bg$year == 2016,])
outsamp_trueinf <- hist_poll_bg$R_pv2p[hist_poll_bg$year == 2016] 
mean(outsamp_predinf - outsamp_trueinf)

## model testing: cross-validation (one run)
years_outsampinf <- sample(hist_poll_bg$year, 8)
modinf <- lm(R_pv2p ~ avg_pollyr,
             hist_poll_bg[!(hist_poll_bg$year %in% years_outsampinf),])

outsamp_predinf <- predict(modinf,
                           newdata = hist_poll_bg[hist_poll_bg$year %in% years_outsampinf,])

mean(outsamp_predinf - hist_poll_bg$R_pv2p[hist_poll_bg$year %in% years_outsampinf])

## model testing: cross-validation (1000 runs) 
outsamp_errorsinf <- sapply(1:1000, function(i){
  years_outsampinf <- sample(hist_poll_bg$year, 8)
  outsamp_modinf <- lm(R_pv2p ~ avg_pollyr,
                       hist_poll_bg[!(hist_poll_bg$year %in% years_outsampinf),])
  outsamp_predinf <- predict(outsamp_modinf,
                             newdata = hist_poll_bg[hist_poll_bg$year %in% years_outsampinf,])
  outsamp_trueinf <- hist_poll_bg$R_pv2p[hist_poll_bg$year %in% years_outsampinf]
  mean(outsamp_predinf - outsamp_trueinf)
})

mean(abs(outsamp_errorsinf))

## histogram 
hist(outsamp_errorsinf,
     xlab = "Figure 2",
     main = "mean out-of-sample residual\n(1000 runs of cross-validation)")


####################################################################
# Out-of-sample validation for Democratic fundamental model

## model testing: leave-one-out
outsamp_modrdi1  <- lm(R_pv2p ~ GDP_growth_qt + turnoutpct_change + net_app, hist_full_data_d[hist_full_data_d$year != "2016",])
outsamp_predrdi1 <- predict(outsamp_modrdi1, hist_full_data_d[hist_full_data_d$year == 2016,])
outsamp_truerdi1 <- hist_full_data_d$R_pv2p[hist_full_data_d$year == 2016] 

## model testing: cross-validation (one run)
years_outsamprdi1 <- sample(hist_full_data_d$year, 8)
modrdi1 <- lm(R_pv2p ~ avg_pollyr,
             hist_full_data_d[!(hist_full_data_d$year %in% years_outsamprdi1),])

outsamp_predrdi1 <- predict(modrdi1,
                           newdata = hist_full_data_d[hist_full_data_d$year %in% years_outsamprdi1,])

mean(outsamp_predrdi1 - hist_full_data_d$R_pv2p[hist_full_data_d$year %in% years_outsamprdi1])

## model testing: cross-validation (1000 runs) 
outsamp_errorsrdi1 <- sapply(1:1000, function(i){
  years_outsamprdi1 <- sample(hist_full_data_d$year, 8)
  outsamp_modrdi1 <- lm(R_pv2p ~ avg_pollyr,
                       hist_full_data_d[!(hist_full_data_d$year %in% years_outsamprdi1),])
  outsamp_predrdi1 <- predict(outsamp_modrdi1,
                             newdata = hist_full_data_d[hist_full_data_d$year %in% years_outsamprdi1,])
  outsamp_truerdi1 <- hist_full_data_d$R_pv2p[hist_full_data_d$year %in% years_outsamprdi1]
  mean(outsamp_predrdi1 - outsamp_truerdi1)
})

mean(abs(outsamp_errorsrdi1))

## histogram  
hist(outsamp_errorsrdi1,
     xlab = "Figure 6",
     main = "mean out-of-sample residual\n(1000 runs of cross-validation)")



####################################################################
### Out of Sample Validation with Republican fundamental model

## model testing: leave-one-out
outsamp_modune1  <- lm(R_pv2p ~ GDP_growth_qt + turnoutpct_change + net_app, hist_full_data_r[hist_full_data_r$year != 2016,])
outsamp_predune1 <- predict(outsamp_modune1, hist_full_data_r[hist_full_data_r$year == 2016,])
outsamp_trueune1 <- hist_full_data_r$R_pv2p[hist_full_data_r$year == 2016] 

## model testing: cross-validation (one run)
years_outsampune1 <- sample(hist_full_data_r$year, 8)
modune1 <- lm(R_pv2p ~ avg_pollyr,
             hist_full_data_r[!(hist_full_data_r$year %in% years_outsampune1),])

outsamp_predune1 <- predict(modune1,
                           newdata = hist_full_data_r[hist_full_data_r$year %in% years_outsampune1,])

mean(outsamp_predune1 - hist_full_data_r$R_pv2p[hist_full_data_r$year %in% years_outsampune1])

## model testing: cross-validation (1000 runs) 
outsamp_errorsune1 <- sapply(1:1000, function(i){
  years_outsampune1 <- sample(hist_full_data_r$year, 8)
  outsamp_modune1 <- lm(R_pv2p ~ avg_pollyr,
                       hist_full_data_r[!(hist_full_data_r$year %in% years_outsampune1),])
  outsamp_predune1 <- predict(outsamp_modune1,
                             newdata = hist_full_data_r[hist_full_data_r$year %in% years_outsampune1,])
  outsamp_trueune1 <- hist_full_data_r$R_pv2p[hist_full_data_r$year %in% years_outsampune1]
  mean(outsamp_predune1 - outsamp_trueune1)
})

mean(abs(outsamp_errorsune1))

## histogram  
hist(outsamp_errorsune1,
     xlab = "Figure 4",
     main = "mean out-of-sample residual\n(1000 runs of cross-validation)")

####################################################################
### Out of Sample Validation with Battleground fundamental model

## model testing: leave-one-out
outsamp_modinf1  <- lm(R_pv2p ~ GDP_growth_qt + turnoutpct_change + net_app, hist_full_data_bg[hist_full_data_bg$year != 2016,])
outsamp_predinf1 <- predict(outsamp_modinf1, hist_full_data_bg[hist_full_data_bg$year == 2016,])
outsamp_trueinf1 <- hist_full_data_bg$R_pv2p[hist_full_data_bg$year == 2016] 

## model testing: cross-validation (one run)
years_outsampinf1 <- sample(hist_full_data_bg$year, 8)
modinf1 <- lm(R_pv2p ~ avg_pollyr,
             hist_full_data_bg[!(hist_full_data_bg$year %in% years_outsampinf1),])

outsamp_predinf1 <- predict(modinf1,
                           newdata = hist_full_data_bg[hist_full_data_bg$year %in% years_outsampinf1,])

mean(outsamp_predinf1 - hist_full_data_bg$R_pv2p[hist_full_data_bg$year %in% years_outsampinf1])

## model testing: cross-validation (1000 runs) 
outsamp_errorsinf1 <- sapply(1:1000, function(i){
  years_outsampinf1 <- sample(hist_full_data_bg$year, 8)
  outsamp_modinf1 <- lm(R_pv2p ~ avg_pollyr,
                       hist_full_data_bg[!(hist_full_data_bg$year %in% years_outsampinf1),])
  outsamp_predinf1 <- predict(outsamp_modinf1,
                             newdata = hist_full_data_bg[hist_full_data_bg$year %in% years_outsampinf1,])
  outsamp_trueinf1 <- hist_full_data_bg$R_pv2p[hist_full_data_bg$year %in% years_outsampinf1]
  mean(outsamp_predinf1 - outsamp_trueinf1)
})

mean(abs(outsamp_errorsinf1))

## histogram
hist(outsamp_errorsinf1,
     xlab = "Figure 2",
     main = "mean out-of-sample residual\n(1000 runs of cross-validation)")




# Tibble for Out-of-Sample Validation
outsample <- tribble(
  ~"Type of state", ~"Poll Model",  ~"Fundamental Model", ~"Ensemble Model",
  "Blue", 1.884846,  1.698765, 1.877403,
  "Red", 4.111622,  1.612673, 4.011664,
  "BG", 1.623447, 1.566087, 1.621153
)
outsample

outsample <- outsample %>%
  gt() %>%
  tab_header(
    title = "Predictive Error of Cross-Validation",
  )
outsample










