
jsonToList <- function(json){

  jsonlite::fromJSON(
    txt               = json,
    simplifyVector    = FALSE,
    simplifyDataFrame = FALSE,
    simplifyMatrix    = FALSE
  )

}

# Output a racchart as .ace json format
#' @export
as.json.racchart <- function(map){

  # Save bootstrap data
  bootstrap <- getMapAttribute(map, "bootstrap")
  if(!is.null(bootstrap)){
    map$chart$set_extension_field(
      "bootstrap",
      jsonListToText(
        bootstrapToJsonList(bootstrap)
      )
    )
  }

  # Output the json
  map$chart$save()

}

# Utility function to read in map json either directly
# or after reading in a file and converting
read.acmap.json <- function(filename){

  if(grepl("\\.ace$", filename)){
    json <- paste(
      readLines(filename, warn = FALSE),
      collapse = "\n"
    )
  } else {
    chart <- new(acmacs.r::acmacs.Chart, path.expand(filename))
    json <- chart$save()
  }

  json

}

# Utility function to get an arbitrary optimization attribute
getJsonOptimizationAttribute <- function(json, attribute, optimization_num){
  attribute_val <- json$c$x[[attribute]]
  if(is.null(attribute_val))                   return(NULL)
  if(optimization_num > length(attribute_val)) return(NULL)
  attribute_val[[optimization_num]]
}

