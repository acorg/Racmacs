
#include <RcppArmadillo.h>
#include "procrustes.h"
#include "utils.h"
#include "utils_error.h"
#include "utils_transformation.h"
#include "ac_titers.h"
#include "acmap_titers.h"
#include "acmap_diagnostics.h"
#include "ac_optimizer_options.h"
#include "ac_relax_coords.h"
#include "ac_coords_stress.h"
#include "ac_bootstrap_output.h"

#ifndef Racmacs__acmap_optimization__h
#define Racmacs__acmap_optimization__h

// Define the optimization class
class AcOptimization {

  private:

    arma::vec fixed_column_bases;
    std::string min_column_basis;
    arma::mat ag_base_coords;
    arma::mat sr_base_coords;
    std::string comment;
    arma::mat transformation;
    arma::mat translation;

  public:

    std::vector<AcDiagnostics> ag_diagnostics;
    std::vector<AcDiagnostics> sr_diagnostics;
    std::vector<BootstrapOutput> bootstrap;
    double stress = arma::datum::nan;

    // Constructors
    AcOptimization(){}
    AcOptimization(
      const int &dimensions,
      const int &num_antigens,
      const int &num_sera
    ){

      ag_base_coords = arma::mat(num_antigens, dimensions, arma::fill::zeros);
      sr_base_coords = arma::mat(num_sera, dimensions, arma::fill::zeros);
      transformation = arma::mat(dimensions, dimensions, arma::fill::eye);
      translation    = arma::mat(dimensions, 1, arma::fill::zeros);
      min_column_basis = "none";
      fixed_column_bases = arma::vec(num_sera);
      fixed_column_bases.fill(arma::datum::nan);
      ag_diagnostics.resize(num_antigens);
      sr_diagnostics.resize(num_sera);

    }

    // Getters
    std::string get_min_column_basis() const { return min_column_basis; }
    arma::vec get_fixed_column_bases() const { return fixed_column_bases; }
    double get_fixed_column_bases(int i) const { return fixed_column_bases(i); }
    std::string get_comment() const { return comment; }
    arma::mat get_transformation() const { return transformation; }
    arma::mat get_translation() const { return translation; }
    double get_stress() const { return stress; }
    int get_dimensions() const { return ag_base_coords.n_cols; }

    // Setters
    void set_comment( std::string comment_in ){ comment = comment_in; }
    void set_transformation( arma::mat transformation_in ){ transformation = transformation_in; }
    void set_translation( arma::mat translation_in ){ translation = translation_in; }
    void set_stress( double stress_in ){ stress = stress_in; }

    void set_fixed_column_bases(
        arma::vec fixed_column_bases_in,
        bool reset_stress = true
      ){

      // Check fixed col bases validity
      if(fixed_column_bases_in.n_elem != sr_base_coords.n_rows){
        Rf_error("Fixed column base length does not match the number of sera");
      }
      fixed_column_bases = fixed_column_bases_in;

      // Invalidate stress
      if (reset_stress) invalidate_stress();

    }

    void set_min_column_basis(
      const std::string min_column_basis_in,
      bool reset_stress = true
    ){

      // Check min col basis validity
      if(min_column_basis_in != "none"){
        check_valid_titer(min_column_basis_in);
      }

      // Set min col basis
      min_column_basis = min_column_basis_in;

      // Invalidate stress
      if (reset_stress) invalidate_stress();

    }

    // Invalidate the currently calculated stress, for example when points are moved
    void invalidate_stress() { stress = arma::datum::nan; }

    // Getting antigen base coords
    arma::mat get_ag_base_coords() const { return ag_base_coords; }
    arma::vec get_ag_base_coords( arma::uword& ag ) const {
      return arma::vectorise(
        ag_base_coords.row(ag)
      );
    }

    // Getting sera base coords
    arma::mat get_sr_base_coords() const { return sr_base_coords; }
    arma::vec get_sr_base_coords( arma::uword& sr ) const {
      return arma::vectorise(
        sr_base_coords.row(sr)
      );
    }


    // Setting antigen base coords
    void set_ag_base_coords( arma::mat ag_base_coords_in ){
      // Check input
      if(ag_base_coords_in.n_rows != ag_base_coords.n_rows){
        ac_error("ag_base_coords rows (%i) does not match input rows (%i)", ag_base_coords.n_rows, ag_base_coords_in.n_rows);
      }
      // Update coords
      ag_base_coords = ag_base_coords_in;
      invalidate_stress();
    }


    // Setting sera base coords
    void set_sr_base_coords( arma::mat sr_base_coords_in ){
      // Check input
      if(sr_base_coords_in.n_rows != sr_base_coords.n_rows){
        ac_error("sr_base_coords rows (%i) does not match input rows (%i)", sr_base_coords.n_rows, sr_base_coords_in.n_rows);
      }
      // Update coords
      sr_base_coords = sr_base_coords_in;
      invalidate_stress();
    }


