
#ifndef Racmacs__ac_optimizer_options__h
#define Racmacs__ac_optimizer_options__h

// Optimizer options
struct AcOptimizerOptions {

  bool dim_annealing;
  std::string method;
  int maxit;
  int num_basis;
  double armijo_constant;
  double wolfe;
  double min_gradient_norm;
  double factr;
  int max_line_search_trials;
  double min_step;
  double max_step;
  int num_cores;
  bool report_progress;
  int progress_bar_length;

};

#endif
