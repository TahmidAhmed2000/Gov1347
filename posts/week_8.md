# 11/1 - Predicting the 2020 Election

## Overview

The time has come! It is time to make our final prediction for the 2020 Presidential election. The upcoming election will be a very unique one. America has not witnessed events like the Coronavirus pandemic and civil unrest from the death of George Floyd in a long time, which may impact voting behaviors. Furthermore, the pandemic has played detrimental effects on the economy, also possibly impacting voting behaviors. In this blog, I will talk about the model we will use to forecast the 2020 election. 

# Models Logistics

To adjust for overfitting, I decided to separate America into three categories - red states, blue states, and battleground states - for my model. While it is better to model by county, there was little data to extract a model from a county basis. Thus, I decided to instead use my model for each of the three groups. 

# Poll Model

```
R_pv2p ~ avg_pollyr
```

The first model I created was a poll model, which is a linear model. The formula of the model uses average poll support as a predictor with a response variable that is Republican vote share and the model uses historical state level polling data from 1972 to 2016. Furthermore, the linear model was used to predict Trump's vote share in each state for 2020 using poll averages from 10/31/20. Thr formula is above. 

![](../figures/poll_final.png)
Figure 1.

The results from this model is seen in Figure 1. Based on this model, Biden is expected to win with an electoral count of 310 votes to Trump's 228 votes. 

I decided to use a poll model because I learned from Nate Silver that polls are actually very good predictors of the election. While in 2016, polls were not as representative of the actual vote results, it is important that many pollsters have improved in their methods. Now many pollsters are asking less biased questions and polling at more areas.

# Fundamental Model
```
R_pv2p ~ GDP_growth_qt + turnoutpct_change + net_app
```

The next model I want to look at is a fundamental model. Given the sucess of the Abromowitz’s Time for Change Model, I thought it was important to include the indicators of that model as part of my fundamental model. Thus, I used Q2 GDP growth and the president's approval rating as my predictors. I also did not add incumbent party as an ineraction variable since I am already looking at incumbent's vote share. However, I did not just use those two predictors: I also used the change in turnout percentage as another predictor. I decided to add change in turnout percentage as another predictor, because I thought it was important that 150 million people are planning to vote (about 11 million more than 2016) and [turnout is already high](https://www.vox.com/2020/11/1/21543381/92-million-people-early-voting-turnout-2020). Furthermore, I considered change in turnout percentage as a fundamental because I considered it as part of political data. Also, the fundamental model was used to predict Trump's vote share in each state for 2020 using Trump's recent approval ratings and each state's Q2 GDP growth rate. Given that we don't have information on change in turnout percentage, I decided to make change in turnout percentage 10% for each state as many news outlets are predicting arounf a 10% increase in voter turnout. The formula for the model is above. 

![](../figures/fundamental_final.png)
Figure 2.

The results from this model is seen in Figure 2. Based on this model, Biden is expected to win with an electoral count of 402 votes to Trump's 136 votes. 

I noticed that using the fundamental model has played a signficant impact on battleground states in comparison to the polls model. I noticed many battleground states like Texas and Georgia have became blue from using the fundamental model. 

# Ensemble Model
```
Trump vote share = 0.96*Poll + 0.04*Fundamental
```

Now that we have our poll model and fundamental model, I decided to then use an ensemble model where I weighted the poll model by 0.96 and the fundamental model by 0.04. I decided to weigh the poll model very high using the logic of FiveThirtyEight's model. There is very little reliable data relating to fundamentals and the relationship between economic conditions and incumbent party's performance remains noisy, making it hard to predict future elections especially for 2020. Silver also mentions how fundamentals are good at predicting past elections but not future ones. The essential formula for this model is above. 

![](../figures/ensemble_final.png)












=

![](../figures/predicatability_final.png)

