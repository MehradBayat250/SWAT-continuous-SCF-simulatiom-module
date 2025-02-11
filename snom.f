      subroutine snom
      
!!    ~ ~ ~ PURPOSE ~ ~ ~
!!    this subroutine predicts daily snom melt when the average air
!!    temperature exceeds 0 degrees Celcius

!!    ~ ~ ~ INCOMING VARIABLES ~ ~ ~
!!    name         |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    elevb(:,:)   |m             |elevation at center of band
!!    elevb_fr(:,:)|none          |fraction of subbasin area within elevation 
!!                                |band
!!    iida         |julian date   |day being simulated (current julian date)
!!    ihru         |none          |HRU number
!!    pcpband(:,:) |mm H2O        |precipitation for the day in band in HRU
!!    precipday    |mm H2O        |precipitation on the current day in the HRU
!!    sub_sftmp    |deg C         |Snowfall temperature
!!                                |Mean air temperature at which precipitation
!!                                |is equally likely to be rain as snow/freezing
!!                                |rain.
!!    sub_smfmn    |mm/deg C/day  |Minimum melt rate for snow during year (Dec.
!!                                |21) where deg C refers to the air temperature
!!    sub_smfmx    |mm/deg C/day  |Maximum melt rate for snow during year (June
!!                                |21) where deg C refers to the air temperature
!!                                |SMFMX and SMFMN allow the rate of snow melt
!!                                |to vary through the year. These parameters
!!                                |are accounting for the impact of soil
!!                                |temperature on snow melt.
!!    sub_smtmp    |deg C         |Snow melt base temperature
!!                                |Mean air temperature at which snow melt will 
!!                                |occur.
!!    sno_hru(:)   |mm H2O        |amount of water in snow in HRU on current day
!!    snocov1      |none          |1st shape parameter for snow cover equation
!!                                |This parameter is determined by solving the
!!                                |equation for 50% snow cover
!!    snocov2      |none          |2nd shape parameter for snow cover equation
!!                                |This parameter is determined by solving the
!!                                |equation for 95% snow cover
!!    snocovmx     |mm H2O        |Minimum snow water content that corresponds
!!                                |to 100% snow cover. If the snow water content
!!                                |is less than SNOCOVMX, then a certain 
!!                                |percentage of the ground will be bare.
!!    snoeb(:,:)   |mm H2O        |snow water content in elevation band on 
!!                                |current day
!!    snotmp(:)    |deg C         |temperature of snow pack in HRU
!!    snotmpeb(:,:)|deg C         |temperature of snow pack in elevation band
!!    tavband(:,:) |deg C         |average temperature for the day in band in HRU
!!    sub_timp     |none          |Snow pack temperature lag factor (0-1)
!!                                |1 = no lag (snow pack temp=current day air
!!                                |temp) as the lag factor goes to zero, the
!!                                |snow pack's temperature will be less
!!                                |influenced by the current day's air 
!!                                |temperature
!!    tmpav(:)     |deg C         |average air temperature on current day for 
!!                                |HRU
!!    tmx(:)       |deg C         |maximum air temperature on current day for 
!!                                |HRU
!!    tmxband(:,:) |deg C         |maximum temperature for the day in band in HRU
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ OUTGOING VARIABLES ~ ~ ~
!!    name         |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    precipday    |mm H2O        |amount of water in effective precipitation
!!                                |in HRU
!!    precipdt(:)  |mm H2O        |precipitation for the time step during day
!!    sno_hru(:)   |mm H2O        |amount of water in snow in HRU on current day
!!    snoeb(:,:)   |mm H2O        |snow water content in elevation band on 
!!                                |current day
!!    snofall      |mm H2O        |amount of precipitation falling as freezing 
!!                                |rain/snow on day in HRU
!!    snomlt       |mm H2O        |amount of water in snow melt for the day in 
!!                                |HRU
!!    snotmp(:)    |deg C         |temperature of snow pack in HRU
!!    snotmpeb(:,:)|deg C         |temperature of snow pack in elevation band
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ LOCAL DEFINITIONS ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    ib          |none          |counter
!!    j           |none          |HRU number
!!    smfac       |
!!    smleb       |mm H2O        |amount of snow melt in elevation band on 
!!                               |current day
!!    smp         |mm H2O        |precipitation on current day for HRU
!!    snocov      |none          |fraction of HRU area covered with snow
!!    sum         |mm H2O        |snow water content in HRU on current day
!!    xx          |none          |ratio of amount of current day's snow water
!!                               |content to the minimum amount needed to
!!                               |cover ground completely
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ SUBROUTINES/FUNCTIONS CALLED ~ ~ ~
!!    Intrinsic: Real, Sin, Exp

!!    ~ ~ ~ ~ ~ ~ END SPECIFICATIONS ~ ~ ~ ~ ~ ~


      use parm

      integer :: j, ib
      real :: sum, smp, smfac, smleb
      real :: xx, snocov 
      
!! M.B_start Modified part
      real :: snocov_tera 
      real :: snocov_ev
