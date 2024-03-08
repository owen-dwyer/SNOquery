library(ggplot2)
library(tidyverse)
library(magrittr)
library(reshape2)

benchmark_codelist = read.csv('../codelists/CORECT_dictionary.csv') %>% 
  filter(Mapping1!='')  %>% 
  select(opcs,Mapping1) %>% 
  filter(!grepl("^(Y|Z)", opcs))

retrieved_codelist_paths = c('omop/ukquery_colorectal_0_snomed_opcs.csv',
                             'omop/ukquery_colorectal_1_snomed_opcs.csv',
                             'omop/ukquery_colorectal_2_snomed_opcs.csv',
                             'omop/ukquery_colorectal_3_snomed_opcs.csv')

plot_data = NA
n = 1
for (p in retrieved_codelist_paths) {
  
  retrieved_codelist = retrieved_codelist = read.csv(paste('../codelists/output/',p,sep='')) %>% 
    select('opcs') %>% 
    distinct()%>% 
    filter(!grepl("^(Y|Z)", opcs))
  
  b <- benchmark_codelist
  b$retrieved <- benchmark_codelist$opcs %in% retrieved_codelist$opcs
  b %>% group_by(Mapping1) %>% count()
  c <- b %>% group_by(Mapping1) %>% summarise(avg=mean(retrieved))
  c$query <- n
  n=n+1
  
  plot_data <- rbind(plot_data, c)
  
}
plot_data <- plot_data %>% drop_na() %>% mutate(query=as.factor(query))

colour_palette <- c('#0868ac', '#43a2ca','#7bccc4','#bae4bc')

ggplot(plot_data, aes(fill=query, x=Mapping1, y=avg)) + 
  geom_bar(position='dodge', stat='identity') + 
  theme_classic() +
  scale_fill_manual(values = colour_palette, labels=c('Query 1','Query 2','Query 3','Query 4')) +
  theme(
    panel.grid.major.y = element_line(colour = "gray"), 
    legend.title=element_blank(),
    axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)
  ) +
  ylim(0,1) + 
  scale_y_continuous(breaks=seq(0,1,0.2), expand = expansion(mult = c(0, 0)))+
  expand_limits(y = 1) +
  xlab('Category') + ylab('Recall')
