# load packages to use
library(tidyverse)
library(caret)
library(statebins)
library(usmap)
library(stargazer)
library(cowplot)

# Read in data
demo <- read_csv("data/demographic_1990-2018.csv")
pvstate <- read_csv("data/popvote_bystate_1948-2016.csv")
pollstate  <- read_csv("data/pollavg_bystate_1968-2016.csv")

# Join data to get demographics, poll, and popular vote share
pvstate$state <- state.abb[match(pvstate$state, state.name)]
pollstate$state <- state.abb[match(pollstate$state, state.name)]
demo_pv <- pvstate %>%
  full_join(pollstate %>%
              filter(weeks_left == 3) %>%
              group_by(year,party,state) %>%
              summarise(avg_poll=mean(avg_poll)),
            by = c("year", "state")) %>%
  left_join(demo %>%
              select(-c("total")),
            by = c("year", "state"))

# Add regions to datasets
demo_pv$region <- state.division[match(demo_pv$state, state.abb)]
demo$region <- state.division[match(demo$state, state.abb)]

# Calculate difference over time among demographics using lagged variables
demo_change <- demo_pv %>%
  group_by(state) %>%
  mutate(Asian_change = Asian - lag(Asian, order_by = year),
         Black_change = Black - lag(Black, order_by = year),
         Hispanic_change = Hispanic - lag(Hispanic, order_by = year),
         Indigenous_change = Indigenous - lag(Indigenous, order_by = year),
         White_change = White - lag(White, order_by = year),
         Female_change = Female - lag(Female, order_by = year),
         Male_change = Male - lag(Male, order_by = year),
         age20_change = age20 - lag(age20, order_by = year),
         age3045_change = age3045 - lag(age3045, order_by = year),
         age4565_change = age4565 - lag(age4565, order_by = year),
         age65_change = age65 - lag(age65, order_by = year))

# lm model to show demographic effects on democratic party vote share
mod_demog_change <- lm(D_pv2p ~ Black_change + Hispanic_change + Asian_change +
                       Female_change + 
                       age20_change + age3045_change + age4565_change +
                       as.factor(region), data = demo_change)
summary((mod_demog_change))

stargazer(mod_demog_change,
          title = "Historical Demographic Effects on Elections",
          header = FALSE,
          covariate.labels = c("Net Black_change", "Hispanic_change", "Asian_change", "Female_change", "age20_change", "age3045_change", "age4565_change"),
          dep.var.labels = "Democratic Vote Share",
          omit.stat = c("f", "rsq"),
          notes.align = "l",
          font.size = "tiny",
          column.sep.width = "1pt")


# 2020 Data for prediction
demo_2020 <- subset(demo, year == 2018)
demo_2020 <- as.data.frame(demo_2020)
rownames(demo_2020) <- demo_2020$state
demo_2020 <- demo_2020[state.abb, ]

# Calculate difference over time among demographics using lagged variables for 2020
demo_2020_change <- demo %>%
  filter(year %in% c(2016, 2018)) %>%
  group_by(state) %>%
  mutate(Asian_change = Asian - lag(Asian, order_by = year),
         Black_change = Black - lag(Black, order_by = year),
         Hispanic_change = Hispanic - lag(Hispanic, order_by = year),
         Indigenous_change = Indigenous - lag(Indigenous, order_by = year),
         White_change = White - lag(White, order_by = year),
         Female_change = Female - lag(Female, order_by = year),
         Male_change = Male - lag(Male, order_by = year),
         age20_change = age20 - lag(age20, order_by = year),
         age3045_change = age3045 - lag(age3045, order_by = year),
         age4565_change = age4565 - lag(age4565, order_by = year),
         age65_change = age65 - lag(age65, order_by = year)
  ) %>%
  filter(year == 2018)
demo_2020_change <- as.data.frame(demo_2020_change)
rownames(demo_2020_change) <- demo_2020_change$state
demo_2020_change <- demo_2020_change[state.abb, ]

# Model using no demographic change
demo_2020_pred <- data.frame(pred = predict(mod_demog_change, newdata = demo_2020_change),
                             state = state.abb) %>%
                             mutate(winner = ifelse(pred > 50, "Democrat", "Republican"))

# Plot for no demographic change
plot_dem <- ggplot(demo_2020_pred, aes(state = state, fill = winner)) + 
  geom_statebins() + 
  theme_statebins() +
  scale_fill_manual(values=c("#619CFF", "#F8766D")) +
  labs(title = "2020 Presidential Election Prediction Map",
       subtitle = "historical demographic effects",
       fill = "") + 
  guides(fill=FALSE)

# If 10% of African Americans voted more
black_2020_pred <- data.frame(pred = predict(mod_demog_change, newdata = demo_2020_change) +
                                                (5.6946 * .1)*demo_2020$Black,
                                                state = state.abb) %>%
  mutate(winner = ifelse(pred > 50, "Democrat", "Republican"))

# Plot if 10% of African Americans voted more
plot_black <- ggplot(black_2020_pred, aes(state = state, fill = winner)) + 
  geom_statebins() + 
  theme_statebins() +
  scale_fill_manual(values=c("#619CFF", "#F8766D")) +
  labs(title = "2020 Presidential Election Prediction Map",
       subtitle = "hypothetical black demographic surge by 10% ",
       fill = "") + 
  guides(fill=FALSE)

plot_grid(plot_dem, plot_black)
ggsave("figures/black.png", height = 7, width = 13)

# If 10% of Females voted more
female_2020_pred <- data.frame(pred = predict(mod_demog_change, newdata = demo_2020_change) +
                                (7.0143 * .01)*demo_2020$Female,
                              state = state.abb) %>%
  mutate(winner = ifelse(pred > 50, "Democrat", "Republican"))

# Plot if 10% of Females voted more
plot_female <- ggplot(female_2020_pred, aes(state = state, fill = winner)) + 
  geom_statebins() + 
  theme_statebins() +
  scale_fill_manual(values=c("#619CFF", "#F8766D")) +
  labs(title = "2020 Presidential Election Prediction Map",
       subtitle = "hypothetical female demographic surge by 1% ",
       fill = "") + 
  guides(fill=FALSE)

plot_grid(plot_dem, plot_female)
ggsave("figures/female.png", height = 7, width = 13)

# If 10% of young voters voted more
young_2020_pred <- data.frame(pred = predict(mod_demog_change, newdata = demo_2020_change) +
                                 (1.8674 * .10)*demo_2020$age20,
                               state = state.abb) %>%
  mutate(winner = ifelse(pred > 50, "Democrat", "Republican"))

# Plot if 10% of Females voted more
plot_young <- ggplot(young_2020_pred, aes(state = state, fill = winner)) + 
  geom_statebins() + 
  theme_statebins() +
  scale_fill_manual(values=c("#619CFF", "#F8766D")) +
  labs(title = "2020 Presidential Election Prediction Map",
       subtitle = "hypothetical young voters demographic surge by 10% ",
       fill = "") + 
  guides(fill=FALSE)

plot_grid(plot_dem, plot_young)
ggsave("figures/young.png", height = 7, width = 13)
