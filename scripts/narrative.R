# Load packages
library(tidyverse)
library(gt)
library(haven)

# Read data
Trump_approve <- read_csv("data/narrative1.csv")
Trump_approve$date <- factor(Trump_approve$date, levels = unique(Trump_approve$date))

Trump_approve %>%
  ggplot(aes(date, approve, group = 1)) +
  geom_line() +
  labs(title = "Trump's Black Approval Rating",
       x = "Date",
       y = "Approval Rating",
       caption = "Source: Gallup") +
  theme_classic() +
  scale_y_continuous(limits = c(0, 50)) +
  guides(x = guide_axis(angle = 45)) +
  geom_vline(xintercept = "5/21 - 5/27") +
  annotate(geom = "text", x = "5/21 - 5/27", y = 20, 
           label = "May 25: 
  George Floyd Killed", color = "blue", fontface = "bold",
           angle = 90)


Biden_support <- read_csv("data/narrative2.csv")
Biden_support$date <- factor(Biden_support$date, levels = unique(Biden_support$date))

Biden_support %>%
  ggplot(aes(date, support, group = 1)) + geom_line() +
  labs(title = "Biden's Black Support",
       x = "Date",
       y = "Support Among African Americans",
       caption = "Source: Gallup") +
  theme_classic() +
  scale_y_continuous(limits = c(0, 100)) +
  guides(x = guide_axis(angle = 45)) +
  geom_vline(xintercept = "5/21 - 5/27") +
  annotate(geom = "text", x = "5/21 - 5/27", y = 40, 
           label = "May 25: 
  George Floyd Killed", color = "blue", fontface = "bold",
           angle = 90)