!! M.B_end Modified part    
      j = 0
      j = ihru
      sum =0.
      smp =0.
      isub = hru_sub(j)
      !! M.B_start Modified part
      SF=0.   
      !! M.B_end Modified part

      if (elevb(1,isub) > 0. .and. elevb_fr(1,isub) > 0.) then 
!! elevation bands
        !! compute snow fall and melt for each elevation band
        do ib = 1, 10
          if (elevb_fr(ib,isub) < 0.) exit
          ! M.B_start Modified part
!          snotmpeb(ib,j) = snotmpeb(ib,j) * (1.-sub_timp(ib,isub)) +
!     &                                tavband(ib,j) * sub_timp(ib,isub)
          snotmpeb(ib,j) = snotmpeb(ib,j) * (1.-timp_me(j)) +
     &                                tavband(ib,j) * timp_me(j)
         ! M.B_end Modified part  
          
          ! M.B_start Modified part
       !   if (tavband(ib,j) < sub_sftmp(ib,isub)) then
          if (tavband(ib,j) < sftmp_me(j)) then
       ! M.B_end Modified part     
            !! compute snow fall if temperature is below sftmp
            snoeb(ib,j) = snoeb(ib,j) + pcpband(ib,j)
            snofall = snofall + pcpband(ib,j) * elevb_fr(ib,isub)
                
            
            else

            !! compute snow melt if temperature is above smtmp
          ! M.B_start Modified part               
           ! if (tmxband(ib,j) > sub_smtmp(ib,isub)) then
            if (tmxband(ib,j) > smtmp_me(j)) then    
          ! M.B_end Modified part               
              smfac = 0.
              smleb = 0.
              
              ! M.B_start Modified part 
!              smfac = (sub_smfmx(ib,isub) + sub_smfmn(ib,isub)) / 2. +  
!     &          Sin((iida - 81) / 58.09) *                              
!     &          (sub_smfmx(ib,isub) - sub_smfmn(ib,isub)) / 2.    !! 365/2pi = 58.09
!              smleb = smfac * (((snotmpeb(ib,j) + tmxband(ib,j)) / 2.)  
!     &                                             - sub_smtmp(ib,isub))

              smfac = (smfmx_me(j) + smfmn_me(j)) / 2. +  
     &          Sin((iida - 81) / 58.09) *                              
     &          (smfmx_me(j) - smfmn_me(j)) / 2.    !! 365/2pi = 58.09
              smleb = smfac * (((snotmpeb(ib,j) + tmxband(ib,j)) / 2.)  
     &                                             - smtmp_me(j))              
          ! M.B_end Modified part             
              
          ! M.B_start Modified part            
       call ascrv(.5,.95,sno50cov_me(j),.95,snocov1,snocov2)       
          !  M.B_end Modified part  
       
       
              !! adjust for areal extent of snow cover
       
          ! M.B_start Modified part      
            !  if (snoeb(ib,j) < snocovmx) then
          if (snoeb(ib,j) < snocovmx_me(j) .and. snoeb(ib,j) > 0.) then
          ! M.B_end Modified part       
                xx = 0.
                snocov = 0.
          ! M.B_start Modified part   
             !   xx = snoeb(ib,j) / snocovmx
                xx = snoeb(ib,j) / snocovmx_me(j)
          ! M.B_end Modified part                 
                snocov = xx / (xx + Exp(snocov1 - snocov2 * xx))
              else
                snocov = 1.               
              endif
              
         ! M.B_start Modified part
             if (snoeb(ib,j) <= 0) then
              snocov = 0.
             endif  
         ! M.B_end Modified part
              
              
              smleb = smleb * snocov
        
              if (smleb < 0.) smleb = 0.

              if (smleb > snoeb(ib,j)) smleb = snoeb(ib,j)
              snoeb(ib,j) = snoeb(ib,j) - smleb
               
              snomlt = snomlt + smleb * elevb_fr(ib,isub)               
            endif
            endif
            
         ! M.B_start Modified part
        ! !! adjust for areal extent of snow cover
        call ascrv(.5,.95,sno50cov_me(j),.95,snocov1,snocov2)       
        if (snoeb(ib,j) < snocovmx_me(j) .and. snoeb(ib,j) > 0.) then       
                xx = 0.
                snocov_ev = 0.   
               xx = snoeb(ib,j) / snocovmx_me(j)            
                snocov_ev = xx / (xx + Exp(snocov1 - snocov2 * xx))
        else if (snoeb(ib,j) >= snocovmx_me(j) .and. snoeb(ib,j)> 0.) then
                snocov_ev = 1. 
        else if (snoeb(ib,j) <= 0.) then  
          snocov_ev = 0. 
              endif
              
        snocov_elev_me(ib,j)=snocov_ev
        !! M.B_end Modified part   
            
            
          sum = sum + snoeb(ib,j) * elevb_fr(ib,isub)
          smp = smp + pcpband(ib,j) * elevb_fr(ib,isub)
          !! M.B_start Modified part
        SF = SF + snocov_elev_me(ib,j) * elevb_fr(ib,isub)
       !SCF_me(j) = SCF_me(j) + snocov_elev_me(ib,j) * elevb_fr(ib,isub) 
          !! M.B_end Modified part
            end do
            
            
            !! M.B_start Modified part
        SCF_me(j) =SF
          !! M.B_end Modified part      


        !! add/sub aggregate snow fall and melt from effective precip 
        !! and snow cover
        
        precipday = smp + snomlt - snofall
        
        if (precipday < 0.) precipday = 0.
        if (nstep > 0) then
          do ii = 1, nstep
            precipdt(ii+1) = precipdt(ii+1) + (snomlt - snofall) / nstep
            if (precipdt(ii+1) < 0.) precipdt(ii+1) = 0.
          end do
        end if
        sno_hru(j) = sum

      else
