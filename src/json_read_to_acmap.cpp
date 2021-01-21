
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

// Function for extracting double, using arma::datum::nan for null
double get_double(
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

// Function for extracting armadillo vector from json array
arma::vec vec_from_json_array(
  const Value& array
){

  arma::vec v(array.Size());
  for(SizeType i=0; i<array.Size(); i++){
    v(i) = get_double(array[i]);
  }
  return v;

}

arma::uvec uvec_from_json_array(
  const Value& array
){

  arma::uvec v(array.Size());
  for(SizeType i=0; i<array.Size(); i++){
    v(i) = array[i].GetInt();
  }
  return v;

}

std::vector<std::string> strvec_from_json_array(
  const Value& array
){

  std::vector<std::string> v(array.Size());
  for(SizeType i=0; i<array.Size(); i++){
    v[i] = array[i].GetString();
  }
  return v;

}

// Function for setting point style
template <typename T>
void set_style_from_json(
  T& pt,
  const Value& style
){

  if(style.HasMember("+")) pt.plotspec.set_shown( style["+"].GetBool() );           // Point shown
  if(style.HasMember("F")) pt.plotspec.set_fill( style["F"].GetString() );          // Fill color
  if(style.HasMember("O")) pt.plotspec.set_outline( style["O"].GetString() );       // Outline color
  if(style.HasMember("o")) pt.plotspec.set_outline_width( style["o"].GetDouble() ); // Outline width
  if(style.HasMember("S")) pt.plotspec.set_shape( style["S"].GetString() );         // Shape
  if(style.HasMember("s")) pt.plotspec.set_size( style["s"].GetDouble() );          // Size
  if(style.HasMember("r")) pt.plotspec.set_rotation( style["r"].GetDouble() );      // Rotation
  if(style.HasMember("a")) pt.plotspec.set_aspect( style["a"].GetDouble() );        // Aspect

}


// Function for setting titers
void set_titers_from_json(
  AcTiterTable& titer_table,
  const Value& td
){

  for (SizeType ag = 0; ag < td.Size(); ag++){
    for (auto& sr : td[ag].GetObject()){
      titer_table.set_titer_string(
        ag, strtoimax( sr.name.GetString(), NULL, 10 ),
        sr.value.GetString()
      );
    }
  }

}


// [[Rcpp::export]]
AcMap json_to_acmap(
  std::string json
){

  // FILE* fp = fopen(filepath.c_str(), "rb"); // non-Windows use "r"
  //
  // char readBuffer[65536];
  // FileReadStream is(fp, readBuffer, sizeof(readBuffer));

  // Parse the json
  Document doc;
  // doc.ParseStream(is);
  doc.Parse(json.c_str());

  // Perform some checks
  if(!doc.IsObject()){
    Rf_error("Could not parse file");
  };


  // == SETUP ==========================
  // Get map data
  const Value& c = doc["c"];

  // Get antigen and sera info and make map
  const Value& a = c["a"]; // antigens
  const Value& s = c["s"]; // sera
  int num_antigens = a.Size();
  int num_sera = s.Size();
  int num_points = num_antigens + num_sera;
  AcMap map(num_antigens, num_sera);


  // == INFO ============================
  if(c.HasMember("i")){
    const Value& i = c["i"]; // map info

    if(i.HasMember("N")){ map.name = i["N"].GetString(); }

  }


  // == ANTIGENS ========================
  for( int i=0; i<num_antigens; i++ ){

    const Value& ag = a[i];
    if(ag.HasMember("N")) map.antigens[i].set_name( ag["N"].GetString() );
    // set_group_values
    // set_date
    // set_reference
    // set_name_full
    // set_name_abbreviated
    // set_id
    // set_group
    // set_sequence

  }


  // == SERA ============================
  for( int i=0; i<num_sera; i++ ){

    const Value& sr = s[i];
    if(sr.HasMember("N")) map.sera[i].set_name( sr["N"].GetString() );
    // set_group_values
    // set_date
    // set_reference
    // set_name_full
    // set_name_abbreviated
    // set_id
    // set_group
    // set_sequence

  }


  // == TITERS ==========================
  if(c.HasMember("t")){
    const Value& t = c["t"];

    if(t.HasMember("l")){

      // This is for the case that titers are stored simply as a matrix
      for (int ag = 0; ag < num_antigens; ag++){
        for (int sr = 0; sr < num_sera; sr++){
          map.titer_table_flat.set_titer_string(
            ag, sr,
            t["l"][ag][sr].GetString()
          );
        }
      }

    } else if (t.HasMember("d")){

      // This is for the case that titers are stored as a series of objects, each with names relating to the serum number
      set_titers_from_json( map.titer_table_flat, t["d"] );

    } else {

      // If none of the above this is an error
      Rf_error("There was a problem parsing the map");

    }

    // Titer layers
    if (t.HasMember("L")){

      // Setup titer table layers
      int num_layers = t["L"].Size();
      std::vector<AcTiterTable> titer_table_layers(
          num_layers,
          AcTiterTable( num_antigens, num_sera )
      );

      // Parse layers
      for (int layer = 0; layer < num_layers; layer++){
        set_titers_from_json( titer_table_layers[layer], t["L"][layer] );
      }

      // Add layers to map
      map.titer_table_layers = titer_table_layers;

    }

  }

  // == PLOTSPEC =====================
  const Value& p = c["p"]; // plotspec
  const Value& pindices = p["p"];
  const Value& pstyles = p["P"];

  // Set drawing order
  if(p.HasMember("d")){
    map.set_pt_drawing_order( uvec_from_json_array(p["d"]) );
  }

  // Style antigens
  for(int i=0; i<num_antigens; i++){
    set_style_from_json( map.antigens[i], pstyles[pindices[i].GetInt()]);
  }

  // Style sera
  for(int i=0; i<num_sera; i++){
    set_style_from_json( map.sera[i], pstyles[pindices[i + num_antigens].GetInt()]);
  }

  // == OPTIMIZATION RUNS ======================
  if(c.HasMember("P")){

    const Value& P = c["P"]; // optimizations aka "projections"

    // Setup optimizations
    std::vector<AcOptimization> optimizations( P.Size() );
    for ( SizeType i=0; i<P.Size(); i++ ){
      const Value& Opt = P[i];

      // Create optimization
      int num_dims = Opt["l"][0].Size();
      AcOptimization optimization( num_dims, num_antigens, num_sera );

      // Set coords
      arma::mat coords( num_points, num_dims );
      coords.fill( arma::datum::nan );
      for( int pt=0; pt < num_points; pt++){
        for( SizeType dim=0; dim < Opt["l"][pt].Size(); dim++){
          coords(pt, dim) = get_double(Opt["l"][pt][dim]);
        }
      }

      optimization.set_ag_base_coords(coords.rows(0, num_antigens - 1));
      optimization.set_sr_base_coords(coords.rows(num_antigens, num_points - 1));

      // Set details
      if(Opt.HasMember("c")) optimization.set_comment(Opt["c"].GetString());
      if(Opt.HasMember("s")) optimization.set_stress(get_double(Opt["s"]));
      if(Opt.HasMember("m")) optimization.set_min_column_basis(Opt["m"].GetString());
      if(Opt.HasMember("C")){
        optimization.set_fixed_column_bases( vec_from_json_array(Opt["C"]) );
      }
      if(Opt.HasMember("t")){
        arma::vec transformation = vec_from_json_array(Opt["t"]);
        int dim = transformation.n_elem / 2;
        optimization.set_transformation(
          arma::reshape( transformation, dim, dim)
        );
      }
      if(Opt.HasMember("T")){
        optimization.set_translation( vec_from_json_array(Opt["T"]) );
      }

      // Add to optimizations
      optimizations[i] = optimization;

    }

    // Add optimizations to the map
    map.optimizations = optimizations;

  }

  // == EXTRAS =====================
  if(c.HasMember("x")){
    const Value& x = c["x"]; // extra items

    // = AGS =
    if(x.HasMember("a")){
      const Value& xa = x["a"];
      for(SizeType i=0; i<xa.Size(); i++){
        const Value& xai = xa[i];
        if(xai.HasMember("g")) map.antigens[i].set_group( xai["g"].GetInt() );
        if(xai.HasMember("q")) map.antigens[i].set_sequence( xai["q"].GetString() );
        if(xai.HasMember("i")) map.antigens[i].set_id( xai["i"].GetString() );
      }
    }

    // = SR =
    if(x.HasMember("s")){
      const Value& xs = x["s"];
      for(SizeType i=0; i<xs.Size(); i++){
        const Value& xsi = xs[i];
        if(xsi.HasMember("g")) map.sera[i].set_group( xsi["g"].GetInt() );
        if(xsi.HasMember("q")) map.sera[i].set_sequence( xsi["q"].GetString() );
        if(xsi.HasMember("i")) map.sera[i].set_id( xsi["i"].GetString() );
      }
    }

    // = OTHER =
    if(x.HasMember("agv")) map.set_ag_group_levels( strvec_from_json_array(x["agv"]) );
    if(x.HasMember("srv")) map.set_sr_group_levels( strvec_from_json_array(x["srv"]) );

  }

  // Return the map
  return map;

}

