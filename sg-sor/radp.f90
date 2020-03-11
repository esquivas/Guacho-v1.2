!=======================================================================
!> @file radp.f90
!> @brief Read table for radiation pressure
!> @author Alejandro Esquivel
!> @date 2/Nov/2014

! Copyright (c) 2014 A. Esquivel, M. Schneiter, C. Villareal D'Angelo
!
! This file is part of Guacho-3D.
!
! Guacho-3D is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see http://www.gnu.org/licenses/.
!=======================================================================

!The locations of tableis is in ./Beta_bourrier.dat

module radpress

  implicit none
  real (kind=8) :: Br(800)
  real (kind=8) :: vr(800)
  real, allocatable :: Beta(:,:,:)

contains

  !=======================================================================
  !> @brief Reads the cooling curve table
  !> @details Reads the cooling curve table generated by CHUANTI,
  !! the location is assumed in /src/CHIANTIlib/coolingCHIANTI.tab
  subroutine read_table_beta()
#ifdef MPIP
    use mpi
#endif
    use parameters, only : workdir, master, nx, ny, nz
    use globals, only : rank
    implicit none

    integer :: i, err
    real (kind=8) :: a, b
    allocate( Beta(nx,ny,nz) )

    if(rank == master) then
      open(unit=21,file=trim(workdir)//'Beta_bourrier.dat', status='unknown')
      do i=1, size(vr)
        read(21,*) a, b
        vr(i) = a
        Br(i) = b
      enddo
      close(unit=21)
      print*, "just read Bourrier's beta table"
      print*,'v(1): ', vr(1), ' v(800): ', vr(800)
      print*,'Beta(1): ', Br(1), ' Beta(800): ', Br(800)
    endif
    #ifdef MPIP
    call mpi_bcast(Br,size(Br),mpi_double_precision,0,mpi_comm_world,err)
    call mpi_bcast(vr,size(vr),mpi_double_precision,0,mpi_comm_world,err)
    #endif

  end subroutine read_table_beta

  !=======================================================================

end module radpress
