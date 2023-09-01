
# Function for title case
simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1, 1)), substring(s, 2),
        sep = "", collapse = " ")
}

# Function for standardising names locally
standardizeStrainName <- function(
  name,
  default_species = NA,
  default_virus_type = "A",
  default_virus_subtype = "HXNX"
  ) {

  # Check stringr package installed
  package_required("stringr")

  # Save original name
  original_name <- name
  parse_error   <- paste0("Unclear how to parse name : ", original_name)

  # Convert to lower
  name <- tolower(name)

  # Strip head and tail blankspace
  name <- gsub("^ *", "", name)
  name <- gsub(" *$", "", name)

  # Deal with brackets
  name <- gsub("^a\\((h([1-9]|x)(n([1-9]|x))?)\\)", "a\\1", name)
  name <- gsub("\\)$", "", name)
  name <- gsub("\\(", "_", name)

  # Strip any suffix
  suffix <- stringr::str_extract(name, "[^\\/]+$")
  suffix <- stringr::str_extract(suffix, "[_\\s].*$")
  name   <- gsub(paste0(suffix, "$"), "", name)
  suffix <- gsub("^(_|\\s)", "", suffix)

  # Strip any prefix
  prefix <- stringr::str_extract(name, "^[^\\/]+")
  prefix <- stringr::str_extract(prefix, "^.*[_\\s]")
  name   <- gsub(paste0("^", prefix), "", name)
  prefix <- gsub("(_|\\s)$", "", prefix)

  # Strip year and convert to 4 digit format
  year   <- stringr::str_match(name, "(.*/)(.*?$)")[3]
  year   <- gsub("^(9.$|8.$|7.$|6.$|5.$|4.$)",
                 "19\\1", year)
  year   <- gsub("^(0.$|1.$)",
                 "20\\1", year)
  name   <- gsub("(.*)/.*?$", "\\1", name)

  if (grepl("[^0-9]+", year)) {
    stop(parse_error)
  }

  # Strip ID
  identifier <- stringr::str_match(name, "(.*[a-z]/)(.*?$)")[3]
  identifier <- gsub("-", "", identifier)
  identifier <- gsub("([[:digit:]])dash([[:digit:]])", "\\1\\2", identifier)
  identifier <- toupper(identifier)
  identifier <- gsub("^0+", "", identifier) # Strip leading 0s
  name       <- gsub("(.*[a-z])/.*?$", "\\1", name)

  # Strip place name and standardise
  place <- stringr::str_match(name, "(.*/|^)(.*?$)")[3]
  if (place %in% tolower(acmacs_placeAbvs$abv)) {

    if (place %in% ambig_places$abv) {
      assumed_place <- ambig_places$placename[
        match(place, tolower(ambig_places$abv))
      ]
      warning(sprintf(
        "Place name '%s' is ambiguous, have assumed it means '%s' \n",
        place,
        assumed_place
      ))
      place <- assumed_place
    }
    else {
      place <- acmacs_placeAbvs$placename[
        match(place, tolower(acmacs_placeAbvs$abv))
      ]
    }

    place <- tolower(place)
  }
  place <- gsub("(-|_|\\s)", "", place)

  if (grepl("[0-9]+", place)) {
    stop(parse_error)
  }
  name  <- gsub("(.*/|^)(.*?$)", "\\1", name)

  # Deal with place name spaces
  place <- gsub("hongkong", "hong kong", place)
  place <- gsub("^south", "south ", place)
  place <- gsub("^new", "new ", place)
  place <- simpleCap(place)
  place <- gsub(" ", "_", place)

  # Look for virus type in name
  virus_type <- NA
  if (grepl("^a", virus_type)) virus_type <- "A"
  if (grepl("^b", virus_type)) virus_type <- "B"
  if (is.na(virus_type)) virus_type <- default_virus_type
  name <- gsub(paste0("^", tolower(virus_type)), "", name)

  # Now look for virus subtype
  subtype_regex <- "(^|\\(|\\/)h([1-9]|x)n?([1-9]|x)?(\\)|\\/)"
  if (grepl(subtype_regex, name)) {
    virus_subtype <- stringr::str_match(name, subtype_regex)[1]
    virus_subtype <- gsub("(\\/|\\(|\\))", "", virus_subtype)

    # If there is only H provided put NX
    virus_subtype <- gsub("^(h([1-9]|x))$", "\\1nx", virus_subtype)

    # Convert to upper and remove from name
    virus_subtype <- toupper(virus_subtype)
    name <- gsub(subtype_regex, "", name)
  }
  else {
    virus_subtype <- default_virus_subtype
  }

  # Look for species-type
  name <- gsub("/", "", name)
  if (name == "") {
    species <- default_species
  }
  else {
    species <- name
    species <- gsub("^sw$", "swine", species)
    species <- simpleCap(species)
  }

  # Deal with extras
  if (is.na(suffix) & !is.na(prefix))  extras <- prefix
  if (!is.na(suffix) & is.na(prefix))  extras <- suffix
  if (!is.na(suffix) & !is.na(prefix)) {
    extras <- paste(prefix, suffix, sep = "_")
  }

  if (is.na(suffix) & is.na(prefix)) {
    extras     <- NA
    extra_text <- ""
  }
  else {
    all_extras <- stringr::str_split(extras, "(_|\\s)")[[1]]
    all_extras <- gsub("r([a-z][0-9]{3}[a-z])", "\\1", all_extras)

    # Find any suffixes that look like HA substitutions
    HA_subs    <- grepl("[a-z][0-9]{3}[a-z]", all_extras)
    all_extras <- c(all_extras[HA_subs], all_extras[!HA_subs])

    extra_text <- toupper(paste0(" ", paste(all_extras, collapse = " ")))
  }

  # Now return name in standard format
  basic_name <- paste0(
    virus_type, "(", virus_subtype, ")/",
    gsub(" ", "_", place), "/",
    identifier, "/",
    year
  )

  if (is.na(species)) {
    species_text <- ""
  }
  else {
    species_text <- paste0(species, "/")
  }

  full_name  <- paste0(
    virus_type, "(", virus_subtype, ")/",
    species_text,
    gsub(" ", "_", place), "/",
    identifier, "/",
    year,
    extra_text
  )

  # Set attributes
  output <- c()
  output$name       <- full_name
  output$basic_name <- basic_name
  output$type       <- virus_type
  output$subtype    <- virus_subtype
  output$species    <- species
  output$id         <- identifier
  output$place      <- place
  output$year       <- year
  output$extras     <- extras
  output


}

