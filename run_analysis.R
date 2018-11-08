#check to see if file exists, if not create file
>if(!file.exists("./Getting and Cleaning Data Assignment")){dir.create("./Getting and Cleaning Data Assignment")}

#set working directory 
>setwd("~/Getting and Cleaning Data Assignment")

#download file
> download.file(fileUrl,destfile="./Dataset.zip",method="curl")
#unzip file into new directory "data"
> unzip(zipfile="./Dataset.zip",exdir="./data")

# "data" directory contains "UCI HAR Dataset" directory within

library(dplyr)
library(data.table)
library(tidyr)

#set location to store tables
>filesPath<-"/Users/tonychour/Getting and Cleaning Data Assignment/data/UCI HAR Dataset"

#read subject files and create data table
>dataSubjectTrain<-tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))
>dataSubjectTest  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))

# Read activity files and create data table
>dataActivityTrain <- tbl_df(read.table(file.path(filesPath, "train", "Y_train.txt")))
>dataActivityTest  <- tbl_df(read.table(file.path(filesPath, "test" , "Y_test.txt" )))

#Read data files and create data table
>dataTrain <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))
>dataTest  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))

#merge subject files and change name of column from "V1" to "subject"
> mergedSubjectfile<-rbind(dataSubjectTrain, dataSubjectTest)
> setnames(mergedSubjectfile, "V1", "subject")

#merge activity files and change name of column from "V1" to "activityNum"
> alldataActivity<- rbind(dataActivityTrain, dataActivityTest)
> setnames(alldataActivity, "V1", "activityNum")

#combine the DATA training and test files
dataTable <- rbind(dataTrain, dataTest)

#set variable names according to feature
dataFeatures <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
colnames(dataTable) <- dataFeatures$featureName

#column names for activity labels
activityLabels<- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))

#merge columns
mergedSubjectfile<- cbind(mergedSubjectfile, alldataActivity)
dataTable <- cbind(mergedSubjectfile, dataTable)

#reading features.txt and extracting mean and std
dataFeaturesMeanSTd<-grep("mean\\(\\)|std\\(\\)",dataFeatures$featureName,value=T)

# Taking only measurements for the mean and standard deviation and add "subject","activityNum"
dataFeaturesMeanStd <- union(c("subject","activityNum"), dataFeaturesMeanStd)
dataTable<- subset(dataTable,select=dataFeaturesMeanStd) 

##enter name of activity into dataTable
dataTable <- merge(activityLabels, dataTable , by="activityNum", all.x=TRUE)
dataTable$activityName <- as.character(dataTable$activityName)

## create dataTable with variable means sorted by subject and Activity
dataTable$activityName <- as.character(dataTable$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = dataTable, mean) 
dataTable<- tbl_df(arrange(dataAggr,subject,activityName))

