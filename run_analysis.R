library(data.table)
fileurl = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(fileurl,'./UCI HAR Dataset.zip', mode = 'wb')
unzip("UCI HAR Dataset.zip", exdir = getwd())

#1.merges the training and the test data sets to create one data set
#read features dataset
features<-read.table("./UCI HAR Dataset/features.txt",sep=" ",header=F)
features<-as.character(features[,2])
#read trainning datasets
train_subject<-read.table("./UCI HAR Dataset/train/subject_train.txt",header=F)
train_X<-read.table("./UCI HAR Dataset/train/X_train.txt", header=F)
train_y<-read.table("./UCI HAR Dataset/train/y_train.txt", header=F)
#combine trainning datasets
train<-data.frame(train_subject,train_y,train_X)
colnames(train)<-c(c("subject","activity"),features)
#read test datasets
test_subject<-read.table("./UCI HAR Dataset/test/subject_test.txt",header=F)
test_X<-read.table("./UCI HAR Dataset/test/X_test.txt", header=F)
test_y<-read.table("./UCI HAR Dataset/test/y_test.txt", header=F)
#combine test datasets
test<-data.frame(test_subject,test_y,test_X)
colnames(test)<-c(c("subject","activity"),features)
#combine the trainning and test datasets into one
all<-rbind(train,test)

#2.Extracts only the measurements on the mean and standard deviation for each measurement
mean_features<-features[grep("mean|std",features)]
all_subset<-all[mean_features]
all_subset2<-cbind(all[,c(1,2)],all_subset)

#3.Uses descrptive activity names to name the activivtes in the data set
label<-read.table("./UCI HAR Dataset/activity_labels.txt",sep=" ",header=F)
colnames(label)<-c("ID","activity_label")
head(label)
label<-as.character(label[,2])
all_subset2$activity<-label[all_subset2$activity]

#4.appropriately labels the data set with descriptive variable names
new_colname<-colnames(all_subset2)
new_colname<-gsub("^t","timedomain_",new_colname)
new_colname<-gsub("^f","frequencydomain_",new_colname)
new_colname<-gsub("Acc","Accelerometer",new_colname)
new_colname <- gsub("Gyro", "Gyroscope", new_colname)
new_colname <- gsub("Mag", "Magnitude", new_colname)
new_colname <- gsub("-mean-", "_Mean_", new_colname)
new_colname <- gsub("-std-", "_StandardDeviation_", new_colname)
new_colname <- gsub("-", "_", new_colname)
new_colname <- gsub("[(][)]", "", new_colname)
colnames(all_subset2) <- new_colname

#5. from the data set in step 4, create a second, independent tidy data set 
#with the average of each variable for each activity and each subject
all_subset_tidy<-aggregate(all_subset2[,3:81], by = list(activity = all_subset2$activity, subject = all_subset2$subject),FUN = mean)
write.table(x = all_subset_tidy, file = "All_tidy.txt", row.names = FALSE)
