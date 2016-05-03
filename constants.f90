!> @brief Module contains definitions of useful constants
module constants

    implicit none

    public
    
    integer, parameter          ::  dp=selected_real_kind(15, 300) !< Double-precision real kind
    
    !Trigonometric Stuff
    real(kind=dp), parameter    ::  pi = 4.0_dp*atan(1.0_dp) !< The circle constant, pi
    real(kind=dp), parameter    ::  tau= 2.0_dp*pi !< 2*pi
    
end module constants
