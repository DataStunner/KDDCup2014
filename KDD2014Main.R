#KDD Cup 2014
#No more initial comments now that I know there are people reading this
#version 0.1

#########################
#Init
rm(list=ls(all=TRUE))

#Load/install libraries
require('tm')
require('psych')
require('Matrix')
require('glmnet')
require('gbm')
require('ggplot2')
require('Metrics')

#Set Working Directory
workingDirectory <- '~/Wacax/Kaggle/KDD Cup 2014/KDD Cup 2014/'
setwd(workingDirectory)

dataDirectory <- '~/Wacax/Kaggle/KDD Cup 2014/Data/'

#Load functions
source(paste0(workingDirectory, 'text2Matrix.R'))
source(paste0(workingDirectory, 'gridCrossValidationGBM.R'))
source(paste0(workingDirectory, 'extractBestTree.R'))
source(paste0(workingDirectory, 'correlationsAndTest.R'))

#############################
#Load Data
#Input Data

#Essay Length
essayNames <- names(read.csv(paste0(dataDirectory, 'essays.csv'), nrows = 1000, stringsAsFactors = FALSE))
essayClasses <- sapply(read.csv(paste0(dataDirectory, 'essays.csv'), nrows = 1000, stringsAsFactors = FALSE), class)

essays <- read.csv(paste0(dataDirectory, 'essays.csv'), header = TRUE, 
                   colClasses = essayClasses, col.names = essayNames,
                   stringsAsFactors = FALSE)

essaysLength <- with(essays, nchar(essay)) 
save(essaysLength, file = 'essaysLength.RData')
rm(essays)

#Essay Bag-Of Words
numberOfDivisions <- 1000 #change this to make bigger or smaller fragments/chunks to analyze later
numberOfEssays <- 664098 #do not change unless there is a new dataset
rowsToRead <- numberOfEssays / numberOfDivisions
if(numberOfEssays %% numberOfDivisions == 0){
  rowsToRead <- rep(rowsToRead, numberOfDivisions)
}else{
  rowsToRead <- c(rep(ceiling(rowsToRead), numberOfEssays %% numberOfDivisions), rep(floor(rowsToRead), numberOfDivisions - numberOfEssays %% numberOfDivisions))
}
#function testing
ifelse(sum(rowsToRead) == numberOfEssays, print(paste('Processing', rowsToRead[1], 'essays at a time')), 
       print(paste('function will not compute all essays. Leaving out', numberOfEssays - sum(rowsToRead), 'essays')))

#create here the loop
#essaysCorpora <- text2Matrix('dummy corpora', sparse = TRUE,  Sparsity = 0.9)
#for(i in 1:numberOfDivisions){
for(i in 1:2){
  essays <- read.csv(paste0(dataDirectory, 'essays.csv'), header = ifelse(i == 1, TRUE, FALSE), 
                   nrows = rowsToRead[i], skip = ifelse(i == 1, 0, sum(rowsToRead[1:i - 1])), 
                   colClasses = essayClasses, col.names = essayNames,
                   stringsAsFactors = FALSE)
  
  #essaysCorpora <- c(essaysCorpora, text2Matrix(essays$need_statement, sparse = TRUE, Sparsity = 0.9))
  #if(i == 1){essaysCorpora <- essaysCorpora[-1, ]}
  print(paste(i, 'of', numberOfDivisions))
}

#essaysCorpora <- weightTfIdf(essaysCorpora)

#Train and Test
projects <- read.csv(paste0(dataDirectory, 'projects.csv'), header = TRUE, stringsAsFactors = FALSE, na.strings=c("", "NA", "NULL"))
resources <- read.csv(paste0(dataDirectory, 'resources.csv'), header = TRUE, stringsAsFactors = FALSE, na.strings=c("", "NA", "NULL"))

