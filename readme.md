Predicting human activity from smartphone data
==============================================

Introduction
------------
 Anguita et al. has attempted to classify physical activity such as walking, sitting, going up and down stairs, etc.  from smartphone data, using novel machine-learning techniques.
For a provided portion of Anguita et al.’s (Ref 1) smartphone data set, we use a [classification-tree] [2] approach to build a model to predict the type of physical activity associated with smartphone measurements. The final model uses a [random forest] [3] with rudimentary feature extraction, in which correlation coefficients are used to filter unnecessary variables.

Data Collection
---------------
The Activity set was provided by the Data Analysis course on Coursera. This data set originated from the [“Human Activity Recognition Using Smartphones Data Set” at the UCI Machine Learning Respository] [4]. In these experiments, a Samsung Galaxy SII phone was strapped to a subject’s waist and accelerometer and gyroscope measurements of their activities were collected. The data set was downloaded from https://spark-public.s3.amazonaws.com/dataanalysis/samsungData.rda on February 26, 2013. 
A target misclassification error rate was selected based on existing literature. Several classification trees were generated and evaluated. Meanwhile, random forests were also created and compared. In some cases, variables were filtered based on their [Spearman correlation coefficients] [5]. The models were evaluated based on misclassification, [GINI index] [6] , complexity and other parameters where applicable.

Results
-------
The Spearman correlation coefficients were calculated for each pair of variables  and used as a rudimentary filter for feature extraction.  In this case, a correlation coefficient threshold of |ρ|>0.95 was used to remove one of a pair of correlated variables. By using this method, 362 variables were filtered out, leaving 201 variables for model building.)

The final random forest model was generated from the filtered training set, containing 150 trees with 12 variables tried at each split. [Cross-validation] [7] occurred during model generation, and the model’s out-of-bag estimate was 1.42%. 
The mean decreases in GINI coefficients were evaluated for the model. Four of the top five most important variables are related to gravitational acceleration. A possible reason for this is that as indicated previously, the direction of gravitational acceleration relative to the smartphone seems to be a good indicator of body orientation (laying versus upright). Also, during movement, each axis likely has a lower mean gravitational acceleration when compared to results from stationary activity. 

**Table 1.** Confusion matrix for the final random forest with correlation-based feature filtering when applied to the test set. Rows show the actual activity, while columns indiate the predicted activity.
<table>
<tr>
	<th>Activity</th><th>Laying</th><th>Sitting</th><th>Standing</th><th>Walking</th><th>Downstairs</th><th>Upstairs</th><th>Sensitivity</th>
</tr>
<tr>
	<td>Laying</td><td>487</td><td>0</td><td>0</td><td>0</td><td>0</td><td>0</td><td>100.0%</td>
</tr>
<tr>
	<td>Sitting</td><td>0</td><td>371</td><td>72</td><td>0</td><td>0</td><td>0</td><td>83.7%</td>
</tr>
<tr>
	<td>Standing</td><td>0</td><td>86</td><td>391</td><td>0</td><td>0</td><td>0</td><td>82.0%</td>
</tr>
<tr>
	<td>Walking</td><td>0</td><td>0</td><td>0</td><td>377</td><td>4</td><td>2</td><td>98.4%</td>
</tr>
<tr>
	<td>Downstairs</td><td>0</td><td>0</td><td>0</td><td>1</td><td>329</td><td>0</td><td>99.7%</td>
</tr>
<tr>
	<td>Upstairs</td><td>0</td><td>0</td><td>0</td><td>2</td><td>2</td><td>356</td><td>98.9%</td>
</tr>
<tr>
	<td>Positive Predictive Value</td><td>100.0%</td><td>81.2%</td><td>84.4%</td><td>99.2%</td><td>98.2%</td><td>99.4%</td><td>93.2%</td>
</tr>
</table>

The final random forest model was run on the test set to predict the activity of each observation; the resulting confusion matrix is in **Table 1**. The test set misclassification error rate is **6.8%**. The activities with significant movement (normal walking, walking downstairs, and walking upstairs) have classification rates >98%, while the predictions for laying are all correct. However, the worse predictions are for sitting and standing, and apparently it is difficult to distinguish between the two in some cases. This may be because these two activities are stationary (low energy) and require similar upper-body positions and hence little difference in gravitational direction.

Data Analysis Issues
--------------------
Since I was still learning statistics, I did not realize at the time that I should have ensured that the relevant data was [IID] [8] before proceeding. Also, there is some question of using cross-validation with random forests; [Breiman and Cutler] [3] imply that cross-validation is inherently part of the random-forest creation process, but other statistics students I talked felt that this was not "real" cross-validation, but I'm still unclear as how to do this with random forests. Finally, I ignored subject-to-subject variation in this analysis.


Conclusion
----------
The final random forest model with correlation-based feature extraction is reasonably successful at predicting human daily activity. However, the model could be improved by implementing better feature extraction methods. While correlation coefficients are used here, other techniques such as chi-squared testing could yield better results. Additionally, the bulk of the data provided is the result of select transforms done on raw time-domain signals from the sensors. A better selection of transforms on the raw signals could further improve prediction accuracy of future models.

 
References
----------
1: Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. “Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine”. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012.
[2]: http://en.wikipedia.org/wiki/Decision_tree_learning "Decision Tree Learning"
[3]: http://www.stat.berkeley.edu/~breiman/RandomForests/cc_home.htm "Random Forests"
[4]: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones “Human Activity Recognition Using Smartphones Data Set”
[5]: http://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient “Spearman’s Rank Correlation Coefficient”
[6]: http://en.wikipedia.org/wiki/Gini_coefficient “GINI Coefficient”
[7]: http://en.wikipedia.org/wiki/Cross-validation_(statistics) “Cross-Validation (Statistics)”
[8]: http://en.wikipedia.org/wiki/IID "Independent and Identically Distributed Variables"


