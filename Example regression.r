#Analysis of quine data
#Author: Sophie King
#Date: 30/12/2016
#Aim: To do a work up of the quine data available in the MASS package in R. This is a bit of overkill given the size of the data, but this is mainly an example of some of my work.
#The data was worked up in Example 4.6 in
# Aitkin, Murray. “The Analysis of Unbalanced Cross-Classifications.” Journal of the Royal Statistical Society. Series A (General), vol. 141, no. 2, 1978, pp. 195–223. www.jstor.org/stable/2344453.
#I have used a different model - Poisson rather than Normal (least squares).
#Thanks and acknowledgements to QuickR (http://www.statmethods.net/) and stackoverflow.com, which I relied on as references.

###The question: What factors indicated that a student in Walgett at the time this data as collected was likely to have a high number of days absent from school?

#0. Setup
setwd('/Users/Sophie/Documents/Playground')
library(MASS)
library(stats)
library(sm)
attach(quine)
library(psych)
source('Helper functions.r')

#1. Initial exploration
#First look, 1-way
summary(quine)

#Distribution among categories, 2-way
#Using function from Helper functions.r (kept in separate file for tidiness)
cat.summ(Eth, Sex)
cat.summ(Eth, Age)
cat.summ(Eth, Lrn)
cat.summ(Sex, Age)
cat.summ(Sex, Lrn)
cat.summ(Age, Lrn)

#The students seem reasonably evenly distributed among the categories (1-way and 2-way)
#Slightly concerned about the distribution of learner status (Lrn) by Age
# - no SL F3, higher proportion of SL in F1 and F2
# - would investigate further how this classification was arrived at, eg. is this provided by the teachers for each form? Or is it based on test results?
# - also would like to know if it is typical for students classed as SL to leave or be encouraged to leave school after F2
# - I'd also suspect that prior year absences could impact this measure. That is, if a student has a high level of absences in earlier forms then it seems reasonable that they might have difficulties keeping up in later forms
# - Also looks like more male students are classified as SL than female. If this measure is subjective then this could indicate bias in classification.

#Distribution of Days, the response variable
hist(Days, freq = F, breaks = 20)
lines(density(Days), col = 'red')
boxplot(Days, main = "Distribution of Absent Days",
        ylab = "Number of Absent Days")

###Density and box plots by each factor
#Using function from Helper functions.r (kept in separate file for tidiness)

qd_density(Sex)
#More males have higher absent days (higher median), but female distribution has a longer tail
qd_density(Age)
#Average is highest for F3 but all have some students with high absence rates
qd_density(Lrn)
#SL has lower average but longer tail
#Also median absent days is higher for AL than SL - suggests this variable might not be super useful
qd_density(Eth)
#Ethnicity A has higher average and median absent days and longer tail. This distriubtion is quite wide though.
#Overall, the distributions of absent days for each level of these factors is wide, with a long tail and outliers. 

par(mfrow = c(1,1))

#2. Create test (~20%) and training datasets (~80%)
set.seed(73067103)
trainIndex <- sample(nrow(quine), floor(nrow(quine) * 0.8))
training <- quine[trainIndex, ]
testing <- quine[-trainIndex, ]
nrow(training) #116
nrow(testing) #30

#3. Possion model (since a count variable)

#Run through the main effects using function to automate adding each factor iteratively one at a time
(me.choice(c('Age','Sex','Eth','Lrn'), thresh = 0.05))

###Output###
#      "Null" "Eth"  "Age"  "Lrn"  "Sex" 
# aics "2032" "1843" "1706" "1683" "1680"

#Model 1, all main effects, no interactions
#Auto testing suggests adding all the variables, although I think Sex gives only a marginal improvement
#Biggest risk here with small data is overfitting
#All variables look like they should remain - not all levels are significant
#AIC: 1679.9
mod <- glm(Days ~ Eth + Age + Lrn + Sex, data = training, family = poisson)
summary(mod)
anova(mod, test = "Chisq")

# Coefficients:
#               Estimate Std. Error z value Pr(>|z|)    
#   (Intercept)  2.52163    0.09062  27.827  < 2e-16 ***
#   EthN        -0.61910    0.04922 -12.579  < 2e-16 ***
#   AgeF1       -0.11117    0.09266  -1.200   0.2302    
#   AgeF2        0.52954    0.08290   6.388 1.69e-10 ***
#   AgeF3        0.58997    0.09143   6.452 1.10e-10 ***
#   LrnSL        0.31700    0.05935   5.341 9.25e-08 ***
#   SexM         0.11580    0.05063   2.287   0.0222 *  
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

