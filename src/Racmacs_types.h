
#include <RcppArmadillo.h>
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_map.h"
#include "procrustes.h"

#ifndef Racmacs__RacmacsWrap__h
#define Racmacs__RacmacsWrap__h

// declaring the specialization
namespace Rcpp {

  // For converting from C++ back to R

  // FROM: ACOPTIMIZATION
  template <>
  SEXP wrap(const AcOptimization& acopt){
    return wrap(
      List::create(
        _["ag_base_coords"] = acopt.get_ag_base_coords(),
        _["sr_base_coords"] = acopt.get_sr_base_coords(),
        _["column_bases"] = acopt.get_column_bases(),
        _["transformation"] = acopt.get_transformation(),
        _["translation"] = acopt.get_translation(),
        _["stress"] = acopt.get_stress(),
        _["comment"] = acopt.get_comment()
      )
    );
  }

  // FROM: ACTITER
  template <>
  SEXP wrap(const AcTiter& t){
    return wrap(t.toString());
  }

  // FROM: ACTITER VECTOR
  template <>
  SEXP wrap(const std::vector<AcTiter>& titers){
    CharacterVector titers_out(titers.size());
    for(int i=0; i<titers.size(); i++){
      titers_out[i] = titers[i].toString();
    }
    return wrap(titers_out);
  }

  // FROM: ACTITERTABLE
  template <>
  SEXP wrap(const AcTiterTable& t){

    int num_ags = t.nags();
    int num_sr = t.nsr();

    CharacterMatrix titers_out(num_ags, num_sr);
    for(int ag=0;ag<num_ags;ag++){
      for(int sr=0;sr<num_sr;sr++){
        titers_out(ag, sr) = t.get_titer_string(ag, sr);
      }
    }

    return wrap(titers_out);
  }

  // FROM: PROCRUSTES
  template <>
  SEXP wrap(const Procrustes& p){
    return wrap(
      List::create(
        _["R"] = p.R,
        _["tt"] = p.tt,
        _["s"] = p.s
      )
    );
  }

  // FROM: ARMA::VEC
  template <>
  SEXP wrap(const arma::vec& v){
    NumericVector out(v.size());
    for(int i=0; i<v.size(); i++){
      out[i] = v[i];
    }
    return wrap(out);
  }

  // FROM: ANTIGEN
  SEXP wrap(const AcAntigen& ag){
    return wrap(
      List::create(
        _["name"] = ag.get_name(),
        _["id"] = ag.get_id(),
        _["shown"] = ag.get_shown(),
        _["size"] = ag.get_size(),
        _["fill"] = ag.get_fill(),
        _["shape"] = ag.get_shape(),
        _["outline"] = ag.get_outline(),
        _["outline_width"] = ag.get_outline_width(),
        _["rotation"] = ag.get_rotation(),
        _["aspect"] = ag.get_aspect(),
        _["drawing_order"] = ag.get_drawing_order()
      )
    );
  }

  // FROM: SERUM
  SEXP wrap(const AcSerum& sr){
    return wrap(
      List::create(
        _["name"] = sr.get_name(),
        _["id"] = sr.get_id(),
        _["shown"] = sr.get_shown(),
        _["size"] = sr.get_size(),
        _["fill"] = sr.get_fill(),
        _["shape"] = sr.get_shape(),
        _["outline"] = sr.get_outline(),
        _["outline_width"] = sr.get_outline_width(),
        _["rotation"] = sr.get_rotation(),
        _["aspect"] = sr.get_aspect(),
        _["drawing_order"] = sr.get_drawing_order()
      )
    );
  }

