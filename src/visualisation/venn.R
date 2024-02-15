library(tidyverse)
library(magrittr)
library(ggplot2)
library(ggpattern)

benchmark_codelist = read.csv('../codelists/lung_dictionary.csv') %>% filter(CorectRMapping!='') %>% select('OPCS_4CHAR') %>% rename(opcs = 'OPCS_4CHAR') %>% distinct()  %>% filter(!grepl("^(Y|Z)", opcs))

retrieved_codelist_paths = c('omop/query_colorectal_0_snomed_opcs.csv',
                             'omop/query_colorectal_1_snomed_opcs.csv',
                             'omop/query_colorectal_2_snomed_opcs.csv',
                             'omop/query_colorectal_3_snomed_opcs.csv')

retrieved_codelist_paths = c('omop/query_lung_0_snomed_opcs.csv',
                             'omop/query_lung_1_snomed_opcs.csv',
                             'omop/query_lung_2_snomed_opcs.csv',
                             'omop/query_lung_3_snomed_opcs.csv')


len_benchmark = benchmark_codelist %>% nrow()

all_plot_data = NA

for (p in retrieved_codelist_paths) {
  retrieved_codelist = retrieved_codelist = read.csv(paste('../codelists/output/',p,sep='')) %>% select('opcs') %>% distinct()
  
  len_retrieved = retrieved_codelist %>% nrow()
  len_overlap = intersect(benchmark_codelist, retrieved_codelist) %>% nrow()
  
  query <- c(rep(p , 3) )
  set <- factor( c("CORECT" , "both" , "SNOMED") , levels = c('SNOMED', 'both', 'CORECT'))
  

  
  value <- c(len_benchmark-len_overlap, len_overlap, len_retrieved-len_overlap) 
  
  
  plot_data <- data.frame(query,set,value)
  plot_data$cum_sum <- cumsum(plot_data$value)
  plot_data$label_pos <- plot_data$cum_sum - plot_data$value/2
  
  all_plot_data <- rbind(all_plot_data, plot_data)
}
all_plot_data <- drop_na(all_plot_data)


left_colour = 'lightblue'
right_colour='pink'

ggplot(data = all_plot_data, aes(y=value, x=query, label=value))+theme_bw() + 
  geom_bar_pattern(position='stack', stat='identity', 
                   aes( pattern_fill=set, fill=set ),
                   pattern_density=0.5,
                   pattern_spacing=0.01,
                   pattern_color=NA) +
  scale_pattern_fill_manual(values = c('CORECT'=left_colour,'both'=left_colour, 'SNOMED'='white'))  +
  scale_fill_manual(values=c('CORECT'='white','both'=right_colour, 'SNOMED'=right_colour)) +
  geom_label(aes(y=label_pos), size = 3, color='black' , label.size=0,  label.padding=unit(0.2,'lines')) +
  coord_flip() 



benchmark_codelist_2 = read.csv('../codelists/lung_dictionary.csv') %>% filter(CorectRMapping!='') %>% select('OPCS_4CHAR','OPCS_4CHAR_Meaning') %>% distinct()

missing <- benchmark_codelist_2 %>% filter(! OPCS_4CHAR %in% retrieved_codelist$opcs)
