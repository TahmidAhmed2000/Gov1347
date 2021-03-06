library(tidyverse)
library(ggplot2)
library(cowplot)
library(broom)


# Reading in data
poll_2016 <- read_csv("data/polls_2016.csv") %>%
  select(pollster, adjpoll_clinton, adjpoll_trump, poll_wt) %>%
  unique()
poll_2020 <- read_csv("data/polls_2020.csv") %>%
  select(pollster, candidate_name, candidate_party, pct) %>%
  unique()
url_2016 = "https://raw.githubusercontent.com/fivethirtyeight/data/master/pollster-ratings/2016/pollster-ratings.csv"
url_2016 <- read_csv(url(url_2016)) 
url_2016
url_2020 = "https://raw.githubusercontent.com/fivethirtyeight/data/master/pollster-ratings/2019/pollster-ratings.csv"
url_2020 <- read_csv(url(url_2020)) 
url_2020


# Joining and cleaning data. Focus on shared polls for both years as I want a
# more controlled standard of comparison.
poll_ratings <- url_2020 %>%
  left_join(url_2016, by = "Pollster") %>%
  mutate(rating_2016 = `538 Grade.y`,
         rating_2020 = `538 Grade.x`) %>%
  drop_na()

# Graph of poll grades in 2016
graph2016 <- ggplot(poll_ratings, aes(x = rating_2016)) +
  geom_bar() +
  theme(legend.position = "none") + 
  labs(title = "Distribution of Poll Grades for 2016 Election",
       x = "2016 Poll Grades",
       y = "Count",
       caption = "Source: FiveThirtyEight") +
  theme_classic()
graph2016

# Graph of poll grades in 2020
graph2020 <- ggplot(poll_ratings, aes(x = rating_2020)) +
  geom_bar() +
  theme(legend.position = "none") + 
  labs(title = "Distribution of Poll Grades for 2020 Election",
       x = "2020 Poll Grades",
       y = "Count",
       caption = "Source: FiveThirtyEight") +
  theme_classic()
graph2020

# Combined plot of both graphs
plot_grid(graph2016, graph2020)

ggsave("figures/pollgrades.png")

