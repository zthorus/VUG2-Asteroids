( Asteroid game for VectorUGo-2

  By S. Morel, Zthorus-Labs

  Date          Action
  ----          ------
  2023-01-18    Created

)

( sprite shapes = sequences of vectors )

data shapep $0000fc0408fcf8fc0404
data shapea1 $0408f4fcfcf414fcfc15
data shapea2 $0602f804fcf80cfc0008
data shapea3 $0003fdfd03fd0303fd03
data shapem $04000a00

( initial values for type-1 asteroids: large )

data xqa1 $2000e0001000f000
data yqa1 $10001000e000d000
data xva1 $00a000a000a0ff80
data yva1 $00100001fff0fff0

( variable arrays: asteroid parameters )
( up to 28 asteroids: 4 type-1, 8 type-2, 16 type-3 )

data tpa *28  ( asteroid types: 1=large, 2=medium, 3=small )
data xqa *28  ( 16-bit coordinates of asteroids )
data yqa *28
data xva *28  ( velocity of asteroids )
data yva *28
data sta *28  ( asteroid states: 0= not in game, 1= in game )
data sprta *28  ( asteroid sprite addresses )
 
data end1graph *48 ( graphic data of end-of-game message )
data end2graph *48
 
: pause1
  400 0 do i loop
;

: pause2
  100 0 do i loop
;

: pause3
  10000 0 do i loop
;

