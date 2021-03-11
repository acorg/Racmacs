
library(Racmacs)
context("Name parsing")

# Some example swine names
name_pairs1 <- tibble::tribble(
  ~name, ~stdname,
  "A/H1N1/NEW_CALEDONIA/20/1999",             "A(H1N1)/New_Caledonia/20/1999",
  "A/H1N1/MEMPHIS/8/2003",                    "A(H1N1)/Memphis/8/2003",
  "A/Solomon Islands/3/2006",                 "A(HXNX)/Solomonislands/3/2006",
  "A/Brisbane/59/2007",                       "A(HXNX)/Brisbane/59/2007",
  "A/H1N2/MICHIGAN/2/2003_E2",                "A(H1N2)/Michigan/2/2003 E2",
  "A/SW/Minnesota/02011/2008",                "A(HXNX)/Swine/Minnesota/2011/2008",
  "A/H1N2/SWINE/TEXAS/1976/2008",             "A(H1N2)/Swine/Texas/1976/2008",
  "A/H1N2/SWINE/IOWA/2039/2008",              "A(H1N2)/Swine/Iowa/2039/2008",
  "A/H1N2/SWINE/MINNESOTA/3294/2011",         "A(H1N2)/Swine/Minnesota/3294/2011",
  "A/H1N2/SWINE/ILLINOIS/3200/2010",          "A(H1N2)/Swine/Illinois/3200/2010",
  "A/SW/Missouri/A01444664/2013",             "A(HXNX)/Swine/Missouri/A01444664/2013",
  "A/H1N2/SWINE/SOUTH_DAKOTA/A01349341/2013", "A(H1N2)/Swine/South_Dakota/A01349341/2013",
  "A/H1N2/SWINE/IOWA/2955/2010",              "A(H1N2)/Swine/Iowa/2955/2010",
  "A/H1N1/SWINE/ILLINOIS/685/2005",           "A(H1N1)/Swine/Illinois/685/2005",
  "A/H1N1/SWINE/MINNESOTA/7002083/2007",      "A(H1N1)/Swine/Minnesota/7002083/2007",
  "A/H1N2/SWINE/OHIO/3295/2010",              "A(H1N2)/Swine/Ohio/3295/2010"
)

# Some other naming forms from the H3N2 map
name_pairs2 <- tibble::tribble(
  ~name, ~stdname,
  "A/PHILIPPINES/472/2002_MDCK",           "A(HXNX)/Philippines/472/2002 MDCK",
  "A/PHILIPPINES/472/2002_EGG",            "A(HXNX)/Philippines/472/2002 EGG",
  "BI/15793/68",                           "A(HXNX)/Bilthoven/15793/1968",
  "A/HK/1/68",                             "A(HXNX)/Hong_Kong/1/1968",
  "AT/3572DASH5/88",                       "A(HXNX)/Atlanta/35725/1988", # Not sure about this one
  "BE/32/1992",                            "A(HXNX)/Beijing/32/1992",
  "A/BEIJING/32/92",                       "A(HXNX)/Beijing/32/1992",
  "A/WELLINGTON/25/93",                    "A(HXNX)/Wellington/25/1993",
  "PROTOTYPE_RG145K_A/NETHERLANDS/178/95", "A(HXNX)/Netherlands/178/1995 G145K PROTOTYPE",
  "A/VICTORIA/8/2010",                     "A(HXNX)/Victoria/8/2010",
  "A/VICTORIA/361/2011",                   "A(HXNX)/Victoria/361/2011",
  "Hanoi/196/2009",                        "A(HXNX)/Hanoi/196/2009",
  "A(HXNX)/Philippines/472/2002 MDCK",     "A(HXNX)/Philippines/472/2002 MDCK"
)

# Pairs that should return a value with a warning
warn_pairs <- tibble::tribble(
  ~name, ~stdname,
  "VN/019/EL442/2010",   "A(HXNX)/Vietnam/19/EL442/2010",
  "HN/196/2009",         "A(HXNX)/Hanoi/196/2009",
  "A/VN/018/EL204/2009", "A(HXNX)/Vietnam/18/EL204/2009"
)


# Combine all name pair lists
name_pairs <- rbind(
  name_pairs1,
  name_pairs2
)

# Make a list of names where you expect a warning
warn_names <- c(
  "HN/196/2009",
  "A/VN/019/EL442/2010"
)


## Check names parse correctly
test_that("Parse antigen names", {

  # These names should work
  apply(name_pairs, 1, function(x) {
    expect_equal(
      standardizeStrainNames(x[["name"]])$name,
      x[["stdname"]]
    )
  })

  apply(warn_pairs, 1, function(x) {
    expect_warning({
      val <- standardizeStrainNames(x[["name"]])$name
    })
    expect_equal(val, x[["stdname"]])
  })

  # These should throw a warning
  lapply(warn_names, function(x) {
    expect_warning(standardizeStrainNames(x)$name)
  })

})
