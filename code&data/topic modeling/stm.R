#load libraries
library("stm")
library("quanteda")
library('readtext')
library(tidyverse)
library('openxlsx')


#load preprocessed document-frequency matrix dataset
load('/dfm2stm.RData')

#compare stm models with different K(topic num) 
kresult1 <- searchK(dfm2stm$documents, dfm2stm$vocab, K = c(20,30,40,50,60,70,80,90,100),
                    max.em.its = 150, data = dfm2stm$meta)

plot(kresult1)

# build stm model
poliblogPrevFit_event_50 <- stm(documents = dfm2stm$documents, vocab = dfm2stm$vocab,
                                K = 50, data = dfm2stm$meta)

# save model
save(poliblogPrevFit_event_50,file='./stm models 50 topics new.RData')

# load existing model used in the paper
load('/stm models 50 topics.RData')

selectedmodel=poliblogPrevFit_event_50

#example articles for each topic
topic_num <- 50

thought_list <- vector(mode = "list", length = topic_num)
for (i in 1:topic_num)
{
  thoughts <- findThoughts(selectedmodel, texts = dfm2stm$meta$`ÕýÎÄ`,  n =1, topics = i)$docs[[1]]
  thought_list[i] <- thoughts
}

####print top words&top proportion of each topic
topic_labels <- labelTopics(selectedmodel, 1:topic_num, n=30)
top_words_list <- vector(mode = "list", length = topic_num)
topic_labels
for (i in 1:topic_num){
  top_words_list[i] <- paste(topic_labels$prob[i,],collapse=" ")
}

stm_result_table <- as.data.frame(cbind(unlist(thought_list),unlist(top_words_list))) 

write.xlsx(stm_result_table,file = './stm_result_table 50topics.xlsx')

########## construct document-topic proportion matrix
stm_dt <- make.dt(selectedmodel, meta = dfm2stm$meta)

write.csv(stm_dt,file = "./dtm_20_topics.csv",
          row.names = F,fileEncoding='utf-8')
