# load packages to use
library(tidyverse)
library(caret)
library(statebins)
library(usmap)
library(stargazer)
library(cowplot)
library(sjPlot)

# Read in data
covid <- read_csv("data/covid_state.csv") %>%
  filter(grepl('2020-10-25', date)) %>%
  mutate(pos_pct = positive/totalTestResults, death_pct = death/totalTestResults)

poll <- read_csv("data/statepoll_2020.csv") 

# Join Covid and Polling data
covid_poll <- covid %>%
  inner_join(poll, by = "state") 

# Graphs to show Covid Variables effects on Trump's Incumbency Share
facet_covid = c("death", 
                "deathIncrease", 
                "hospitalizedIncrease",
                "hospitalizedCurrently",
                "negative",
                "negativeIncrease",
                "onVentilatorCurrently",
                "positive",
                "positiveIncrease",
                "recovered",
                "totalTestResults",
                "totalTestResultsIncrease",
                "Trump_pct")
Facet_corona <- covid_poll %>% 
  select(facet_covid) %>% 
  tidyr::gather(key, Covid, -Trump_pct) %>% 
  select(key,Covid,Trump_pct)

Facet_corona %>%
  ggplot(aes(x=Covid, y=Trump_pct, color = key)) + 
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x) +
  ylab("Incumbent Popular Vote Share") +
  xlab("Covid Related Variables") +
  labs(caption = "Source: 270toWin, The Covid Tracking Project" ) +
  facet_wrap(~key, ncol = 5, scales = "free") +
  theme_classic()+
  theme(legend.position = "none")

ggsave("figures/Incumbent_covid.png", height = 10, width = 12)

# Linear Covid Model to analyze Covid effects
covid_model <- lm(Trump_pct ~ deathIncrease + positiveIncrease + totalTestResultsIncrease + negativeIncrease +
                              hospitalizedIncrease, data = covid_poll)
summary((covid_model))

tab_model(covid_model,
          title = "Effect of Covid Pandemic on Incumbent's Voteshare by State",
          dv.labels = "Incumbent's State Voteshare")



# Graph to show Covid positivity rates by state
ggplot(covid_poll, aes(state = state, fill = pos_pct)) + 
  geom_statebins() + 
  scale_fill_gradient2(
    high = "blue",
    mid = "white",
    low = "red",
    name = "Positivity Rate ") +
  theme_statebins() +
  labs(title = "Covid Positivity Rate by State",
       caption = "The Covid Tracking Project") 

ggsave("figures/state_covid.png")

# Graph to show Covid death rates by state
ggplot(covid_poll, aes(state = state, fill = death_pct)) + 
  geom_statebins() + 
  scale_fill_gradient2(
    high = "blue",
    mid = "white",
    low = "red",
    name = "Death Rate") +
  theme_statebins() +
  labs(title = "Covid Death Rate by State",
       caption = "The Covid Tracking Project") 

ggsave("figures/death_covid.png")

