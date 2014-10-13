#----------------------------------------------------------------------------
# run_analysis.R
# Getting and Cleaning Data    - Project #1
# 
# The script should;
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for
#    each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data
#   set with the average of each variable for each activity and each subject.
#----------------------------------------------------------------------------
library(plyr)
library(dplyr)

# Get the zip file if we don't have it already
zipUrl  <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "./getdata-projectfiles-UCI HAR Dataset.zip"
dir     <- "./UCI HAR Dataset/"

if (!file.exists(zipFile)) {
  download.file(zipUrl, zipFile, 'curl')
}

# Unzip the archive
if (file.exists(zipFile)) {
  unzip(zipFile, overwrite = TRUE)
}

# Load the various tables
featureFile        <- paste(dir, "features.txt", sep="")
xTrainFile         <- paste(dir, "train/X_train.txt", sep="")
xTestFile          <- paste(dir, "test/X_test.txt", sep="")
yTrainFile         <- paste(dir, "train/Y_train.txt", sep="")
yTestFile          <- paste(dir, "test/Y_test.txt", sep="")
subjectTrainFile   <- paste(dir, "train/subject_train.txt", sep="")
subjectTestFile    <- paste(dir, "test/subject_test.txt", sep="")
activityLabelsFile <- paste(dir, "activity_labels.txt", sep="")

# Get the descriptive variable names from features.txt
featuresCSV <- read.csv(featureFile, stringsAsFactors = FALSE, header=FALSE, sep=" ")
features    <- tbl_df(featuresCSV)
features    <- rename(features, c("V1" = "FeatureID", "V2" = "FeatureLabel"))

# Add "_avg" to each variable name from features.txt
# However, the ones that don't contain "mean" or "std" will get removed down below
colNames    <- paste(features$FeatureLabel, "avg", sep = "_")

# Merge the train and test datasets
xTrainTbl <- read.table(xTrainFile, header=FALSE, col.names = colNames, check.names=FALSE)
xTestTbl  <- read.table(xTestFile, header=FALSE, col.names = colNames, check.names=FALSE)
xTrainTbl <- rbind(xTrainTbl, xTestTbl)

xTrain <- tbl_df(xTrainTbl)

# Get rid of data no longer needed in memory
rm("xTrainTbl")
rm("xTestTbl")

# Extract only measurements on the mean and standard deviation for each measurement
xTrain <- select(xTrain, matches("mean", ignore.case = FALSE), matches("std", ignore.case=FALSE))

# Merge the train and test subjects
subjectTrainTbl <- read.table(subjectTrainFile, header=FALSE, col.names=c("Subject"))
subjectTestTbl  <- read.table(subjectTestFile, header=FALSE, col.names=c("Subject"))
subjectTrainTbl <- rbind(subjectTrainTbl, subjectTestTbl)

# Add Subject to main table
xTrain <- mutate(xTrain, Subject = subjectTrainTbl$Subject)
# Get rid of data no longer needed in memory
rm("subjectTrainTbl")
rm("subjectTestTbl")

# Get descriptive activity names from activity_labels.txt
# to name the activities in the data set
activityLabelsTbl <- read.table(activityLabelsFile, header=FALSE, col.names=c("ActivityID", "Activity"))
activityLabels    <- tbl_df(activityLabelsTbl)
# Get rid of data no longer needed in memory
rm("activityLabelsTbl")

# Merge the train and test activities
yTrainTbl <- read.table(yTrainFile, header=FALSE, col.names=c("ActivityID"))
yTestTbl <- read.table(yTestFile, header=FALSE, col.names=c("ActivityID"))
yTrainTbl <- rbind(yTrainTbl, yTestTbl)
# Get rid of data no longer needed in memory
rm("yTestTbl")

# Add Activity data to main table
xTrain <- mutate(xTrain, ActivityID = yTrainTbl$ActivityID)
xTrain <- inner_join(xTrain, activityLabels, by = c("ActivityID"))

# Group by Subject and Activity and compute mean for each measurement
gTrain <- group_by(xTrain, Subject, Activity)
# Get rid of data no longer needed in memory
rm("xTrain")
allMeans <- summarise_each(gTrain, funs(mean), -ActivityID)

# Save summary table to output file
write.table(allMeans, "./subject-activity-means.txt", append=FALSE, sep=" ", row.names=FALSE, quote=FALSE)

