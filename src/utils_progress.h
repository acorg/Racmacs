
#include <RcppArmadillo.h>
#include <progress.hpp>
#include <progress_bar.hpp>
#include <R.h>

#ifndef Racmacs__utils_progress__h
#define Racmacs__utils_progress__h

class AcProgressBar: public ProgressBar{

  private:
    int barlength = 100;
    bool report;

  public:

    AcProgressBar(
      int length,
      bool reportprogress
    ){
      _finalized = false;
      barlength = length;
      report = reportprogress;
    }

    ~AcProgressBar() {}

    void display() {
      if(!report) return;
      for(int i=0; i<barlength; i++){
        REprintf("-");
      }
    }

    void update(
      float progress
    ){
      if(!report) return;
      if (_finalized) return;
      int amount_done = barlength*progress;
      REprintf("\r");
      for(int i=0; i<amount_done; i++){
        REprintf("=");
      }
    }

    void end_display() {
      if (_finalized) return;
      _finalized = true;
    }

    void complete(
      char const *msg,
      bool finished = true
    ) {

      if(!report) return;
      if(finished){
        REprintf("\r");
        for(int i=0; i<barlength; i++){
          REprintf("=");
        }
        REprintf("\n");
      }

      REprintf(msg);
      REprintf("\n");

    }

  private:

    bool _finalized;

};

#endif

