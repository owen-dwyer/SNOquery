library(tidyverse)
library(magrittr)
library(ggplot2)
library(RColorBrewer)
library(reshape2)
library(patchwork)

matrix_length = read.csv('../visualisation/stats/length_matrix_uk.csv') %>% melt() %>% mutate(variable = gsub('\\.',  ' ', matrix_length$variable) )
matrix_precision = read.csv('../visualisation/stats/precision_matrix_uk.csv') %>% melt() %>% mutate(variable = gsub('\\.',  ' ', matrix_length$variable) )
matrix_recall = read.csv('../visualisation/stats/recall_matrix_uk.csv') %>% melt() %>% mutate(variable = gsub('\\.',  ' ', matrix_length$variable) )
  
factor_levels <- c('lung','colorectal','glaucoma','cataract','appendix')
matrix_length$X <- factor(matrix_length$X, levels = factor_levels)
matrix_precision$X <- factor(matrix_precision$X, levels = factor_levels)
matrix_recall$X <- factor(matrix_recall$X, levels = factor_levels)

plot_theme <- theme(
  axis.line = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.border = element_blank(),
  panel.background = element_blank(),
  legend.position='bottom',
  legend.title=element_blank(),
  axis.title.x = element_blank(),
  axis.ticks.x = element_blank(),
  axis.ticks.y = element_blank(),
  plot.margin=unit(c(0,0,0,0),"cm"),
  plot.title = element_text(hjust = 0.5)
  )

plot1 <- ggplot(matrix_length, aes(variable, X, fill=value)) + 
  geom_tile(color = "white",
            lwd = 2,
            linetype = 1) + 
  scale_fill_distiller(
    palette = ("Blues"),
    direction=1, 
    trans='log', 
    breaks=c(1,10,100,1000),
    limits=c(10,max(matrix_length$value))
  ) + coord_equal() +
  geom_text( 
    aes(
      label = str_pad(scales::comma(value,2), 6)), 
      color = "black", 
      size = 4, 
      hjust=0.5
    ) + 
  plot_theme + ylab('Diagnosis') +
  ggtitle('Length')


plot2 <- ggplot(matrix_precision, aes(variable, X, fill=value)) + 
  geom_tile(color = "white",
            lwd = 2,
            linetype = 1) + 
  scale_fill_distiller(
    palette = ("Greens"),
    direction=1, 
    limits=c(0,1)
  ) + coord_equal() +
  geom_text( 
    aes( 
      label = format(round(value,3))
    ),
    color = 'black', 
    size = 4, 
    hjust=0.5
  ) +
  plot_theme + theme(axis.text.y=element_blank()) + ylab('') +
  ggtitle('Precision')

plot3 <- ggplot(matrix_recall, aes(variable, X, fill=value)) + 
  geom_tile(color = "white",
            lwd = 2,
            linetype = 1) + 
  scale_fill_distiller(
    palette = ("Greens"),
    direction=1, 
    limits=c(0,1)
  ) + coord_equal() +
  geom_text( 
    aes(
      label = format(round(value,3))
    ), 
    color = "black", 
    size = 4, 
    hjust=0.5
  ) +
  plot_theme + theme(axis.text.y=element_blank()) + ylab('')+
  ggtitle('Recall')





plot1 + plot2 + plot3