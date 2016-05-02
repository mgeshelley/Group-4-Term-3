program lattice

    use constants

    implicit none
    
    integer                                 ::  status
    integer                                 ::  L                   !Length of edge of lattice
    integer                                 ::  N                   !No. of distances to try for sheets
    integer                                 ::  x, y, z, i
    integer, dimension(:,:,:), allocatable  ::  sheet               !Array for thin sheets
    integer, dimension(:,:,:), allocatable  ::  cube                !Array for random cube
    
    real(kind=dp)                           ::  prop


    print*, 'Length for cube?'
    read(*,*) L
    print*, L

    print*, 'Proportion of metal atoms that are calcium?'
    read(*,*) prop

    print*, 'CUBE TEST'

    open(unit=10,file='lattice.dat', status='replace')
    
    do i = 0, 4, 1
        
        prop = 0.25*i
        call cube_init(L, cube, prop)
        call write_cube(cube, L,  prop, i)
        deallocate(cube)
    
    end do

    call sheet_init(L, 10, sheet)
    call write_sheet(sheet, L, 10, 0)

    contains

    subroutine sheet_init(L, V, sheet)

        implicit none

        integer, intent(in)                                     ::  L, V                !L is length of side of sheet, V is 'length' really just the total height of structure
        integer, dimension(:,:,:), allocatable, intent(inout)   ::  sheet
        integer                                                 ::  x, y, parity

        allocate(sheet(0:L-1,0:L-1,0:V-1), stat = status)
        if (status /= 0) stop "Error allocating sheet array"

        sheet = 3   !3 means an unfilled space. This is just for the purpose of having a vacuum
        
        do x = 0, L-1, 1
            do y = 0, L-1, 1
                do z = 0, V-1, 1

                    parity = modulo(x+y+z,2)
                    if((z .le. 2).or.(z == V-1))then!If it's in the first three layers or the very top layer
                        if(parity==1)then
                            sheet(x,y,z) = 0
                        else if((z==0).or.(z==V-1))then!Sets it to Mg if it's in the bottom or top layers
                            sheet(x,y,z) = 2
                        else if((z==1).or.(z==2))then!Sets it to Ca if it's in the 2 layers above the bottom layer
                            sheet(x,y,z) = 1
                        end if
                    end if                    

                end do
            end do
        end do

    end subroutine sheet_init

    subroutine cube_init(L, cube, prop)

        implicit none

        integer, dimension(:,:,:), allocatable, intent(inout)   ::  cube            !Cube array for atom coords
        integer, intent(in)                                     ::  L               !Length of side of cube
        integer                                                 ::  atoms           !Total number of atoms in cube
        integer                                                 ::  nme, nca, nmg   !Total number of metal, calcium , magnesium atoms
        integer                                                 ::  x, y, z, i, seed

        real(kind=dp), intent(inout)                            ::  prop            !Proportion of metal ions that are calcium atoms
        real(kind=dp)                                           ::  prob            !'Chance' of placing ca

        call srand(seed)

        allocate(cube(0:L-1,0:L-1,0:L-1), stat = status)
        if (status /= 0) stop "Error allocating cube"

        cube = 0
        atoms = L**3
        print*, 'no of atoms =', atoms
        nme = aint(real(atoms, dp)/2.0_dp)
        print*, 'no of metal =', nme
        nca = nint(prop*real(nme, dp))
        print*, 'no of ca =', nca
        nmg = nme - nca
        print*, 'no of mg =', nmg

        prop = real(nca)/real(nme)

        random_ca: do i = 1, 10000, 1
            do x = 0, L-1, 1
                do y = 0, L-1, 1
                    do z = 0, L-1, 1

                    if(modulo(x+y+z, 2) /= 1)then
                        
                        prob = rand(seed)
                        !print*, nca, nmg, prob, real(nca, dp)/(real(nca, dp)+real(nmg, dp))                        

                        if((nca==1).and.(nmg==0))then!Sets atom to calcium if only one ca left
                            cube(x,y,z) = 1
                            nca = nca - 1
                            exit random_ca
                        else if((nca==0).and.(nmg==1))then!Sets atom to mg if only one mg left
                            cube(x,y,z) = 2
                            nmg = nmg - 1
                            exit random_ca                   
                        else if(prob.lt.(real(nca, dp)/(real(nca, dp)+real(nmg, dp))))then!Sets atom to calcium if probability is right
                            cube(x,y,z) = 1
                            nca = nca - 1
                        else !Sets atom to magnesium
                            cube(x,y,z) = 2
                            nmg = nmg - 1
                        end if

                    end if    

                    end do
                end do
            end do
        end do random_ca
    end subroutine
    
    subroutine write_cube(cube, L,  prop, fileno)
    
        implicit none
        
        integer, dimension(:,:,:), allocatable, intent(in)  ::  cube    !Cube array for atom coords
        real(kind=dp), intent(in)                           ::  prop
        integer, intent(in)                                 ::  L
        integer, intent(in)                                 ::  fileno
        
        character(len=10), parameter                        ::  fmt1 = '(I3.3)'
        character(len=3)                                    ::  filename
        character(len=3)                                    ::  filename2
        
        integer                                             ::  x, y, z
        
        real(kind=dp)                                       ::  step
        real(kind=dp)                                       ::  cart
        
        
        step = 1.0_dp/real(L)
        cart = 4.2_dp*real(L)/2.0_dp
        
        write(filename, fmt1)  int(prop*100.0_dp)
        write(filename2, fmt1) fileno
        
        open(unit=fileno, file='cube_'//filename//'_'//filename2//'.cell')
        
        write(fileno, *) '%BLOCK LATTICE_CART'
        write(fileno, *) cart, 0.0_dp, 0.0_dp
        write(fileno, *) 0.0_dp, cart, 0.0_dp
        write(fileno, *) 0.0_dp, 0.0_dp, cart
        write(fileno, *) '%ENDBLOCK LATTICE_CART'
        write(fileno, *)
        
        write(fileno, *) '%BLOCK POSITIONS_FRAC'
        do x = 0,L-1,1
            do y = 0,L-1,1
                do z = 0,L-1,1
                    write(900+fileno,*) x, y, z, cube(x,y,z)
                    if(cube(x,y,z)==0) write(fileno, *) 'O', x*step, y*step, z*step
                    if(cube(x,y,z)==1) write(fileno, *) 'Ca', x*step, y*step, z*step
                    if(cube(x,y,z)==2) write(fileno, *) 'Mg', x*step, y*step, z*step
                end do
            end do
        end do
        write(fileno, *) '%ENDBLOCK POSITIONS_FRAC'
        write(fileno, *)
        
        write(fileno, *) 'kpoints_mp_grid', 3, 3, 3
        
        write(fileno, *) 'symmetry_generate'
        
        write(fileno, *) '%BLOCK CELL_CONSTRAINTS'
        write(fileno, *) 1, 1, 1
        write(fileno, *) 0, 0, 0
        
        write(fileno, *) '%ENDBLOCK CELL_CONSTRAINTS'
        
        close(unit=fileno)
        
    end subroutine write_cube

    subroutine write_sheet(sheet, L, V, fileno)
    
        implicit none
        
        integer, dimension(:,:,:), allocatable, intent(in)  ::  sheet    !Cube array for atom coords
        integer, intent(in)                                 ::  L
        integer, intent(in)                                 ::  V
        integer, intent(in)                                 ::  fileno
        
        character(len=10), parameter                        ::  fmt1 = '(I3.3)'
        character(len=3)                                    ::  filename
        character(len=3)                                    ::  filename2
        
        integer                                             ::  x, y, z
        
        real(kind=dp)                                       ::  step
        real(kind=dp)                                       ::  cart
        real(kind=dp)                                       ::  stepz
        real(kind=dp)                                       ::  cartz
        
        step  = 1.0_dp/real(L)
        stepz = 1.0_dp/real(V)
        cart  = 4.2_dp*real(L)/2.0_dp
        cartz = 4.2_dp*real(V)/2.0_dp
        
        write(filename, fmt1)  int(prop*100.0_dp)
        write(filename2, fmt1) fileno
        
        open(unit=fileno, file='sheet_'//filename//'_'//filename2//'.cell')
        
        write(fileno, *) '%BLOCK LATTICE_CART'
        write(fileno, *) cart, 0.0_dp, 0.0_dp
        write(fileno, *) 0.0_dp, cart, 0.0_dp
        write(fileno, *) 0.0_dp, 0.0_dp, cartz
        write(fileno, *) '%ENDBLOCK LATTICE_CART'
        write(fileno, *)
        
        write(fileno, *) '%BLOCK POSITIONS_FRAC'
        do x = 0,L-1,1
            do y = 0,L-1,1
                do z = 0,V-1,1
                    !if(sheet(x,y,z).lt.3)then
                        write(900+fileno,*) x, y, z, sheet(x,y,z)
                        print *, x, y, z, sheet(x,y,z)
                        if(sheet(x,y,z)==0) write(fileno, *) 'O', x*step, y*step, z*stepz
                        if(sheet(x,y,z)==1) write(fileno, *) 'Ca', x*step, y*step, z*stepz
                        if(sheet(x,y,z)==2) write(fileno, *) 'Mg', x*step, y*step, z*stepz
                    !end if
                end do
            end do
        end do
        write(fileno, *) '%ENDBLOCK POSITIONS_FRAC'
        write(fileno, *)
        
        write(fileno, *) 'kpoints_mp_grid', 3, 3, 3
        
        write(fileno, *) 'symmetry_generate'
        
        write(fileno, *) '%BLOCK CELL_CONSTRAINTS'
        write(fileno, *) 1, 1, 1
        write(fileno, *) 0, 0, 0
        
        write(fileno, *) '%ENDBLOCK CELL_CONSTRAINTS'
        
        close(unit=fileno)
        
    end subroutine write_sheet


end program lattice
