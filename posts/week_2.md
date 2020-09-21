
# 9/20 - How Does the Economy Affect Voting Behaviors?

### Overview
Historically speaking, the economy has remained a critical factor affecting how people vote. One can argue that how the economy is doing is not so much of a bipartisan issue: everyone wants a strong economy. Thus, given that the economy can play a signficant role in how citizens vote, let's analyze more in depth of how certain economic predictors, such as inflation and unemployment, can tell us more about voting behaviors in 2020. 

### Model 1: How Inflation Impacts the Incumbent Party Popular Vote Share?
In our first model, we will look at how inflation affects the incumbent party vote share. Since, we are focused mainly on the election timeline, we will look at Quarter 2 data. This is because Quarter 2 has recent economic data before the election data as opposed to Quarter 4, which has data after the election. Furthermore, the most recent and complete data in our dataset is the second quarter of the 2016 election. Thus, it makes sense to look at Q2 so we can make a prediction and compare it with the actual vote margin. 

![](../figures/voteshar&inflation.png)

In **Figure 1**, we can see that the relationship between inflation and the incumbent party vote share is negatively correlated. In this case, r = -.22 (of inflation) and the residual error was 5.30, showing that the relationship between inflation and vote share is fairly strong. What this implies is that as inflation increases, voters are less likely to vote for the incumbent president. Logically, an increased rate of inflation means that the purchasing power of each unit of currency is reduced; thus, we may see an increase in prices of goods. Given that consumers are price sensitive, an increased prices can potentially lead to voters hesitant to vote for the incumbent president if inflation rates remain high. 

Furthermore, we can use cross validation with our data to make valid predictions of the vote share of 2016. Cross-validation essentially witholds a random subset of the sample of data we make, and fits the model with the rest of the sample. We can evaluate the predictive performance on the held-out observations, which involves repeatedly evaluating against many randomly held-out “out-of-sample” datasets. Rather than looking at one single evaluation, we can thus look at a distribution of evaluations. 

![](../figures/hist_infvs.png)

In **Figure 2**, we can see that mean of out-of-sample residuals are mostly around zero, so our prediction model should be valid. The following bullets tell us about our prediction model for 2016 Q2 vote margin for the incumbent party if we use inflation as an indicator: 

+ The mean difference between our prediction using out-of-sample validation and the true value is 0.97
+ The average error of the out-of-sample residuals is 2.00
+ Our prediction we get using out-of-sample validation is 49.75% with a confidence interval of (37.08, 62.43)







