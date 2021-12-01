
// #in// #include <cstdio>
#include <string.h>
#include <RcppArmadillo.h>
#include "acmap_map.h"
#include "acmap_point.h"
#include "acmap_optimization.h"
#include "json_write_from_acmap.h"
using namespace rapidjson;

// [[Rcpp::export]]
std::string acmap_to_json(
    AcMap map,
    std::string version,
    bool pretty,
    bool round_titers
){

  // Round titers if requested
  if (round_titers) {
    map.titer_table_flat.roundTiters();
    for(auto &titer_table : map.titer_table_layers){
      titer_table.roundTiters();
    }
  }

  // Setup the document
  Document doc;
  doc.SetObject();
  Document::AllocatorType& allocator = doc.GetAllocator();

  // Add basic info
  doc.AddMember("_", "-*- js-indent-level: 2 -*-", allocator);  // json info..?
  doc.AddMember("  version", "acmacs-ace-v1", allocator);       // Version info
  doc.AddMember("?created", "", allocator);                     // Comment field

  // Map information
  Value c(kObjectType);
  Value i(kObjectType);
  int num_antigens = map.antigens.size();
  int num_sera = map.sera.size();
  int num_points = num_antigens + num_sera;

  // == INFO ============================
  i.AddMember("N", jsonifya(map.name, allocator), allocator);

  // == ANTIGENS ========================
  Value a(kArrayType);
  for( int i=0; i<num_antigens; i++ ){

    AcAntigen& ag = map.antigens[i];
    Value agval(kObjectType);

    agval.AddMember("N", jsonifya(ag.get_name(), allocator), allocator);
    if (!ag.isdefault("passage")) agval.AddMember("P", jsonifya(ag.get_passage(), allocator), allocator);
    if (!ag.isdefault("clade"))   agval.AddMember("c", jsonifya(ag.get_clade(), allocator), allocator);
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

    srval.AddMember("N", jsonifya(sr.get_name(), allocator), allocator);
    if (!sr.isdefault("passage")) srval.AddMember("P", jsonifya(sr.get_passage(), allocator), allocator);
    if (!sr.isdefault("clade"))   srval.AddMember("c", jsonifya(sr.get_clade(), allocator), allocator);
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
  Value d = jsonifya( map.titer_table_flat, allocator );
  t.AddMember("d", d, allocator);

  if(map.titer_table_layers.size() > 1){
    Value L(kArrayType);
    for(arma::uword layer=0; layer<map.titer_table_layers.size(); layer++){
      Value titertableval = jsonifya( map.titer_table_layers[layer], allocator );
      L.PushBack(titertableval, allocator);
    }
    t.AddMember("L", L, allocator);
  }

  // == PLOTSPEC =====================
  Value p(kObjectType);
  Value ptstyles(kArrayType);
  arma::uvec ptstyle_indices( num_points );

  // Antigens
  for(int i=0; i<num_antigens; i++){

    // Generate the point style
    Value ptstyle = jsonifya(map.antigens[i].plotspec, allocator);

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
    Value ptstyle = jsonifya(map.sera[i].plotspec, allocator);

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
  p.AddMember("p", jsonifya(ptstyle_indices, allocator), allocator);
  p.AddMember("P", ptstyles, allocator);

  // Drawing order
  p.AddMember("d", jsonifya(map.get_pt_drawing_order(), allocator), allocator);


  // == OPTIMIZATION RUNS ======================
  Value P(kArrayType); // optimizations aka "projections"

  // Add optimizations
  for(arma::uword i=0; i<map.optimizations.size(); i++){

    Value optjson(kObjectType);

    // Comment
    if (!map.optimizations[i].isdefault("comment")) {
      optjson.AddMember("c", jsonifya(map.optimizations[i].get_comment(), allocator), allocator);
    }

    // Stress
    optjson.AddMember("s", jsonify(map.optimizations[i].stress), allocator);

    // Minimum column basis
    if (!map.optimizations[i].isdefault("minimum_column_basis")) {
      optjson.AddMember("m", jsonifya(map.optimizations[i].get_min_column_basis(), allocator), allocator);
    }

    // Fixed column bases
    if (!map.optimizations[i].isdefault("fixed_column_bases")) {
      optjson.AddMember("C", jsonifya( map.optimizations[i].get_fixed_column_bases(), allocator), allocator);
    }

    // Transformation
    if (!map.optimizations[i].isdefault("transformation")) {
      arma::vec transformation_vec = arma::vectorise( map.optimizations[i].get_transformation() );
      optjson.AddMember("t", jsonifya( transformation_vec , allocator ), allocator);
    }

    // Coords
    arma::mat coords = arma::join_cols( map.optimizations[i].get_ag_base_coords(), map.optimizations[i].get_sr_base_coords() );
    optjson.AddMember("l", jsonifya( coords, allocator ), allocator);

    // Add to array
    P.PushBack(optjson, allocator);

  }

  // == EXTRAS ==================================
  Value x(kObjectType);
  x.AddMember("racmacs-v", jsonifya(version, allocator), allocator); // Version info

  // = AGs =
  Value xa(kArrayType);
  bool ag_extras = false;
  bool ag_grouping_included = !map.isdefault("ag_group_levels");
  for(arma::uword i=0; i<map.antigens.size(); i++){
    Value agx(kObjectType);
    if (ag_grouping_included) {
      ag_extras = true;
      agx.AddMember("g", map.antigens[i].get_group(), allocator);
    }
    if (!map.antigens[i].isdefault("sequence")) {
      ag_extras = true;
      agx.AddMember("q", jsonifya(map.antigens[i].get_sequence(), allocator), allocator);
    }
    if (!map.antigens[i].isdefault("id")) {
      ag_extras = true;
      agx.AddMember("i", jsonifya(map.antigens[i].get_id(), allocator), allocator);
    }
    if (!map.antigens[i].isdefault("extra")) {
      ag_extras = true;
      agx.AddMember("x", jsonifya(map.antigens[i].get_extra(), allocator), allocator);
    }
    xa.PushBack(agx, allocator);
  }
  if (ag_extras) x.AddMember("a", xa, allocator);

  // = SR =
  Value xs(kArrayType);
  bool sr_extras = false;
  bool sr_grouping_included = !map.isdefault("sr_group_levels");
  for(arma::uword i=0; i<map.sera.size(); i++){
    Value srx(kObjectType);
    if (sr_grouping_included) {
      sr_extras = true;
      srx.AddMember("g", map.sera[i].get_group(), allocator);
    }
    if (!map.sera[i].isdefault("sequence")) {
      sr_extras = true;
      srx.AddMember("q", jsonifya(map.sera[i].get_sequence(), allocator), allocator);
    }
    if (!map.sera[i].isdefault("id")) {
      sr_extras = true;
      srx.AddMember("i", jsonifya(map.sera[i].get_id(), allocator), allocator);
    }
    if (!map.sera[i].isdefault("extra")) {
      sr_extras = true;
      srx.AddMember("x", jsonifya(map.sera[i].get_extra(), allocator), allocator);
    }
    xs.PushBack(srx, allocator);
  }
  if (sr_extras) x.AddMember("s", xs, allocator);

  // = OPTIMIZATIONS =
  Value xp(kArrayType);
  bool opt_extras = false;
  for(arma::uword i=0; i<map.optimizations.size(); i++){

    Value optx(kObjectType);

    // Translation
    if (!map.optimizations[i].isdefault("translation")) {
      opt_extras = true;
      optx.AddMember(
        "t",
        jsonifya(
          arma::conv_to<arma::vec>::from(map.optimizations[i].get_translation()),
          allocator
        ),
        allocator
      );
    }

    // Ag reactivity adjustments
    if (!map.optimizations[i].isdefault("ag_reactivity")) {
      opt_extras = true;
      optx.AddMember(
        "r",
        jsonifya(
          map.optimizations[i].get_ag_reactivity_adjustments(),
          allocator
        ),
        allocator
      );
    }

    // Bootstrapping
    if (!map.optimizations[i].isdefault("bootstrap")) {
      opt_extras = true;
      if (map.optimizations[i].bootstrap.size() > 0) {
        optx.AddMember(
          "b",
          jsonifya(map.optimizations[i].bootstrap, allocator),
          allocator
        );
      }
    }

    // // Hemisphering
    // for(arma::uword ag=0; ag<map.optimizations[i].ag_diagnostics.size(); ag++){
    //   if (map.optimizations[i].ag_diagnostics[ag].hemi.size() > 0) {
    //     Value key(
    //         std::to_string(ag).c_str(),
    //         allocator
    //     );
    //     optxh.AddMember(
    //       key,
    //       jsonifya(
    //         map.optimizations[i].ag_diagnostics[ag].hemi,
    //         allocator
    //       ),
    //       allocator
    //     );
    //   }
    // }
    //
    // for(arma::uword sr=0; sr<map.optimizations[i].sr_diagnostics.size(); sr++){
    //   if (map.optimizations[i].sr_diagnostics[sr].hemi.size() > 0) {
    //     Value key(
    //         std::to_string(sr + num_antigens).c_str(),
    //         allocator
    //     );
    //     optxh.AddMember(
    //       key,
    //       jsonifya(
    //         map.optimizations[i].sr_diagnostics[sr].hemi,
    //         allocator
    //       ),
    //       allocator
    //     );
    //   }
    // }
    //
    // if (optxh.Size() > 0) {
    //   optx.AddMember("h", optxh, allocator);
    // }

    xp.PushBack(optx, allocator);

  }
  if (opt_extras) x.AddMember("p", xp, allocator);

  // = OTHER =
  if (!map.isdefault("ag_group_levels"))   x.AddMember("agv", jsonifya(map.get_ag_group_levels(), allocator), allocator);
  if (!map.isdefault("sr_group_levels"))   x.AddMember("srv", jsonifya(map.get_sr_group_levels(), allocator), allocator);
  if (!map.isdefault("layer_names"))       x.AddMember("ln",  jsonifya(map.get_layer_names(), allocator), allocator);
  if (!map.isdefault("dilution_stepsize")) x.AddMember("ds",  map.dilution_stepsize, allocator);
  if (!map.isdefault("description"))       x.AddMember("D",   jsonifya(map.description, allocator), allocator);
  if (!map.isdefault("ag_reactivity"))     x.AddMember("r",   jsonifya(map.get_ag_reactivity_adjustments(), allocator), allocator);

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
  bool success;

  // Setup the writer
  if (pretty) {

    // PrettyWriter<StringBuffer> writer(buffer);
    PrettyWriter<
      StringBuffer, // Output Stream
      UTF8<>,       // Source Encoding
      UTF8<>,       // Target Encoding
      CrtAllocator,
      kParseFullPrecisionFlag
    > writer(buffer);
    writer.SetMaxDecimalPlaces(6);
    success = doc.Accept(writer);

  } else {

    // Writer<StringBuffer> writer(buffer);
    Writer<
      StringBuffer, // Output Stream
      UTF8<>,       // Source Encoding
      UTF8<>,       // Target Encoding
      CrtAllocator,
      kParseFullPrecisionFlag
      > writer(buffer);
    writer.SetMaxDecimalPlaces(6);
    success = doc.Accept(writer);

  }

  // Check for errors
  if(!success){
    Rf_error("Parsing to json .ace format failed");
  }

  // Return the string
  return buffer.GetString();

}

