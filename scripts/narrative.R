# Load packages
library(tidyverse)
library(gt)
library(haven)

# Read Trump's approval ratings data
Trump_approve <- read_csv("data/narrative1.csv")
Trump_approve$date <- factor(Trump_approve$date, levels = unique(Trump_approve$date))

# Plot Trump's approval rating graph
Trump_approve %>%
  ggplot(aes(date, approve, group = 1)) +
  geom_line() +
  labs(title = "Trump's Approval Rating Among African Americans",
       x = "Date",
       y = "Approval Rating",
       caption = "Source: Democracy Fund + UCLA Nationscape") +
  theme_classic() +
  scale_y_continuous(limits = c(0, 50)) +
  guides(x = guide_axis(angle = 45)) +
  geom_vline(xintercept = "5/21 - 5/27") +
  annotate(geom = "text", x = "5/21 - 5/27", y = 20, 
           label = "May 25: 
  George Floyd Killed", color = "blue", fontface = "bold",
           angle = 90)

# Save plot
ggsave("figures/Trump_blackapprove.png")


# Read Biden's support data
Biden_support <- read_csv("data/narrative2.csv")
Biden_support$date <- factor(Biden_support$date, levels = unique(Biden_support$date))

# Plot Biden's support graph
Biden_support %>%
  ggplot(aes(date, support, group = 1)) + geom_line() +
  labs(title = "Biden's Support Among African Americans",
       x = "Date",
       y = "Support Among African Americans",
       caption = "Source: Democracy Fund + UCLA Nationscape") +
  theme_classic() +
  scale_y_continuous(limits = c(0, 100)) +
  guides(x = guide_axis(angle = 45)) +
  geom_vline(xintercept = "5/21 - 5/27") +
  annotate(geom = "text", x = "5/21 - 5/27", y = 40, 
           label = "May 25: 
  George Floyd Killed", color = "blue", fontface = "bold",
           angle = 90)

# Save plot
ggsave("figures/Biden_blacksupport.png")


# Read Trump's support data
Trump_support <- read_csv("data/narrative3.csv")
Trump_support$date <- factor(Trump_support$date, levels = unique(Trump_support$date))

# Plot Trump's support graph
Trump_support %>%
  ggplot(aes(date, support, group = 1)) + geom_line() +
  labs(title = "Trump's Support Among African Americans",
       x = "Date",
       y = "Support Among African Americans",
       caption = "Source: Democracy Fund + UCLA Nationscape") +
  theme_classic() +
  scale_y_continuous(limits = c(0, 30)) +
  guides(x = guide_axis(angle = 45)) +
  geom_vline(xintercept = "5/21 - 5/27") +
  annotate(geom = "text", x = "5/21 - 5/27", y = 15, 
           label = "May 25: 
  George Floyd Killed", color = "blue", fontface = "bold",
           angle = 90)

# Save plot
ggsave("figures/Trump_blacksupport.png")


