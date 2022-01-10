#libraries to load
library(tidyverse)
library(vtable)
library (lme4)
library (lmerTest)
library(effects)
library (ggrepel)
library(psycho)


# 1 reading the raw csv ------------------------
allresults_o<-read_csv("...")

# throwing out unnecessary columns and rows
maincol_o<- allresults_o %>% dplyr::select(Parameter, Value, stimulil,  ivl,  SonorityL, FrequencyL, stimulir, ivr, SonorityR, FrequencyR, group, PID, Order.number.of.item) %>% filter (Parameter %in% c("age", "birthplace", "degree", "otherlanguages", "gender", "personal_code", "headphone", "Selection"))

maincol_o$group<-as.numeric(maincol_o$group)



# 2. wrangling data ------------------------

#creating a tibble for form information only
form_o <-maincol_o %>% dplyr::select(PID, Parameter, Value) %>% filter(Parameter %in% c("age", "birthplace", "degree", "otherlanguages", "gender", "personal_code", "headphone")) %>% pivot_wider(names_from= Parameter, values_from= Value)

# excluding some participants
form2_o<-form_o %>% filter (PID != "15", PID != "45", PID != "82", PID != "19", PID !="17",PID != "62", PID !="66", PID !="67", PID !="68", PID != "65", PID !="72", PID !="73", PID !="71", PID !="107", PID !="108",PID != "109")


#writing the form to a csv file
write_csv(form_f, file="...")

# making a tibble for the group+ID
groupID_o <- maincol_o %>% select (PID, stimulil, stimulir, Value, group, Order.number.of.item) %>% filter(Order.number.of.item==10)


# adding a new column to for attestedness
ivsplit_o<-allresults_o %>% mutate(AttestednessL = case_when (ivl %in% c(-3,-2,-1,0,1,2,3) ~ 0, ivl %in% c("H-3", "H-2", "H-1", "H0", "H+1", "H+2", "H+3", "L-3", "L-2", "L-1", "L0", "L+1", "L+2", "L+3") ~ 1, TRUE ~ NA_real_)) %>% mutate(AttestednessR = case_when (ivr %in% c(-3,-2,-1,0,1,2,3) ~ 0, ivr %in% c("H-3", "H-2", "H-1", "H0", "H+1", "H+2", "H+3", "L-3", "L-2", "L-1", "L0", "L+1", "L+2", "L+3") ~ 1, TRUE ~ NA_real_))


# adding a new column to show cluster heads, duplicating and separating
ivsplit_o$stimulil2= ivsplit_o$stimulil
ivsplit_o$stimulir2= ivsplit_o$stimulir
stimheads_o<-ivsplit_o %>% separate(stimulil2, into = c("l.head", "l.tail"), sep = 2) %>% separate(stimulir2, into = c("r.head", "r.tail"), sep = 2)


#ordering the columns
result_o<-stimheads_o %>% dplyr::select(Parameter, Value, stimulil,  ivl,  SonorityL, FrequencyL, AttestednessL, stimulir, ivr, SonorityR, FrequencyR, AttestednessR, l.head, l.tail, r.head, r.tail,  group, PID) %>% filter (Parameter=="Selection")


# adding two new columns for chosen stimuli
result_o$Value<-as.character(result_o$Value)
result_o$stimulil<-as.character(result_o$stimulil)
result_o$stimulir<-as.character(result_o$stimulir)

Choice <- result_o %>% rowwise() %>% mutate(ChosenStimuli = case_when (Value == "right" ~ stimulir,Value == "left" ~ stimulil,))

# adding the iv variables for the chosen stimuli
Choice.iv <- Choice %>% rowwise() %>% 
  mutate(iv= case_when (ChosenStimuli==stimulir ~ ivr, ChosenStimuli==stimulil ~ ivl )) %>%
  mutate(sonority= case_when (ChosenStimuli==stimulir ~ SonorityR, ChosenStimuli==stimulil ~ SonorityL )) %>%
  mutate(frequency= case_when (ChosenStimuli==stimulir ~ FrequencyR, ChosenStimuli==stimulil ~ FrequencyL)) %>%
  mutate(attestedness= case_when (ChosenStimuli==stimulir ~ AttestednessR, ChosenStimuli==stimulil ~ AttestednessL))%>%
  mutate(head= case_when (ChosenStimuli==stimulir ~ r.head, ChosenStimuli==stimulil ~ l.head))%>%
  mutate(tail= case_when (ChosenStimuli==stimulir ~ r.tail, ChosenStimuli==stimulil ~ l.tail))


#excluding the practice items
Choice.ivwp<- Choice.iv %>% drop_na(group)

# excluding some participants
tidyresult_o<-Choice.ivwp %>% filter(PID != "15", PID != "45", PID != "82", PID != "19", PID !="17",PID != "62", PID !="66", PID !="67", PID !="68", PID != "65", PID !="72", PID !="73", PID !="71", PID !="107", PID !="108",PID != "109")


#writing the whole tibble to a new csv file
write_csv(tidyresult_o, file="..." )

#a few lines needed to deleted
tidyo<-read_csv("...")
data<-read_csv("...")


