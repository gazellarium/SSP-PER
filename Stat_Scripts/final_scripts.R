# necessary libraries 
library(tidyverse)
library(dplyr)
library(kableExtra)
library(HH)
library(gplots)
library(corrplot)
library (ordinal)
library (lme4)
library (lmerTest)

# 1 reading the raw csv file ----
allresults_f<-read_csv("...")

## 1.1 throwing out unnecessary columns and rows ----
maincol_f<- allresults_f %>% dplyr::select(Parameter, Value, type, stimuli, IVS, Sonority, Frequency, group, PID, Order.number.of.item) %>% filter (Parameter %in% c("age", "birthplace", "degree", "otherlanguages", "gender", "personal_code", "headphone", "Selection"))



# 2 wrangling data -----
## 2.1 creating a tibble for form information only ----
form_f <-maincol_f %>% dplyr::select (PID, Parameter, Value) %>% filter(Parameter %in% c("age", "birthplace", "degree", "otherlanguages", "gender", "personal_code", "headphone"))  %>% pivot_wider(names_from= Parameter, values_from= Value)

## 2.2 making a tibble for the group+ID ----
groupID_f <- maincol_f %>% dplyr::select (PID, stimuli, IVS, Value, group, Order.number.of.item) %>% filter(Order.number.of.item==14) 

## 2.3 writing the form to a csv file
write_csv(form_f, file="...")

## 2.4 adding a new column to for attestedness ----
ivsplit_f<-allresults_f %>% mutate(Attestedness = case_when (IVS %in% c(-3,-2,-1,0,1,2,3) ~ 0, IVS %in% c("H-3", "H-2", "H-1", "H0", "H+1", "H+2", "H+3", "L-3", "L-2", "L-1", "L0", "L+1", "L+2", "L+3") ~ 1, TRUE ~ NA_real_))


## 2.5 adding a new column to show cluster heads, duplicating and separating ----
ivsplit_f$stimuli2= ivsplit_f$stimuli 
stimheads_f<-ivsplit_f %>% separate(stimuli2, into = c("tail", "head"), sep = 3)

## 2.6 ordering the columns ----
tidyresult_f<-stimheads_f %>% dplyr::select(PID, group, type, stimuli, Sonority, Attestedness, Frequency, IVS, head, tail, Value, Parameter) %>% filter (Parameter=="Selection") 

## 2.7 ordering the columns and throwing out participants ----
tidyresult_f<-stimheads_f %>% dplyr::select(PID, group, type, stimuli, Sonority, Attestedness, Frequency, IVS, head, tail, Value, Parameter) %>% filter (Parameter=="Selection") %>% filter ( PID !=20, PID != 68)



# the full participants list to be removed
filter (PID != 69, PID != 77, PID != 85, PID != 93, PID != 98, PID != 71, PID !=20, PID != 42, PID != 65, PID !=16, PID != 90, PID != 28, PID != 75, PID != 109, PID != 68, PID !=84)

## 2.8 throwing out participants out of the form tibble
form2_f <- form_f %>% filter (PID != 69, PID != 77, PID != 85, PID != 93, PID != 98, PID != 71, PID !=20, PID != 42, PID != 65, PID !=16, PID != 90, PID != 28, PID != 75, PID != 109, PID != 68, PID !=84)



#writing the whole tibble to a new csv file
write_csv(tidyresult_f, file="..." )


tidyresult_f<-read_csv(file="...")




# 3 Summarize ----
form2_f$age<-as.numeric(form2_f$age)


summary (form2_f$age)
table (form2_f$gender)
table (form2_f$birthplace)
table (form2_f$headphone)


#mean per participant
tidyresult_f$Value<-as.numeric(tidyresult_f$Value)
tidyresult_f$Attestedness<-as.character(tidyresult_f$Attestedness)

means_bypid<-tidyresult_f %>% dplyr::select(PID, Sonority, Attestedness, Frequency, Value, type) %>% filter(type=="Stimuli") %>% group_by(PID, Sonority, Attestedness) %>% summarize(meansonp=mean(Value))


#mean per tail
means_bytail<-tidyresult_f %>% dplyr::select(PID, Sonority, Attestedness, Frequency, Value,tail, type) %>% filter(type=="Stimuli") %>% group_by( tail, Attestedness, Sonority) %>% summarize(meanst=mean(Value))


#mean per heads
means_byhead<- tidyresult_f %>% dplyr::select(type, stimuli, Sonority, Attestedness, Frequency, Value, Parameter, PID, group, head) %>% filter (type=="Stimuli")  %>% group_by (head, Attestedness, Sonority, Frequency) %>% summarize(mean.rating = mean(Value))


#output to kable
means_byhead %>%pivot_wider(names_from = Sonority, values_from = mean.rating) %>% kbl() %>% kable_classic(full_width = F, html_font = "Times New Roman")

write_csv(means_byhead, file="...")




# 4 Plots-----------------------------
# a histogram for age category
form_f2$age<-as.numeric(form_f2$age)
histage<- form_f %>% ggplot(aes(x=age)) + geom_bar( fill = 'dodgerblue')
print(histage)

