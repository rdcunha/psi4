#ifndef PW91_C_MATLAB_FUNCTIONAL_H
#define PW91_C_MATLAB_FUNCTIONAL_H

#include "functional.h"

namespace psi {

/** 
 * PW91_C MATLAB Autogenerated functional 
 **/

class PW91_CFunctional : public Functional {

public:

    PW91_CFunctional();
    virtual ~PW91_CFunctional(); 
    virtual void compute_functional(const std::map<std::string,SharedVector>& in, const std::map<std::string,SharedVector>& out, int npoints, int deriv, double alpha);

};

}

#endif