# converting
data$PID <- as.factor(data$PID)
data$attestedness <- as.factor(data$attestedness)
data$head <- as.factor(data$head)
data$tail <- as.factor(data$tail)
data$ChosenStimuli <- as.factor (data$ChosenStimuli)
data$frequency <- as.factor (data$frequency)


## 2.1 frequency of chosen stimuli in the whole list ---------

Countall<-data %>%  add_count(ChosenStimuli)
Proportion<-Countall %>% mutate(proportion=(n/110)*100)


write_csv(Proportion, file="...")






# 3 Regression ------------------------


## 3.1 lmer ------

model<- lmer (proportion ~ sonority + attestedness + sonority:attestedness+
                (1| tail) ,
                data=Proportion, REML = TRUE)

summary(model)


##

model1<- lmer (proportion ~ sonority+
                 (1 + sonority | tail) + (1| Value),
              data=Proportion)

summary(model1)


##

model2<- lmer (proportion ~ sonority +  attestedness  + sonority:attestedness+
                 (1 + sonority | tail) + (1| Value)+ (1 + attestedness | tail),
               data=Proportion)

summary(model2)

##

anova(model2)

##

anova(model1, model2)






 
 
# 4 Summarize ------------------------

# mean age of participants
form2_o$age<-as.numeric(form2_o$age)

# boxplot for age and gender
boxage<-form2_o %>% ggplot ( aes(x=gender, y=age)) + geom_boxplot( varwidth = TRUE) + scale_y_continuous(breaks = pretty(c(0,70), n = 5)) +theme_classic() + coord_flip()
boxage  

summary (form2_o$age)
table (form2_o$gender)
table (form2_o$birthplace)
table (form2_o$headphone)



# 5 Plotting ------------------------

mean1 <- Proportion %>%
  select(sonority, attestedness, frequency, tail, proportion, n, PID, head) %>%
  group_by(sonority, attestedness, head) %>%
  summarise(mean_val1 = mean(proportion, na.rm=TRUE))


mean2 <- Proportion %>%
  select(sonority, attestedness, frequency, tail, proportion, n, PID, head) %>%
  group_by(sonority, attestedness) %>%
  summarise(mean_val2 = mean(proportion, na.rm=TRUE))

mean3<- Proportion %>%
  select(sonority, attestedness, frequency, tail, proportion, PID, head) %>%
  group_by(sonority) %>%
  summarise(mean_val3 = mean(proportion, na.rm=TRUE))


new.plot <- data.frame (mean1, mean_val2=rep(mean2$mean_val2, each=4))
str (new.data)

write_csv(new.plot, file="...")

# heads turned into IPA
new.data2<- read_csv("...")


## 5.1 line plot ipa ----
plotonset <- new.data2 %>%
  ggplot (aes(sonority, mean_val1, color = attestedness, shape=attestedness, label=head))+
  geom_point (size=3, aes(group = attestedness, color = attestedness, shape=attestedness)) +
  geom_line (size=1, aes(y=mean_val2, group = attestedness, color = attestedness))+
  geom_line(size=0.7,linetype=2, color="black" , aes( y=mean_val3))+
  scale_colour_manual(values=c("darkred","darkblue")) +
  ylab("Average of Proportion") +
  geom_text_repel()+
  scale_x_continuous(breaks=seq(-3, 3, 1)) +
  scale_y_continuous(breaks=seq(5, 90, 5)) +
  theme_bw() 

plotonset





## 5.2 plot per id ----

Count$n<-as.numeric(Count$n)
Count$attestedness<-as.factor(Count$attestedness)
count_id<-tidyresult_o %>% dplyr::select(PID, sonority, attestedness, ChosenStimuli) %>% group_by(PID, sonority) %>% add_count(ChosenStimuli)

count_id %>% ggplot(aes (x=sonority, y= n)) +geom_point() +facet_wrap(~PID, nrow = 7) + theme_minimal() + geom_smooth(size=0.5, method=glm)


## 5.3 plot per tail -----
prop_tail<-Proportion %>% dplyr::select(PID, sonority, attestedness, n, proportion, tail, ChosenStimuli) %>% group_by(tail, sonority, attestedness) %>% summarize(meant=(mean(proportion)))


prop_tail %>% ggplot(aes (x=sonority, y= meant, color= as.factor(attestedness))) +geom_path() +facet_wrap(~tail, nrow = 2) + theme_minimal() + geom_smooth(size=0.5, method=glm, se=FALSE)


# 5.4 effects plot -----
eff <- effect("sonority:attestedness", model2)
ef<-effect("sonority", model2)
predeff<-predictorEffect("sonority", model2)

effects<-all.effects(model2)
sonorityeff<-as.data.frame(eff)
sonorityeff$sonority<-as.factor(sonorityeff$sonority)
Countall$n<-as.numeric(Countall$n)
sonorityeff %>% ggplot() + geom_line (aes(sonority, fit), color="blue") + geom_ribbon(aes(x=sonority, ymin=lower, ymax=upper), alpha=0.3, fill="blue")

plot(eff, colors=c("black", "red"))
plot(predeff)
