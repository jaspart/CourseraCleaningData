# Getting and Cleaning Data Course Project : cookbook

### How to
Run this script without any pre requisits (except running it in R) by sourcing the file:
`source("run_analysis.R")`
The script will create 2 files:
* first_tidy.txt : The mean and standard deviation tidy data set of each observation.
* second_tidy.txt : The average of the mean and standard deviation for each tuples (activity , subject).

### Program description
The script prepares the environment by installing and loading the necessary packages:
* dplyr
* data.table

Then it downloads the data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.
And it proceeds to the cleaning according to the following steps:
1. Merges the training and the test sets to create one data set.
1. Extracts only the measurements on the mean and standard deviation for each measurement.
1. Uses descriptive activity names to name the activities in the data set
1. Appropriately labels the data set with descriptive variable names.
1. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Data information
The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions :
* tBodyAcc-XYZ
* tGravityAcc-XYZ
* tBodyAccJerk-XYZ
* tBodyGyro-XYZ
* tBodyGyroJerk-XYZ
* tBodyAccMag
* tGravityAccMag
* tBodyAccJerkMag
* tBodyGyroMag
* tBodyGyroJerkMag
* fBodyAcc-XYZ
* fBodyAccJerk-XYZ
* fBodyGyro-XYZ
* fBodyAccMag
* fBodyAccJerkMag
* fBodyGyroMag
* fBodyGyroJerkMag

The set of variables that were estimated from these signals are: 
* mean(): Mean value
* std(): Standard deviation
* mad(): Median absolute deviation 
* max(): Largest value in array
* min(): Smallest value in array
* sma(): Signal magnitude area
* energy(): Energy measure. Sum of the squares divided by the number of values. 
* iqr(): Interquartile range 
* entropy(): Signal entropy
* arCoeff(): Autorregresion coefficients with Burg order equal to 4
* correlation(): correlation coefficient between two signals
* maxInds(): index of the frequency component with largest magnitude
* meanFreq(): Weighted average of the frequency components to obtain a mean frequency
* skewness(): skewness of the frequency domain signal 
* kurtosis(): kurtosis of the frequency domain signal 
* bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
* angle(): Angle between to vectors.

Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:
* gravityMean
* tBodyAccMean
* tBodyAccJerkMean
* tBodyGyroMean
* tBodyGyroJerkMean

The complete list of variables of each feature vector is available in 'features.txt':

The activity are labelled as follow:
1 WALKING
2 WALKING_UPSTAIRS
3 WALKING_DOWNSTAIRS
4 SITTING
5 STANDING
6 LAYING


### Code book
#### Install and load libraries if not already done
```
if (!"dplyr" %in% installed.packages()) {
    warning("The package dplyr is required : Installing it now.")
    install.packages("dplyr")
}
if (!"data.table" %in% installed.packages()) {
    warning("The package data.table is required : Installing it now.")
    install.packages("data.table")
}
library(dplyr)
library(data.table)
```

#### Download and unzip the dataset if not already done
```
if (!file.exists("UCI HAR Dataset")) { 
    filename <- "FUCIDataset.zip"
    if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, filename, method="curl")
    }  
    unzip(filename) 
}
```
#### 1. Merges the training and the test sets to create one data set.
```
# Reading Measurements
testMeasurements <- read.csv("UCI HAR Dataset/test/X_test.txt", sep = "", header = FALSE)
testMeasurements$ObsType <- rep("TEST",nrow(testMeasurements))
trainMeasurements <- read.csv("UCI HAR Dataset/train/X_train.txt", sep = "", header = FALSE)
trainMeasurements$ObsType <- rep("TRAIN",nrow(trainMeasurements))
measurements <- rbind(testMeasurements,trainMeasurements)
observations <- measurements$ObsType
measurements$ObsType <- NULL
rm(testMeasurements, trainMeasurements)
```

#### 2. Extracts only the measurements on the mean and standard deviation for each measurement
```
features <- read.table("UCI HAR Dataset/features.txt")
features <- as.character(features[,2])
extraction <- grep(".*mean.*|.*std.*", features)
measurements <- measurements[extraction]
features <- features[extraction]
rm(extraction)
```
#### 3. Uses descriptive activity names to name the activities in the data set
```
# Reading Activities
testActivities <- read.csv("UCI HAR Dataset/test/y_test.txt", sep = "", header = FALSE)
trainActivities <- read.csv("UCI HAR Dataset/train/y_train.txt", sep = "", header = FALSE)
activities <- data.frame(rbind(testActivities, trainActivities))
activities_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activities_labels <- as.character(activities_labels[,2])
activities <- activities_labels[activities$V1]
rm(testActivities, trainActivities, activities_labels)
```
#### 4. Appropriately labels the data set with descriptive variable names
```
# Load the measurement feature names
features <- gsub('-mean', 'Mean', features)
features <- gsub('-std', 'Std', features)
features <- gsub('[-()]', '', features)
features <- gsub(',', '_', features)
colnames(measurements) <- as.character(features)
rm(features)

# Reading Subject
testSubjects <- read.csv("UCI HAR Dataset/test/subject_test.txt", sep = "", header = FALSE)
trainSubjects <- read.csv("UCI HAR Dataset/train/subject_train.txt", sep = "", header = FALSE)
subjects <- rbind(testSubjects, trainSubjects)
subjects <- paste("Subject_", sprintf("name_%02d", subjects$V1), sep="")
rm(testSubjects, trainSubjects)

# Bind Observation, Subjects, Activity and Measurements
first_tidy <- cbind(observations,subjects,activities,measurements)
rm(observations)
```
#### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```
second_tidy <- cbind(subjects,activities,measurements)
second_tidy <- second_tidy %>% 
    group_by(subjects, activities) %>%  
    summarise_all(funs(mean))
rm(subjects,activities,measurements)
```
#### 5. Export the results into files
```
write.table(first_tidy, "first_tidy.txt", row.names = FALSE, quote = FALSE)
write.table(second_tidy, "second_tidy.txt", row.names = FALSE, quote = FALSE)

#rm(first_tidy,second_tidy)
```

### Variables
The input variables are:
* measurements : the Samsung sensor measurements
* observations : the type of observations (training or testing)
* features : the feature names (sensor/axis/data type/...)
* activities : the activity names (laying, sitting, walking, ...)

The output files are:
* first_tidy.txt : the measurement tidy data (with labelled non numerical variables and measurement numerical variables).
* second_tidy.txt : the average of the numerical variables grouped by subjects and activities.

### Description
The purpose of this project is to demonstrate the ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

This program contains the following steps :
1. Merges the training and the test sets to create one data set.
1. Extracts only the measurements on the mean and standard deviation for each measurement.
1. Uses descriptive activity names to name the activities in the data set
1. Appropriately labels the data set with descriptive variable names.
1. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