    // Setting coords of a specific ag
    void set_ag_base_coords(
        arma::uword ag_index,
        arma::vec ag_base_coords_in
    ){
      // Check input
      if(ag_base_coords_in.n_elem != ag_base_coords.n_cols){
        ac_error("antigen coords length (%i) exceeds antigen coords dimensions (%i)", ag_base_coords_in.n_elem, ag_base_coords.n_cols);
      }
      // Update coords
      for(arma::uword i=0; i<ag_base_coords.n_cols; i++){
        ag_base_coords( ag_index, i ) = ag_base_coords_in(i);
      }
      invalidate_stress();
    }


    // Setting coords of a specific sr
    void set_sr_base_coords(
        arma::uword sr_index,
        arma::vec sr_base_coords_in
    ){
      // Check input
      if(sr_base_coords_in.n_elem != sr_base_coords.n_cols){
        ac_error("sera coords length (%i) exceeds sera coords dimensions (%i)", sr_base_coords_in.n_elem, sr_base_coords.n_cols);
      }
      // Update coords
      for(arma::uword i=0; i<sr_base_coords.n_cols; i++){
        ag_base_coords( sr_index, i ) = sr_base_coords_in(i);
      }
      invalidate_stress();
    }


    // Setting coords of a subset of ags
    void set_ag_base_coords(
        arma::uvec ag_indices,
        arma::mat ag_base_coords_in
    ){
      // Check input
      if(ag_base_coords_in.n_rows != ag_indices.n_elem){
        ac_error("ag_indices length (%i) does not match input rows (%i)", ag_indices.n_elem, ag_base_coords_in.n_rows);
      }
      if(ag_indices.max() > ag_base_coords.n_rows - 1){
        ac_error("ag_indices max (%i) exceeds max antigen index (%i)", ag_indices.max(), ag_base_coords.n_rows - 1);
      }
      // Update coords
      ag_base_coords.rows( ag_indices ) = ag_base_coords_in;
      invalidate_stress();
    }


    // Setting coords of a subset of sr
    void set_sr_base_coords(
        arma::uvec sr_indices,
        arma::mat sr_base_coords_in
    ){
      // Check input
      if(sr_base_coords_in.n_rows != sr_indices.n_elem){
        ac_error("sr_indices length (%i) does not match input rows (%i)", sr_indices.n_elem, sr_base_coords_in.n_rows);
      }
      if(sr_indices.max() > sr_base_coords.n_rows - 1){
        ac_error("sr_indices max (%i) exceeds max antigen index (%i)", sr_indices.max(), sr_base_coords.n_rows - 1);
      }
      // Update coords
      sr_base_coords.rows( sr_indices ) = sr_base_coords_in;
      invalidate_stress();
    }


    // Get dimensions
    int dim() const {
      return ag_base_coords.n_cols;
    }

    int num_ags() const {
      return ag_base_coords.n_rows;
    }

    int num_sr() const {
      return sr_base_coords.n_rows;
    }

    // Retrieve point base coordinates (ag then sera)
    arma::mat ptBaseCoords() const {
      return arma::join_cols(
        ag_base_coords,
        sr_base_coords
      );
    }

    // Retrieve antigen coordinates
    arma::mat agCoords() const{
      return transform_coords(
        ag_base_coords,
        transformation,
        translation
      );
    }

    // Retrieve sera coordinates
    arma::mat srCoords() const{
      return transform_coords(
        sr_base_coords,
        transformation,
        translation
      );
    }

    // Retrieve point coordinates (ags then sr)
    arma::mat ptCoords() const{
      return arma::join_cols(
        agCoords(),
        srCoords()
      );
    }

    // Apply the optimization transform to an arbitrary set of coordinates
    arma::mat applyTransformation(
      arma::mat coords
    ) const {
      return transform_coords(
        coords,
        transformation,
        translation
      );
    }

    // Bake in the current transformation into the base coordinates
    void bake_transformation(){

      // Set the base coordinates
      ag_base_coords = agCoords();
      sr_base_coords = srCoords();

      // Reset transformation and translation
      set_transformation(
        arma::mat(dim(), dim(), arma::fill::eye)
      );
      set_translation(
        arma::mat(dim(), 1, arma::fill::zeros)
      );

    }

    // Set ag coordinates
    void set_ag_coords(
      arma::mat coords
    ){
      bake_transformation();
      set_ag_base_coords(coords);
    }

    // Set sr coordinates
    void set_sr_coords(
        arma::mat coords
    ){
      bake_transformation();
      set_sr_base_coords(coords);
    }

    // Align to another optimization
    void alignToOptimization(
      AcOptimization target
    ){

        // Get coordinates
        arma::mat source_coords = ptBaseCoords();
        arma::mat target_coords = target.ptBaseCoords();

        // Perform procrustes
        Procrustes pc = ac_procrustes(
          source_coords,
          target_coords
        );

        // Set transformation
        transformation = pc.R;
        translation = pc.tt;

    }