# boxplot for age and gender
boxage<-form2_f %>% ggplot ( aes(x=gender, y=age)) + geom_boxplot( varwidth = TRUE) + scale_y_continuous(breaks = pretty(c(0,70), n = 5)) +theme_classic() + coord_flip()
boxage  

# a histogram for gender category
form$age<-as.numeric(form$age)
histgen<- form_f_remove %>% ggplot(aes(x=gender)) + geom_bar( fill = 'grey')
print(histgen)

# a histogram for gender category
form$age<-as.numeric(form$age)
hist2<- form %>% ggplot(aes(x=headphone)) + geom_bar( fill = 'brown')
print(hist2)


#histogram for ratings of sonority profiles
tidyplot$Sonority<-as.factor(tidyplot$Sonority)
histson<-tidyplot %>% filter(Sonority==-1) %>% ggplot(aes(x=Value, y=n)) +geom_bar( stat="identity" ) 
print(histson)

# line for sonority and attestedness by each participant
means_bypid %>% ggplot(aes (x=Sonority, y= meansonp, color=Attestedness)) +geom_path() +facet_wrap(~PID, nrow = 7) + theme_minimal() + geom_smooth(size=0.5, method=glm)

means_bypid %>% ggplot(aes (x=as.numeric(Attestedness), y= meansonp, color=as.numeric(Sonority))) +geom_path() +facet_wrap(~PID, nrow = 7) + theme_minimal() + geom_smooth(size=0.5, method=glm)

means_bypid %>% filter(PID==10| PID==33| PID==22| PID==77| PID==84| PID==109) %>% ggplot(aes (x=Sonority, y= meansonp, shape= Attestedness, color=Attestedness)) + geom_point() + facet_wrap(~PID, nrow = 2) + geom_smooth(size=0.5, method=glm, alpha=0.5 , se= FALSE ,aes(color= Attestedness)) + scale_color_manual(values = c("darkred", "darkblue")) + theme_minimal() + scale_x_continuous(breaks = seq(-3, +3, 1)) +
  scale_y_continuous(breaks = seq(1, 5, 1))


# line for sonority and attestedness by each head
means_bytail %>% ggplot(aes (x=Sonority, y= meanst, color=Attestedness)) +geom_path() +facet_wrap(~tail, nrow = 7) + theme_minimal() + geom_smooth(size=0.5, method=glm)


#line for sonority and attestedness by each head
means_byhead %>% ggplot(aes(x = Sonority, y = mean.rating, shape=Attestedness, color=Attestedness, )) + geom_point(size=3) + geom_text(aes(label = head), nudge_x=0.2, size=4) +
  theme_minimal() +
  scale_color_manual(values = c("darkred", "darkblue")) +
  scale_x_continuous(breaks = seq(-3, +3, 1)) +
  scale_y_continuous(breaks = seq(1, 4, 0.1))


# stimuli heads with a trend line
meanratingstim$Attestedness<-as.character(meanratingstim$Attestedness)

meanratingstim %>% ggplot(aes(x = Sonority, y = meanrating.stim, color=Attestedness)) + geom_point() +
  geom_smooth(method = "lm", se= F) +
  geom_text(aes(label = head), nudge_x=0.1) +
  theme_minimal() +
  scale_color_manual(values = c("indianred3", "cornflowerblue")) +
  scale_x_continuous(breaks = seq(-3, +3, 1)) +
  scale_y_continuous(breaks = seq(1, 5, 0.2))


#test crazy plot all participants
meanrating_f$Attestedness<-as.character(meanrating_f$Attestedness)
meanrating_f %>% ggplot(aes (x=Sonority, y= mean.rating, color = Attestedness)) +geom_path() +facet_wrap(~PID, nrow = 6) + theme_minimal()


#test crazy plot all participants group by group
meanrating_f$PID<-as.character(meanrating_f$PID)
meanrating_f %>% ggplot(aes (x=Sonority, y= mean.rating, color = PID, shape =Attestedness)) +geom_point() +geom_smooth(method = "lm", se = FALSE) +facet_wrap(~group, nrow = 1) + theme_minimal()

#crazy plot all heads mean by participant
meanratinghead_f$Attestedness<-as.character(meanratinghead_f$Attestedness)
meanratinghead_f$PID<-as.character(meanratinghead_f$PID)
meanratinghead_f$Frequency <- replace(meanratinghead_f$Frequency,is.na(meanratinghead_f$Frequency),0)
meanratinghead_f %>% ggplot(aes (x=Sonority, y= mean.rating, color = Attestedness, shape= Frequency, size= 0.5, alpha= 0.5)) +geom_point()+ geom_text(aes(label = head), nudge_x=0.1)  + theme_minimal()





## likertscale plotting----

#making a small tibble 
tidyplothead<- tidyresult_f %>% filter(type=="Stimuli") %>% group_by( PID, head, Value) %>% add_count(Value)
write_csv(tidyplothead, "...")

tidyplot<-tidyresult_f %>% filter(type=="Stimuli") %>% group_by( PID, Sonority, Attestedness, Value) %>% add_count(Value)

