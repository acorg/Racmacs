
#include "acmap_titers.h"
#include "acmap_diagnostics.h"

#include "json_assert.h"
// [[Rcpp::depends(rapidjsonr)]]
#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>
// #include <rapidjson/filereadstream.h>

#ifndef Racmacs__json_write_from_acmap__h
#define Racmacs__json_write_from_acmap__h

// Setup general template for conversions
using namespace rapidjson;
template <typename T> Value jsonify(const T& object);

// To double
template <>
Value jsonify(
    const double& d
){

  Value val;
  if(std::isfinite(d)){
    val.SetDouble(d);
  } else {
    val.SetNull();
  }
  return val;

}

// Setup general template for conversions using allocator
template <typename T> Value jsonifya(const T& object, Document::AllocatorType& allocator);

// To string
template <>
Value jsonifya(
    const std::string& s,
    Document::AllocatorType& allocator
){

  Value val;
  val.SetString( StringRef(s.c_str()), allocator );
  return val;

}

// To string array
template <>
Value jsonifya(
    const std::vector<std::string>& stringvec,
    Document::AllocatorType& allocator
){

  Value strvecjson(kArrayType);
  for(SizeType i=0; i<stringvec.size(); i++){
    strvecjson.PushBack(
      jsonifya( stringvec[i], allocator ),
      allocator
    );
  }
  return strvecjson;

}

// From arma::vec
template <>
Value jsonifya(
    const arma::vec& x,
    Document::AllocatorType& allocator
){

  Value a(kArrayType);
  for( arma::uword i=0; i<x.n_elem; i++ ){
    if(std::isfinite(x(i))){
      a.PushBack(x(i), allocator);
    } else {
      Value null(kNullType);
      a.PushBack(null, allocator);
    }
  }
  return a;

}

template <>
Value jsonifya(
    const arma::uvec& x,
    Document::AllocatorType& allocator
){

  Value a(kArrayType);
  for( arma::uword i=0; i<x.n_elem; i++ ){
    a.PushBack(x(i), allocator);
  }
  return a;

}

// From arma::mat
template <>
Value jsonifya(
    const arma::mat& m,
    Document::AllocatorType& allocator
){

  Value a(kArrayType);
  for( arma::uword i=0; i<m.n_rows; i++ ){
    arma::vec row = arma::vectorise( m.row(i) );
    a.PushBack(
      jsonifya(row, allocator),
      allocator
    );
  }
  return a;

}

// From titer table to json
template <>
Value jsonifya(
    const AcTiterTable& titertable,
    Document::AllocatorType& allocator
){

  Value agrows(kArrayType);
  for(SizeType ag=0; ag<titertable.nags(); ag++){
    Value srtiters(kObjectType);
    for(SizeType sr=0; sr<titertable.nsr(); sr++){
      if(titertable.titer_measured(ag, sr)){
        srtiters.AddMember(
          jsonifya( std::to_string(sr), allocator ),
          jsonifya(titertable.get_titer_string(ag, sr), allocator),
          allocator
        );
      }
    }
    agrows.PushBack(srtiters, allocator);
  }
  return agrows;

}

// From plotspec to json
template <>
Value jsonifya(
    const AcPlotspec& plotspec,
    Document::AllocatorType& allocator
){

  Value ptstyle(kObjectType);
  ptstyle.AddMember("+", plotspec.get_shown(), allocator);
  ptstyle.AddMember("F", jsonifya(plotspec.get_fill(), allocator), allocator);
  ptstyle.AddMember("O", jsonifya(plotspec.get_outline(), allocator), allocator);
  ptstyle.AddMember("o", plotspec.get_outline_width(), allocator);
  ptstyle.AddMember("S", jsonifya(plotspec.get_shape(), allocator), allocator);
  ptstyle.AddMember("s", plotspec.get_size(), allocator);
  ptstyle.AddMember("r", plotspec.get_rotation(), allocator);
  ptstyle.AddMember("a", plotspec.get_aspect(), allocator);
  return ptstyle;

}

// From arma::mat
template <>
Value jsonifya(
    const std::vector<NoisyBootstrapOutput>& bootstraps,
    Document::AllocatorType& allocator
){

  Value bs(kObjectType);
  Value ag_noise(kArrayType);
  Value coords(kArrayType);

  for(auto &bootstrap : bootstraps){
    ag_noise.PushBack(jsonifya(bootstrap.ag_noise, allocator), allocator);
    coords.PushBack(jsonifya(bootstrap.coords, allocator), allocator);
  }

  bs.AddMember("coords", coords, allocator);
  bs.AddMember("ag_noise", ag_noise, allocator);
  return bs;

}

#endif