#Just Train
outcomes <- read.csv(paste0(dataDirectory, 'outcomes.csv'), header = TRUE, stringsAsFactors = FALSE, na.strings=c("", "NA", "NULL"))
donations <- read.csv(paste0(dataDirectory, 'donations.csv'), header = TRUE, stringsAsFactors = FALSE, na.strings=c("", "NA", "NULL"))

#Template
submissionTemplate <- read.csv(paste0(dataDirectory, 'sampleSubmission.csv'), header = TRUE, stringsAsFactors = FALSE, na.strings=c("", "NA", "NULL"))

################################################################
#Preprocessing
projects <- transform(projects, school_city = as.factor(school_city), school_state = as.factor(school_state),
                      school_metro = as.factor(school_metro), school_charter = as.factor(school_charter), 
                      school_magnet = as.factor(school_magnet), school_year_round = as.factor(school_year_round), 
                      school_nlns = as.factor(school_nlns), school_kipp = as.factor(school_kipp), 
                      school_charter_ready_promise = as.factor(school_charter_ready_promise), 
                      teacher_prefix = as.factor(teacher_prefix), teacher_teach_for_america = as.factor(teacher_teach_for_america),
                      teacher_ny_teaching_fellow = as.factor(teacher_ny_teaching_fellow), primary_focus_subject = as.factor(primary_focus_subject),
                      primary_focus_area = as.factor(primary_focus_area), secondary_focus_subject = as.factor(secondary_focus_subject),
                      secondary_focus_area = as.factor(secondary_focus_area), resource_type = as.factor(resource_type),
                      poverty_level = as.factor(poverty_level), grade_level = as.factor(grade_level),
                      fulfillment_labor_materials = as.factor(fulfillment_labor_materials),
                      eligible_double_your_impact_match = as.factor(eligible_double_your_impact_match), eligible_almost_home_match = as.factor(eligible_almost_home_match),
                      date_posted = as.Date(date_posted, format = '%Y-%m-%d')
                      )

resources <- transform(resources, project_resource_type = as.factor(project_resource_type), 
                       vendorid = as.factor(vendorid)
                       )
#Outcomes to predict
y <- as.factor(outcomes$is_exciting)
save(y, file = 'y.RData')

#Create Train and Test dataframes
#Projects Indices Train 
indicesTrainProjects <- match(outcomes$projectid, projects$projectid)
save(indicesTrainProjects, file = 'indicesTrainProjects.RData')
#resources Indices Train 
indicesTrainResources <- match(outcomes$projectid, resources$projectid)
save(indicesTrainResources, file = 'indicesTrainResources.RData')
#Essays Indices Train
indicesTrainEssays <- match(outcomes$projectid, essays$projectid)
save(indicesTrainEssays, file = 'indicesTrainEssays.RData')

#Indices Test
#Projects
indicesTestProjects <- match(submissionTemplate$projectid, projects$projectid)
save(indicesTestProjects, file = 'indicesTestProjects.RData')
#Resources
indicesTestResources <- match(submissionTemplate$projectid, resources$projectid)
save(indicesTestResources, file = 'indicesTestResources.RData')
#Essays
indicesTestEssays <- match(submissionTemplate$projectid, essays$projectid)
save(indicesTestEssays, file = 'indicesTestEssays.RData')


#Merge
train <- 

test <- 


################################################################
#EDA
#Unique Samples
ggplot(as.data.frame(y), aes(y)) + geom_histogram()
isExitingProbabilities <- table(y) / length(y)

str(projects)
apply(projects, 2, function(vector){return(length(unique(vector)))})
str(resources)
apply(resources, 2, function(vector){return(length(unique(vector)))})

#Find correlations between data
rowProjects <- 50000
#rowProjects <- nrow(projects)
correlationsProjectsList <- correlationsAndTest(projects[indicesTrainProjects[1:rowProjects], c(30, 31, 32)], y[1:rowProjects])
correlationsResourcesList <- correlationsAndTest(resources[indicesTrainProjects[1:rowProjects], c(30, 31, 32)], y[1:rowProjects])

#Cross-validation Projects Model