# Convert from the json format to a racmap object
json_to_racmap <- function(json){

  # Convert the json to a list
  jsonlist <- jsonToList(json)

  # Get basic info
  num_antigens <- length(jsonlist$c$a)
  num_sera     <- length(jsonlist$c$s)

  # Create a fresh map
  map <- racmap.new()

  # Chart attributes
  name(map, .check = FALSE) <- jsonlist$c$i$N

  # Titers
  if(!is.null(jsonlist$c$t$l)) {
    titers <- matrix(
      data  = unlist(jsonlist$c$t$l),
      nrow  = num_antigens,
      byrow = TRUE
    )
  } else if(!is.null(jsonlist$c$t$d)) {
    titers <- strip_titers(
      jsonlist$c$t$d,
      num_sera
    )
  } else {
    stop("There was a problem parsing this map")
  }
  titerTable(map, .check = TRUE) <- titers

  # Set any titer table layers
  if(!is.null(jsonlist$c$t$L)){
    titerlayers <- lapply(
      jsonlist$c$t$L,
      strip_titers,
      num_sera = num_sera
    )
    titerTableLayers(map) <- titerlayers
  }

  # Antigen attributes
  antigens <- t(vapply(jsonlist$c$a, function(ag){
    with(
      ag,{
        c(
          name    = get0("N", ifnotfound = "", inherits = FALSE),
          date    = get0("D", ifnotfound = "", inherits = FALSE),
          passage = get0("P", ifnotfound = "", inherits = FALSE)
        )
      }
    )
  }, character(3)))

  agNames(map, .check = FALSE) <- antigens[,"name"]
  if(sum(antigens[,"date"] != "") > 0) agDates(map) <- antigens[,"date"]


  # Serum attributes
  sera <- t(vapply(jsonlist$c$s, function(sr){
    with(
      sr,{
        c(
          name    = get0("N", ifnotfound = "", inherits = FALSE),
          passage = get0("P", ifnotfound = "", inherits = FALSE)
        )
      }
    )
  }, character(2)))

  srNames(map, .check = FALSE) <- sera[,"name"]

  # Plotspec attributes
  pt_indices <- unlist(jsonlist$c$p$p)+1
  ag_indices <- pt_indices[seq_len(num_antigens)]
  sr_indices <- pt_indices[-seq_len(num_antigens)]

  plotspec <- do.call("rbind", lapply(jsonlist$c$p$P, function(ps){
    with(
      ps,{
        data.frame(
          shown         = get0("+", ifnotfound = TRUE,          inherits = FALSE),
          fill          = get0("F", ifnotfound = "transparent", inherits = FALSE),
          outline       = get0("O", ifnotfound = "black",       inherits = FALSE),
          outline_width = get0("o", ifnotfound = 1,             inherits = FALSE),
          shape         = get0("S", ifnotfound = "CIRCLE",      inherits = FALSE),
          size          = get0("s", ifnotfound = 5,             inherits = FALSE),
          rotation      = get0("r", ifnotfound = 0,             inherits = FALSE),
          aspect        = get0("a", ifnotfound = 1,             inherits = FALSE),
          stringsAsFactors = FALSE
        )
      }
    )
  }))

  plotspec$shape[plotspec$shape == "C"] <- "CIRCLE"
  plotspec$shape[plotspec$shape == "B"] <- "BOX"
  plotspec$shape[plotspec$shape == "T"] <- "TRIANGLE"
  plotspec$shape[plotspec$shape == "E"] <- "EGG"
  plotspec$shape[plotspec$shape == "U"] <- "UGLYEGG"

  agShown(map, .check = FALSE) <- plotspec$shown[ag_indices]
  srShown(map, .check = FALSE) <- plotspec$shown[sr_indices]

  agSize(map, .check = FALSE) <- plotspec$size[ag_indices]
  srSize(map, .check = FALSE) <- plotspec$size[sr_indices]

  agFill(map, .check = FALSE) <- plotspec$fill[ag_indices]
  srFill(map, .check = FALSE) <- plotspec$fill[sr_indices]

  agOutline(map, .check = FALSE) <- plotspec$outline[ag_indices]
  srOutline(map, .check = FALSE) <- plotspec$outline[sr_indices]

  agOutlineWidth(map, .check = FALSE) <- plotspec$outline_width[ag_indices]
  srOutlineWidth(map, .check = FALSE) <- plotspec$outline_width[sr_indices]

  agRotation(map, .check = FALSE) <- plotspec$rotation[ag_indices]
  srRotation(map, .check = FALSE) <- plotspec$rotation[sr_indices]

  agAspect(map, .check = FALSE) <- plotspec$aspect[ag_indices]
  srAspect(map, .check = FALSE) <- plotspec$aspect[sr_indices]

  agShape(map, .check = FALSE) <- plotspec$shape[ag_indices]
  srShape(map, .check = FALSE) <- plotspec$shape[sr_indices]

  # Get drawing order as priorities
  draw_priority <- draw_order_to_priority(unlist(jsonlist$c$p$d) + 1)

  # Optimization attributes
  map$optimizations <- lapply(
    seq_along(jsonlist$c$P),
    function(x){
      list()
    }
  )

  for(n in seq_along(jsonlist$c$P)){

    P <- jsonlist$c$P[[n]]

    layout            <- P$l
    coord_lengths     <- sapply(layout, length)
    na_coords         <- coord_lengths == 0
    map_dim           <- max(coord_lengths)
    layout[na_coords] <- list(as.list(rep(NA, map_dim)))
    layout            <- do.call(rbind, lapply(layout, unlist))

    agBaseCoords(map, n, .check = FALSE) <- layout[seq_len(num_antigens),,drop=F]
    srBaseCoords(map, n, .check = FALSE) <- layout[-seq_len(num_antigens),,drop=F]

    mapComment(map, n, .check = FALSE)    <- P$c
    mapDimensions(map, n, .check = FALSE) <- ncol(layout)

    if(!is.null(P$C))      colBases(map, n, .check = FALSE)    <- unlist(P$C)
    else if(!is.null(P$m)) minColBasis(map, n, .check = FALSE) <- P$m
    else                   minColBasis(map, n, .check = FALSE) <- "none"

    transformation <- unlist(getJsonOptimizationAttribute(jsonlist, "transformation", n))
    if(!is.null(transformation) && transformation != as.vector(diag(nrow = ncol(layout)))){
      mapTransformation(map, n, .check = FALSE) <- matrix(transformation, sqrt(length(transformation)))
    } else if(!is.null(P$t)) {
      mapTransformation(map, n, .check = FALSE) <- matrix(unlist(P$t), map_dim, byrow = TRUE)
    }

    translation <- unlist(getJsonOptimizationAttribute(jsonlist, "translation", n))
    if(sum(translation != 0) > 0){
      mapTranslation(map, n, .check = FALSE) <- translation
    }

  }

  # Bootstrap data
  if(!is.null(jsonlist$c$x$bootstrap)){
    map <- setMapAttribute(map, "bootstrap", bootstrapFromJsonlist(jsonlist$c$x$bootstrap))
  }

  # Selected optimization
  if(!is.null(jsonlist$c$x$selected_optimization)){
    selectedOptimization(map) <- unlist(jsonlist$c$x$selected_optimization)
  }

  # Return the map
  map

}


# Strip ag titers from ace format
strip_titers <- function(titerset, num_sera){

  t(vapply(
    titerset,
    function(agtiters){
      titerrow <- rep("*", num_sera)
      titerrow[as.numeric(names(agtiters))+1] <- unname(unlist(agtiters))
      titerrow
    },
    character(num_sera)
  ))

}

