
#ifndef Racmacs__json_assert__h
#define Racmacs__json_assert__h

// Define the rapid json assert macro
void ac_assert(bool x);
#define RAPIDJSON_ASSERT(x) ac_assert(x)

#endif