  // FROM: ACMAP
  template <>
  SEXP wrap(const AcMap& acmap){

    // Antigens
    List antigens = List::create();
    for(int i=0; i<acmap.antigens.size(); i++){
      antigens.push_back(as<List>(wrap(acmap.antigens[i])));
    }

    // Sera
    List sera = List::create();
    for(int i=0; i<acmap.sera.size(); i++){
      sera.push_back(as<List>(wrap(acmap.sera[i])));
    }

    // Optimizations
    List optimizations = List::create();
    for(int i=0; i<acmap.optimizations.size(); i++){
      optimizations.push_back(as<List>(wrap(acmap.optimizations[i])));
    }

    // Titer table layers
    List titer_table_layers = List::create();
    for(int i=0; i<acmap.titer_table_layers.size(); i++){
      titer_table_layers.push_back(as<List>(wrap(acmap.titer_table_layers[i])));
    }

    // Titer table flat
    CharacterMatrix titer_table_flat = as<CharacterMatrix>(wrap(acmap.titer_table_flat));

    return wrap(
      List::create(
        _["name"] = acmap.name,
        _["antigens"] = antigens,
        _["sera"] = sera,
        _["titer_table_flat"] = titer_table_flat,
        _["titer_table_layers"] = titer_table_layers
      )
    );

  }

  // For converting from R to C++
  // TO: ACOPTIMIZATION
  template <>
  AcOptimization as(SEXP sxp){
    List opt = as<List>(sxp);
    AcOptimization acopt = AcOptimization();
    acopt.set_ag_base_coords( as<arma::mat>(wrap(opt["ag_base_coords"])) );
    acopt.set_sr_base_coords( as<arma::mat>(wrap(opt["sr_base_coords"])) );
    acopt.set_comment( as<std::string>(wrap(opt["comment"])) );
    acopt.set_stress( as<double>(wrap(opt["stress"])) );
    acopt.set_transformation( as<arma::mat>(wrap(opt["transformation"])) );
    acopt.set_translation( as<arma::mat>(wrap(opt["translation"])) );
    acopt.set_min_column_basis( as<std::string>(wrap(opt["min_column_basis"])) );
    if(opt["min_column_basis"] == "fixed"){
      acopt.set_column_bases( as<arma::vec>(wrap(opt["column_bases"])) );
    }
    return acopt;
  };

  // TO: ACTITER
  template <>
  AcTiter as(SEXP sxp){
    std::string titer = as<std::string>(sxp);
    return AcTiter(titer);
  };

  // TO: ACTITERTABLE
  template <>
  AcTiterTable as(SEXP sxp){
    try {

      // First try character matrix
      CharacterMatrix titers = as<CharacterMatrix>(sxp);
      int num_ags = titers.nrow();
      int num_sr = titers.ncol();
      AcTiterTable titertable = AcTiterTable(
        num_ags,
        num_sr
      );
      for(int ag=0; ag<num_ags; ag++){
        for(int sr=0; sr<num_sr; sr++){
          titertable.set_titer_string(
            ag, sr,
            as<std::string>(titers(ag,sr))
          );
        }
      }
      return titertable;

    } catch(...){

      // Then try numeric matrix
      NumericMatrix titers = as<NumericMatrix>(sxp);
      int num_ags = titers.nrow();
      int num_sr = titers.ncol();
      AcTiterTable titertable = AcTiterTable(
        num_ags,
        num_sr
      );
      for(int ag=0; ag<num_ags; ag++){
        for(int sr=0; sr<num_sr; sr++){
          titertable.set_titer_double(
            ag, sr,
            titers(ag,sr)
          );
        }
      }
      return titertable;

    }
  };

  // TO: ACTITER VECTOR
  template <>
  std::vector<AcTiter> as(SEXP sxp){
    CharacterVector titerstrings = as<CharacterVector>(sxp);
    int ntiters = titerstrings.size();
    std::vector<AcTiter> out(ntiters);
    for(int i=0; i<ntiters; i++){
      out[i] = as<AcTiter>(wrap(titerstrings(i)));
    }
    return out;
  }

