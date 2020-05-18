
# Function to convert a json list to text
jsonListToText <- function(json){
  as.character(
    jsonlite::toJSON(
      json,
      auto_unbox = TRUE,
      pretty     = 1,
      digits     = 8
    )
  )
}

# Function to convert titers to the ace list format
titerTableToList <- function(titertable){
  unname(apply(titertable, 1, function(x){

    na_titers <- x == "*"
    x <- as.list(x[!na_titers])
    names(x) <- which(!na_titers) - 1
    x

  }))
}

# Function to convert to json
#' @export
as.json.racmap <- function(map){

  # Setup json
  json <- list()
  json$`_`         <- "-*- js-indent-level: 1 -*-"
  json$`  version` <- "acmacs-ace-v1"
  json$`?created`  <- sprintf("AD Racmacs on %s", Sys.time())

  # Chart attributes
  json$c$i   <- list()
  json$c$i$N <- name(map)

  # Titers
  json$c$t$l <- titerTable(map, .name = FALSE)

  # Titer layers
  if(length(titerTableLayers(map)) > 1){
    json$c$t$L <- lapply(titerTableLayers(map), titerTableToList)
  }

  # Antigen attributes
  antigens <- data.frame(
    N = agNames(map),
    stringsAsFactors = FALSE
  )
  ag_dates <- as.character(agDates(map))
  ag_dates[is.na(ag_dates)] <- ""
  if(sum(ag_dates != "") > 0){
    antigens$D <- ag_dates
  }
  json$c$a <- apply(antigens, 1, function(ag){
    as.list(ag)
  })

  # Serum attributes
  sera <- data.frame(
    N = srNames(map),
    stringsAsFactors = FALSE
  )
  json$c$s <- apply(sera, 1, function(sr){
    as.list(sr)
  })

  # Plotspec attributes
  plotspec <- data.frame(
    "+" = c(agShown(map),         srShown(map)),
    "F" = c(agFill(map),          srFill(map)),
    "O" = c(agOutline(map),       srOutline(map)),
    "o" = c(agOutlineWidth(map),  srOutlineWidth(map)),
    "S" = c(agShape(map),         srShape(map)),
    "s" = c(agSize(map),          srSize(map)),
    "r" = c(agRotation(map),      srRotation(map)),
    "a" = c(agAspect(map),        srAspect(map)),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  plotspec_list          <- do.call(Map, c(list, plotspec))
  plotspec_list_unique   <- unique(plotspec_list)
  plotspec_point_indices <- vapply(
    seq_along(plotspec_list),
    function(i) match(plotspec_list[i], plotspec_list_unique),
    numeric(1)
  )

  json$c$p$P <- plotspec_list_unique
  json$c$p$p <- plotspec_point_indices - 1

  # Set draw order
  json$c$p$d <- draw_priority_to_order(
    c(agDrawingOrder(map), srDrawingOrder(map))
  ) - 1

  # Optimization attributes
  json$c$P <- lapply(
    seq_len(numOptimizations(map)),
    function(n){

      # Convert coordinates to a list
      base_coords <- rbind(
        agBaseCoords(map, n),
        srBaseCoords(map, n)
      )

      base_coords_list <- lapply(
        seq_len(nrow(base_coords)),
        function(i){
          I(base_coords[i,])
        }
      )

      na_coords <- which(rowSums(is.na(base_coords)) > 0)
      base_coords_list[na_coords] <- lapply(seq_along(na_coords), function(x){ list() })

      # Save the optimization data
      optimization_json <- list(
        l = base_coords_list
      )

      if(!is.null(mapComment(map, n))){
        optimization_json$c <- mapComment(map, n)
      }

      # Sort out column bases
      if(minColBasis(map, n) == "fixed"){
        optimization_json$C <- I(colBases(map, n))
      } else {
        optimization_json$m <- minColBasis(map, n)
      }

      # Return the json
      optimization_json

    }
  )

  # Sort out map translations
  json$c$x$translation <- lapply(
    seq_len(numOptimizations(map)),
    function(n){
      translation <- mapTranslation(map, n)
      if(!is.null(translation)) translation <- I(as.vector(translation))
      translation
    }
  )

  # Sort out map transformations
  json$c$x$transformation <- lapply(
    seq_len(numOptimizations(map)),
    function(n){

      transformation <- mapTransformation(map, n)
      if(!is.null(transformation)) transformation <- I(as.vector(t(transformation)))
      transformation

    }
  )

  # Save bootstrap data
  bootstrap <- getMapAttribute(map, "bootstrap")
  if(!is.null(bootstrap)){
    json$c$x$bootstrap <- bootstrapToJsonList(bootstrap)
  }

  # Additional custom attributes
  if(!is.null(getMapAttribute(map, "agIDs")))    json$c$x$antigen_ids    <- getMapAttribute(map, "agIDs")
  if(!is.null(getMapAttribute(map, "srIDs")))    json$c$x$sera_ids       <- getMapAttribute(map, "srIDs")
  if(!is.null(getMapAttribute(map, "agGroups"))) json$c$x$antigen_groups <- getMapAttribute(map, "agGroups")
  if(!is.null(getMapAttribute(map, "srGroups"))) json$c$x$sera_groups    <- getMapAttribute(map, "srGroups")

  # Convert the json
  jsonListToText(
    json
  )

}



