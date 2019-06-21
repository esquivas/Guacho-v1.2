!=======================================================================
!> @file user_mod.f90
!> @brief User input module
!> @author C. Villarreal, M. Schneiter, A. Esquivel
!> @date 4/May/2016

! Copyright (c) 2016 Guacho Co-Op
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

!> @brief User imput module
!> @details  This is an attempt to have all input neede from user in a
!! single file
!!!  This module should load additional modules (i.e. star, jet, sn), to
!!  impose initial and boundary conditions (such as sources)

module user_mod

  ! load auxiliary modules

  implicit none

contains

!> @brief Initializes variables in the module, as well as other
!! modules loaded by user.
!! @n It has to be present, even if empty
subroutine init_user_mod()

  implicit none
  !  initialize modules loaded by user
!  call init_vortex()

end subroutine init_user_mod

!=====================================================================

!> @brief Here the domain is initialized at t=0
!> @param real [out] u(neq,nxmin:nxmax,nymin:nymax,nzmin:nzmax) :
!! conserved variables
!> @param real [in] time : time in the simulation (code units)

subroutine initial_conditions(u)

  use parameters, only : neq, nxmin, nxmax, nymin, nymax, nzmin, nzmax, &
       pmhd, mhd, passives, rsc,rhosc, vsc, psc, cv, Tempsc, neqdyn, tsc,   &
       gamma, nx, ny, nz, nxtot, nytot, nztot

  use globals,    only: coords, dx ,dy ,dz
  use constants,  only: pi

  implicit none
  real, intent(out) :: u(neq,nxmin:nxmax,nymin:nymax,nzmin:nzmax)

  integer :: i,j,k
  real :: velx, vely, velz, eps, s, dens, temp, rad, x, y, z

  !--------------------------------------------------------------------------------------------
  !       MEDIO AMBIENTE
  !       VORTEX PROBLEM (high Order Finite Difference and Finite Volume WENO Schemes
  !       and Discontinuous Galerkin Methodsfor CFDChi-Wang Shu)
  !--------------------------------------------------------------------------------------------

  eps  = 5.  ! se normaliza????
  s    = 1.

  do k=nzmin,nzmax
    do j=nymin,nymax
      do i=nxmin,nxmax

        !  this is the position with respect of the grid center
        x= ( real(i+coords(0)*nx-nxtot/2) - 0.5) *dx
        y= ( real(j+coords(1)*ny-nytot/2) - 0.5) *dy
        z= ( real(k+coords(2)*nz-nztot/2) - 0.5) *dz
        rad=sqrt(x**2+y**2)

        !calculates the velocity according to the vortex problem
        !see Chi-Wang Shu
        velx = 0. - y * eps * exp(0.5*(1.-rad**2))/2./pi
        vely = 0. + x * eps * exp(0.5*(1.-rad**2))/2./pi
        velz = 0.

        temp = 1.-(gamma-1.)*eps**2*exp(1.-rad**2)/8./gamma/pi**2
        dens = temp**(1./(gamma-1.))

        !   total density and momenta
        u(1,i,j,k) = dens
        u(2,i,j,k) = dens*velx
        u(3,i,j,k) = dens*vely
        u(4,i,j,k) = dens*velz

        !  total energy (kinetic + thermal)
        u(5,i,j,k) = 0.5*dens*(velx**2+vely**2+velz**2) + cv*dens**gamma

      end do
    end do
  end do

end subroutine initial_conditions

!=====================================================================

!> @brief User Defined Boundary conditions
!> @param real [out] u(neq,nxmin:nxmax,nymin:nymax,nzmin:nzmax) :
!! conserved variables
!> @param real [in] time : time in the simulation (code units)
!> @param integer [in] order : order (mum of cells to be filled in case
!> domain boundaries are being set)

subroutine impose_user_bc(u,order)

  use parameters, only:  neq, nxmin, nxmax, nymin, nymax, nzmin, nzmax, tsc
  use globals,    only: time, dt_CFL
  implicit none
  real, intent(out)    :: u(neq,nxmin:nxmax,nymin:nymax,nzmin:nzmax)
  real, save           :: w(neq,nxmin:nxmax,nymin:nymax,nzmin:nzmax)
  integer, intent(in)  :: order
  integer              :: i, j, k

end subroutine impose_user_bc

!=======================================================================

!> @brief User Defined source terms
!> This is a generic interrface to add a source term S in the equation
!> of the form:  dU/dt+dF/dx+dG/dy+dH/dz=S
!> @param real [in] pp(neq) : vector of primitive variables
!> @param real [inout] s(neq) : vector with source terms, has to add to
!>  whatever is there, as other modules can add their own sources
!> @param integer [in] i : cell index in the X direction
!> @param integer [in] j : cell index in the Y direction
!> @param integer [in] k : cell index in the Z direction

subroutine get_user_source_terms(pp,s, i, j , k)

  use parameters, only : neq

  implicit none
  real, intent(in)   :: pp(neq)
  real, intent(out)  :: s(neq)
  integer :: i, j, k

end subroutine get_user_source_terms


!=======================================================================

end module user_mod

!=======================================================================
