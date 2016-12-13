Instructions






The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.





Review criterialess ?





1.The submitted data set is tidy. 
2.The Github repo contains the required scripts.
3.GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
4.The README that explains the analysis files is clear and understandable.
5.The work submitted for this project is the work of the student who submitted it.




Getting and Cleaning Data Course Projectless ?






The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

You should create one R script called run_analysis.R that does the following. 
1.Merges the training and the test sets to create one data set.
2.Extracts only the measurements on the mean and standard deviation for each measurement. 
3.Uses descriptive activity names to name the activities in the data set
4.Appropriately labels the data set with descriptive variable names. 
5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#set url
url<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
#filename
filename <- "dataset.zip"
#download the dataset
if (!file.exists(path)) {
    dir.create(path)
}
download.file(url, file.path(path, filename))


#Read subject files using fread from the data.tables package
SubjectTrain <- fread(file.path("./", "train", "subject_train.txt"))
SubjectTest <- fread(file.path("./", "test", "subject_test.txt"))

#Read activity files
ActivityTrain <- fread(file.path("./", "train", "Y_train.txt"))
ActivtyTest <- fread(file.path("./", "test", "Y_test.txt"))

#Read data files
DataTrain <- fread(file.path("./", "train", "X_train.txt"))
DataTest <- fread(file.path("./", "test", "X_test.txt"))

#Merge the training and data sets
MergeSubject <- rbind(SubjectTrain, SubjectTest)
MergeActivity <- rbind(ActivityTrain, ActivityTest)
MergeData <- rbind(DataTrain, DataTest)

#rename column headers
colnames(MergeSubject) <- "Subject"
setnames(MergeActivity, "V1", "ActivityNumber")

#Merge Columns
dataSubject <- cbind(MergeSubject, MergeActivity)
dt <- cbind(dataSubject, MergeData)

#read in features and change column names
dtFeatures <- fread(file.path("./", "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))

#subset to get rows for mean and std
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]

#set key for later joining
setkey(dt, Subject, ActivityNumber)

#convert columns names to match columns in dt for later joining
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]

#read descriptive activiyt names
ActivityNames <- fread(file.path("./", "activity_labels.txt"))
setnames(ActivityNames, names(ActivityNames), c("activityNum", "activityName"))

#Merge activyt labels
dt <- merge(dt, ActivityNames, by = "ActivityNumber", all.x = TRUE)

#add activityName as a key
setkey(dt, Subject, ActivityNumber, activityName)

#Melt the data table to reshape it from a short and wide format to a tall and narrow format.

dt <- data.table(melt(dt, key(dt), variable.name = "featureCode"))

#Merge activity name.

dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by = "featureCode", 
    all.x = TRUE)

#Create a new variable,  activity  that is equivalent to  activityName  as a factor class. #Create a new variable,  feature  that is equivalent to  featureName  as a factor class.

dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)