#' Standardize strain names
#'
#' This is a utility function to help standardise antigen names into a more
#' consistent format, also attempting to break apart different components
#' of the name.
#'
#' @param names Strain names to be standardised
#' @param default_species Are the strains isolated from a particular species?
#' @param default_virus_type Default virus type to be used (if no type found in
#'   name)
#' @param default_virus_subtype Default virus subtype to be used (if no subtype
#'   found in name)
#'
#' @returns Returns a tibble of standardised names and extracted information
#' @export
#'
standardizeStrainNames <- function(
  names,
  default_species = NA,
  default_virus_type = "A",
  default_virus_subtype = "HXNX"
) {

  # Check tibble package is installed
  package_required("tibble")

  # Get name attributes
  name_list <- lapply(names, function(x) {
    standardizeStrainName(x,
                           default_species       = default_species,
                           default_virus_type    = default_virus_type,
                           default_virus_subtype = default_virus_subtype)
  })

  # Return output
  output <- list()
  for (attribute in names(name_list[[1]])) {
    attr_vector <- sapply(name_list, function(x) {
      as.vector(unlist(x[[attribute]]))
    })
    output[[attribute]] <- attr_vector
  }
  output

  # Include the original names
  output <- c(list(original_name = names), output)

  # Return output as a tibble
  tibble::as_tibble(output)

}