#Model 2, include Age*Sex interaction
#This was in the final model in the paper (which used a different technique) so I'll test it
#Age*Sex interaction is significant and provides a lot of information in the model
#Keep, but getting wary of overfitting
#AIC: 1569.9
mod <- glm(Days ~ Eth + Age + Lrn + Sex + Age*Sex, data = training, family = poisson)
summary(mod)
anova(mod, test = "Chisq")

# Coefficients:
#               Estimate Std. Error z value Pr(>|z|)    
#   (Intercept)  3.36944    0.11939  28.222  < 2e-16 ***
#   EthN        -0.64077    0.04955 -12.932  < 2e-16 ***
#   AgeF1       -0.91613    0.13715  -6.680 2.39e-11 ***
#   AgeF2       -0.51935    0.14147  -3.671 0.000242 ***
#   AgeF3       -0.54002    0.13861  -3.896 9.78e-05 ***
#   LrnSL        0.46146    0.06528   7.068 1.57e-12 ***
#   SexM        -1.09416    0.15115  -7.239 4.53e-13 ***
#   AgeF1:SexM   0.63061    0.19522   3.230 0.001237 ** 
#   AgeF2:SexM   1.41918    0.17559   8.082 6.35e-16 ***
#   AgeF3:SexM   1.74883    0.17987   9.723  < 2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

#Model 3, include Eth*Sex interaction
#All significant, possibly overfitting, keep interaction for now
#Improvement in AIC is getting smaller
#AIC: 1555.5
mod <- glm(Days ~ Eth + Age + Lrn + Sex + Age*Sex + Eth*Sex, data = training, family = poisson)
summary(mod)
anova(mod)

# Coefficients:
#               Estimate Std. Error z value Pr(>|z|)    
#   (Intercept)  3.48281    0.12195  28.559  < 2e-16 ***
#   EthN        -0.83311    0.06930 -12.022  < 2e-16 ***
#   AgeF1       -0.96311    0.13779  -6.989 2.76e-12 ***
#   AgeF2       -0.57467    0.14224  -4.040 5.34e-05 ***
#   AgeF3       -0.57844    0.13894  -4.163 3.14e-05 ***
#   LrnSL        0.47180    0.06560   7.192 6.39e-13 ***
#   SexM        -1.27564    0.15725  -8.112 4.97e-16 ***
#   AgeF1:SexM   0.65248    0.19513   3.344 0.000826 ***
#   AgeF2:SexM   1.47848    0.17611   8.395  < 2e-16 ***
#   AgeF3:SexM   1.76964    0.17986   9.839  < 2e-16 ***
#   EthN:SexM    0.40023    0.09859   4.060 4.91e-05 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

#Usually I would continue testing interactions but I suspect we're at the point where everything will fit, given the sample size. These two interactions were the ones which were significant in the Normal modelling in the paper quoted, so I am just testing them (in the interests of brevity).

# ANOVA
# 
#         Df Deviance Resid. Df Resid. Dev
# NULL                      115     1569.0
# Eth      1  191.226       114     1377.8
# Age      3  142.939       111     1234.8
# Lrn      1   24.952       110     1209.9
# Sex      1    5.220       109     1204.7
# Age:Sex  3  115.984       106     1088.7
# Eth:Sex  1   16.438       105     1072.2

#Looking at the ANOVA table and judging by residual deviance, Eth and Age are the most informative, with Sex and Lrn providing less explanatory power. I would keep Sex though, since the Age*Sex interaction gives a large drop in AIC. If I were just relying on judgement here, I would tend towards keeping only the factors Eth, Age, Sex, Age*Sex.

#Model 4, remove less effective variables
#AIC: 1555.5
mod <- glm(Days ~ Eth + Age + Sex + Age*Sex, data = training, family = poisson)
summary(mod)
anova(mod)

