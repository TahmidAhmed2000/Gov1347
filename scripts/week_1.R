## install via `install.packages("name")`
## Blog_1 code
library(tidyverse)
library(usmap)
library(ggplot2)
library(ggrepel)
library(skimr)
library(gt)

#created my own theme
theme_tahmid <- theme_classic() + 
  theme(panel.border = element_blank(),
        plot.title   = element_text(size = 12, hjust = 0.5), 
        axis.text.x  = element_text(angle = 45, hjust = 1),
        axis.text    = element_text(size = 10),
        strip.text   = element_text(size = 15),
        axis.line    = element_line(colour = "blue"),
        legend.position = "top",
        legend.text = element_text(size = 11),
        plot.subtitle = element_text(size = 12, hjust = 0.5))

# Read popular voting data
popvote_df <- read_csv("data/popvote_1948-2016.csv")

## format
(popvote_wide_df <- popvote_df %>%
    select(year, party, pv2p) %>%
    spread(party, pv2p))

## modify
(popvote_wide_df <- popvote_wide_df %>% 
    mutate(winner = case_when(democrat > republican ~ "D",
                              TRUE ~ "R")))

####----------------------------------------------------------#
#### Visualize trends in national pres pop vote ####
####----------------------------------------------------------#


## EXCELLENT plot:

ggplot(popvote_df, aes(x = year, y = pv2p, colour = party)) +
  geom_line(stat = "identity") +
  scale_color_manual(values = c("blue", "red"), name = "") +
  xlab("") + ## no need to label an obvious axis
  ylab("popular vote %") +
  ggtitle("Presidential Vote Share (1948-2016)") + 
  scale_x_continuous(breaks = seq(from = 1948, to = 2016, by = 4)) +
  theme_tahmid

## saves last displayed plot
ggsave("figures/PV_national_historical.png", height = 4, width = 8)

####----------------------------------------------------------#
#### State-by-state map of pres pop votes ####
####----------------------------------------------------------#

## read in state pop vote
pvstate_df <- read_csv("data/popvote_bystate_1948-2016.csv")
pvstate_df$full <- pvstate_df$state

## shapefile of states from `usmap` library
## note: `usmap` merges this internally, but other packages may not!
states_map <- usmap::us_map()
unique(states_map$abbr)

## map: GOP pv2p (`plot_usmap` is wrapper function of `ggplot`)
plot_usmap(data = pvstate_df, regions = "states", values = "R_pv2p") + 
  scale_fill_gradient(low = "white", high = "red", name = "GOP two-party voteshare") +
  theme_void()

## map: wins
pv_win_map <- pvstate_df %>%
  filter(year == 2000) %>%
  mutate(winner = ifelse(R > D, "republican", "democrat"))

## map: wins bty state
plot_usmap(data = pv_win_map, regions = "states", values = "winner") +
  scale_fill_manual(values = c("blue", "red"), name = "state PV winner") +
  theme_void()

## map: win-margins
pv_margins_map <- pvstate_df %>%
  filter(year == 2000) %>%
  mutate(win_margin = (R_pv2p-D_pv2p))

## map win margins by state
plot_usmap(data = pv_margins_map, regions = "states", values = "win_margin") +
  scale_fill_gradient2(
    high = "red", 
    # mid = scales::muted("purple"), ##TODO: purple or white better?
    mid = "white",
    low = "blue", 
    breaks = c(-50,-25,0,25,50), 
    limits = c(-50,50),
    name = "win margin"
  ) +
  theme_void()

## map grid
pv_map_grid <- pvstate_df %>%
  filter(year >= 1980) %>%
  mutate(winner = ifelse(R > D, "republican", "democrat"))

## map grid by states
plot_usmap(data = pv_map_grid, regions = "states", values = "winner", color = "white") +
  facet_wrap(facets = year ~.) + ## specify a grid by year
  scale_fill_manual(values = c("blue", "red"), name = "PV winner") +
  theme_void() +
  theme(strip.text = element_text(size = 12),
        aspect.ratio=1)

## save plot of historical trends
ggsave("figures/PV_states_historical.png", height = 3, width = 8)


## Read Electoral College Data of 2016
evstate2016_df <- read_csv("data/electoralvote2016.csv") %>%
  mutate(id = 1:51)

# filter for 2016 presidential election for popular vote
pv_margins_map_2016 <- pvstate_df %>%
  filter(year == 2016) %>%
  mutate(win_margin = (D_pv2p-R_pv2p)) %>%
  mutate(id = 1:51) %>%
  mutate(democrat_margin_pop = D - R)

# join both electoral college data and popular vote data
joineddata <- inner_join(pv_margins_map_2016, evstate2016_df, by = "id")

# Plot 2016 win margin map, using a Red to Blue Scale and Purple as middle to
# represent current themes
plot_usmap(data = pv_margins_map_2016, regions = "states", values = "win_margin") +
  scale_fill_gradient2(
    high = "blue", 
    mid = scales::muted("purple"),
    low = "red", 
    breaks = c(-50,-25,0,25,50), 
    limits = c(-52,50),
    name = "Win margin"
  ) +
  theme_void() + 
  labs(title = "Popular Voting Share Margins in 2016 Election",
       subtitle = "Popular Voting Shares in a 2-Party System",
       caption = "Data taken from Gov 1347 Lab") + 
  theme(plot.title = element_text(size = 14, hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5))


## Save popular voting margins amp
ggsave("figures/PV_states_2016.png", height = 4, width = 8)


## Plot electoral college states with simialr themes from popular vote
plot_usmap(data = evstate2016_df, regions = "states", values = "win_margin") +
  scale_fill_gradient2(
    high = "blue", 
    mid = scales::muted("purple"),
    low = "red", 
    breaks = c(-50,-25,0,25,50), 
    limits = c(-52,55),
    name = "Win margin"
  ) +
  theme_void() + 
  labs(title = "2016 Presidential Electoral Vote Share Win Margin",
       subtitle = "2-party Electoral College Vote share",
       caption = "Data collected from Federal Election Commission.") +
  theme(plot.title = element_text(size = 14, hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5))

## Save popular voting margins amp
ggsave("figures/EV_states_2016.png", height = 4, width = 8)

## Plot democratic margins in both opular vote and electoral college against
## each other
joineddata %>%
  ggplot(aes(democrat_margin_pop, win_margin.y)) + 
  geom_point() + 
  geom_smooth(method='lm') +
  labs(title = "2016 Democratic Margins in Popular Vote and Electoral Vote",
       subtitle = "Regression Plot of Voting Margins",
       caption = "Data collected from joined data set",
       y = "Electoral Vote Margin",
       x = "Popular Vote Margin") +
  theme_tahmid 


## save resulting regression plot
ggsave("figures/regmargins_states_2016.png", height = 4, width = 8)


## Ran regression of both types of margins
democrat_reg <- lm(win_margin.y ~ democrat_margin_pop, data = joineddata)

## Evaluate summary of regression
demregsummary <- summary(democrat_reg)
demregsummary

