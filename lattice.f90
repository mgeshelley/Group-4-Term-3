!> \brief Fortran 2003 program to generate an initial lattice
!! 
!! \todo Produce a pair of sheets with a vacuum between them
!!
!! This program creates a CASTEP cell file consisting of a random
!! arrangement of Ca and Mg atoms in a crystal structure with
!! oxygen, according to a user specification.

!! \bug Code generates a file called fort.6. It is unknown what this is or why it exists. It appears to contain lots of lattice information preceeded by a 7.
program lattice

    use constants

    implicit none
    
    integer                                 ::  status
    integer                                 ::  L                   !< Length of edge of lattice
    integer                                 ::  V                   !< Length of cuboid in z direction, determines the size of the vacuum
    integer                                 ::  x, y, z, i, j
    integer                                 ::  no                  !< No. of runs
    integer, dimension(:,:,:), allocatable  ::  sheet               !< Array for thin sheets
    integer, dimension(:,:,:), allocatable  ::  cube                !< Array for random cube
    
    real(kind=dp)                           ::  prop                !< Proportion of metal
    real(kind=dp)                           ::  prop_inc            !< Increment for the proportion


    L = 3
    v = 10
    
    no = floor(real(L**3)/2.0_dp)       !Number of runs to get as many different proportions in the cube as possible
    prop_inc = 1.0_dp/real(no)          !The increment in the proportion
    
    !Loops over all different proportions
    do i = 0, no, 1
        prop = prop_inc*i
        call cube_init(L, cube, prop)
        call write_cube(cube, L,  prop, i)
        deallocate(cube) 
        print *, 'cube', i   
    end do

    L = 4

    no = floor(real(L**2)/2.0_dp)
    prop_inc = 1.0_dp/real(no)

    do j = 0, no, 1
        prop = prop_inc*j
        call sheet_init(L, V, sheet, prop)
        call write_sheet(sheet, L, V, prop, j)
        deallocate(sheet)
    end do

    contains

    !> \brief Initialises a thin sheet of randomly-arranged atoms
    !! \param[in] L (integer) length of a side of the sheet
    !! \param[in] V (integer) total height of the structure
    !! \param[out] sheet (integer array) the generated sheet
    subroutine sheet_init(L, V, sheet, prop)

        implicit none

        integer, intent(in)                                     ::  L, V                !L is length of side of sheet, V is 'length' really just the total height of structure
        integer, dimension(:,:,:), allocatable, intent(inout)   ::  sheet
        integer                                                 ::  x, y, parity, seed
        integer                                                 ::  atoms               !Total number of atoms in the one atom thick sheet interface 
        integer                                                 ::  nme, nca, nmg       !Total number of metal, calcium , magnesium atoms

        real(kind=dp), intent(inout)                            ::  prop                !Proportion of metal ions that are calcium atoms
        real(kind=dp)                                           ::  prob                !'Chance' of placing ca

        call srand(seed)        

        atoms = L**2

        nme = ceiling(real(atoms, dp)/2.0_dp)

        nca = nint(prop*real(nme, dp))

        nmg = nme - nca


        prop = real(nca)/real(nme)

        allocate(sheet(0:L-1,0:L-1,0:V-1), stat = status)
        if (status /= 0) stop "Error allocating sheet array"

        sheet = 3   !3 means an unfilled space. This is just for the purpose of having a vacuum
        
        do x = 0, L-1, 1
            do y = 0, L-1, 1
                do z = 0, V-1, 1
                    !Determines odd or even
                    parity = modulo(x+y+z,2)
                    if((z .le. 1).or.(z == V-1))then!If it's in the first two layers or the very top layer then it's not a vacuum
                        if(parity==1)then
                            sheet(x,y,z) = 0
                        else if((z==0).or.(z==V-1))then!Sets it to Mg if it's in the bottom or top layers
                            sheet(x,y,z) = 2
                        else if(z==1)then!Sets it to Ca if it's in the 2 layers above the bottom layer
                            if((nca==1).and.(nmg==0))then!Sets atom to calcium if only one ca left
                            sheet(x,y,z) = 1
                            nca = nca - 1
                        else if((nca==0).and.(nmg==1))then!Sets atom to mg if only one mg left
                            sheet(x,y,z) = 2
                            nmg = nmg - 1                   
                        else if(prob.lt.(real(nca, dp)/(real(nca, dp)+real(nmg, dp))))then!Sets atom to calcium if probability is right
                            sheet(x,y,z) = 1
                            nca = nca - 1
                        else !Sets atom to magnesium
                            sheet(x,y,z) = 2
                            nmg = nmg - 1
                        end if
                        end if
                    end if                    

                end do
            end do
        end do

    end subroutine sheet_init
    
    !> \brief Initialises a cube of randomly-arranged atoms
    !! \param[in] L (integer) length of a side of the cube
    !! \param[out] cube (integer array) the generated cube
    !! \param[in] prop (real) proportion of metal ions that are calcium
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

        nme = ceiling(real(atoms, dp)/2.0_dp)

        nca = nint(prop*real(nme, dp))

        nmg = nme - nca


        prop = real(nca)/real(nme)

        random_ca: do i = 1, 10000, 1
            do x = 0, L-1, 1
                do y = 0, L-1, 1
                    do z = 0, L-1, 1

                    if(modulo(x+y+z, 2) /= 1)then
                        
                        prob = rand(seed)
                                

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
    
    !> \brief Writes a generated cube to a CASTEP cell file
    !! \param[in] cube (integer array) the cube of atoms
    !! \param[in] L (real) length of a side of the cube
    !! \param[in] prop (real) proportion of metal ions that are calcium
    !! \param[in] fileno (integer) the memory unit corresponding to the file to which to write
    subroutine write_cube(cube, L,  prop, fileno)
    
        implicit none
        
        integer, dimension(:,:,:), allocatable, intent(in)  ::  cube    !Cube array for atom coords
        real(kind=dp), intent(in)                           ::  prop
        integer, intent(in)                                 ::  L
        integer, intent(in)                                 ::  fileno
        integer                                             ::  cellfile, datfile
        
        character(len=10), parameter                        ::  fmt1 = '(I3.3)'
        character(len=3)                                    ::  filename
        
        integer                                             ::  x, y, z
        
        real(kind=dp)                                       ::  step
        real(kind=dp)                                       ::  cart
        
        
        step = 1.0_dp/real(L)
        cart = 4.2_dp*real(L)/2.0_dp
        
        write(filename, fmt1)  int(prop*100.0_dp)
        
        cellfile = 10+fileno
        datfile  = 50+fileno

        open(unit=cellfile, file='cube_'//filename//'.cell')
        open(unit=datfile, file='cube_'//filename//'.dat')
        
        write(cellfile, *) '%BLOCK LATTICE_CART'
        write(cellfile, *) cart, 0.0_dp, 0.0_dp
        write(cellfile, *) 0.0_dp, cart, 0.0_dp
        write(cellfile, *) 0.0_dp, 0.0_dp, cart
        write(cellfile, *) '%ENDBLOCK LATTICE_CART'
        write(cellfile, *)
        
        write(cellfile, *) '%BLOCK POSITIONS_FRAC'
        do x = 0,L-1,1
            do y = 0,L-1,1
                do z = 0,L-1,1
                    write(datfile,*) x, y, z, cube(x,y,z)
                    if(cube(x,y,z)==0) write(cellfile, *) 'O', x*step, y*step, z*step
                    if(cube(x,y,z)==1) write(cellfile, *) 'Ca', x*step, y*step, z*step
                    if(cube(x,y,z)==2) write(cellfile, *) 'Mg', x*step, y*step, z*step
                end do
            end do
        end do
        write(cellfile, *) '%ENDBLOCK POSITIONS_FRAC'
        write(cellfile, *)
        
        write(cellfile, *) 'kpoints_mp_grid', 3, 3, 3
        
        write(cellfile, *) 'symmetry_generate'
        
        write(cellfile, *) '%BLOCK CELL_CONSTRAINTS'
        write(cellfile, *) 1, 1, 1
        write(cellfile, *) 0, 0, 0
        
        write(cellfile, *) '%ENDBLOCK CELL_CONSTRAINTS'
        
        close(unit=cellfile)
        close(unit=datfile)
        
    end subroutine write_cube

    !> \brief Writes a generated sheet to a CASTEP cell file
    !! \param[in] sheet (integer array) the sheet of atoms
    !! \param[in] L (real) length of a side of the sheet
    !! \param[in] V (integer) total height of the structure
    !! \param[in] fileno (integer) the memory unit corresponding to the file to which to write
    subroutine write_sheet(sheet, L, V, prop, fileno)
    
        implicit none
        
        integer, dimension(:,:,:), allocatable, intent(in)  ::  sheet    !Cube array for atom coords
        integer, intent(in)                                 ::  L
        integer, intent(in)                                 ::  V
        integer, intent(in)                                 ::  fileno
        integer                                             ::  cellfile
        integer                                             ::  datfile
        
        character(len=10), parameter                        ::  fmt1 = '(I3.3)'
        character(len=3)                                    ::  filename
        
        integer                                             ::  x, y, z
        
        real(kind=dp), intent(in)                           ::  prop
        real(kind=dp)                                       ::  step
        real(kind=dp)                                       ::  cart
        real(kind=dp)                                       ::  stepz
        real(kind=dp)                                       ::  cartz
        
        cellfile = 10+fileno
        datfile  = 50+fileno

        !Sets the lattice constants and steps in fractional coords in x,y
        step  = 1.0_dp/real(L)
        stepz = 1.0_dp/real(V)
        !Sets the lattice constants and steps in fractional coords in z
        cart  = 4.2_dp*real(L)/2.0_dp
        cartz = 4.2_dp*real(V)/2.0_dp
        
        write(filename, fmt1) int(prop*100.0_dp)
        
        open(unit=cellfile, file='sheet_'//filename//'.cell')
        open(unit=datfile, file='sheet_'//filename//'.dat')
        
        write(cellfile, *) '%BLOCK LATTICE_CART'
        write(cellfile, *) cart, 0.0_dp, 0.0_dp
        write(cellfile, *) 0.0_dp, cart, 0.0_dp
        write(cellfile, *) 0.0_dp, 0.0_dp, cartz
        write(cellfile, *) '%ENDBLOCK LATTICE_CART'
        write(cellfile, *)
        
        write(cellfile, *) '%BLOCK POSITIONS_FRAC'
        do x = 0,L-1,1
            do y = 0,L-1,1
                do z = 0,V-1,1
                    !if(sheet(x,y,z).lt.3)then
                        write(datfile,*) x, y, z, sheet(x,y,z)
                        print *, x, y, z, sheet(x,y,z)
                        if(sheet(x,y,z)==0) write(cellfile, *) 'O', x*step, y*step, z*stepz
                        if(sheet(x,y,z)==1) write(cellfile, *) 'Ca', x*step, y*step, z*stepz
                        if(sheet(x,y,z)==2) write(cellfile, *) 'Mg', x*step, y*step, z*stepz
                    !end if
                end do
            end do
        end do
        write(cellfile, *) '%ENDBLOCK POSITIONS_FRAC'
        write(cellfile, *)
        
        write(cellfile, *) 'kpoints_mp_grid', 3, 3, 3
        
        write(cellfile, *) 'symmetry_generate'
        
        write(cellfile, *) '%BLOCK CELL_CONSTRAINTS'
        write(cellfile, *) 1, 1, 0                    !The 0 fixes the vacuum by telling castep to not vary the z coordinates when figuring out the lattice
        write(cellfile, *) 0, 0, 0
        
        write(cellfile, *) '%ENDBLOCK CELL_CONSTRAINTS'
        
        close(unit=cellfile)
        close(unit=datfile)
        
    end subroutine write_sheet


end program lattice