!! no elevation bands
      
	ib = 1
      ! M.B_start Modified part  ! add estimation scocov shp value by updated sno50cov_me
      call ascrv(.5,.95,sno50cov_me(j),.95,snocov1,snocov2) ! add estimation scocov shp value byupdated sno50cov_me
      ! M.B_end Modified part
        
    ! M.B_start Modified part
        !! estimate snow pack temperature
 !       snotmp(j)=snotmp(j) * (1. - sub_timp(ib,isub)) + tmpav(j) *     
 !    &            sub_timp(ib,isub)
         snotmp(j)=snotmp(j) * (1. - timp_me(j)) + tmpav(j) *     
     &            timp_me(j)
	  ! M.B_end Modified part
        
   ! M.B_start Modified part
       ! if (tmpav(j) <= sub_sftmp(ib,isub)) then
         if (tmpav(j) <= sftmp_me(j)) then    
   ! M.B_end Modified part        
          !! calculate snow fall
           
          sno_hru(j) = sno_hru(j) + precipday
          snofall = precipday
          precipday = 0.
          precipdt = 0.
         
        endif
 ! M.B_start Modified part
       ! if (tmx(j) > sub_smtmp(ib,isub) .and. sno_hru(j) > 0.) then
         if (tmx(j) > smtmp_me(j) .and. sno_hru(j) > 0.) then   
 ! M.B_end Modified part           
          !! adjust melt factor for time of year
          smfac = 0.
          snomlt = 0.
 ! M.B_start Modified part
!          smfac = (sub_smfmx(ib,isub) + sub_smfmn(ib,isub)) / 2. +      
!     &       Sin((iida - 81) / 58.09) *                                 
!     &       (sub_smfmx(ib,isub) - sub_smfmn(ib,isub)) / 2.    !! 365/2pi = 58.09
!          snomlt = smfac * (((snotmp(j)+tmx(j))/2.)-sub_smtmp(ib,isub))
          smfac = (smfmx_me(j) + smfmn_me(j)) / 2. +      
     &       Sin((iida - 81) / 58.09) *                                 
     &       (smfmx_me(j) - smfmn_me(j)) / 2.    !! 365/2pi = 58.09
          snomlt = smfac * (((snotmp(j)+tmx(j))/2.)-smtmp_me(j))
  ! M.B_end Modified part         
          
          !! adjust for areal extent of snow cover
          ! M.B_start Modified part
         ! if (sno_hru(j) < snocovmx) then
          if (sno_hru(j) < snocovmx_me(j)) then  
          ! M.B_end Modified part             
            xx = 0.
            !! M.B_start Modified part
            !xx = sno_hru(j) / snocovmx
             xx = sno_hru(j) / snocovmx_me(j)
            ! M.B_end Modified part
            snocov = xx / (xx + Exp(snocov1 - snocov2 * xx))
          else
            snocov = 1.
          endif
          snomlt = snomlt * snocov
          

          if (snomlt < 0.) snomlt = 0.
          if (snomlt > sno_hru(j)) snomlt = sno_hru(j)
          sno_hru(j) = sno_hru(j) - snomlt
         
          
          precipday = precipday + snomlt
        
          
          if (nstep > 0) then
            do ii = 1, nstep
             precipdt(ii+1) = precipdt(ii+1) + snomlt / nstep
            end do
          end if
          if (precipday < 0.) precipday = 0.
        else
          snomlt = 0.
        end if
        
       ! M.B_start Modified part
        if (sno_hru(j) <snocovmx .and. sno_hru(j) > 0.) then          
            xx = 0.
             xx = sno_hru(j) / snocovmx
            snocov = xx / (xx + Exp(snocov1 - snocov2 * xx))  
        else if (sno_hru(j) >=snocovmx .and. sno_hru(j) > 0.) then
           snocov = 1. 
       else if (sno_hru(j) <= 0.) then    
            snocov = 0.       
       end if  
       
       SCF_me(j)=snocov
       ! M.B_end Modified part
        
        
        
        
        
        
          endif
         !! M.B_start Modified part    
          snocov_me(j)=SCF_me(j)        
          !! M.B_end Modified part
      return
      end