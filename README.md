## Semi-formal writeup
_For a mixed audience of analysts and non-analyst decision-makers._

Note that not all the detail is included in this analysis, as it is not relevant for decision makers. The code is included so analysts who are interested can look closer. There are further notes in the comments of the code.

### Question:
What factors indicated that a student in Walgett at the time this data as collected was likely to have a high number of days absent from school?

### Recommendation:
There are some serious limitations in the data. We recommend further data collection, which should include a wider variety of explanatory factors to test and data from more schools. If immediate action is required, a strategy could be formulated to engage indigenous students in school more effectively. However, it must be stressed that this data and analysis do not provide strong evidence that ethnicity is a driving factor for absenteeism.

### Data:
quine from the MASS package in R. This was taken from Example 4.6 in:
_Aitkin, Murray. “The Analysis of Unbalanced Cross-Classifications.” Journal of the Royal Statistical Society. Series A (General), vol. 141, no. 2, 1978, pp. 195–223. www.jstor.org/stable/2344453_
The data includes the number of days absent from school in one year of 146 students sampled from a school in Walgett. It records for each student their sex, age (by school year), ethnicity and learner status.

### Method:
Exploratory data analysis was performed. Mosaic plots and frequency tables were used to examine the distribution of pupils in each of the factor levels. Density plots, box plots and summary statistics of the response variable _Days_ were examined at level of each factor.

The data was then split into training (80%) and testing (20%) datasets.

Poisson regression with a log link was chosen to model the number days absent (_Days_). Poisson modelling is the most appropriate for modelling count data using regression.

Main effects were chosen by adding each variable to the model separately, keeping the most effective variable to keep (based on Chi-squared significance and AIC) and then repeating the process to add variables to the model. Any variable with a p-value of greater than 5% was not used. Then two interactions were tested, _Age*Sex_ and _Eth*Sex_.

The models were evaluated using AIC, ANOVA and significance testing. Variables which did not provide much extra information were dropped, in the interests of a concise model. The q-q and leverage plots for final model were then examined, as well as a plot of actual vs predicted values for the training and testing datasets.

### Results:

#### One-way analysis

There were differences for levels all factors. This suggests that they all could be significant in the model. The most striking difference between levels of a factor in the one-way analysis was for the factor ethnicity (_Eth_). The median number of days absent for indigenous children was 15, while the median for non-indigenous was 7. The density plot below demonstrates that the mode for absent days is higher for indigenous students (_Eth = 'A'_) and that the tail of that distribution is fatter.

![Density and box plots of absent days by ethnicity](https://cloud.githubusercontent.com/assets/7769706/21584055/4cce6326-d0ed-11e6-9afd-7287941390f5.png)

The one-way analysis indicated that the male group had higher median days of absence. The median days of absence for students in forms 2 and 3 are higher than those in primary (F0) and form 1. The summaries for learner status were ambiguous - while the mean was higher for the slow learner group, the median was lower. 

#### Poisson regression model
The final model chosen was:
 _Days_ = 3.38 - 0.66*(_Eth = 'N'_) - 0.60*(_Age = 'F1'_) - 0.11*(_Age = 'F2'_) - 0.54*(_Age = 'F3'_) - 0.91*(_Sex = 'M'_) + 0.49*(_Age = 'F1'_ and _Sex = 'M'_) + 1.00*(_Age = 'F2_ and _Sex = 'M'_) + 1.57 *(_Age = 'F3'_ and _Sex = 'M'_)

The main effects model was:
 _Days_ = 2.52 - 0.62*(_Eth = 'N'_) - 0.11*(_Age = 'F1'_) + 0.53*(_Age = 'F2'_) + 0.59*(_Age = 'F3'_) + 0.12*(_Sex = 'M'_) + 0.32*(_Lrn = 'SL'_)

In the plot of actual vs predicted days of absence for the final model is presented below. The red line is a line of best fit through the data and the blue a spline. These are used to show the trend. Note that the groups created by the model don't correspond very well with the actual data.

![Plot of actual versus predicted values for training data](https://cloud.githubusercontent.com/assets/7769706/21584167/3db841b4-d0f1-11e6-94ac-53d20a654c69.png)


#### Discussion:
The final model was not good at predicting the number of days a student was be absent. The predicted vs actual plots showed a wide scatter, which indicated that many students were having their absences over- or under-estimated. Thus we would not recommend using this model to identify high-risk groups.
 
The analysis of single variables shows that the median number of absent days for indigenous students is higher than non-indigenous students (better to look at the median, given the skewed distributions). However given the model does not perform well, we think that there are probably underlying factors which correlate with ethnicity that would be more useful in describing groups that are at risk of high levels of absenteeism. The main effects model (that is, the model with no interactions included) suggests that ethnicity is probably the best indicator of those factors which were collected, so if this is the best data you can gather then you could tentatively use this result to inform further action. However this analysis does not imply any causality and does not give strong predictive results. We would be very hesitant to generalise any findings based on this data, given the limited scope of the study and the variables collected. 

Finally, and we think most importantly, there are issues with the design of the study and the data collected, which limit the usefulness of this analysis. These issues are:

1. There are only a small number of data points, including only students from one school over just one year:
  * To understand factors which correlate with absenteeism, we think that following individuals over time might be more useful, to see the behavioural development and also to possibly identify events and circumstances that trigger this behaviour.
  * This data only covers Walgett, a small, rural town. Ideally this data would be collected from a large sample of schools, both rural and urban. This would allow for more informative and robust results. It might also suggest some ways to reduce student absences by comparing high performing with low performing schools - however that is outside the scope of this analysis.
2. Some possibly useful explanatory variables are missing.
  * Factors we would like to test: family socioeconomic status, parental employment/unemployment, parental educational level. These often crop up in explaining education outcomes for students and it seems like a big omission not to test them here.
  * A qualitative study to support this analysis would have been helpful to determine what kind of factors might be important in absenteeism. The factors measured are easy to measure, but do suggest to us a pre-judgement of which factors would correlate with absence from school.

#### Conclusion:
The analysis did not provide a good model for identifying students at risk of absenteeism. It did provide a possible starting point for answering the question, but given the limitations of the data, further study is required.