# Coefficients:
#               Estimate Std. Error z value Pr(>|z|)    
#   (Intercept)  3.37858    0.11933  28.314  < 2e-16 ***
#   EthN        -0.65574    0.04942 -13.270  < 2e-16 ***
#   AgeF1       -0.59643    0.12837  -4.646 3.38e-06 ***
#   AgeF2       -0.10680    0.12833  -0.832    0.405    
#   AgeF3       -0.54301    0.13860  -3.918 8.94e-05 ***
#   SexM        -0.91342    0.14818  -6.164 7.09e-10 ***
#   AgeF1:SexM   0.48576    0.19344   2.511    0.012 *  
#   AgeF2:SexM   0.99882    0.16472   6.064 1.33e-09 ***
#   AgeF3:SexM   1.56770    0.17738   8.838  < 2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

#This looks to me like male students in the higher age groups with Ethnicity A are at the highest risk

#Now I'm going to try and remove the variable which are just picking up noise so that we get a concise and explanatory model.
#So the next steps are to check the fit and examine how this model looks on the testing data

#Checking
plot(mod)
#Fit doesn't look amazing, but not completely off the planet. There are some outliers, mainly non-aboriginal children with high numbers of absences.
#I'd be hesitant to look at these estimates as anything more than an general indicator of those groups at higher risk of absence.

#Two large value for Cook's distance
#Low leverage though, so no need to remove
quine[104,] #69
quine[72,] #67

#Look at fit on training data
plot(c(0,80), c(0,80), type = 'n',
     main = "Actual vs predicted - training",
     xlab = 'Actual',
     ylab = 'Predicted')
points(training$Days, mod$fitted.values)
abline(lm(mod$fitted.values ~ training$Days), col = 'red')
lines(lowess(training$Days, mod$fitted.values), col = 'blue')
#Not great, wide scatter and underestimates absences at most levels. General trend is OK though.
#I would usually go through by factor to see what's fitting or not, but I don't think this model is really any good for prediction. At best, the results are indicative.
#Will try colouring the points by Lrn since I dropped that variable rather arbitrarily

plot(c(0,80), c(0,80), type = 'n',
     main = "Actual vs predicted - training",
     xlab = 'Actual',
     ylab = 'Predicted')
points(training$Days, mod$fitted.values, col = training$Lrn)
legend('topright',  inset = 0.1, legend = unique(training$Lrn),col=1:length(training$Lrn),pch=1)
#Yeah, I don't think that's it

#Look at fit on test data

test.fitted <- predict(mod, newdata = testing, type = 'response')

plot(c(0,80), c(0,80), type = 'n',
     main = "Actual vs predicted - test",
     xlab = 'Actual',
     ylab = 'Predicted')
points(testing$Days, test.fitted)
abline(lm(test.fitted ~ testing$Days), col = 'red')
lines(lowess(testing$Days, test.fitted), col = 'blue')
#As expected, not good.

###Conclusion###
#Poisson modelling does not produce predictive results.
#The analysis of single variables shows that the median number of absent days for indigenous students is higher than non-indigenous students. (Better to look at the median, given the skewed distributions). However given the model does not perform well, I think that there are probably underlying factors which correlate with ethnicity that would be more useful in describing groups that are at risk of high levels of absenteeism. The main effects model (that is, no interactions) suggests that ethnicity is probably the best indicator of those factors which were collected, so if this is the best data you can gather then you could tentatively use this result to inform further action. However this analysis does not imply any causality and does not give strong predictive results. I would be very hesitant to generalise any findings based on this data, given the limited scope of the study and the variables collected. Finally, there are issues with the design of the study and the data collected, which limit the usefulness of this analysis.
#These issues are:
#1. Small number of data points; just a snapshot of one year.
# - To understand factors which correlate with absenteeism, I think that following individuals over time might be more useful, to see the behavioural development and also to possibly identify events and circumstances that trigger this behaviour.
# - Also this data only covers Walgett, a small, rural town. Ideally this data would be collected from a large sample of schools, both rural and urban. This would allow for more informative and robust results. It might also suggest some ways to reduce student absences by comparing high performing with low performing schools - however that is outside the scope of this analysis.
#2. Possibly missing explanatory variables
# - Factors I would have liked to test: family socioeconomic status, parental employment/unemployment, parental educational level. These often crop up in explaining education outcomes for students and it seems like a big omission not to test them here.
# - Also, I think a qualitative study to support this analysis would have been helpful to determine what kind of factors might be important in absenteeism. The factors measured are I guess easy to measure, but do suggest to me a pre-judgement of correlating factors with absence from school.