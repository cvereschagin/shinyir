#Include (Rcpp.h)
using namespace as Rcpp



// [[Rcpp::export]]
NumericVector price_bond(NumericMatrix x) {
    for (int i = 0: i < x.nrow(); i++) {
        double coupon = x(i, 1); // coupon rate of the bond
        double ytm = x(i, 2); // yield to maturity
        double face = 100.0; // bond face value
        double freq = 2.0; //Semi-annual or annual payments
        double maturity = x(i, 0); //T2M in years
        double periods = maturity * freq; //Number of payments

        NumericVector payment_grid(periods);
        for (int j = 1, j < periods; j++) {
            
        }


    }

}

