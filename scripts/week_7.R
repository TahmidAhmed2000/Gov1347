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
  filter(grepl('2020-10-25', date))

poll <- read_csv("data/statepoll_2020.csv") 

covid_poll <- covid %>%
  left_join(poll, by = "state") 

ggplot(covid_poll, aes(x = positive, y = Trump_pct, label = state)) + 
  geom_point() +
  theme_classic() +
  geom_smooth(method = "lm", formula = y ~ x) +
  labs(title = "The Effect of Number of Covid Cases on Polling Average",
       x = "Positive Cases",
       y = "Popular Vote for Incumbent",
       color = "",
       caption = "Source: 270toWin, The Covid Tracking Project") 

ggplot(covid_poll, aes(x = death, y = Trump_pct, label = state)) + 
  geom_point() +
  theme_classic() +
  geom_smooth(method = "lm", formula = y ~ x) +
  labs(title = "The Effect of Number of Covid Deaths on Polling Average",
       x = "Deaths",
       y = "Popular Vote for Incumbent",
       color = "",
       caption = "Source: 270toWin, The Covid Tracking Project") 

facet_covid = c("death", 
                "deathIncrease", 
                "hospitalizedIncrease",
                "hospitalizedCurrently",
                "negative",
                "negativeIncrease",
                "onVentilatorCumulative",
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
  facet_wrap(~key, ncol = 5, scales = "free") +
  theme_classic()+
  theme(legend.position = "none")

ggsave("Incumbent_covid.png", height = 10, width = 12)

covid_model <- lm(Trump_pct ~ deathIncrease + positiveIncrease + totalTestResultsIncrease + negativeIncrease +
                              hospitalizedIncrease, data = covid_poll)
summary((covid_model))

stargazer(covid_model,
          title = "Covid Effects on Trump's Vote Share",
          header = FALSE,
          covariate.labels = c("deathIncrease", "positiveIncrease", "negativeIncrease", "totalTestResultsIncrease", "hospitalizedIncrease"),
          dep.var.labels = "Incumbent Vote Share",
          omit.stat = c("f", "rsq"),
          notes.align = "l",
          font.size = "tiny",
          column.sep.width = "1pt")

tab_model(covid_model,
          title = "The Impact of COVID Cases on Trump's Voteshare by State",
          dv.labels = "Trump's Projected State Voteshare")
