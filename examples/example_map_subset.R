
# Subsetting an antigenic map -------

## Subset the map by antigen and sera indices
map_subset1 <- subsetMap(h3map2004,
                         antigens = 1:4,
                         sera     = 1:4)

## Subset the map by antigen and sera names
map_subset2 <- subsetMap(h3map2004,
                         antigens = c("BI/2600/75", "HK/3/95"),
                         sera     = c("HK/34/90", "NL/172/96"))

## If nothing is given for the antigen or sera argument then the default is to select all
map_subset3 <- subsetMap(h3map2004,
                         antigens = c("BI/2600/75", "HK/3/95"))

## A warning is returned if an antigen or sera are not found
map_subset4 <- subsetMap(h3map2004,
                         antigens = c("BI/2600/75", "BI/2700/75", "EN/975/75"),
                         sera     = c("NL/172/96", "BE/172/89", "FU/172/02"))