tidyplotlik<-tidyresult_f %>%  filter(type=="Stimuli") %>% dplyr::select(Sonority, Attestedness, Value)  %>% group_by(Sonority, Attestedness) %>% add_count(Value) %>% pivot_wider(names_from = Value, values_from = n, values_fn=mean) %>% dplyr::select ("Sonority", "Attestedness", "1", "2", "3", "4", "5")
write_csv(tidyplotlik, "...")

tidyplotlik$Sonority<-as.factor(tidyplotlik$Sonority)


#plotting

likert(Sonority ~ .| Attestedness, data=tidyplotlik, layout=c(1,2),
       scales=list(y=list(relation="free"),x=list(limits=c(-60,+60), at=seq(-60        ,60,5), labels=seq(-60,60,5), tck=.5)),between=list(y=1),
       strip.left=strip.custom(bg="gray97"),  strip=FALSE,
       par.strip.text=list(cex=1.1, lines=2), ylab=NULL, cex=1.2,
       ReferenceZero=3,as.percent=TRUE, positive.order=FALSE,
       main = list("Survey Report",x=unit(.55, "npc")),
       sub= list(" Rating",x=unit(.57, "npc")),
       xlim=c(-65,-45,-25,0,25,45,65),resize.height.tuning=1,
       col=brewer.pal.likert(5, "RdBu"))





# Chisquare test -----
chisq<-chisq.test(tidyplot$Sonority,tidyplot$Value, correct=FALSE)
corrplot(chisq$residuals, is.cor = FALSE)
chisq$expected


# plotting chisquare ----
attestedheads<-tidyplot %>% filter (Attestedness==1)
unattestedheads<-tidyplot %>% filter (Attestedness==0)


chisqat<-chisq.test(attestedheads$Sonority,attestedheads$Value, correct=FALSE)
corrplot(chisqat$residuals, is.cor = FALSE, method="circle", main="attested", tl.col = 'black')


# correlation plot  
chisqun<-chisq.test(unattestedheads$Sonority,unattestedheads$Value, correct=FALSE)
corrplot(chisqun$residuals, is.cor = FALSE, method="circle", main="unattested", tl.col = 'black')



# Contribution in percentage (%)
contriba <- 100*chisqat$residuals^2/chisqat$statistic
round(contriba, 3)
# Visualize the contribution
corrplot(contriba, is.cor = FALSE)


# Spearman correlation ----
attested<-tidyplot %>% filter (Attestedness==1)
unattested<-tidyplot %>% filter (Attestedness==0)
attested$Sonority<-as.numeric(attested$Sonority)
attested$Value<-as.numeric(attested$Value)
sp<-cor.test(attested$Sonority,attested$Value, method = "spearman", exact = FALSE)
print(sp)










# --------------- Ordinal Regression modeling ------------------
# 1. Importing the data ----
path <- "..."
final_data <- read_csv(path)


head (final_data)
attach (final_data)
str (final_data)

## 1.1 filling the na ----
final_data$Frequency <- replace(final_data$Frequency,is.na(final_data$Frequency),"N")

## 1.2 Converting some character variables into factors ----
final_data$PID <- as.factor(final_data$PID)
final_data$Frequency <- as.factor(final_data$Frequency)
final_data$Attestedness <- as.factor(final_data$Attestedness)
final_data$type <- as.factor(final_data$type)
final_data$tail <- as.factor(final_data$tail)
final_data$Value <- as.factor(final_data$Value)

head(final_data)


## 1.3 Changing the Dependent Variable into ordinal factor ----
final_data$Value <- ordered(final_data$Value)



## 1.4 Splitting the data ----
final_df <- final_data %>%
  filter(type=="Stimuli") %>%
  dplyr::select(Sonority, Attestedness, Frequency, stimuli, tail, head, Value, PID) %>% filter ( PID !=20, PID != 68) 

# unattested clusters
unattested<-final_df %>% filter (Attestedness==-1)

# attested clusters
attested<-final_df %>% filter (Attestedness==1) %>% mutate(Freq= case_when(Frequency=="L" ~ -1, Frequency=="H" ~ 1))

attested$Freq<-as.factor(attested$Freq)



# 2.            Fitting Ordinal Logistic Mixed Effects Model ---------
## 2.1 fixed effect of Sonority   + random effects: PID, tail in unattesteds clusters ----

fit1 <- clmm (Value ~ Sonority + (1+ Sonority| PID) + (1 | tail), data=unattested)
summary(fit1)




## 2.2 fixed effect of Sonority and Frequency + random effects: PID, tail in attested clusters ----
fit2 <- clmm (Value ~ Sonority + Frequency  +
                Sonority : Frequency +
                (1 + Sonority| PID) + (1 | tail), data=attested)
summary (fit2)




## 2.3 fixed effect of Sonority and Attestedness  +random effects: PID, tail in all clusters ----
fit3 <- clmm (Value ~ Sonority + Attestedness +
                Sonority : Attestedness +
                (1+ Sonority |PID) + (1+Attestedness| PID) + (1|tail)  , data=final_df)
summary (fit3)