  // TO: ACTITERTABLE VECTOR
  template <>
  std::vector<AcTiterTable> as(SEXP sxp){
    List list = as<List>(sxp);
    std::vector<AcTiterTable> out;
    for(int i=0; i<list.size(); i++){
      out.push_back(
        as<AcTiterTable>(wrap(
          list(i)
        ))
      );
    }
    return out;
  }

  // TO: ACANTIGEN
  template <>
  AcAntigen as(SEXP sxp){

    List list = as<List>(sxp);
    AcAntigen ag;

    if(list.containsElementNamed("name")) { ag.set_name(list["name"]); }
    if(list.containsElementNamed("id")) { ag.set_id(list["id"]); }
    if(list.containsElementNamed("shown")) { ag.set_shown(list["shown"]); }
    if(list.containsElementNamed("size")) { ag.set_size(list["size"]); }
    if(list.containsElementNamed("fill")) { ag.set_fill(list["fill"]); }
    if(list.containsElementNamed("shape")) { ag.set_shape(list["shape"]); }
    if(list.containsElementNamed("outline")) { ag.set_outline(list["outline"]); }
    if(list.containsElementNamed("outline_width")) { ag.set_outline_width(list["outline_width"]); }
    if(list.containsElementNamed("rotation")) { ag.set_rotation(list["rotation"]); }
    if(list.containsElementNamed("aspect")) { ag.set_aspect(list["aspect"]); }
    if(list.containsElementNamed("drawing_order")) { ag.set_drawing_order(list["drawing_order"]); }

    return ag;

  }

  // TO: ACSERUM
  template <>
  AcSerum as(SEXP sxp){

    List list = as<List>(sxp);
    AcSerum sr;

    if(list.containsElementNamed("name")) { sr.set_name(list["name"]); }
    if(list.containsElementNamed("id")) { sr.set_id(list["id"]); }
    if(list.containsElementNamed("shown")) { sr.set_shown(list["shown"]); }
    if(list.containsElementNamed("size")) { sr.set_size(list["size"]); }
    if(list.containsElementNamed("fill")) { sr.set_fill(list["fill"]); }
    if(list.containsElementNamed("shape")) { sr.set_shape(list["shape"]); }
    if(list.containsElementNamed("outline")) { sr.set_outline(list["outline"]); }
    if(list.containsElementNamed("outline_width")) { sr.set_outline_width(list["outline_width"]); }
    if(list.containsElementNamed("rotation")) { sr.set_rotation(list["rotation"]); }
    if(list.containsElementNamed("aspect")) { sr.set_aspect(list["aspect"]); }
    if(list.containsElementNamed("drawing_order")) { sr.set_drawing_order(list["drawing_order"]); }

    return sr;

  }

  // TO: ACMAP
  template <>
  AcMap as(SEXP sxp){

    List list = as<List>(sxp);

    List antigens = list["antigens"];
    List sera = list["sera"];
    List optimizations = list["optimizations"];
    List titer_table_layers = list["titer_table_layers"];

    AcMap acmap(antigens.size(), sera.size());

    // Antigens
    for(int i=0; i<acmap.antigens.size(); i++){
      acmap.antigens[i] = as<AcAntigen>(wrap(antigens[i]));
    }

    // Sera
    for(int i=0; i<acmap.sera.size(); i++){
      acmap.sera[i] = as<AcSerum>(wrap(sera[i]));
    }

    // Optimizations
    for(int i=0; i<optimizations.size(); i++){
      acmap.optimizations.push_back(as<AcOptimization>(wrap(optimizations[i])));
    }

    // Titer table layers
    for(int i=0; i<titer_table_layers.size(); i++){
      acmap.titer_table_layers.push_back(as<AcTiterTable>(wrap(titer_table_layers[i])));
    }

    // Titer table flat
    acmap.titer_table_flat = as<AcTiterTable>(wrap(list["titer_table_flat"]));

    return acmap;
  }

}

#endif
