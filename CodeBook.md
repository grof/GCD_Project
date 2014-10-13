As prescribed by Kirsten Frank in [this dicussion forum thread](https://class.coursera.org/getdata-007/forum/thread?thread_id=28), this CodeBook describes the variables and transformations they went through to produce the resulting data set.

### Source data files
The zip file that carries the source data for this project contains a number of different files.  The files that are of interest to us are:

 * 'features.txt': List of all features.
 * 'activity_labels.txt': Links the class labels with their activity name.
 * 'train/X_train.txt': Training set.
 * 'train/y_train.txt': Training labels.
 * 'test/X_test.txt': Test set.
 * 'test/y_test.txt': Test labels.
 * 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. There were 21 subjects who provided data for the training set.
 * 'test/subject_test.txt': Each row identifies the subject who performed the activity for each window sample. There were 9 subjects who provided data for the test set.

### Source data structure
David Hood, one of the community TAs, produce the following diagram that clearly depicts how the various files are related.

![File Structure](/images/Slide2.png)

### Transformations
__Reading in features data__

The original data set has the name of each measurement stored in file features.txt.  This file is read in and both columns are named "FeatureID" and "FeatureLabel" respectively.

__Reading in training and test data and naming columns__

We extract a vector called "colNames" to us as the value of `col.names` when reading the training (train/X_train.txt) and test (test/X_test.txt) data sets.  We add "_avg" to each column name as our end goal is to provide the mean value of each measurement. All columns get renamed that way but some will get removed in a later step as we only want to keep data about means and standard deviations.  We end up with two data frames that have the same column names.

__Merging the training and test data sets to create the main table__

We merge the training datasets using `rbind`.

__Dropping columns that are not needed__

As the project requirements state, we are to only keep the columns that provide measurements for mean and standard deviation.  We interpreted this as keeping columns that matches "mean" and "std" (case sensitively) which is enough to match all column names that contain "mean()" and "std()".  `select` with the relevant `matches` was used here.

__Reading Subject data__

The source data uses data from separate subject files (train/subject_train.txt and test/subject_test.txt) to identify which subject was involved for each row of measurements found in the training and test data sets.  Combined, the two subject files count as many rows as the two data files.  We read both files into data frames and name the only column they contain "Subject". We use `rbind` to merge both sets.

__Adding Subject data to the main table__

As we have 1-to-1 correspondance between the merged data tables and the merged subject tables, we simply need to add a "Subject" column to our main table.  We use `mutate` to add a new "Subject" column to the main table, using data collected in the previous step.

__Reading Activity definitions__

Activity definitions are contained in file activity_labels.txt.  We read this file into a table and name its columns "ActivityID" and "Activity" respectively.  We later use this table in a join with the main table.

__Reading Activity data__

Activity data is stored in two separate files (train/y_train.txt and test/y_test.txt).  Similarly to how subject data is organzied, each row in in both activity data files corrspond 1-to-1 to a row in the associated training or test data files.  We thus first read both activity data files into data frames and name their only column "ActivityID".  Next, we merge both sets using `rbind`.

__Adding Activity data to the main table__

We add the merged activity data into the main table using `inner_join` on the "ActivityID" column.  Our main table is now complete.

__Grouping the main table by Subject and Activity__

As requested by the project requirements, we group the main table using `group_by` on "Subject" and then "Activity"

__Generating the summary table__

Finally, we use `summarise_each` on the grouped-by table to compute the mean of each column using the grouping prescribed in the previous step.


## Data Dictionary


The data contained in the summary table called "subject-activity-means.txt" is the following.

 * Subject: unique identifier for one of the 30 subjects who took part in the study.
 * Activity: identifies one of 6 possible activities subject was performing when measurement was taken.  Activities can be one of: LAYING, SITTING, STANDING, WALKING, WALKING_DOWNSTAIRS and WALKING_UPSTAIRS.

The table is keyed on "Subject" and "Activity".

All the remaining 79 variables that are named "\<measurement\>_avg" refer to the average of the measurements on the mean and standard deviation of measurements captured by the mobile device.  Each \<measurement\> refers to a variable name from the original data set which was described as follows by the authors of the study:

>The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz.

>Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).

>Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals).

