## Install and load libraries if not already done
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


## Download and unzip the dataset if not already done
if (!file.exists("UCI HAR Dataset")) { 
    filename <- "FUCIDataset.zip"
    if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, filename, method="curl")
    }  
    unzip(filename) 
}

##############
### 1. Merges the training and the test sets to create one data set.
# Reading Measurements
testMeasurements <- read.csv("UCI HAR Dataset/test/X_test.txt", sep = "", header = FALSE)
testMeasurements$ObsType <- rep("TEST",nrow(testMeasurements))
trainMeasurements <- read.csv("UCI HAR Dataset/train/X_train.txt", sep = "", header = FALSE)
trainMeasurements$ObsType <- rep("TRAIN",nrow(trainMeasurements))
measurements <- rbind(testMeasurements,trainMeasurements)
observations <- measurements$ObsType
measurements$ObsType <- NULL
rm(testMeasurements, trainMeasurements)

##############
### 2. Extracts only the measurements on the mean and standard deviation for each measurement
features <- read.table("UCI HAR Dataset/features.txt")
features <- as.character(features[,2])
extraction <- grep(".*mean.*|.*std.*", features)
measurements <- measurements[extraction]
features <- features[extraction]
rm(extraction)

##############
### 3. Uses descriptive activity names to name the activities in the data set
# Reading Activities
testActivities <- read.csv("UCI HAR Dataset/test/y_test.txt", sep = "", header = FALSE)
trainActivities <- read.csv("UCI HAR Dataset/train/y_train.txt", sep = "", header = FALSE)
activities <- data.frame(rbind(testActivities, trainActivities))
activities_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activities_labels <- as.character(activities_labels[,2])
activities <- activities_labels[activities$V1]
rm(testActivities, trainActivities, activities_labels)

##############
### 4. Appropriately labels the data set with descriptive variable names
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

##############
### 5. From the data set in step 4, creates a second, independent tidy data set 
###    with the average of each variable for each activity and each subject.
second_tidy <- cbind(subjects,activities,measurements)
second_tidy <- second_tidy %>% 
    group_by(subjects, activities) %>%  
    summarise_all(funs(mean))
rm(subjects,activities,measurements)

##############
### Export the results into files
write.table(first_tidy, "first_tidy.txt", row.names = FALSE, quote = FALSE)
write.table(second_tidy, "second_tidy.txt", row.names = FALSE, quote = FALSE)

#rm(first_tidy,second_tidy)
