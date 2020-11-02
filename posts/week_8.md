# 11/1 - Predicting the 2020 Election

## Overview

The time has come! It is time to make our final prediction for the 2020 Presidential election. The upcoming election will be a very unique one. America has not witnessed events like the Coronavirus pandemic and civil unrest from the death of George Floyd in a long time, which may impact voting behaviors. Furthermore, the pandemic has played detrimental effects on the economy, also possibly impacting voting behaviors. In this blog, I will talk about the model we will use to forecast the 2020 election. 

## Models Logistics

+ To adjust for overfitting, I decided to separate America into three categories - red states, blue states, and battleground states - for my model. 
+ While it is better to model by county, there was little data to extract a model from a county basis. Thus, I decided to instead use my model for each of the three groups. 
+ In addition, we will be asssuming District of Columbia is a blue state and a projected democratic winner. 

## Poll Model

```
R_pv2p ~ avg_pollyr
```
+ R_pv2p represents Republican vote share
+ avg_pollyr represents average polling support for republican candidate

The first model I created was a poll model, which is a linear model. The formula of the model uses average poll support for a republican as a predictor with a response variable that is Republican vote share and the model uses historical state level polling data from 1972 to 2016. Furthermore, the linear model was used to predict Trump's vote share in each state for 2020 using poll averages from 10/31/20. Thr formula is above. 

![](../figures/poll_final.png)
Figure 1.

The results from this model is seen in Figure 1. Based on this model, **Biden is expected to win with an electoral count of 310 votes to Trump's 228 votes**. 

I decided to use a poll model because I learned from Nate Silver that polls are actually very good predictors of the election. While in 2016, polls were not as representative of the actual vote results, it is important that many pollsters have improved in their methods. Now many pollsters are asking less biased questions and polling at more areas.

## Fundamental Model
```
R_pv2p ~ GDP_growth_qt + turnoutpct_change + net_app
```
+ turnoutpct_change represents percent change in voter turnout
+ net_app represents net approval for republican candidate

The next model I want to look at is a fundamental model. Given the sucess of the Abromowitz’s Time for Change Model, I thought it was important to include the indicators of that model as part of my fundamental model. Thus, I used Q2 GDP growth and the president's approval rating as my predictors. I also did not add incumbent party as an interaction  variable since I am already looking at incumbent's vote share and the Republican party. However, I did not just use those two predictors: I also used the change in turnout percentage as another predictor. I decided to add change in turnout percentage as another predictor, because I thought it was important that 150 million people are planning to vote (about 11 million more than 2016) and [turnout is already high](https://www.vox.com/2020/11/1/21543381/92-million-people-early-voting-turnout-2020). Furthermore, I considered change in turnout percentage as a fundamental because I considered it as part of political data. Also, the fundamental model was used to predict Trump's vote share in each state for 2020 using Trump's recent approval ratings and each state's Q2 GDP growth rate. Given that we don't have information on change in turnout percentage, I decided to make change in turnout percentage 10% for each state as many news outlets are predicting arounf a 10% increase in voter turnout. The formula for the model is above. 

![](../figures/fundamental_final.png)
Figure 2.

The results from this model is seen in Figure 2. **Based on this model, Biden is expected to win with an electoral count of 402 votes to Trump's 136 votes**. 

I noticed that using the fundamental model has played a signficant impact on battleground states in comparison to the polls model. I noticed many battleground states like Texas and Georgia have became blue from using the fundamental model. 

## Ensemble Model
```
Trump vote share = 0.96*Poll + 0.04*Fundamental
```

Now that we have our poll model and fundamental model, I decided to then use an ensemble model where I weighted the poll model by 0.96 and the fundamental model by 0.04. I decided to weigh the poll model very high using the logic of FiveThirtyEight's model. There is very little reliable data relating to fundamentals and the relationship between economic conditions and incumbent party's performance remains noisy, making it hard to predict future elections especially for 2020. Silver also mentions how fundamentals are good at predicting past elections but not future ones. Thus, I wanted my ensemble model to weught the poll model heavily and the fundamental model less. In addition, according to [Abramowitz](https://www-cambridge-org.ezp-prod1.hul.harvard.edu/core/services/aop-cambridge-core/content/view/47BBC0D5A2B7913DBB37FDA0542FD7E8/S1049096520001389a.pdf/its_the_pandemic_stupid_a_simplified_model_for_forecasting_the_2020_presidential_election.pdf), "There are good reasons to expect that in 2020, two of the model’s (TFC model) predictors—the change in real GDP in the second quarter and the time-for-change dummy variable—will not perform as they normally do." However, I still think the fundamentals can still play an impact on the election, which is why I weighted them but very litle

![](../figures/ensemble_final.png)
Figure 3.

Just like the FiveThirtyEight model, I relied heavily on polling data. The ensemble model predicts Biden to win with 310 electoral votes and Trump to lose with 228 votes. Whie there are not necessarily any glaring predictions, it is important to understand that there is uncertainty with this model. 

# Predictability of Ensemble Model

![](../figures/predicatability_final.png)
Figure 4. 

+ According to Figure 4, I have plotted the 95% prediction intervals for Trump's predicted vote share in each state based on the ensemble model. 
+ According to the model, all the battleground states cross the 50% threshold and are near the 50% vote share, meaning those states are most likely to be swing states. T
+ he above figure also shows the predictability of the model on a state by state basis. 


# Sensitivity Analysis

![](../figures/ensemble95_final.png)
Figure 5. 

In order to validate our model, I decided to do a sensitivity analysis on our model. Thus, I essentially changed the weights of the model. I decided to weigh the Poll model by 0.95 and the fundamental model by 0.05. The results are in the figure above. We can see that by decreasing the weight of the poll model by one percent and increasing the weight of the fundamental model by one percent, Biden wins Texas. This shows that the fundamental model heavily favors the democratic party. This could be partly because Q2 GDP growth rate has been historically low as well as Trump's approval ratings for some states. 

Using the sensitivity analysis for the ensemble model, it was hard to get a prediction of when Trump wins the election. If we use a weight greater than 0.96 for the poll model and a weight less than 0.04 for the fundamental model, we have the same predictions as the current ensmeble model of 0.96(Poll) + 0.04(Fundamental). 


















