# Bond Risk Manager

This is an app that allows the user to mimic a bond portfolio and retrieve the relevant risk sensitivity measures at the current market 
conditions, or apply their portfolio to past market conditions and see how it would have performed.

## Portfolio Builder

Here users can input their coupon rate, face value, expiry date, and coupon payment frequency on the side bar and click the add to portfolio
button to start building their mock bond portfolio. The table in the center of the screen will populate with bonds that have been added and are
currently being priced into the portfolio.

The portfolio can be quickly cleared by clicking the "clear" button.

The use can also select a valuation date going back to 1992 where the relevant FRED constant maturity treasury curve will be used
to value the bonds.

Below has a graph showing the two yield curves for the selected valuation date. The par yield curve is equivalent to the FRED curve on that day,
it has the been bootstrapped to the zero yield curve also displayed.

## Analysis

By clicking the analysis tab users can view the Price, Delta, and Gamma of each bond in the selected portfolio. It is automatically updated when the
user adds a bond to their portfolio.

## Known Bugs

The RCPPbootstrap_curve function causes R to crash and has been removed from active use.
