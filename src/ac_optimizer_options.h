
#ifndef Racmacs__ac_optimizer_options__h
#define Racmacs__ac_optimizer_options__h

// Optimizer options
struct AcOptimizerOptions {

  bool dim_annealing;
  std::string method;
  int maxit;
  int num_cores;
  bool report_progress;
  int progress_bar_length;

};

#endif
