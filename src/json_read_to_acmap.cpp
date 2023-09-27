
#include "json_read_to_acmap.h"

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
  doc.Parse<kParseFullPrecisionFlag>(json.c_str());

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
  // Rcpp::Rcout << "\n" << "ANTIGENS";
  for( int i=0; i<num_antigens; i++ ){

    const Value& ag = a[i];
    if(ag.HasMember("N")) map.antigens[i].set_name( ag["N"].GetString() );
    if(ag.HasMember("P")) map.antigens[i].set_passage( ag["P"].GetString() );
    if(ag.HasMember("c")) map.antigens[i].set_clade( parse<std::vector<std::string>>(ag["c"]) );
    if(ag.HasMember("a")) map.antigens[i].set_annotations( parse<std::vector<std::string>>(ag["a"]) );
    if(ag.HasMember("l")) map.antigens[i].set_labids( parse<std::vector<std::string>>(ag["l"]) );
    if(ag.HasMember("A")) map.antigens[i].set_sequence( ag["A"].GetString() );
    if(ag.HasMember("Ai")) map.antigens[i].set_sequence_insertions(parse<std::vector<SeqInsertion>>(ag["Ai"]));
    if(ag.HasMember("D")) map.antigens[i].set_date( ag["D"].GetString() );
    if(ag.HasMember("L")) map.antigens[i].set_lineage( ag["L"].GetString() );
    if(ag.HasMember("R")) map.antigens[i].set_reassortant( ag["R"].GetString() );
    if(ag.HasMember("S")) map.antigens[i].set_strings( ag["S"].GetString() );
    if(ag.HasMember("C")) map.antigens[i].set_continent( ag["C"].GetString() );
    if(ag.HasMember("B")) map.antigens[i].set_nucleotidesequence( ag["B"].GetString() );

    // set_reference
    // set_name_full
    // set_name_abbreviated

  }


  // == SERA ============================
  // Rcpp::Rcout << "\n" << "SERA";
  for( int i=0; i<num_sera; i++ ){

    const Value& sr = s[i];
    if(sr.HasMember("N")) map.sera[i].set_name( sr["N"].GetString() );
    if(sr.HasMember("P")) map.sera[i].set_passage( sr["P"].GetString() );
    if(sr.HasMember("c")) map.sera[i].set_clade( parse<std::vector<std::string>>(sr["c"]) );
    if(sr.HasMember("a")) map.sera[i].set_annotations( parse<std::vector<std::string>>(sr["a"]) );
    if(sr.HasMember("A")) map.sera[i].set_sequence( sr["A"].GetString() );
    if(sr.HasMember("Ai")) map.sera[i].set_sequence_insertions(parse<std::vector<SeqInsertion>>(sr["Ai"]));
    if(sr.HasMember("D")) map.sera[i].set_date( sr["D"].GetString() );
    if(sr.HasMember("I")) map.sera[i].set_id( sr["I"].GetString() );
    if(sr.HasMember("s")) map.sera[i].set_species( sr["s"].GetString() );
    if(sr.HasMember("h")) map.sera[i].set_homologous_ags( parse<arma::uvec>(sr["h"]) );
    if(sr.HasMember("L")) map.sera[i].set_lineage( sr["L"].GetString() );
    if(sr.HasMember("R")) map.sera[i].set_reassortant( sr["R"].GetString() );
    if(sr.HasMember("S")) map.sera[i].set_strings( sr["S"].GetString() );
    if(sr.HasMember("C")) map.sera[i].set_continent( sr["C"].GetString() );
    if(sr.HasMember("B")) map.sera[i].set_nucleotidesequence( sr["B"].GetString() );

    // set_reference
    // set_name_full
    // set_name_abbreviated

  }


  // == TITERS ==========================
  // Rcpp::Rcout << "\n" << "TITERS";
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
    // Rcpp::Rcout << "\n" << "TITER LAYERS";
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
  // Rcpp::Rcout << "\n" << "PLOTSPEC";
  if(c.HasMember("p")){

    const Value& p = c["p"]; // plotspec
    const Value& pindices = p["p"];
    const Value& pstyles = p["P"];

    // Set drawing order
    if(p.HasMember("d")){
      map.set_pt_drawing_order( parse<arma::uvec>(p["d"]) );
    }

    // Style antigens
    for(int i=0; i<num_antigens; i++){
      set_style_from_json( map.antigens[i], pstyles[pindices[i].GetInt()]);
    }

    // Style sera
    for(int i=0; i<num_sera; i++){
      set_style_from_json( map.sera[i], pstyles[pindices[i + num_antigens].GetInt()]);
    }

  }

  // == OPTIMIZATION RUNS ======================
  // Rcpp::Rcout << "\n" << "OPTIMIZATIONS";
  if(c.HasMember("P")){

    const Value& P = c["P"]; // optimizations aka "projections"

    // Setup optimizations
    std::vector<AcOptimization> optimizations;
    for ( SizeType i=0; i<P.Size(); i++ ){
      const Value& Opt = P[i];

      // Create optimization
      arma::uword num_dims = 0;
      for (int pt=0; pt < num_points; pt++) {
        if (Opt["l"][pt].Size() > num_dims) {
          num_dims = Opt["l"][pt].Size();
        }
      }
      AcOptimization optimization( num_dims, num_antigens, num_sera );

      // Set coords
      arma::mat coords( num_points, num_dims );
      coords.fill( arma::datum::nan );
      for( int pt=0; pt < num_points; pt++){
        for( SizeType dim=0; dim < Opt["l"][pt].Size(); dim++){
          coords(pt, dim) = parse<double>(Opt["l"][pt][dim]);
        }
      }

      optimization.set_ag_base_coords(coords.rows(0, num_antigens - 1));
      optimization.set_sr_base_coords(coords.rows(num_antigens, num_points - 1));

      // Set details
      if(Opt.HasMember("c")) optimization.set_comment(Opt["c"].GetString());
      if(Opt.HasMember("m")) optimization.set_min_column_basis(Opt["m"].GetString());
      if(Opt.HasMember("C")){
        optimization.set_fixed_column_bases( parse<arma::vec>(Opt["C"]));
      }
      if(Opt.HasMember("t")){
        arma::vec transformation = parse<arma::vec>(Opt["t"]);
        int dim = sqrt(transformation.n_elem);
        optimization.set_transformation(
          arma::reshape( transformation, dim, dim)
        );
      }
      if(Opt.HasMember("T")){
        optimization.set_translation( parse<arma::vec>(Opt["T"]));
      }
      if(Opt.HasMember("s")) optimization.set_stress(parse<double>(Opt["s"]));

      // Add to optimizations
      optimizations.push_back(optimization);

    }

    // Add optimizations to the map
    map.optimizations = optimizations;

  }

  // == EXTRAS =====================
  // Rcpp::Rcout << "\n" << "EXTRAS";
  if(c.HasMember("x")){
    const Value& x = c["x"]; // extra items

    // = AGS =
    if(x.HasMember("a")){
      const Value& xa = x["a"];
      for(SizeType i=0; i<xa.Size(); i++){
        const Value& xai = xa[i];
        if(xai.HasMember("g")) map.antigens[i].set_group( xai["g"].GetInt() );
        if(xai.HasMember("q")) map.antigens[i].set_sequence( xai["q"].GetString() ); // For backwards compatibility
        if(xai.HasMember("i")) map.antigens[i].set_id( xai["i"].GetString() );
        if(xai.HasMember("x")) map.antigens[i].set_extra( xai["x"].GetString() );
      }
    }

    // = SR =
    if(x.HasMember("s")){
      const Value& xs = x["s"];
      for(SizeType i=0; i<xs.Size(); i++){
        const Value& xsi = xs[i];
        if(xsi.HasMember("g")) map.sera[i].set_group( xsi["g"].GetInt() );
        if(xsi.HasMember("q")) map.sera[i].set_sequence( xsi["q"].GetString() ); // For backwards compatibility
        if(xsi.HasMember("i")) map.sera[i].set_id( xsi["i"].GetString() ); // For backwards compatibility
        if(xsi.HasMember("x")) map.sera[i].set_extra( xsi["x"].GetString() );
      }
    }

    // = OPTIMIZATIONS =
    if(x.HasMember("p")){
      const Value& xp = x["p"];
      for(SizeType i=0; i<xp.Size(); i++){
        const Value& xpi = xp[i];
        if(xpi.HasMember("t")) map.optimizations.at(i).set_translation(parse<arma::mat>(xpi["t"]));
        if(xpi.HasMember("r")) {
          map.optimizations.at(i).set_ag_reactivity_adjustments(parse<arma::vec>(xpi["r"]));

          if (i == 0) {
            // For backwards compatibility before reactivity adjustments were an
            // attribute of the map not the optimization
            map.set_ag_reactivity_adjustments(parse<arma::vec>(xpi["r"]));
          }

        }
        if(xpi.HasMember("b")) map.optimizations.at(i).bootstrap = parse<std::vector<BootstrapOutput>>(xpi["b"]);
      }
    }

    // = OTHER =
    if(x.HasMember("agv")) map.set_ag_group_levels( parse<std::vector<std::string>>(x["agv"]) );
    if(x.HasMember("srv")) map.set_sr_group_levels( parse<std::vector<std::string>>(x["srv"]) );
    if(x.HasMember("ds"))  map.dilution_stepsize = x["ds"].GetDouble();
    if(x.HasMember("ln"))  map.set_layer_names( parse<std::vector<std::string>>(x["ln"]) );
    if(x.HasMember("r"))   map.set_ag_reactivity_adjustments( parse<arma::vec>(x["r"]) );
    if(x.HasMember("D"))   map.description = x["D"].GetString();

  }

  // Return the map
  // Rcpp::Rcout << "\n" << "DONE";
  return map;

}

