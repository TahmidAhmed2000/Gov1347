## download packages
library(tidyverse)
library(ggplot2)

# read data sets
social_df <- read_csv("data/social_media.csv")

# Spending on Social Media
social_df <- social_df %>%
  filter(`Page Name` == "Joe Biden" | `Page Name` == "Donald J. Trump")

social_df %>%
  ggplot(aes(`Page Name`, `Total Spend++`, fill = `Page Name`)) + 
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Comparison of Facebook Ad Spending in 2020") +
  xlab("Presidential Candidate") +
  ylab("Total Spent on Facebook Ads") +
  theme_minimal()

ggsave("figures/FB.png")


# Social Media Topics
topic_df <- read_csv("data/topic_sm.csv") 

topictrump_df <- topic_df %>%
  filter(Candidate == "Donald J. Trump") %>%
  pivot_longer(cols = c(Governance, Safety, Education,
                        Health, Covid)) %>%
  select(!`Social Program`)

topictrump_df %>%
  ggplot(aes(name, value, fill = name)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip(xlim = NULL, ylim = NULL, expand = TRUE, clip = "on") 

str_sub() # remove $
grep() # remove ,


