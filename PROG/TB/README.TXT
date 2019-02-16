

                 WELCOME TO TURBO BASIC
                 컴컴컴컴컴컴컴컴컴컴컴

    This README file contains information that will be useful
    and/or of interest to you. Please read it in its entirety,
    referring to it when you encounter problems in the manual.

    TABLE OF CONTENTS
    컴컴컴컴컴컴컴컴�

    1. How to get Help
    2. Graphics support for the new IBM Personal System computers
    3. Corrections/Additions to the Manual
    4. Important tips
    5. Files on the disk


    1. HOW TO GET HELP
    컴컴컴컴컴컴컴컴컴

    If you have any problems, please read this file and the
    Owner's Handbook first. If you still have a question and need
    assistance, help is available from the following sources:

       1. Type GO BORLAND on the CompuServe bulletin board system.
       2. Check with your local software dealer or users' group.
       3. Write to us at the following address:

         Borland International
         Turbo Basic Technical Support
         4585 Scotts Valley Dr.
         Scotts Valley, CA  95066

       4. If you have an urgent problem that cannot wait and you
       have sent in the license agreement from the front of
       your manual, then call the Borland Technical Support
       department. Please have the following information ready
       before calling:

       a) Product name and serial number on your original
          distribution disk.

       b) Product version number. The version number for Turbo
          Basic is displayed when you first load the program
          and before you press any keys.

       c) Computer brand, model, and the brands and model
          numbers of any additional hardware.

       d) Operating system and version number. (The version
          number can be determined by typing VER at the DOS
          prompt.)

       e) Contents of your AUTOEXEC.BAT file.

       f) Contents of your CONFIG.SYS file.



    2. NEW IBM GRAPHICS MODE SUPPORT
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

    Turbo Basic supports the new enhanced graphics modes
    available on the new IBM Personal System computers.

    Use the SCREEN statement to access the new modes.  The 
    following table describes the new modes the SCREEN
    statement takes:


       SCREEN   MODE
       컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
       11   640 X 480  black and white
       12   640 X 480  16 Color


    3. CORRECTIONS/ADDITIONS TO THE MANUAL
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

    The following lists the corrections and additions to the
    Turbo Basic manual. They are sequential by page number so you
    can easily update your manual while you read through them.

    Page 38 - The G (for global) option in the editor's Find
    command does NOT stop at the position of each occurrence of
    your search string. It searches through the entire file from
    beginning to end, and positions the cursor on the LAST
    occurrence of the search string.

    Page 38 - The N (for Next) option of the Find command is not
    documented here. The N option finds the Next occurrence of a
    search string, starting at the current cursor position in the
    file you are editing. Keep in mind that the G option will
    override the N option if you use both at the same time. Also,
    note that the N option is different than the n of the Find
    command. The lower case n represents an integer that can be
    used in the option list of the Find command.

    Page 39 - The n (for number) option of the Find and replace
    command. Unlike the n option in the Find command, the n
    option for Find and replace causes the next n cases of the
    search string to be replaced by the replace string. If the G
    option is used, the search starts at the top of the file;
    otherwise it starts at the current cursor position.

    Page 49 - A word of warning is necessary concerning the 8087
    coprocessor and Turbo Basic. In some cases, a program will
    read that your machine has an 8087 chip when it really
    doesn't; for example, if you've set the switch on for 8087
    but have yet to install the chip. This will either cause
    Turbo Basic to hang when running a program or to generate
    compile-time errors when compiling programs with numbers.
    Environment variables solve this problem nicely. Add the
    following to your AUTOEXEC.BAT file:

       SET 87=NO

    Take a look at Appendix G, "A DOS Primer," for more
    information about environment variables and AUTOEXEC.BAT
    files.

    Page 52 - The sentence: "Note that 8 notes equal 1 byte;"
    should be: "Note that 1 note equals 8 bytes;"

    Page 55 - In the discussion of Save Options/Window/Setup, it
    says that you may save the options to TB.EXE. Actually, a
    file extension of .TB is always added to the end of the
    configuration file's name.

    Page 57 - Under the Run-time error option in the Debug menu,
    note that you'll receive a "Run-time error not found" error
    message if you give an invalid program counter.

    Page  76 - Arrays are  considered dynamic in the following
    cases:

       - If declared after the $DYNAMIC metastatement is used, 
         as in
        10 $DYNAMIC
        20 DIM A(10)
       - If declared as dynamic explicitly, as in
        10 DIM DYNAMIC A(10)
       - If a variable is used in the DIM statement, as in
        10 X% = 10
        20 DIM A(X%)
       - If the array is included in a COMMON statement, as in
        10 DIM A(10)
        20 COMMON A(1)
       - If there are two or more DIM statements for the same
         array identifier, as in
        10 DIM A(10)
        20 A(0) = 10
        30 DIM A(10)
       - If an array is declared local to a procedure or function, 
         as in
        DEF FNTest%
          LOCAL A()
          DIM A(10)
          FNTest% = A(0)
        END DEF


    Page 107 - The example program on this page  uses a variable
    called name$. This variable will cause a syntax error because
    you cannot use a reserved  word as a  variable. Replace the
    variable name$ with FileName$.

    Page 125 - $INLINE's example program contains two extra
    commas that will cause a compile error. Remove the commas
    at the end of the first two $INLINE statements.

    Page 144 - The description of the CEIL function should read:

       The CEIL function converts a numeric variable or
       expression to an integer by returning the smallest integer
       that is...

    Page 155 - Make the following modification to the example program for
    the CLOSE statement:

     Change:
       OPEN "CLOSEFIL.ONE" AS #1
       OPEN "CLOSEFIL.TWO" AS #2

     To:
       OPEN "CLOSEFIL.ONE" FOR OUTPUT AS #1
       OPEN "CLOSEFIL.TWO" FOR OUTPUT AS #2

    Page 162 - Remove the OPEN statement in COM(n)'s example
    program; it is extraneous and will cause a compile error.

    Page 174 - Remove the following line from the example program:

       Your results:

    Page 180 - The example statement in the middle of the page:

       = m + 16

     should be:

       n = m + 16

    Page 191 - Make the following change to the example program
    for DRAW:

     Change:

       DRAW "M= " +VARPTR$(I%) + ",40"

     To:

       DRAW "BM=" + VARPTR$(I%) + ",40"

    Page 239 - The first sentence in the Remarks section should be:

       n is the trapped key, and integer expression from 1-25,
       30, or 31, according to the following:

    The table following the first paragraph should be modified to
    look exactly like the one on page 274.

    Page 242 - The syntax description for LBOUND is:

       LBOUND(array(dimension))

     In the example program, the statement:

       PRINT "Lower Array Bound of Dimension 2 is ";LBOUND(Array%,2)

     Should be changed to:

       PRINT "Lower Array Bound of Dimension 2 is ";LBOUND(Array%(2))


    Page 274 - The first sentence in the Remarks section should be:

       n is the trapped key, and integer expression from 1-25,
       30, or 31, according to the following:

    Page 286 - The syntax for the OPEN COM statement is:

       OPEN "COMn:[baud] [,parity] [,data] [,stop] [options]"

    Page 287 - The example program for OPEN COM should be changed
    to the following:

       ' allocate a string array to store input
       DIM ComPortInput$(1)

       $COM1 1024    ' set up a 1K input buffer

       OPEN "COM1:300,n,8,1,DS,RS,CS,CD" AS #1 LEN = 1

       PRINT "Press any key to terminate the program..."
       WHILE NOT INSTAT ' while a key hasn't been pressed
        ' if there is any input available
         IF LOF(1) > 0 THEN
            ' read any info available in the com port buffer
            ComPortInput$(0) = INPUT$(LOF(1), #1)
            ' display input
            PRINT "COM Port input: ";ComPortInput$(0)
         END IF
       WEND

       END   ' end of program

    Page 301 - The example statement in the middle of the page is
    missing a colon.

     Change:

       a$ = "C D E" PLAY "E D E X" + VARPTR$(a$)

     To:

       a$ = "C D E" : PLAY "E D E X" + VARPTR$(a$)

    Page 319 - The DATA statements for the example program are
    missing. Use the following:

       DATA W. Perry,    78, 65, 35, 79, 86, 93, 79, 85, 99, 96
       DATA P. Watson,   98, 94, 70, 88, 99, 100, 75, 96, 100, 95
       DATA M. Ciccone, 65, 59, 75, 82, 56, 79, 82, 76, 69, 89

    Page 352 - Remove the comment from the first statement of the
    program:

      Change:

       ' top$ = STRING$(40,61)

      To:

       top$ = STRING$(40,61)

    Page 365 - The syntax for UBOUND is:

       UBOUND(array(dimension))

     In the example program, the statement:

       FOR index% = LBOUND(Array%) TO UBOUND(Array%)

     Should be changed to:

       FOR index% = LBOUND(Array%(1)) TO UBOUND(Array%(1))

    Page 382 - In the DATA statement for the example program add
    an ending double quote to the word "Paris".

    Page 401 - The original assembly language source code for the
    INLINE procedure on this page is:

      program segment   ; begin program segment
      assume cs:program

      push BP           ; save the Base Pointer
      mov  BP,SP        ; move stack pointer to BP
      les  DI,[BP+6]    ; offset address of parameter
      mov  AX, 64h      ; constant to fill
      mov  CX, C8h      ; length of fill
      cld               ; clear the direction flag
      rep               ; fill the words
      stosw
      pop  BP           ; restore Base Pointer

      program ends      ; end program segment
      ends              ; end compilation


    Note that there is no RET at the end of the routine. You may
    run this code through The MicroSoft Assembler to generate the
    code listed in the manual.

    Page 416 - Error 242, String memory corrupt, should be
    String/array memory corrupt.


    4. IMPORTANT TIPS
    컴컴컴컴컴컴컴컴�

    CTRL-BREAK - If you want to be able to use CTRL-BREAK when
    running a program, toggle ON the Keyboard break option in the
    Options pulldown menu before compiling/running your program.
    Note that CTRL-BREAK will only interrupt your program if the
    Keyboard break option is turned ON and your program is doing
    screen I/O or you have turned the Trace option ON in the
    Debug menu. This is important to note because many public
    domain programs written for BASICA do not provide any way
    for the user to terminate execution other than pressing
    CTRL-BREAK.

    PRINT USING - When using the PRINT USING statement to display
    real numbers (single and double precision), you may find that
    the format strings for your BASICA programs do not format the
    numeric values correctly. One symptom may be that your
    numbers are displayed with a preceding % character followed
    by the number. This is because Turbo Basic provides 80 bits
    of numeric precision compared to BASICA's 24 bits. In other
    words, you have proportionately more-significant digits for
    all of your numbers. And consequently, you may have to make
    more room for your numbers when you output them.

    We have also found that some versions of GW BASIC
    automatically remove the last character of a number when
    there isn't enough room in the format string to display a
    negative sign. BASICA does not do this, nor does Turbo Basic.
    If you need to display a negative sign, you must allow for it
    in the PRINT USING statement's format string.


    5. FILES ON THE DISK
    컴컴컴컴컴컴컴컴컴컴

    Disk 1
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    README   COM - The program to use to peruse this README file

    TB       EXE - The Turbo Basic compiler

    TBINST   COM - The Turbo Basic installation program

    TBHELP   TBH - The help file for Turbo Basic

    HANOI    BAS - An example Turbo Basic program that plays the
                   famous Towers of Hanoi game.

    README       - This file!



    Disk 2
    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

    REGNAMES INC - The named constants representing the registers
                   used by the CALL INTERRUPT statement

    ACKERMAN BAS - An example program demonstrating the Ackerman
                   algorithm (illustrating recursion)

    BALL     BAS - An example graphics program

    HANOI    BAS - An example Turbo Basic program that plays the
                   famous Towers of Hanoi game.

    HILBD    BAS - An example program demonstrating the precision
                   of the 8087 math package

    MUSIC    BAS - An example sound program

    QUIKSORT BAS - An example program implementing the Quick Sort
                   algorithm

    RECQUICK BAS - An example program implementing the Quick Sort
                   algorithm using recursion

    SIEVE    BAS - An example program implementing the Sieve
                   algorithm

    WHEREIS  BAS - The Main file for the WHEREIS program
    WHEREIS  INC - The Include file for the WHEREIS program
    GETDIR   ASM - The Assembly language source for Turbo Basic
                   Inline procedure; gets the current directory
    GETDRIVE ASM - The Assembly language source for Turbo Basic
                   Inline procedure; gets the current drive
    GETDTA   ASM - The Assembly language source for Turbo Basic
                   Inline procedure; gets the current DTA
    SETDTA   ASM - The Assembly language source for Turbo Basic
                   Inline procedure; sets the DTA to a new location
    GETDIR   BIN - The Assembled version of GETDIR.ASM; ready to be
                   used by WHEREIS.BAS
    GETDRIVE BIN - The Assembled version of GETDRIVE.ASM; ready to
                   be used by WHEREIS.BAS
    GETDTA   BIN - The Assembled version of GETDTA.ASM; ready to
                   be used by WHEREIS.BAS
    SETDTA   BIN - The Assembled version of SETDTA.ASM; ready to
                   be used by WHEREIS.BAS

    MC       BAS - The Main file for the MicroCalc example program
    MC0      INC - An Include file for MicroCalc
    MC1      INC - An Include file for MicroCalc
    MC2      INC - An Include file for MicroCalc
    MC3      INC - An Include file for MicroCalc
    MC4      INC - An Include file for MicroCalc
    MC5      INC - An Include file for MicroCalc
    MC6      INC - An Include file for MicroCalc
    MC7      INC - An Include file for MicroCalc
    MC8      INC - An Include file for MicroCalc
    MC       HLP - The help file for MicroCalc
    MCDEMO       - The Demonstration work sheet for MicroCalc




