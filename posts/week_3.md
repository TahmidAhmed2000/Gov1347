
# 9/27 - Taking a Deep Dive into FiveThirtyEight and The Economist's Election Forecasts

## Overview
Election forecasts are often very volatile but they give citizens a sense of what the upcming election may look like. Two such popular forecasts are [FiveThirtyEight's Presidential Forecast](https://projects.fivethirtyeight.com/2020-election-forecast/) and [The Economists' Presidential Forecast](https://projects.economist.com/us-2020-forecast/president). While both models share many similarities, they are both different, however: the FivethirtyEight model seems to place more of an emphasis on polls while The Economist's models appears to place more of an emphasis on fundamentals. For clarification, "fundamentals" are a political science term for structural factors (such as the economy and incumbency) that impact voter decisions.

## How does FiveThirtyEight's Model work?

### Step 1: Collect, analyze, and adjust polls

+ FiveThirtyEight constructs both national and state polling averages, where they are weighted based on their sample size and pollster rating.
+ Polling averages are adjusted according to different types: likely voter adjustment, house effects adjustment, timeline adjustment, and [convention bounce adjustment](https://fivethirtyeight.com/features/measuring-a-convention-bounce/). Note, however, that the counvention bound adjustments will be small due to fewer events as a result of Covid and social distancing. 

![](../figures/pollgrades.png)

This is snapshot of the distribution of FiveThirtyEight grades on polls. These polls are used in their model, but it's important to understnd that the polls are not super accurate of the general public. This explains why the company spends so much care to adjusting the polls. 

### Step 2: Combining polls with fundamentals

+ FiveThirtyEight uses an **enhanced snapshot**, where polling averages for each state is combined with a model estimate of the vote based on demographics and past voting patterns. The snapshot is further combined with priors, including fundentals like incumbency and economic conditions. 
+ To make the enhanced snapshot, a partisan lean index is applied into polling averages, which reflects how states voted in the past two elections compared to the national mean. For the sake of brevity, the partisan lean index is applied in three different ways to polling averages, where FiveThirtyEight can combine these three methods into an **ensemble forecast**. The ensemble forecast is combined with the state's polling average to get the enhanced snapshot for the state and then all enhanced snapshots of each state are combined to get a **national snapshot**. 
+ Once the national snapshot is created, it is combined with fundamentals like economic and incumbency conditions. The company applies an index of economic conditions to their model, which is combined with incumbency trends. 

### Step 3: Accounting for Uncertainty and Making Simulations

+ The model tries to account for four types of uncertainty, including national drift, national election day error, correlated state error, and state-specific error. More about these errors can be found on their website. Complex mathematical formulas are applied to account for uncertainty. 
+ 




