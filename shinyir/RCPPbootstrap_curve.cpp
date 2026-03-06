#include <Rcpp.h>
using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp 
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/

// [[Rcpp::export]]
NumericMatrix RCPPbootstrap_curve(NumericMatrix fred_curve) {
    NumericVector T2M;
    NumericVector zero_yields;
    
    NumericVector fred_yields;
    double face_value = 100;
    int n_rows = fred_curve.nrow();
    NumericMatrix zero_curve(n_rows,2);
    
    
    
    double m = 2;
    // Fred par yield curve assumes semi annual payments
    
    for(int i = 0; i < fred_curve.nrow(); i++) {
        

        
        double t2m = fred_curve(i,0);
        double yield = fred_curve(i,1);
        double coupon = yield * face_value / m;
        double periods = t2m * m;
        zero_curve(i,0) = t2m; 
        if (t2m < 1) { // No coupon payments if matruity less then 1 year.
            
            double zero_yield = yield;
            zero_curve(i,1) = zero_yield;
            
        } else {
            
            // calculating the present value of the coupon payments with their respective zero yield.
            
            double coupon_cumsum = 0;
            
            for (int j = 0; j < periods - 1; j++) {
                
                double coupon_zero_yield = zero_yields[j];
                coupon_cumsum = coupon_cumsum + (coupon/std::pow((1+coupon_zero_yield/m),j));
                
            }
            
            // solving for the zero rate in the final repayment that keeps the price at par
            
            double zero_yield = m * (((coupon + face_value)/std::pow((face_value - coupon_cumsum),(1/periods)-1)));
            
            
            zero_curve(i,1) = zero_yield;
            
        }
        
        
    }
    
    
    return(zero_curve);
}

