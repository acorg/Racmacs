
#ifndef Racmacs__json_assert__h
#define Racmacs__json_assert__h

// Define the rapid json assert macro
void R_assert(bool x){
  if(!x) Rf_error("Parsing failed");
}
#define RAPIDJSON_ASSERT(x) R_assert(x)

#endif
