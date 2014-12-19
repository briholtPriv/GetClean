getwd()
#for latitutde
setwd("/home/brian/Projects/Coursera/GetAndClean/data/UCI HAR Dataset/")
dir()

#for dater
setwd("/home/brian/Projects/Coursera/GetAndCleanData/data/UCI HAR Dataset")


#for windater
setwd("C:\\Users\\Brian\\Documents\\Projects\\GetClean\\data\\UCI HAR Dataset")

########
######
#Create Table for Test Data 

subject_test<-read.table("./test/subject_test.txt",sep="")
X_test<-read.table("./test/X_test.txt",sep="")
Y_test<-read.table("./test/y_test.txt",sep="")
test_set<-cbind(subject_test,Y_test,X_test)

######
#Create Table for train Data 

subject_train<-read.table("./train/subject_train.txt",sep="")
X_train<-read.table("./train/X_train.txt",sep="")
Y_train<-read.table("./train/y_train.txt",sep="")
train_set<-cbind(subject_train,Y_train,X_train)

######
#Create "Set" Variable to differentiate train from test in final data
test_set$Set<-1
train_set$Set<-0

###Merge test and train set, then sort by 1st column (subject)
full_data<-rbind(test_set,train_set)
dim(full_data)
full_data<-full_data[order(full_data[,1]),]


####
#Varialbes name manipulation

Activities<-read.table("./activity_labels.txt",sep="") #lists activities by name
Features<- read.csv("./features.txt",sep="",header=F) #561 list of features
table1<-sort(table((Features[,2])),decreasing=T) #creates table to find duplicates
table1[table1>1] #lists duplicates; none have "mean" or "std"

grep("mean|std",names(table1[table1>1]),ignore.case=T) #confirms list doesn't contain mean/std
grep("mean|std",Features[,2],ignore.case=T,value=T)

#####
#Rename columns and activity
fullColNames<-make.names(Features[,2],unique=T)
fullColNames<-c("Subject","Activity",fullColNames,"Set")
colnames(full_data)<-fullColNames
head(names(full_data))

KeptColumns<-grep("subject|activity|mean|std",fullColNames,ignore.case=T,value=F)
tidy<-full_data[,KeptColumns]

str(tidy)

tidy$Activity<-with(tidy,ifelse(tidy$Activity==1,"Walk",
                                         ifelse(tidy$Activity==2,"Walk_Up",
                                                ifelse(tidy$Activity==3,"Walk_Down",
                                                       ifelse(tidy$Activity==4,"Sit",
                                                              ifelse(tidy$Activity==5,"Stand","Lay"))))))


######
#melt the data
library("dplyr")
library("tidyr")

long_tidy<-gather(data=tidy,feature, value, tBodyAcc.mean...X:angle.Z.gravityMean. , na.rm = TRUE)

final<-summarize(group_by(long_tidy,Subject,Activity,feature),mean(value))

#quick sanity check to see if this data produces similar data to that posted in FAQ by "Brandon"
final[final$Subject == 1 ,]


