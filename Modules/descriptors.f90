!
! Copyright (C) 2002 FPMD group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!

   MODULE descriptors
      !
      IMPLICIT NONE
      SAVE

      INTEGER  ldim_block, ldim_cyclic, ldim_block_cyclic
      INTEGER  lind_block, lind_cyclic, lind_block_cyclic
      EXTERNAL ldim_block, ldim_cyclic, ldim_block_cyclic
      EXTERNAL lind_block, lind_cyclic, lind_block_cyclic

      !  Descriptor for Cannon's algorithm
      !
      !  Parameters to define and manage the Descriptor
      !  of square matricxes block distributed on a square grid of processors
      !  to be used with Cannon's algorithm for matrix multiplication
      !
      INTEGER, PARAMETER :: descla_siz_ = 13
      INTEGER, PARAMETER :: ilar_        = 1
      INTEGER, PARAMETER :: nlar_        = 2
      INTEGER, PARAMETER :: ilac_        = 3
      INTEGER, PARAMETER :: nlac_        = 4
      INTEGER, PARAMETER :: nlax_        = 5
      INTEGER, PARAMETER :: lambda_node_ = 6
      INTEGER, PARAMETER :: la_n_        = 7
      INTEGER, PARAMETER :: la_nx_       = 8
      INTEGER, PARAMETER :: la_npr_      = 9
      INTEGER, PARAMETER :: la_npc_      = 10
      INTEGER, PARAMETER :: la_myr_      = 11
      INTEGER, PARAMETER :: la_myc_      = 12
      INTEGER, PARAMETER :: la_comm_     = 13
      !
      ! desc( ilar_ )  globla index of the first row in the local block of lambda
      ! desc( nlar_ )  number of row in the local block of lambda ( the "2" accounts for spin)
      ! desc( ilac_ )  global index of the first column in the local block of lambda
      ! desc( nlac_ )  number of column in the local block of lambda
      ! desc( nlax_ )  leading dimension of the distribute lambda matrix
      ! desc( lambda_node_ )  if > 0 the proc holds a block of the lambda matrix

       
   CONTAINS

   !------------------------------------------------------------------------
   !
   SUBROUTINE descla_init( desc, n, nx, np, me, comm )
      !
      IMPLICIT NONE  
      INTEGER, INTENT(OUT) :: desc(:)
      INTEGER, INTENT(IN)  :: n, nx
      INTEGER, INTENT(IN)  :: np(2), me(2), comm
      INTEGER  :: ir, nr, ic, nc, lnode, nlax
      INTEGER  :: ip
      INTEGER  :: ldim_block, gind_block 
      EXTERNAL :: ldim_block, gind_block
      
      IF( np(1) /= np(2) ) THEN
         CALL errore( ' descla_init ', ' only square grid of proc are allowed ', 2 )
      END IF

      IF( me(1) >= 0 ) THEN
         !
         nr = ldim_block( nx, np(1), me(1) )
         nc = ldim_block( nx, np(2), me(2) )
         !
         nlax = ldim_block( nx, np(1), 0 )
         DO ip = 1, np(1) - 1
            nlax = MAX( nlax, ldim_block( nx, np(1), ip ) )
         END DO
         !
         ir = gind_block( 1, nx, np(1), me(1) )
         ic = gind_block( 1, nx, np(2), me(2) )
         !
         ! This is to try to keep a matrix N * N into the same
         ! distribution of a matrix NX * NX, useful to have 
         ! the matrix of spin-up distributed in the same way
         ! of the matrix of spin-down
         !
         IF( ir + nr - 1 > n ) nr = n - ir + 1
         IF( ic + nc - 1 > n ) nc = n - ic + 1
         !
         lnode = 1
         !
      ELSE
         !
         nr = 1
         nc = 1
         !  
         ir = 0
         ic = 0
         !
         lnode = -1
         !
         nlax = 1
         !
      END IF

      desc( ilar_ ) = ir
      desc( nlar_ ) = nr
      desc( ilac_ ) = ic
      desc( nlac_ ) = nc
      desc( nlax_ ) = nlax
      desc( lambda_node_ ) = lnode
      desc( la_n_  ) = n
      desc( la_nx_ ) = nx
      desc( la_npr_ ) = np(1)
      desc( la_npc_ ) = np(2)
      desc( la_myr_ ) = me(1)
      desc( la_myc_ ) = me(2)
      desc( la_comm_ ) = comm

      IF( nr < 1 .OR. nc < 1 ) THEN
         CALL errore( ' descla_init ', ' wrong dim ', 1 )
      END IF
      IF( nlax < 1 ) THEN
         CALL errore( ' descla_init ', ' wrong dim ', 2 )
      END IF

   END SUBROUTINE descla_init


   END MODULE descriptors
