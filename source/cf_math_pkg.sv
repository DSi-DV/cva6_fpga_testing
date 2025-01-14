/// cf_math_pkg: Constant Function Implementations of Mathematical Functions for HDL Elaboration
///
/// This package contains a collection of mathematical functions that are commonly used when defining
/// the value of constants in HDL code.  These functions are implemented as Verilog constants
/// functions.  Introduced in Verilog 2001 (IEEE Std 1364-2001), a constant function (§ 10.3.5) is a
/// function whose value can be evaluated at compile time or during elaboration.  A constant function
/// must be called with arguments that are constants.
package cf_math_pkg;

  /// Ceiled Division of Two Natural Numbers
  ///
  /// Returns the quotient of two natural numbers, rounded towards plus infinity.
  function automatic integer ceil_div(input longint dividend, input longint divisor);
    automatic longint remainder;
    remainder = dividend;
    for (ceil_div = 0; remainder > 0; ceil_div++) begin
      remainder = remainder - divisor;
    end
  endfunction

  /// Index width required to be able to represent up to `num_idx` indices as a binary
  /// encoded signal.
  /// Ensures that the minimum width if an index signal is `1`, regardless of parametrization.
  ///
  /// Sample usage in type definition:
  /// As parameter:
  ///   `parameter type idx_t = logic[cf_math_pkg::idx_width(NumIdx)-1:0]`
  /// As typedef:
  ///   `typedef logic [cf_math_pkg::idx_width(NumIdx)-1:0] idx_t`
  function automatic integer unsigned idx_width(input integer unsigned num_idx);
    return (num_idx > 32'd1) ? unsigned'($clog2(num_idx)) : 32'd1;
  endfunction

endpackage
