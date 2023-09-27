
// #include <cstdio>
#include <RcppArmadillo.h>
#include "acmap_map.h"
#include "acmap_point.h"
#include "acmap_optimization.h"
#include "json_assert.h"

// [[Rcpp::depends(rapidjsonr)]]
#include <rapidjson/document.h>
// #include <rapidjson/filereadstream.h>
using namespace rapidjson;

#ifndef Racmacs__json_read_to_acmap__h
#define Racmacs__json_read_to_acmap__h

// Generic template for parsing
template <typename T> T parse(const Value& v);

// To double
template <>
double parse(
    const Value& v
){
  double x;
  if(v.IsNull()){
    x = arma::datum::nan;
  } else {
    x = v.GetDouble();
  }
  return x;
}

// To vector
template <>
arma::vec parse(
    const Value& v
){

  arma::vec out(v.Size());
  for (SizeType i = 0; i < v.Size(); i++) {
    out(i) = parse<double>(v[i]);
  }
  return out;

}

template <>
arma::uvec parse(
    const Value& v
){

  arma::uvec out(v.Size());
  for (SizeType i = 0; i < v.Size(); i++) {
    out(i) = v[i].GetInt();
  }
  return out;

}

// To string vector
template <>
std::vector<std::string> parse(
    const Value& v
){

  std::vector<std::string> out(v.Size());
  for(SizeType i=0; i<v.Size(); i++){
    out[i] = v[i].GetString();
  }
  return out;

}

// To matrix
template <>
arma::mat parse(
    const Value& v
){

  SizeType nrows;
  SizeType ncols;

  nrows = v.Size();
  if (v[0].IsArray()) ncols = v[0].Size();
  else                ncols = 1;

  arma::mat out(nrows, ncols);

  if (v[0].IsArray()) {
    for (SizeType i = 0; i < nrows; i++) {
      for (SizeType j = 0; j < ncols; j++) {
        out(i,j) = parse<double>(v[i][j]);
      }
    }
  } else {
    for (SizeType i = 0; i < nrows; i++) {
      out(i,0) = parse<double>(v[i]);
    }
  }

  return out;

}

// To bootstrap
template <>
BootstrapOutput parse(
    const Value& v
){

  BootstrapOutput out;
  out.coords = parse<arma::mat>(v["coords"]);
  if (v.HasMember("sampling")) {
    out.sampling = parse<arma::vec>(v["sampling"]);
  }
  return out;

}

template <>
std::vector<BootstrapOutput> parse(
    const Value& v
){

  const Value& coords = v["coords"];
  arma::uword num_bootstrap = coords.Size();

  std::vector<BootstrapOutput> out(num_bootstrap);
  for (SizeType i = 0; i < num_bootstrap; i++) {
    out[i].coords = parse<arma::mat>(coords[i]);
  }

  if (v.HasMember("sampling")) {
    const Value& sampling = v["sampling"];
    for (SizeType i = 0; i < num_bootstrap; i++) {
      out[i].sampling = parse<arma::vec>(sampling[i]);
    }
  }

  return out;

}

template <>
std::vector<SeqInsertion> parse(
    const Value& v
){

  std::vector<SeqInsertion> out(v.Size());
  for (SizeType i = 0; i < v.Size(); i++) {
    SeqInsertion s;
    s.position = v[i][0].GetUint();
    s.insertion = v[i][1].GetString();
    out[i] = s;
  }
  return out;

}

#endif
