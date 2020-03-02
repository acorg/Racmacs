library(ggplot2)

## authored by Guangchuang Yu <guangchuangyu@gmail.com>


plot.acmap <- function(acmap) {
    dd <- as.data.frame(rbind(agCoords(acmap), srCoords(acmap)))
    names(dd) <- c('x', 'y')

    dd$fill  <- c(agFill(acmap), rep('grey', length(srFill(acmap))))
    dd$type <- c(rep('AG', length(agFill(acmap))),
                 rep('SR', length(srFill(acmap))))

    rx <- floor(range(dd$x))
    ry <- floor(range(dd$y))

    ggplot(dd, aes(x, y, color=fill, shape=type)) +
        geom_point(aes(size=3)) +
        scale_y_reverse(breaks = seq(ry[1], ry[2])) +
        scale_size_identity() +
        scale_shape_manual(values=c(16, 0)) +
        scale_x_continuous(breaks = seq(rx[1], rx[2])) +
        scale_color_identity(guide = "legend") +
        theme_bw() + xlab(NULL) + ylab(NULL) +
        theme(axis.text=element_blank(),
              axis.ticks=element_blank(),
              legend.position='none') +
        coord_fixed() 
}
