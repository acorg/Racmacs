

#' Read in a table of titer data
#'
#' Reads in a table of titer data, converting it to a matrix of titers with
#' labelled column and row names.
#'
#' @param filepath Path to the table of titer data
#'
#' @return Returns a matrix of titers.
#' @details Currently supported file formats are .csv and .xls and .txt
#' @export
#'
read.titerTable <- function(filepath, Fnum_to_SRname = FALSE){

  if(grepl("\\.csv$", filepath)){

    # Read from csv
    titer_table <- read.csv(file             = filepath,
                         row.names        = 1,
                         check.names      = FALSE,
                         stringsAsFactors = FALSE,
                         colClasses       = 'character')

  } else if(grepl("\\.xls$", filepath) | grepl("\\.xlsx$", filepath)){

    # Read from xls
    titer_table <- gdata::read.xls(xls              = filepath,
                                row.names        = 1,
                                check.names      = FALSE,
                                stringsAsFactors = FALSE,
                                colClasses='character')

  } else if(grepl("\\.txt$", filepath)){

    # Read from tab delimted txt
    fileLines <- readLines(filepath)

    # Ignore lines starting with ;
    fileLines <- fileLines[!grepl("^;", fileLines)]

    rows <- lapply(fileLines, function(x){ scan(text = x, what="c", quiet=TRUE) })

    rowlengths  <- sapply(rows, length)
    header_rows <- which(rowlengths < max(rowlengths))

    # Bind the data into a table
    titer_table <- do.call(rbind, rows[-header_rows])

    # Take row names from the first column
    rownames(titer_table) <- titer_table[,1]
    titer_table <- titer_table[,-1]

    # Apply column names
    colnames(titer_table) <- rows[[header_rows[1]]]

  } else {

    # Unsupported filetype
    stop("File type '", tools::file_ext(filepath),"' not supported.")

  }

  # Convert to matrix
  titer_table <- as.matrix(titer_table)

  # Convert to character
  mode(titer_table) <- "character"

  # Trim white space
  titer_table <- trimws(titer_table)

  # Replace blanks with "*"
  if(sum(titer_table == "") > 0){
    titer_table[titer_table == ""] <- "*"
    warning('Missing values ("*") introduced into HI table by coercion.', call. = FALSE)
  }

  # Return HI table
  titer_table

}

