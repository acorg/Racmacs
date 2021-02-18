
// #include <cstdio>
#include <string.h>
#include <RcppArmadillo.h>
#include "acmap_map.h"
#include "acmap_point.h"
#include "acmap_optimization.h"

#include "json_assert.h"
// [[Rcpp::depends(rapidjsonr)]]
#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>
// #include <rapidjson/filereadstream.h>
using namespace rapidjson;

// Create a double value
Value doubleval(
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

// Create a string value
Value strval(
  const std::string& s,
  Document::AllocatorType& allocator
){

  Value val;
  val.SetString( StringRef(s.c_str()), allocator );
  return val;

}

// Create a string array
Value str_vec_to_json(
  std::vector<std::string> stringvec,
  Document::AllocatorType& allocator
){

  Value strvecjson(kArrayType);
  for(SizeType i=0; i<stringvec.size(); i++){
    strvecjson.PushBack(
      strval( stringvec[i], allocator ),
      allocator
    );
  }
  return strvecjson;

}

// Create a titer table record
Value titer_table_to_json(
  AcTiterTable& titertable,
  Document::AllocatorType& allocator
){

  Value agrows(kArrayType);
  for(SizeType ag=0; ag<titertable.nags(); ag++){
    Value srtiters(kObjectType);
    for(SizeType sr=0; sr<titertable.nsr(); sr++){
      if(titertable.titer_measured(ag, sr)){
        srtiters.AddMember(
          strval( std::to_string(sr), allocator ),
          strval(titertable.get_titer_string(ag, sr), allocator),
          allocator
        );
      }
    }
    agrows.PushBack(srtiters, allocator);
  }
  return agrows;

}

// Convert an arma::vec to a json array
template <typename T>
Value vec_to_json_array(
  const T& x,
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

// Convert an arma::mat to a json array
Value mat_to_json_array(
  const arma::mat& m,
  Document::AllocatorType& allocator
){

  Value a(kArrayType);
  for( arma::uword i=0; i<m.n_rows; i++ ){
    arma::vec row = arma::vectorise( m.row(i) );
    a.PushBack(
      vec_to_json_array(row, allocator),
      allocator
    );
  }
  return a;

}

// Create a point style record
template <typename T>
Value json_point_style(
  const T& pt,
  Document::AllocatorType& allocator
){

  Value ptstyle(kObjectType);
  ptstyle.AddMember("+", pt.plotspec.get_shown(), allocator);
  ptstyle.AddMember("F", strval(pt.plotspec.get_fill(), allocator), allocator);
  ptstyle.AddMember("O", strval(pt.plotspec.get_outline(), allocator), allocator);
  ptstyle.AddMember("o", pt.plotspec.get_outline_width(), allocator);
  ptstyle.AddMember("S", strval(pt.plotspec.get_shape(), allocator), allocator);
  ptstyle.AddMember("s", pt.plotspec.get_size(), allocator);
  ptstyle.AddMember("r", pt.plotspec.get_rotation(), allocator);
  ptstyle.AddMember("a", pt.plotspec.get_aspect(), allocator);
  return ptstyle;

}

// Create a point diagnostics record
Value pt_diagnostics_to_json(
    const AcDiagnostics& d,
    Document::AllocatorType& allocator
){

  Value ptdiag(kObjectType);

  // Hemisphering info
  Value pthemi(kArrayType);
  for(arma::uword i=0; i<d.hemi.size(); i++){
    Value hemi(kObjectType);
    hemi.AddMember("d", strval(d.hemi[i].diagnosis, allocator), allocator);
    hemi.AddMember("c", vec_to_json_array(d.hemi[i].coords, allocator), allocator);
    pthemi.PushBack(hemi, allocator);
  }
  ptdiag.AddMember("h", pthemi, allocator);

  return ptdiag;

}


// [[Rcpp::export]]
std::string acmap_to_json(
    AcMap map,
    std::string version
){

  // Setup the document
  Document doc;
  doc.SetObject();
  Document::AllocatorType& allocator = doc.GetAllocator();

  // Add basic info
  doc.AddMember("_", "-*- js-indent-level: 2 -*-", allocator);       // json info..?
  doc.AddMember("  version", strval(version, allocator), allocator); // Version info
  doc.AddMember("?created", "", allocator);                          // Comment field

  // Map information
  Value c(kObjectType);
  Value i(kObjectType);
  int num_antigens = map.antigens.size();
  int num_sera = map.sera.size();
  int num_points = num_antigens + num_sera;

  // == INFO ============================
  Value name;
  name.SetString( StringRef(map.name.c_str()), allocator );
  i.AddMember("N", name, allocator);

  // == ANTIGENS ========================
  Value a(kArrayType);
  for( int i=0; i<num_antigens; i++ ){

    AcAntigen& ag = map.antigens[i];
    Value agval(kObjectType);

    agval.AddMember("N", strval(ag.get_name(), allocator), allocator);
    agval.AddMember("P", strval(ag.get_passage(), allocator), allocator);
    // set_group_values
    // set_date
    // set_reference
    // set_name_full
    // set_name_abbreviated
    // set_id
    // set_group
    // set_sequence
    a.PushBack(agval, allocator);

  }


  // == SERA ============================
  Value s(kArrayType);
  for( int i=0; i<num_sera; i++ ){

    AcSerum& sr = map.sera[i];
    Value srval(kObjectType);

    srval.AddMember("N", strval(sr.get_name(), allocator), allocator);
    srval.AddMember("P", strval(sr.get_passage(), allocator), allocator);
    // set_group_values
    // set_date
    // set_reference
    // set_name_full
    // set_name_abbreviated
    // set_id
    // set_group
    // set_sequence
    s.PushBack(srval, allocator);

  }


  // == TITERS ==========================
  Value t(kObjectType);
  Value d = titer_table_to_json( map.titer_table_flat, allocator );
  t.AddMember("d", d, allocator);

  if(map.titer_table_layers.size() > 1){
    Value L(kArrayType);
    for(arma::uword layer=0; layer<map.titer_table_layers.size(); layer++){
      Value titertableval = titer_table_to_json( map.titer_table_layers[layer], allocator );
      L.PushBack(titertableval, allocator);
    }
    t.AddMember("L", L, allocator);
  }

  // == PLOTSPEC =====================
  Value p(kObjectType);
  Value ptstyles(kArrayType);
  arma::ivec ptstyle_indices( num_points );

  // Antigens
  for(int i=0; i<num_antigens; i++){

    // Generate the point style
    Value ptstyle = json_point_style(map.antigens[i], allocator);

    // Check if that point style already exists
    int ptstyle_index = -1;
    for(SizeType j=0; j<ptstyles.Size(); j++){
      if(ptstyles[j] == ptstyle){
        ptstyle_index = j;
        break;
      }
    }

    // Add the point style if not already found
    if(ptstyle_index == -1){
      ptstyles.PushBack(ptstyle, allocator);
      ptstyle_index = ptstyles.Size() - 1;
    }

    // Record the point style index
    ptstyle_indices[i] = ptstyle_index;

  }

  // Sera
  for(int i=0; i<num_sera; i++){

    // Generate the point style
    Value ptstyle = json_point_style(map.sera[i], allocator);

    // Check if that point style already exists
    int ptstyle_index = -1;
    for(SizeType j=0; j<ptstyles.Size(); j++){
      if(ptstyles[j] == ptstyle){
        ptstyle_index = j;
        break;
      }
    }

    // Add the point style if not already found
    if(ptstyle_index == -1){
      ptstyles.PushBack(ptstyle, allocator);
      ptstyle_index = ptstyles.Size() - 1;
    }

    // Record the point style index
    ptstyle_indices[i + num_antigens] = ptstyle_index;

  }

  // Add to the plotspec json
  p.AddMember("p", vec_to_json_array(ptstyle_indices, allocator), allocator);
  p.AddMember("P", ptstyles, allocator);

  // Drawing order
  p.AddMember("d", vec_to_json_array(map.get_pt_drawing_order(), allocator), allocator);


  // == OPTIMIZATION RUNS ======================
  Value P(kArrayType); // optimizations aka "projections"

  // Add optimizations
  for(arma::uword i=0; i<map.optimizations.size(); i++){

    Value optjson(kObjectType);

    // Comment
    optjson.AddMember("c", strval(map.optimizations[i].get_comment(), allocator), allocator);

    // Stress
    optjson.AddMember("s", doubleval(map.optimizations[i].stress), allocator);

    // Minimum column basis
    optjson.AddMember("m", strval(map.optimizations[i].get_min_column_basis(), allocator), allocator);

    // Fixed column bases
    optjson.AddMember("C", vec_to_json_array( map.optimizations[i].get_fixed_column_bases(), allocator), allocator);

    // Transformation
    arma::vec transformation_vec = arma::vectorise( map.optimizations[i].get_transformation() );
    optjson.AddMember("t", vec_to_json_array( transformation_vec , allocator ), allocator);

    // Coords
    arma::mat coords = arma::join_cols( map.optimizations[i].get_ag_base_coords(), map.optimizations[i].get_sr_base_coords() );
    optjson.AddMember("l", mat_to_json_array( coords, allocator ), allocator);

    // Add to array
    P.PushBack(optjson, allocator);

  }

  // == EXTRAS ==================================
  Value x(kObjectType);

  // = AGs =
  Value xa(kArrayType);
  for(arma::uword i=0; i<map.antigens.size(); i++){
    Value agx(kObjectType);
    agx.AddMember("g", map.antigens[i].get_group(), allocator);
    agx.AddMember("q", strval(map.antigens[i].get_sequence(), allocator), allocator);
    agx.AddMember("i", strval(map.antigens[i].get_id(), allocator), allocator);
    xa.PushBack(agx, allocator);
  }
  x.AddMember("a", xa, allocator);

  // = SR =
  Value xs(kArrayType);
  for(arma::uword i=0; i<map.sera.size(); i++){
    Value srx(kObjectType);
    srx.AddMember("g", map.sera[i].get_group(), allocator);
    srx.AddMember("q", strval(map.sera[i].get_sequence(), allocator), allocator);
    srx.AddMember("i", strval(map.sera[i].get_id(), allocator), allocator);
    xs.PushBack(srx, allocator);
  }
  x.AddMember("s", xs, allocator);

  // = OPTIMIZATIONS =
  Value xp(kArrayType);
  for(arma::uword i=0; i<map.optimizations.size(); i++){

    Value optx(kObjectType);

    // Translation
    optx.AddMember("t", vec_to_json_array(map.optimizations[i].get_translation(), allocator), allocator);

    // AG Diagnostics
    Value optxagd(kArrayType);
    for(arma::uword ag=0; ag<map.optimizations[i].ag_diagnostics.size(); ag++){
      optxagd.PushBack(
        pt_diagnostics_to_json(
          map.optimizations[i].ag_diagnostics[ag],
          allocator
        ),
        allocator
      );
    }

    // SR Diagnostics
    Value optxsrd(kArrayType);
    for(arma::uword ag=0; ag<map.optimizations[i].ag_diagnostics.size(); ag++){
      optxagd.PushBack(
        pt_diagnostics_to_json(
          map.optimizations[i].ag_diagnostics[ag],
          allocator
        ),
        allocator
      );
    }

    optx.AddMember("ad", optxagd, allocator);
    optx.AddMember("sd", optxsrd, allocator);
    xp.PushBack(optx, allocator);

  }
  x.AddMember("p", xp, allocator);

  // = OTHER =
  x.AddMember("agv", str_vec_to_json(map.get_ag_group_levels(), allocator), allocator);
  x.AddMember("srv", str_vec_to_json(map.get_sr_group_levels(), allocator), allocator);

  // == FINISH UP ===============================
  // Assemble the json map data and add it
  c.AddMember("i", i, allocator);
  c.AddMember("a", a, allocator);
  c.AddMember("s", s, allocator);
  c.AddMember("t", t, allocator);
  c.AddMember("p", p, allocator);
  c.AddMember("P", P, allocator);
  c.AddMember("x", x, allocator);
  doc.AddMember("c", c, allocator);

  // Return the map
  StringBuffer buffer;
  Writer<StringBuffer> writer(buffer);
  // Writer<
  //   StringBuffer, // Output Stream
  //   UTF8<>,       // Source Encoding
  //   UTF8<>,       // Target Encoding
  //   CrtAllocator,
  //   kWriteNanAndInfFlag
  //   > writer(buffer);
  bool success = doc.Accept(writer);

  // Check for errors
  if(!success){
    Rf_error("Parsing to json .ace format failed");
  }

  // Return the string
  return buffer.GetString();

}