>These signals were used to estimate variables of the feature vector for each pattern: '-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

The 79 remaining variables are thus:

 * tBodyAcc-mean()-X_avg
 * tBodyAcc-mean()-Y_avg
 * tBodyAcc-mean()-Z_avg
 * tBodyAcc-std()-X_avg
 * tBodyAcc-std()-Y_avg
 * tBodyAcc-std()-Z_avg
 * tGravityAcc-mean()-X_avg
 * tGravityAcc-mean()-Y_avg
 * tGravityAcc-mean()-Z_avg
 * tGravityAcc-std()-X_avg
 * tGravityAcc-std()-Y_avg
 * tGravityAcc-std()-Z_avg
 * tBodyAccJerk-mean()-X_avg
 * tBodyAccJerk-mean()-Y_avg
 * tBodyAccJerk-mean()-Z_avg
 * tBodyAccJerk-std()-X_avg
 * tBodyAccJerk-std()-Y_avg
 * tBodyAccJerk-std()-Z_avg
 * tBodyGyro-mean()-X_avg
 * tBodyGyro-mean()-Y_avg
 * tBodyGyro-mean()-Z_avg
 * tBodyGyro-std()-X_avg
 * tBodyGyro-std()-Y_avg
 * tBodyGyro-std()-Z_avg
 * tBodyGyroJerk-mean()-X_avg
 * tBodyGyroJerk-mean()-Y_avg
 * tBodyGyroJerk-mean()-Z_avg
 * tBodyGyroJerk-std()-X_avg
 * tBodyGyroJerk-std()-Y_avg
 * tBodyGyroJerk-std()-Z_avg
 * tBodyAccMag-mean()_avg
 * tBodyAccMag-std()_avg
 * tGravityAccMag-mean()_avg
 * tGravityAccMag-std()_avg
 * tBodyAccJerkMag-mean()_avg
 * tBodyAccJerkMag-std()_avg
 * tBodyGyroMag-mean()_avg
 * tBodyGyroMag-std()_avg
 * tBodyGyroJerkMag-mean()_avg
 * tBodyGyroJerkMag-std()_avg
 * fBodyAcc-mean()-X_avg
 * fBodyAcc-mean()-Y_avg
 * fBodyAcc-mean()-Z_avg
 * fBodyAcc-std()-X_avg
 * fBodyAcc-std()-Y_avg
 * fBodyAcc-std()-Z_avg
 * fBodyAcc-meanFreq()-X_avg
 * fBodyAcc-meanFreq()-Y_avg
 * fBodyAcc-meanFreq()-Z_avg
 * fBodyAccJerk-mean()-X_avg
 * fBodyAccJerk-mean()-Y_avg
 * fBodyAccJerk-mean()-Z_avg
 * fBodyAccJerk-std()-X_avg
 * fBodyAccJerk-std()-Y_avg
 * fBodyAccJerk-std()-Z_avg
 * fBodyAccJerk-meanFreq()-X_avg
 * fBodyAccJerk-meanFreq()-Y_avg
 * fBodyAccJerk-meanFreq()-Z_avg
 * fBodyGyro-mean()-X_avg
 * fBodyGyro-mean()-Y_avg
 * fBodyGyro-mean()-Z_avg
 * fBodyGyro-std()-X_avg
 * fBodyGyro-std()-Y_avg
 * fBodyGyro-std()-Z_avg
 * fBodyGyro-meanFreq()-X_avg
 * fBodyGyro-meanFreq()-Y_avg
 * fBodyGyro-meanFreq()-Z_avg
 * fBodyAccMag-mean()_avg
 * fBodyAccMag-std()_avg
 * fBodyAccMag-meanFreq()_avg
 * fBodyBodyAccJerkMag-mean()_avg
 * fBodyBodyAccJerkMag-std()_avg
 * fBodyBodyAccJerkMag-meanFreq()_avg
 * fBodyBodyGyroMag-mean()_avg
 * fBodyBodyGyroMag-std()_avg
 * fBodyBodyGyroMag-meanFreq()_avg
 * fBodyBodyGyroJerkMag-mean()_avg
 * fBodyBodyGyroJerkMag-std()_avg
 * fBodyBodyGyroJerkMag-meanFreq()_avg
