/*REXX

    advent_of_code_day_01: Secret Entrance 
    https://adventofcode.com/2025/day/1
 
    Goal:
        1. What is the secret code?
        2. Find the Super Secret Code
*/

/*********************************************************************
Initialize vars & capture program name
*********************************************************************/
/*trace i*/
/*'CLRSCRN'*/ 
/*call msg('OFF')*/ 
rc = 0
secretCode = 0
superSecretCode = 0
parse source . . this_ .
exposedVars = 'this_',
              'rc';



arg puzzleDsn dialSize dialPos

/*Capture program name with oorexx*/
parse source system invocation fullProgramPath
fullProgramPath = reverse(fullProgramPath)
parse var fullProgramPath 'xer.' this_ '/' .
this_ = reverse(this_)


/*validate input dsn on mainframe
if sysdsn("'"puzzleDsn"'") <> 'OK' then do 
  rc = 8
  rMsg = "Error: Invalid puzzle dsn"
  call ExitProgram rc rMsg
end */


/*Read the file
"alloc file(readit) da('"puzzleDsn"') shr reuse"
if rc > 0 then do
  rc = 8
  rMsg = "Error: file allocation"
  call ExitProgram rc rMsg
end 

"execio * diskr readit (finis stem puzzleStr."
if rc > 0 then do 
  rc = 8
  rMsg = "Error: File Read"
  call ExitProgram rc rMsg
end  */


/*check member for strings
if puzzleStr.0 = 0 then do 
  rc = 4
  rMsg = "warning: No strings in member"
  call ExitProgram rc rMsg
end */

/* Read in data using oorexx for testing
file = "puzzleinput.txt" 

puzzleStr.0 = 0

i = 0
do while lines(file) > 0
  i = i + 1
  puzzleStr.i = linein(file)
end

puzzleStr.0 = i
call lineout file 
*/

/*Test stem data 
puzzleStr.0 = 10
puzzleStr.1 = 'L68'
puzzleStr.2 = 'L30'
puzzleStr.3 = 'R48'
puzzleStr.4 = 'L5'
puzzleStr.5 = 'R60'
puzzleStr.6 = 'L55'
puzzleStr.7 = 'L1'
puzzleStr.8 = 'L99'
puzzleStr.9 = 'R14'
puzzleStr.10 = 'L82'
*/


/* first dialPos passed in by user Aoc said 50*/

temp = dialPos
do i = 1 to puzzleStr.0 + 1 /*off by one error quick fix*/ 
  puzzleStr.i = strip(puzzleStr.i)
  dialPos.i = strip(temp)
  say time() this_ "dialPos."i" is " dialPos.i 

  /*calculate next rotation and store result*/
  call CalcRotation dialPos.i puzzleStr.i dialSize
  temp = result

  /*check to see if we landed on zero*/
  call updateCode dialPos.i secretCode
  secretCode = result
  say time() this_ "Secret code updated to " secretCode

  /*supersecret Code check*/
  call CrossesZero dialPos.i puzzleStr.i
  parse var result clicksOnZero '00'x .
  say time() this_ "Number of clicks on zero:" clicksOnZero
  superSecretCode = clicksOnZero + superSecretCode 
 
end i 

  
Answer = superSecretCode + secretCode
say time() this_ "Answer is" answer
/*say time() this_ "Secret code is " secretCode */
/*say time() this_ "Super secret code is " superSecretCode + secretCode*/

rMsg = "Secret code is " secretCode
call ExitProgram rc rMsg 

exit rc

/*********************************************************************
Name: ExitProgram
Goal: Return data in standard format
*********************************************************************/
ExitProgram: procedure 

arg returnCode msgData

say time() this_||'00'x||returnCode||'00'x||msgData
exit returnCode

/*********************************************************************
Name: CalcRotation
Goal: Calculate the dial position after rotation
*********************************************************************/
CalcRotation: procedure expose(exposedVars) 

arg currentPos rotateBy dialSize


parse var rotateBy rotationDirection+1 rotationDistance .

if rotationDirection == "L" then do

  /*Try to implement a circular array. How is this the first half of the challege?*/
  
/*********************************************************************
When rotating left there is a chance for negative number in array. 
Create a large number to prevent going negative.
subtract that from currentPosition. Then when using the modulo, 
it should have a positie remainder equal to new position.
**********************************************************************/
  
  newPosition = (currentPos - rotationDistance + dialSize * rotationDistance)
  newPosition = (newPosition // dialSize) 
end

if rotationDirection == "R" then do
  
  /*Circle array logic in the other direction*/

  /* These shouldn't go negative so add rotation to currentposition.
     the module will give remainder if we go over 100 that should 
     equal new position*/
  newPosition = (currentPos + rotationDistance)
  newPosition = (newPosition // dialSize)
end 

return newPosition

/*********************************************************************
Name: updateCode
Goal: Increase secret code counter by 1 every time rotation landds on
      zero
*********************************************************************/
UpdateCode: procedure expose(exposedVars)

arg dialLocation code

if dialLocation == 0 then
  code = code + 1

return code 

/*********************************************************************
Name: CrossesZero
Goal: Calculate how many times the dial lands on zero during a roation
*********************************************************************/
CrossesZero: procedure expose(exposedVars)

this_ = 'CrossesZero'

arg currentPos rotateBy

parse var rotateBy rotateDirection+1 rotationDistance .

clicksOnZero = 0 

if rotateDirection = 'L' then do 
  say time() this_ "Left Rotation Distance: "rotationDistance

  /*when zero passed in*/
  if currentPos == 0 then 
    currentPos = 100

  do rotationDistance 
    /*Capture the click on zero*/
    if currentPos == 0 then do
      clicksOnZero = clicksOnZero + 1
      currentPos = 100
      currentPos = currentPos - 1
    end 
    else 
      currentPos = currentPos - 1
  end 

end 

if rotateDirection == 'R' then do 
  say time() this_ "Right Rotation Distance: "rotationDistance

  do rotationDistance
    if currentPos == 100 then do 
      clicksOnZero = clicksOnZero + 1
      currentPos = 0
      currentPos = currentPos + 1
    end 
    else 
      currentPos = currentPos + 1
  end
end 

if currentPos == 100 then 
  currentPos = 0


return clicksOnZero||'00'x||currentPos