: main
  var xp var yp   ( player's spaceship coordinates )
  var ap          ( player's spaceship angle )
  var xvp var yvp ( player's spaceship velocity )
  var xqp var yqp ( player's spaceship coordinates on 16 bits )
  var xap var yap ( player's spaceship acceleration )
  var xdp var ydp ( player's spaceship braking deceleration ) 
  var thrust      ( player's spaceship thrust duration )
  var xm var ym   ( missile coordinates )
  var xqm var yqm ( missile coordinates on 16 bits )
  var xvm var yvm ( missile velocity )
  var ml          ( =1 if missile launched, 0 otherwise )
  var xa var ya   ( current asteroid coordinates )
  var dx var dy   ( difference between spaceship and asteroid coordinates )
  var xll var xlr ( x limits of spaceship rebirth area )
  var yld var ylu ( y limits of spaceship rebirth area ) 
  var sprtp       ( player's spaceship sprite )
  var sprtm       ( missile sprite )
  var sprtast     ( current asteroid sprite processed )
  var joy         ( joystick state )
  var killed      ( =2 if spaceship hit by asteroid \ )
                  ( =1 if waiting for rebirth )
  var hit         ( =1 if asteroid hit by missile )
  var scfp        ( scaling factor of spaceship ) 
  var xqast var yqast ( current asteroid 16-bit coordinates )
  var astidx      ( index of asteroid in array )
  var typast      ( current type of asteroid )
  var nbast       ( number of asteroids spawned from a bigger one )
  var rand        ( pseudo random number )
  var count       ( main loop counter used to generate random number )
  var xvast var yvast ( current asteroid velocity )
  var aast        ( asteroid angle )
  var astshot     ( number of asteroid remaining to shoot )
  var score       ( player's score )
  var scoretext   ( text display item for score )
  var lives       ( player's number of lives )
  var livestext   ( text display item for number of lives )
  var end1text    ( text display item for end-of-game message )
  var end2text

  ( sprite definitions )

  shapep 5 defsprite sprtp !
  shapem 2 defsprite sprtm !
  3 0 do
    shapea1 5 defsprite sprta i + !
  loop  
  4 astidx !
  ( initialization of type-2 asteroids )
  7 0 do
    shapea2 5 defsprite sprta astidx @ + !
    astidx @ 1+ astidx !
  loop 
  15 0 do
    shapea3 5 defsprite sprta astidx @ + !
    astidx @ 1+ astidx !
  loop 

  0 count ! ( initialize counter that generates random numbers )
  12345 rand ! ( random number initial value )
 
  120 120 at ." 00000" scoretext ! 
  10 120 at ." 0" livestext !  

  0 score !
  8 lives !

  begin ( beginning of game or level )

    ( initialization of spaceship parameters )

    64 xp ! 64 yp ! 16384 xqp ! 16384 yqp ! 64 ap !
    0 xvp ! 0 yvp ! 0 xap ! 0 yap ! 0 thrust !
    32 xm ! 32 ym ! 8192 xqm ! 8192 yqm !
    0 xvm ! 0 yvm ! 0 ml ! 
    sprtp @ showsprite
    xp @ yp @ sprtp @ putsprite

    ( initialization of asteroid states )
 
    3 0 do
      sprta i + @ showsprite
      1 tpa i + !
      1 sta i + !
      xqa1 i + @ xqa i + !
      yqa1 i + @ yqa i + !
      xva1 i + @ xva i + !
      yva1 i + @ yva i + !
    loop
    4 astidx !
    7 0 do
      sprta astidx @ + @ hidesprite
      2 tpa astidx @ + !
      0 sta astidx @ + !
      astidx @ 1+ astidx !
    loop 
    15 0 do
      sprta astidx @ + @ hidesprite
      3 tpa astidx @ + !
      0 sta astidx @ + !
      astidx @ 1+ astidx !
    loop 
 
    28 astshot ! 
    0 killed !
    score @ scoretext @ .
    ( display lives by modifying vectors in its text item )
    livestext @ 1+ @ 1+ 1+ 1+ 1+ ( get address in vec table )
    lives @ 48 + emit ( display lives as ASCII char )

    begin ( main loop )

      ( manage player's actions )

      killed @ 0
      if=
        joystick joy !
        joy @ 16 and 0 ( move right )
        if=
          4 ap @ - ap !  ( clockwise spaceship rotation )
        then
        joy @ 8 and 0 ( move left )
        if=
         4 ap @ + ap !   ( counterclockwise spaceship rotation )
        then
        ap @ 255 and ap !
        joy @ 2 and 0    ( move up = thrust )
        if=
          thrust @ 32 
          if!=              ( acceleration )
            16 ap @ rcos xap !
            16 ap @ rsin yap !
            xap @ xvp @ + xvp !  ( update velocity )
            yap @ yvp @ + yvp ! 
            thrust @ 1+ thrust !
            xvp @ 2/ 2/ xdp !    
            yvp @ 2/ 2/ ydp !
          else
            64 ap @ rcos 2* 2* 2* xvp !  ( max velocity reached )
            64 ap @ rsin 2* 2* 2* yvp !  ( steer the spaceship )
          then
          16 ap @ rcos xdp !        
          16 ap @ rsin ydp !
        else
          thrust @ 0
          if!=
            xdp @ xvp @ - xvp !  ( deceleration )
            ydp @ yvp @ - yvp !
            thrust @ 1- thrust !
          else                   
            0 xvp ! 0 yvp !      ( spaceship not moving )
          then
        then
        joy @ 4 and 0  ( move down = hyperspace jump )
        if=
          1 killed !
          sprtp @ hidesprite
          rand @ 2/ 2/ 2/ rand @ xor 26666 xor rand !
          count @ rand @ + rand !  ( pseudo-random number )
          rand @ 63 and 30 + xp ! 
          rand @ 2/ 2/ 2/ rand @ xor 26666 xor rand !
          rand @ 63 and 30 + yp !
          xp @ switch xqp ! 
          yp @ switch yqp ! 
          0 xvp ! 0 yvp ! 0 thrust ! 0 xap ! 0 yap ! 
        then
        joy @ 1 and 0  ( fire )
        if=
          ml @ 0     
          if=
            xqp @ 32767 and xqm !
            yqp @ 32767 and yqm !
            64 ap @ rcos 2* 2* 2* 2* xvm !
            64 ap @ rsin 2* 2* 2* 2* yvm !
            xvp @ xvm @ + xvm !  ( missile velocity is relative to spaceship )
            yvp @ yvm @ + yvm !
            1 ml !
            16 ap @ sprtm @ rotscalsprite
            sprtm @ showsprite
          then
        then

        xvp @ xqp @ + xqp !        ( update precise position )
        yvp @ yqp @ + yqp !
        xqp @ switch 127 and xp !  ( update position for display )
        yqp @ switch 127 and yp !

        ml @ 1
        if=                          ( missile motion )
          xqm @ switch 127 and xm !
          yqm @ switch 127 and ym !
          xvm @ xqm @ + xqm !
          yvm @ yqm @ + yqm !
          xm @ ym @ sprtm @ putsprite
          xqm @ 32768 and yqm @ 32768 and or 0 ( check missile reached limit )
          if!=
            sprtm @ hidesprite
            0 ml !      
          then
        then
        xp @ yp @ sprtp @ putsprite
        16 ap @ sprtp @ rotscalsprite
      then

      killed @ 2
      if=                               ( animation of spaceship been killed )
        scfp @ ap @ sprtp @ rotscalsprite 
        16 ap @ + ap !   
        ap @ 255 and ap !
        scfp @ 1+ scfp !
        scfp @ 150
        if=           ( end of animation: restore spaceship central \ )
                      ( position but hide it )
          1 killed ! 
          64 xp ! 64 yp ! 16384 xqp ! 16384 yqp ! 64 ap !
          0 xvp ! 0 yvp ! 0 thrust ! 0 xap ! 0 yap ! 
          sprtp @ hidesprite
        then
      then 

      ( manage asteroids motions )

      27 0 do
        sta i + @ 1 ( check if asteroid is active )
        if=
          sprta i + @ sprtast !
          xqa i + @ switch 127 and xa !
          yqa i + @ switch 127 and ya !
          xa @ ya @ sprtast @ putsprite
          xva i + @ xqa i + @ + xqa i + !
          yva i + @ yqa i + @ + yqa i + !
        then
      loop

      ( manage collisions )
   
      killed @ 0
      if= 
        27 0 do
          sta i + @ 1 ( check if asteroid is active )
          if=
            xqa i + @ switch 127 and xa ! ( check if asteroid is in \ ) 
            yqa i + @ switch 127 and ya ! ( vincinity of spaceship )
            xa @ xp @
            if>
              xa @ xp @ - dx !
            else
              xp @ xa @ - dx !
            then
            ya @ yp @
            if>
              ya @ yp @ - dy !
            else
              yp @ ya @ - dy !
            then
            16 dx @ < 16 dy @ < and
            if 
              sprta i + @ sprtast !
              sprtast @ sprtp @ collision 0 ( check asteroid hit spaceship )
              if!=
                2 killed !
                lives @ 1- lives !
                livestext @ 1+ @ 1+ 1+ 1+ 1+ ( get address in vec table )
                lives @ 48 + emit ( display remaining lives as ASCII char )
              then
            else
              pause1 ( compensate time that would have been \ ) 
            then     ( spent by collision detection )
          else
            pause1
          then
        loop
        killed @ 2
        if=
          0 ml !              ( spaceship hit => disable missile )
          sprtm @ hidesprite
          16 scfp !           ( initialize scaling factor of spaceship )
        then
      then

      ( if spaceship was killed, check if it has enough room to reborn )
      ( check there is no asteroid within a rectangular area around \ )
      ( the x=64;y=64 position where the spaceship will reborn )

      killed @ 1
      if=
        0 killed ! ( assume the spaceship can reborn )
        27 0 do
          sta i + @ 1
          if=
            20 xp @ - xll !
            20 xp @ + xlr !
            20 yp @ - yld !
            20 yp @ + ylu ! 
            xqa i + @ switch 127 and xa !  
            yqa i + @ switch 127 and ya !
            xll @ xa @ > xlr @ xa @ < and
            if
              yld @ ya @ > ylu @ ya @ < and
              if
                1 killed ! ( asteroid within critical area => ship still dead )
              then
            then
          then
        loop
        killed @ 0
        if=
          sprtp @ showsprite
        then
      then

      0 hit !
      27 0 do         ( check if missile hit an asteroid )
        sta i + @ 1 ( check if asteroid is active )
        if=
          sprta i + @ sprtast !
          ml @ 1
          if=
            xqa i + @ switch 127 and xa ! ( check if asteroid is in \ ) 
            yqa i + @ switch 127 and ya ! ( vincinity of missile )
            xa @ xm @
            if>
              xa @ xm @ - dx !
            else
              xm @ xa @ - dx !
            then
            ya @ ym @
            if>
              ya @ ym @ - dy !
            else
              ym @ ya @ - dy !
            then
            16 dx @ < 16 dy @ < and
            if 
              sprtast @ sprtm @ collision 0
              if!=
                hit @ 0 ( only one asteroid can be shot at a time )
                if=
                  1 hit !
                  0 ml !
                  astshot @ 1- astshot !
                  10 score @ + score !
                  score @ scoretext @ . 
                  sprtm @ hidesprite
                  sprtast @ hidesprite
                  xqa i + @ xqast !
                  yqa i + @ yqast !
                  0 sta i + !
                  tpa i + @ typast !
                  typast @ 3 
                  if!=            ( spawn 2 smaller asteroids if type<3 )
                    typast @ 1+ typast !
                    0 astidx !
                    0 nbast !
                    begin 
                      astidx @ sta + @ 0  ( try to find free slot for asteroid )
                      if=
                        astidx @ tpa + @ typast @
                        if= 
                          1 astidx @ sta + !        ( spawn asteroid )
                          xqast @ astidx @ xqa + !
                          yqast @ astidx @ yqa + !
                          rand @ 2/ 2/ 2/ rand @ xor 26666 xor rand !
                          count @ rand @ + rand !  ( pseudo-random number for ) 
                          rand @ 255 and aast !    ( velocity angle )
                          64 aast @ rcos 2* 2* xvast !        
                          64 aast @ rsin 2* 2* yvast !        
                          xvast @ astidx @ xva + !
                          yvast @ astidx @ yva + !
                          astidx @ sprta + @ showsprite
                          nbast @ 1+ nbast !
                          nbast @ 2            ( if all asteroids spawned )
                          if=
                            27 astidx !
                          then
                        then
                      then
                      astidx @ 1+ astidx !
                      astidx @ 28
                    until=
                  then
                then
              then 
            else
              pause2 ( compensate time that would have been spent by \ )
            then     ( collision detection )
          then
        then 
      loop

      count @ 1+ count !
      pause1
      lives @ 0 = astshot @ 0 = or 
    until

    ( end of level or game )

    sprtp @ hidesprite
    27 0 do
      sprta i + @ hidesprite
    loop

    lives @ 0
    if= 
      80 64 at ." GAME" end1text !
      80 64 at ." OVER" end2text !
      end1graph end1text @ copysprite
      end2graph end2text @ copysprite
      $f207 end1graph ! ( modify radial vector )
      $f2f3 end2graph ! ( modify radial vector )
      4 scfp !
      36 0 do ( outro animation )
        scfp @ 0 end1text @ rotscalsprite
        scfp @ 0 end2text @ rotscalsprite
        pause3
        scfp @ 1+ scfp !
      loop
      0 score !
      8 lives !
    else
      80 64 at ." NEXT" end1text !
      76 64 at ." LEVEL" end2text !
      end1graph end1text @ copysprite
      end2graph end2text @ copysprite
      $f207 end1graph ! ( modify radial vector )
      $edf3 end2graph ! ( modify radial vector )
      0 ap !
      120 0 do ( level interlude animation )
        16 ap @ end1text @ rotscalsprite 
        16 ap @ end2text @ rotscalsprite 
        1000 0 do i loop
        8 ap @ + 255 and ap !
      loop
      16 0 end1text @ rotscalsprite 
      16 0 end2text @ rotscalsprite
    then
    begin            ( wait for player to press fire to start new game )
      joystick joy !
      joy @ 1 and 0  ( fire )
    until=
    end1text @ delsprite
    end2text @ delsprite
    0
  until
;
