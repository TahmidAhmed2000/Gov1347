# Load libraries
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
library(plotly)

# Read data needed
myprediction <- read_csv("data/pred_ensemble.csv")
popvote <- read_csv("data/popvote_bystate_1948-2020.csv") %>%
  filter(year == 2020)
popvote$state <- state.abb[match(popvote$state, state.name)] 
popvote$R_pv2p <- popvote$R_pv2p * 100

joined <- myprediction %>%
  left_join(popvote, by = "state") %>%
  mutate(winner_pv = ifelse(R_pv2p > 50, "Republican", "Democrat")) %>%
  mutate(diff = R_pv2p - pred)

# Plotting actual vs predicted state pv2p
joined_plot <- joined %>% 
  ggplot(aes(x = pred, y = R_pv2p, color = winner_pv, labels = state)) +
  geom_point() + 
  geom_abline() +
  scale_color_manual(values = c(muted("blue"), "red3")) +
  scale_x_continuous(labels = percent_format(accuracy = 1, scale = 1), limits = c(25, 95), breaks = c(30, 40, 50, 60, 70, 80, 90)) +
  scale_y_continuous(labels = percent_format(accuracy = 1, scale = 1), limits = c(25, 95), breaks = c(30, 40, 50, 60, 70, 80, 90)) +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "Actual vs Predicted Trump Two-Party Popular Vote per State",
       x = "Predicted Trump Two-Party Popular Vote",
       y = "Actual Trump Two-Party Popular Vote")

# Switching to plotly
ggplotly(joined_plot, tooltip = c("state", "R_pv2p", "pred"))

# Calculating the mse and rmse for all states
mse_all = sum(joined$diff**2) / nrow(joined)
rmse_all = sqrt(mse_all)



# Plot results of actual results
plot_usmap(data = joined, regions = "states", values = "winner_pv") +
  scale_fill_manual(breaks = c("Democrat", "Republican"),
                    values = c(muted("blue"), "red3")) +
  theme_void() +
  labs(fill = "Political Party",
       title = "2020 Presidential Election Actual Results")

# Plot forecast error
plot_usmap(data = joined, regions = "states", values = "diff") +
  theme_void() +
  scale_fill_gradient2(
    high = "blue",
    mid = "white",
    low = "red", 
    breaks = c(-15, -10, -5, 0, 5, 10), 
    name = "Difference") +
  labs(title = "Forecast Error",
       subtitle = "Difference betwween Trump's Actual and Predicted Two Party Vote Share") 

# generating histograms
joined %>% 
    ggplot(aes(diff)) +
    geom_histogram(aes(y = after_stat(count / sum(count))), bins = 10, fill = '#BE1E26') + 
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(x = "Difference Between Trump's Actual and Predicted \nTwo-Party Vote Share",
         y = "Count",
         title = "Error Distributions for Model") +
    theme_classic()

