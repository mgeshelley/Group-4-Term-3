module constants

    implicit none

    public
    
    !Selected Real Kind
    integer, parameter          ::  dp=selected_real_kind(15, 300)
    
    !Trigonometric Stuff
    real(kind=dp), parameter    ::  pi = 4.0_dp*atan(1.0_dp)
    real(kind=dp), parameter    ::  tau= 2.0_dp*pi
    
end module constants