    // Calculate the distance matrix
    arma::mat distance_matrix(
    ) const {

      int nags = num_ags();
      int nsr = num_sr();

      arma::mat distmat( nags, nsr );
      for(int ag=0; ag<nags; ag++){
        for(int sr=0; sr<nsr; sr++){
          distmat(ag, sr) = ptDist(ag, sr);
        }
      }

      return distmat;

    }

    // Calculate point distance
    double ptDist(
      int ag,
      int sr
    ) const {

      return euc_dist(
        arma::vectorise(ag_base_coords.row(ag)),
        arma::vectorise(sr_base_coords.row(sr))
      );

    }

    // Calculate the column bases
    arma::vec calc_colbases(
       AcTiterTable titers
    ) const {
      return titers.colbases(
        min_column_basis,
        fixed_column_bases
      );
    }

    // Reduce dimensions of optimization through principle component analysis
    void reduceDimensions(
      arma::uword dims
    ){

      // Reduce coordinate dimensions
      arma::mat coords = arma::join_cols(
        ag_base_coords,
        sr_base_coords
      );
      arma::mat coeff = arma::princomp(coords);
      ag_base_coords = ag_base_coords*coeff.cols(0, dims);
      sr_base_coords = sr_base_coords*coeff.cols(0, dims);
      invalidate_stress();

    }

    // Randomise coordinates
    void randomizeCoords(
      double boxsize
    ){

      double min = -boxsize/2.0;
      double max = boxsize/2.0;
      ag_base_coords.randu();
      sr_base_coords.randu();
      ag_base_coords = ag_base_coords*(max-min) + min;
      sr_base_coords = sr_base_coords*(max-min) + min;
      invalidate_stress();

    }

    // Recalulate the optimization stress
    void recalculate_stress(
      AcTiterTable titertable
    ){

      arma::vec colbases = calc_colbases( titertable );
      stress = ac_coords_stress(
        titertable.numeric_table_distances( colbases ),
        titertable.get_titer_types(),
        ag_base_coords,
        sr_base_coords
      );

    }

    // Relax the optimization
    void relax_from_raw_matrices(
      const arma::mat &tabledist_matrix,
      const arma::umat &titertype_matrix,
      const AcOptimizerOptions options,
      const arma::uvec &fixed_antigens = arma::uvec(),
      const arma::uvec &fixed_sera = arma::uvec(),
      const arma::mat &titer_weights = arma::mat()
    ){

      stress = ac_relax_coords(
        tabledist_matrix,
        titertype_matrix,
        ag_base_coords,
        sr_base_coords,
        options,
        fixed_antigens,
        fixed_sera,
        titer_weights
      );

    }

    void relax_from_titer_table(
      AcTiterTable titers,
      const AcOptimizerOptions options,
      const arma::uvec &fixed_antigens = arma::uvec(),
      const arma::uvec &fixed_sera = arma::uvec(),
      const arma::mat &titer_weights = arma::mat()
    ){

      relax_from_raw_matrices(
        titers.numeric_table_distances(
          calc_colbases(titers)
        ),
        titers.get_titer_types(),
        options,
        fixed_antigens,
        fixed_sera,
        titer_weights
      );

    }

    // Removing antigens and sera
    void remove_antigen(
        arma::uword ag
    ){
      ag_base_coords.shed_row(ag);
      ag_diagnostics.erase(ag_diagnostics.begin() + ag);
    }

    void remove_serum(
        arma::uword sr
    ){
      sr_base_coords.shed_row(sr);
      sr_diagnostics.erase(sr_diagnostics.begin() + sr);
      fixed_column_bases.shed_row(sr);
    }

    // Subsetting
    void subset(
        arma::uvec ags,
        arma::uvec sr
    ){

      ag_base_coords = ag_base_coords.rows(ags);
      sr_base_coords = sr_base_coords.rows(sr);
      fixed_column_bases = fixed_column_bases.elem(sr);
      ag_diagnostics = subset_vector(ag_diagnostics, ags);
      sr_diagnostics = subset_vector(sr_diagnostics, sr);
      invalidate_stress();

    }

    // Transformation
    void transform(
      arma::mat transform_matrix
    ){

      ac_transform_translation(
        translation,
        transform_matrix
      );

      ac_transform_transformation(
        transformation,
        transform_matrix
      );

    }

    // Translation
    void translate(
      arma::mat translation_matrix
    ){

      ac_translate_translation(
        translation,
        translation_matrix
      );

    }

    // Rotation
    void rotate(
      double degrees,
      arma::uword axis_num = 2
    ){

      transform(
        ac_rotation_matrix(
          degrees,
          dim(),
          axis_num
        )
      );

    }

    // Reflection
    void reflect(
      arma::uword axis_num = 0
    ){

      transform(
        ac_reflection_matrix(
          dim(),
          axis_num
        )
      );

    }

};

#endif
