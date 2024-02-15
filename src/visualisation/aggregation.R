library(tidyverse)
library(magrittr)
library(ggplot2)

retrieved_codelist = read.csv(paste('../codelists/output/omop/query_colorectal_0_snomed_opcs.csv',sep='')) %>% 
  select('opcs') %>% 
  distinct() %>% 
  filter(!grepl("^(Y|Z)", opcs))

retrieved_codelist$opcs_3char <- substring(retrieved_codelist$opcs, 0, 3)
retrieved_codelist$opcs_1char <- substring(retrieved_codelist$opcs, 0, 1)


opcs_3char_count <- data.frame(table(retrieved_codelist$opcs_3char))
ggplot(data = opcs_3char_count ) + 
  geom_col( aes(x=Var1, y=Freq))

opcs_1char_count <- data.frame(table(retrieved_codelist$opcs_1char))
ggplot(data = opcs_1char_count) + 
  geom_col( aes(x=Var1, y=Freq))