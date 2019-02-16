*:*****************************************************************************
*:
*: Procedure file: C:\FOXPROW\GENSCRN.PRG
*:         System: GenScrn
*:         Author: Microsoft Corp.
*:      Copyright (c) 1990 - 1993 Microsoft Corp.
*:  Last modified: 1/4/93 at 19:33:06
*:
*:      Documented              FoxDoc version 3.00a
*:*****************************************************************************
*
* GENSCRN - Screen Code Generator.
*
* Copyright (c) 1990 - 1993 Microsoft Corp.
* One Microsoft Way
* Redmond, WA 98502
*
* Description:
* This program generates code for objects designed and built with
* FoxPro screen builder.
*
* Notes:
* In this program, for clarity/readability reasons, we use variable
* names that are longer than 10 characters.  Note, however, that only
* the first 10 characters are significant.
*
PARAMETER m.projdbf, m.recno
PRIVATE ALL

IF SET("TALK") = "ON"
   SET TALK OFF
   m.talkset = "ON"
ELSE
   m.talkset = "OFF"
ENDIF

m.escape = SET("ESCAPE")
ON ESCAPE
SET ESCAPE OFF
m.trbetween = SET("TRBET")
SET TRBET OFF
m.comp = SET("COMPATIBLE")
SET COMPATIBLE FOXPLUS
mdevice = SET("DEVICE")
SET DEVICE TO SCREEN

*
* Declare Global Constants
*
#DEFINE c_otscreen         1
#DEFINE c_otworkarea       2
#DEFINE c_otindex          3
#DEFINE c_otrel			   4
#DEFINE c_ottext           5
#DEFINE c_otline           6
#DEFINE c_otbox            7
#DEFINE c_otlist          11
#DEFINE c_ottxtbut        12
#DEFINE c_otradbut        13
#DEFINE c_otchkbox        14
#DEFINE c_otfield         15
#DEFINE c_otpopup         16
#DEFINE c_otpicture       17
#DEFINE c_otinvbut        20
#DEFINE c_otspinner       22

#DEFINE c_authorlen       45
#DEFINE c_complen         45
#DEFINE c_addrlen         45
#DEFINE c_citylen         20
#DEFINE c_statlen          5
#DEFINE c_ziplen          10
#DEFINE c_countrylen      40

#DEFINE c_sgsay            0
#DEFINE c_sgget            1
#DEFINE c_sgedit           2
#DEFINE c_sgfrom           3
#DEFINE c_sgbox            4
#DEFINE c_sgboxd           5
#DEFINE c_sgboxp           6
#DEFINE c_sgboxc           7

#DEFINE c_dos     "DOS"
#DEFINE c_windows "WINDOWS"
#DEFINE c_mac     "MAC"
#DEFINE c_unix    "UNIX"

* Determines whether SHOW snippets are checked for suspicious SHOW GETS statements
#DEFINE c_checkshow        1

#DEFINE c_maxwinds        25
#DEFINE c_maxpops         25
#DEFINE c_maxscreens       5
#DEFINE c_maxplatforms     4
#DEFINE c_20scxflds		  57
#DEFINE c_scxflds         79
#DEFINE c_pjxflds         31
#DEFINE c_pjx20flds       33

#DEFINE c_esc			CHR(27)
#DEFINE c_null			CHR(0)
#DEFINE c_cret			CHR(13)
#DEFINE c_lf			CHR(10)
#DEFINE c_under			"_"
#DEFINE c_single		"ÚÄ¿³ÙÄÀ³"
#DEFINE c_double		"ÉÍ»º¼ÍÈº"
#DEFINE c_panel			"ÛÛÛÛÛÛÛÛ"
#DEFINE c_fromone		1
#DEFINE c_untilend		0

#DEFINE c_error_1		"Minor"
#DEFINE c_error_2		"Serious"
#DEFINE c_error_3		"Fatal"

#DEFINE c_aliaslen   10   && maximum alias length

#DEFINE c_premode			0
#DEFINE c_postmode			1

#DEFINE c_userprecode		"*# USERPRECOMMAND"
#DEFINE c_userpostcode		"*# USERPOSTCOMMAND"

IF _MAC
   m.g_dlgface = "Geneva"
   m.g_dlgsize = 10.000
   m.g_dlgstyle = ""
ELSE
   m.g_dlgface = "MS Sans Serif"
   m.g_dlgsize = 8.000
   m.g_dlgstyle = "B"
ENDIF

#DEFINE c_pathsep  "\"

#DEFINE c_genexpr    0
#DEFINE c_gencode    1
#DEFINE c_genboth    -1

#DEFINE c_therm1      5
#DEFINE c_therm2     15
#DEFINE c_therm3     35
#DEFINE c_therm4     60
#DEFINE c_therm5     65
#DEFINE c_therm6     70
#DEFINE c_therm7     95

#DEFINE c_all 1
m.g_picext = "PCT"   && Mac picture
m.g_bmpext = "BMP"   && Windows bitmap
m.g_icnext = "ICN"   && Mac icon
m.g_icoext = "ICO"   && Windows icon

m.g_genparams = PARAMETERS()
*
* Declare Variables
*
STORE "" TO m.cursor, m.consol, m.bell, m.exact, ;
   m.safety, m.fixed, m.print, m.delimiters, m.unique, mudfparms, ;
   m.fields, mfieldsto, m.mdecpoint, m.origpretext, m.mcollate, m.mmacdesk
STORE 0 TO m.deci, m.memowidth

m.g_closefiles = .F.           && Generate code to close files?
m.g_current    = ""            && current DBF
m.g_defasch1   = 0		       && Default color scheme 1
m.g_defasch2   = 0		       && Default color scheme 2
m.g_defwin     = .F.           && Generate code to define windows?
m.g_errlog     = ""		       && Path + name of .ERR file
m.g_homedir    = ""		       && Application Home Directory
m.g_idxfile    = 'idxfile.idx' && Index file
m.g_itse       = c_null	       && Designating character from #ITSEXPRESSION
m.g_lastwindow = ""            && Name of last window defined
m.g_keyno      = 0
m.g_havehand = .F.
m.g_redefi     = .F.           && Don't redefine windows
m.g_screen     = 0             && Screen currently being generated.  Also used in error messages.
m.g_nscreens   = 0             && Number of screens
m.g_nwindows   = 0             && Number of unique windows in this platform
m.g_multreads  = .F.           && Multiple reads?
m.g_openfiles  = .F.           && Generate code to open files?
m.g_orghandle  = -1            && File handle for ctrl file
m.g_outfile    = ""            && Output file name
m.g_projalias  = ""            && Project database alias
m.g_projpath   = ""
m.g_rddir      = .F.           && Is there a #READCLAUSES directive?
m.g_windclauses= ""            && #WCLAUSES parameters for DEFINE WINDOW
m.g_rddirno    = 0             && Number of 1st screen with #READ directive
m.g_readcycle  = .F.           && READ CYCLE?
m.g_readlock   = .F.           && READ LOCK/NOLOCK?
m.g_readmodal  = .F.           && READ MODAL?
m.g_readborder = .F.           && READ BORDER?
m.g_relwin     = .F.           && Generate code to release windows?
m.g_moddesktop = .F.
m.g_snippcnt   = 0             && Count of snippets
m.g_somepops   = .F.           && Any Generated popups?
m.g_status     = 0
m.g_thermwidth = 0             && Thermometer width
m.g_tmpfile    = SYS(3)+".tmp" && Temporary file
m.g_tmphandle  = -1            && File handle for tmp file
m.g_windows    = .F.           && Any windows in screen files?
m.g_withlist   = ""
m.g_workarea   = 0
m.g_genvers	   = ""            && version we are generating for
m.g_thisvers   = ""            && version we are running under now
m.g_graphic    = .F.
m.g_isfirstproc= .T.           && is this the first procedure emitted?
m.g_procsmatch = .F.           && are cleanup snippets for all platforms identical
m.g_noread     = .F.           && omit the read statement?
m.g_noreadplain= .F.           && omit the read statement and the SET TALK TO.. statements?
m.g_dualoutput = .F.           && generating for Mac on Windows (& etc.) ?

m.g_boxstrg = ['Ä','Ä','³','³','Ú','¿','À','Ù','Ä','Ä','³','³','Ú','¿','À','Ù']

m.g_validtype  = ""
m.g_validname  = ""
m.g_whentype   = ""
m.g_whenname   = ""
m.g_actitype   = ""
m.g_actiname   = ""
m.g_deattype   = ""
m.g_deatname   = ""
m.g_showtype   = ""
m.g_showname   = ""
m.g_showexpr   = ""

m.g_sect1start = 0
m.g_sect2start = 0

m.g_devauthor  = PADR("Author's Name",c_authorlen," ")
m.g_devcompany = PADR("Company Name",c_complen, " ")
m.g_devaddress = PADR("Address",c_addrlen," ")
m.g_devcity    = PADR("City",c_citylen," ")
m.g_devstate   = "  "
m.g_devzip     = PADR("Zip",c_ziplen," ")
m.g_devctry    = PADR("Country",c_countrylen, " ")

m.g_allplatforms = .T.            && generate for all platforms in the SCX?
m.g_numplatforms = 1              && number of platforms we are generating for
m.g_parameter    = ""             && the parameter statement for this SPR
m.g_areacount    = 1              && index into g_areas to count workareas we use
m.g_dblampersand = CHR(38) + CHR(38)   && used in some tight loops.  Concatenate just once here.

DO CASE
CASE AT(c_windows, UPPER(VERSION())) <> 0
   m.g_thisvers = c_windows
   m.g_graphic  = .T.
CASE AT(c_mac, UPPER(VERSION())) <> 0
   m.g_thisvers = c_mac
   m.g_graphic  = .T.
CASE AT(c_unix, UPPER(VERSION())) <> 0
   m.g_thisvers = c_unix
   m.g_graphic  = .F.
CASE AT("FOXPRO", UPPER(VERSION())) <> 0
   m.g_thisvers = c_dos
   m.g_graphic  = .F.
OTHERWISE
   DO errorhandler WITH "Unknown FoxPro platform",LINENO(),c_error_3
ENDCASE

STORE "" TO m.g_corn1, m.g_corn2, m.g_corn3, m.g_corn4, m.g_corn5, ;
   m.g_corn6, m.g_verti2
STORE "*" TO  m.g_horiz, m.g_verti1

* This array stores the names of the DBFs in the environment for this platform
DIMENSION g_dbfs[1]
g_dbfs = ""

* If you add arrays that are based on C_MAXSCREENS, remember to check PrepScreens().
* You'll probably need to add the array name there so that if the number of screens
* exceeds C_MAXSCREENS, your array gets expanded too.

*	generated popup names associated with scollable lists.
*
*	g_popups[*,1] - screen basename
*	g_popups[*,2] - record number
*	g_popups[*,3] - generated popup name
*
DIMENSION g_popups[C_MAXPOPS,3]
g_popups = ""

* 	screen file name array definition
*
* 	g_screens[*,1] - screen fully qualified name
* 	g_screens[*,2] - window name if any
* 	g_screens[*,3] - recno in proj dbf
*	g_screens[*,4] - initially opened?
*	g_screens[*,5] - alias
*	g_screens[*,6] - 2.0 screen file?
*	g_screens[*,7] - Platform to generate from
*
DIMENSION g_screens[C_MAXSCREENS,7]
g_screens = ""

* Array to store window stack.
* g_wndows[*,1]  - Window name
* g_wndows[*,2]  - Window sequence
DIMENSION g_wndows[C_MAXWINDS,2]
g_wndows = ""

* Store the substitution string for window names
DIMENSION g_wnames[C_MAXSCREENS, C_MAXPLATFORMS]
g_wnames = ""

* g_platforms holds a list of platforms in common among all screens
DIMENSION g_platforms[C_MAXSCREENS]
g_platforms = ""

* g_platprocs is a parallel array to g_platforms.  It holds the name
* of the procedure to contain the setup snippet and all the @SAYs
* and @GETs for the corresponding platform.
DIMENSION g_platproc[C_MAXSCREENS]
g_platproc = ""

* g_areas holds a list of areas we opened files in during this gen and that
* we need to close on exit.
DIMENSION g_areas[256]
g_areas = 0

* g_firstproc holds the line number of the first PROCEDURE or FUNCTION in
* the cleanup snippet of each screen.
DIMENSION g_firstproc[C_MAXSCREENS]
g_firstproc = 0

DIMENSION g_platlist[C_MAXPLATFORMS]
g_platlist[1] = c_dos
g_platlist[2] = c_windows
g_platlist[3] = c_mac
g_platlist[4] = c_unix

DIMENSION g_procs[1,C_MAXPLATFORMS+3]
* First column is a procedure name
* Second through n-th column is the line number in the cleanup snippet where
*    a procedure with this name starts.
* C_MAXPLATFORMS+2 column is a 1 if this procedure has been emitted.
* C_MAXPLATFORMS+3 column holds the parameter statement, if any.
* One row for each unique procedure name found in the cleanup snippet for any platform.
g_procs = -1
g_procs[1,1] = ""
g_procs[1,C_MAXPLATFORMS+3] = ""
g_procnames = 0   && the number we've found so far

**
** Main program
**

m.onerror = ON("ERROR")
ON ERROR DO errorhandler WITH MESSAGE(), LINENO(), c_error_3

IF m.g_genparams < 2
   DO errorhandler WITH "Invalid number of parameters passed to"+;
      " the generator",LINENO(),c_error_3
   RETURN m.g_status
ENDIF

DO setall

IF openprojdbf(m.projdbf, m.recno) AND prepscreens(m.g_thisvers) AND prepplatform()
   DO BUILD
ENDIF

DO cleanup

RETURN m.g_status

**
** Code Responsible for Genscrn's environment setting.
**

*!*****************************************************************************
*!
*!      Procedure: SETALL
*!
*!      Called by: GENSCRN.PRG
*!
*!*****************************************************************************
PROCEDURE setall
*)
*) SETALL - Create program's environment.
*)
*) Description:
*) Save the user's environment that is being modified by the GENSCRN,
*) then issue various SET commands.
*)
CLEAR PROGRAM
CLEAR GETS

m.g_workarea = SELECT()
m.delimiters = SET('TEXTMERGE',1)
SET TEXTMERGE DELIMITERS TO
SET TEXTMERGE NOSHOW
mudfparms = SET('UDFPARMS')
SET UDFPARMS TO VALUE

m.mfieldsto = SET("FIELDS",1)
m.fields = SET("FIELDS")
SET FIELDS TO
SET FIELDS OFF
m.memowidth = SET("MEMOWIDTH")
SET MEMOWIDTH TO 256
m.cursor = SET("CURSOR")
SET CURSOR OFF
m.consol = SET("CONSOLE")
SET CONSOLE OFF
m.bell = SET("BELL")
SET BELL OFF
m.exact = SET("EXACT")
SET EXACT ON
m.safety = SET("SAFETY")
m.deci = SET("DECIMALS")
SET DECIMALS TO 0
m.mdecpoint = SET("POINT")
SET POINT TO "."
m.fixed = SET("FIXED")
SET FIXED ON
m.print = SET("PRINT")
SET PRINT OFF
m.unique = SET("UNIQUE")
SET UNIQUE OFF
m.mcollate = SET("COLLATE")
SET COLLATE TO "machine"
#if "MAC" $ UPPER(VERSION(1))
   IF _MAC
      m.mmacdesk = SET("MACDESKTOP")
      SET MACDESKTOP ON
	ENDIF
#endif
m.origpretext = _PRETEXT
_PRETEXT = ""
RETURN

*!*****************************************************************************
*!
*!      Procedure: CLEANUP
*!
*!      Called by: GENSCRN.PRG
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : ESCHANDLER         (procedure in GENSCRN.PRG)
*!
*!          Calls: CLEANSCRN          (procedure in GENSCRN.PRG)
*!               : CLEARAREAS         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE cleanup
*)
*) CLEANUP - Restore environment to pre-execution state.
*)
*) Description:
*) Put SET command settings back the way we found them.
*)
PRIVATE m.i, m.delilen, m.ldelimi, m.rdelimi
IF EMPTY(m.g_projalias)
   RETURN
ENDIF
SELECT (m.g_projalias)
USE
DO cleanscrn
DO clearareas  && clear the workareas we opened during this run
SELECT (m.g_workarea)

DELETE FILE (m.g_tmpfile)
DELETE FILE (m.g_idxfile)

m.delilen = LEN(m.delimiters)
m.ldelimi = SUBSTR(m.delimiters,1,;
   IIF(MOD(m.delilen,2)=0,m.delilen/2,CEILING(m.delilen/2)))
m.rdelimi = SUBSTR(m.delimiters,;
   IIF(MOD(m.delilen,2)=0,m.delilen/2+1,CEILING(m.delilen/2)+1))
SET TEXTMERGE DELIMITERS TO m.ldelimi, m.rdelimi

SET FIELDS TO &mfieldsto
IF m.fields = "ON"
   SET FIELDS ON
ELSE
   SET FIELDS OFF
ENDIF
IF m.cursor = "ON"
   SET CURSOR ON
ELSE
   SET CURSOR OFF
ENDIF
IF m.consol = "ON"
   SET CONSOLE ON
ELSE
   SET CONSOLE OFF
ENDIF
IF m.escape = "ON"
   SET ESCAPE ON
ELSE
   SET ESCAPE OFF
ENDIF
IF m.bell = "ON"
   SET BELL ON
ELSE
   SET BELL OFF
ENDIF
IF m.exact = "ON"
   SET EXACT ON
ELSE
   SET EXACT OFF
ENDIF
IF m.safety = "ON"
   SET SAFETY ON
ELSE
   SET SAFETY OFF
ENDIF
IF m.comp = "ON"
   SET COMPATIBLE ON
ENDIF
IF m.print = "ON"
   SET PRINT ON
ENDIF
SET DECIMALS TO m.deci
SET MEMOWIDTH TO m.memowidth
SET DEVICE TO &mdevice
SET UDFPARMS TO &mudfparms
SET POINT TO "&mdecpoint"
SET COLLATE TO "&mcollate"
#if "MAC" $ UPPER(VERSION(1))
   IF _MAC
      SET MACDESKTOP &mmacdesk
	ENDIF
#endif
IF m.fixed = "OFF"
   SET FIXED OFF
ENDIF
IF m.trbetween = "ON"
   SET TRBET ON
ENDIF
IF m.talkset = "ON"
   SET TALK ON
ENDIF
IF m.unique = "ON"
   SET UNIQUE ON
ENDIF
SET MESSAGE TO
_PRETEXT = m.origpretext
* Leave this array if dbglevel is defined.  Used for profiling.
* IF TYPE("dbglevel") = "U"
*   RELEASE ticktock
* ENDIF

ON ERROR &onerror
RETURN

*!*****************************************************************************
*!
*!      Procedure: CLEANSCRN
*!
*!      Called by: CLEANUP            (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE cleanscrn
*)
*) CLEANSCRN - Clean up after each screen set generation, once per platform
*)
PRIVATE m.i
FOR m.i = 1 TO m.g_nscreens
   m.g_screen = i
   IF NOT EMPTY(g_screens[m.i,4])
      LOOP
   ENDIF
   IF USED(g_screens[m.i,5])
      SELECT (g_screens[m.i,5])
      USE
   ENDIF
ENDFOR
m.g_screen = 0
RETURN

*!*****************************************************************************
*!
*!      Procedure: BUILDENABLE
*!
*!      Called by: BUILD              (procedure in GENSCRN.PRG)
*!
*!          Calls: PREPFILE           (procedure in GENSCRN.PRG)
*!               : ESCHANDLER         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE buildenable
*)
*> BUILDENABLE - Enable code generation.
*)
*) Description:
*) Call prepfile to open output file(s).
*) If error(s) encountered in prepfile then exit, otherwise
*) SET TEXTMERGE ON
*)
*) Returns: .T. on success; .F. on failure
*)
DO prepfile WITH m.g_outfile, m.g_orghandle
DO prepfile WITH m.g_tmpfile, m.g_tmphandle

SET TEXTMERGE ON
ON ESCAPE DO eschandler
SET ESCAPE ON
RETURN

*!*****************************************************************************
*!
*!      Procedure: BUILDDISABLE
*!
*!      Called by: BUILD              (procedure in GENSCRN.PRG)
*!               : ESCHANDLER         (procedure in GENSCRN.PRG)
*!
*!          Calls: CLOSEFILE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE builddisable
*)
*) BUILDDISABLE - Disable code generation.
*)
*) Description:
*) Issue the command SET TEXTMERGE OFF.
*) Close the generated output file.
*) Close the temporary file.
*) If anything goes wrong display appropriate message to the user.
*)
SET ESCAPE OFF
ON ESCAPE
SET TEXTMERGE OFF
IF m.g_havehand
   DO closefile WITH m.g_orghandle
   DO closefile WITH m.g_tmphandle
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: PREPPARAMS
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!          Calls: CHECKPARAM()       (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE prepparams
*)
*) PREPPARAMS - Read through each of the platforms on screen 1
*)              and ensure that any parameter statements in #SECTION 1
*)              are identical.
*)
PRIVATE m.i, m.j, m.dbalias, m.thisparam
m.g_screen = 1
m.dbalias = g_screens[m.g_screen,5]
SELECT (m.dbalias)
DO CASE
CASE g_screens[m.g_screen,6] OR !multiplat()
   * DOS 2.0 screen or just one 2.5 platform being generated
   GO TOP
   RETURN checkparam(m.g_screen)

OTHERWISE
   FOR m.j = 1 TO c_maxplatforms
      LOCATE FOR ALLTRIM(UPPER(platform)) = g_platlist[m.j] AND objtype = c_otscreen
      DO CASE
      CASE !FOUND() OR EMPTY(setupcode)
         LOOP
      CASE !checkparam(m.g_screen)
         RETURN .F.
      ENDCASE
   ENDFOR
ENDCASE
m.g_screen = 0
RETURN .T.

*!*****************************************************************************
*!
*!       Function: CLEANPARAM
*!
*!      Called by: CHECKPARAM()       (function  in GENSCRN.PRG)
*!               : UPDPROCARRAY       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION cleanparam
*)
*) CLEANPARAM - Clean up a parameter string so that it may be compared with another one.
*)              This function replaces tabs with spaces, capitalizes the string, merges
*)              forces single spacing, and strips out CR/LF characters.
*)
PARAMETER m.p, m.cp
m.cp = UPPER(ALLTRIM(CHRTRAN(m.p,";"+CHR(13)+CHR(10),"")))   && drop CR/LF and continuation chars
m.cp = CHRTRAN(m.cp,CHR(9),' ')   && tabs to spaces
DO WHILE AT('  ',m.cp) > 0         && reduce multiple spaces to a single space
   m.cp = STRTRAN(m.cp,'  ',' ')
ENDDO
DO WHILE AT(', ',m.cp) > 0         && drop spaces after commas
   m.cp = STRTRAN(m.cp,', ',',')
ENDDO
RETURN m.cp

*!*****************************************************************************
*!
*!       Function: CHECKPARAM
*!
*!      Called by: PREPPARAMS         (procedure in GENSCRN.PRG)
*!
*!          Calls: GETPARAM()         (function  in GENSCRN.PRG)
*!               : CLEANPARAM()       (function  in GENSCRN.PRG)
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION checkparam
*)
*) CHECKPARAM - See if this parameter statement matches others we have found. Generate
*)               an error message if it doesn't.  g_parameter is empty if we haven't
*)               seen any parameter statements yet, or it contains the variables in the
*)               parameter statement (but not the PARAMETERS keyword) if we have seen one
*)               before.
*)
PARAMETER m.i
PRIVATE m.thisparam
m.thisparam = getparam("setupcode")  && get parameter from setup snippet at current record position

IF !EMPTY(m.thisparam)
   IF !EMPTY(m.g_parameter) AND !(cleanparam(m.thisparam) == cleanparam(m.g_parameter))
      DO errorhandler WITH "DOS and Windows setup code has different parameters", ;
         LINENO(), c_error_3
      RETURN .F.
   ELSE
      g_parameter = m.thisparam
   ENDIF
ENDIF
RETURN .T.

*!*****************************************************************************
*!
*!      Procedure: PREPPLATFORM
*!
*!      Called by: GENSCRN.PRG
*!
*!*****************************************************************************
PROCEDURE prepplatform
*)
*) PREPPLATFORM - Create an array of platform names in the screen set.  Make sure that
*)                there is at least one common platform across all SCXs in the screen set.
*)                g_platforms comes out of this procedure containing the intersection of
*)                the set of platforms in each screen.  If there are no common platforms
*)                across all screens, it will be empty.
*)
PRIVATE m.i, m.j, m.firstscrn, m.p_cur, m.tempplat, m.numtodel, m.in_area, ;
   m.rcount
IF m.g_nscreens <= 0
   RETURN .F.
ENDIF

DIMENSION t_platforms[ALEN(g_platforms)]
m.in_area = SELECT()
IF g_screens[1,6]         && First screen is a DOS 2.0 screen
   g_platforms = ""
   g_platforms[1] = "DOS"
ELSE
   IF _DOS
      * Avoid selecting into an array to conserve memory
      SELECT DISTINCT platform FROM (g_screens[1,1]) ;
      	WHERE IIF(INLIST(UPPER(platform), c_dos, ;
			c_windows, c_mac, c_unix), .T., .F.) ;
      	INTO CURSOR curstemp ;
         ORDER BY platform
      m.rcount = _TALLY
      SELECT curstemp
      DIMENSION g_platforms[m.rcount]
      GOTO TOP
      FOR m.i = 1 TO m.rcount
         g_platforms[m.i] = curstemp->platform
         SKIP
      ENDFOR
      USE                                             && get rid of the cursor
   ELSE
      SELECT DISTINCT platform FROM (g_screens[1,1]) ;
      	WHERE IIF(INLIST(UPPER(platform), c_dos, ;
			c_windows, c_mac, c_unix), .T., .F.) ;
      	INTO ARRAY g_platforms ;
         ORDER BY platform
   ENDIF
ENDIF

m.numtodel = 0   && number of array elements to delete
FOR m.i = 2 TO m.g_nscreens
   m.g_screen = m.i
   IF g_screens[m.i,6]   && DOS 2.0 screen
      DIMENSION t_platforms[1]
      t_platforms = ""
      t_platforms[1] = "DOS"
   ELSE
      IF _DOS
         * Avoid selecting into an array to conserve memory
         SELECT DISTINCT platform FROM (g_screens[m.i,1]) ;
  	      	WHERE IIF(INLIST(UPPER(platform), c_dos, ;
				c_windows, c_mac, c_unix), .T., .F.) ;
			INTO CURSOR curstemp ;
            ORDER BY platform
         m.rcount = _TALLY
         SELECT curstemp
         DIMENSION t_platforms[m.rcount]
         GOTO TOP
         FOR m.k = 1 TO m.rcount
            t_platforms[m.k] = curstemp->platform
            SKIP
         ENDFOR
         USE                                             && get rid of the cursor
      ELSE
         SELECT DISTINCT platform FROM (g_screens[m.i,1]) ;
  	      	WHERE IIF(INLIST(UPPER(platform), c_dos, ;
				c_windows, c_mac, c_unix), .T., .F.) ;
         	INTO ARRAY t_platforms ;
            ORDER BY platform
      ENDIF
   ENDIF

   * Update g_platforms with the intersection of g_platforms
   *  and t_platforms
   m.j = 1
   DO WHILE m.j < ALEN(g_platforms) -  m.numtodel
      IF !INLIST(TYPE("g_platforms[m.j]"),"L","U") ;
            AND ASCAN(t_platforms,g_platforms[m.j]) = 0
         =ADEL(g_platforms,m.j)
         m.numtodel = m.numtodel + 1
      ELSE
         m.j = m.j + 1
      ENDIF
   ENDDO

ENDFOR
SELECT (m.in_area)

m.g_screen = 0
* Shrink the unique platform array if necessary
DIMENSION g_platforms[ALEN(g_platforms)-m.numtodel]

IF ALEN(g_platforms) <= 0 OR EMPTY(g_platforms[1])
   WAIT WINDOW  "No common platforms in these screens.  Press any key."
   CANCEL
ELSE
   FOR m.j = 1 TO ALEN(g_platforms)
      g_platforms[m.j] = UPPER(ALLTRIM(g_platforms[m.j]))
   ENDFOR

   * If the current platform is in the list of common platforms, put it at the top
   m.p_cur = ASCAN(g_platforms, m.g_thisvers)
   IF m.p_cur > 1
      m.tempplat = g_platforms[1]
      g_platforms[1] = g_platforms[m.p_cur]
      g_platforms[m.p_cur] = m.tempplat
   ENDIF
ENDIF
RETURN .T.

*!*****************************************************************************
*!
*!      Procedure: PREPFILE
*!
*!      Called by: BUILDENABLE        (procedure in GENSCRN.PRG)
*!
*!          Calls: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE prepfile
*)
*) PREPFILE - Create and open the application output file.
*)
*) Description:
*) Create or open a file that will hold the generated application.
*) If error(s) encountered at any time issue an error message
*) and return .F.
*)
PARAMETER m.filename, m.ifp
PRIVATE m.msg
m.ifp = FCREATE(m.filename)

IF (m.ifp = -1)
   m.msg = "Cannot open "+LOWER(m.filename)
   m.g_havehand = .F.
   DO errorhandler WITH m.msg, LINENO(), c_error_3
ELSE
   m.g_havehand = .T.
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: CLOSEFILE
*!
*!      Called by: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : BUILDDISABLE       (procedure in GENSCRN.PRG)
*!
*!          Calls: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE closefile
*)
*) CLOSEFILE - Close a low level file opened with FCREATE.
*)
PARAMETER m.ifp
IF (m.ifp > 0) AND !FCLOSE(m.ifp)
   DO errorhandler WITH "Unable to close the generated file",;
      LINENO(), c_error_2
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: PREPSCREENS
*!
*!      Called by: GENSCRN.PRG
*!               : DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!          Calls: BASENAME()         (function  in GENSCRN.PRG)
*!               : SCREENUSED()       (function  in GENSCRN.PRG)
*!               : NOTEAREA           (procedure in GENSCRN.PRG)
*!               : GETPLATFORM()      (function  in GENSCRN.PRG)
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : PREPWNAMES         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION prepscreens
*)
*) PREPSCREENS - Prepare screen file(s) for processing.
*)
*) Description:
*) Called once per platform.
*)
*) Open PJX database, index it to find all screen files belonging
*) to a screen set if part of a project.
*)
*) Open all screen file(s).  If screen file already opened, then
*) select it.  Assign unique aliases to screen with name conflicts.
*) If error is encountered while opening any of the screen files
*) this program will be aborted.
*)
PARAMETER m.gen_version

PRIVATE m.status, m.projdbf, m.saverec, m.dbname, m.dbalias
m.status = .T.

SELECT (m.g_projalias)
SET SAFETY OFF
INDEX ON STR(scrnorder) TO (m.g_idxfile) COMPACT
SET SAFETY ON
GO TOP
SCAN FOR NOT DELETED() AND setid = m.g_keyno AND TYPE = 's'
   m.saverec = RECNO()
   m.dbname  = FULLPATH(ALLTRIM(name), m.g_projpath)
   if right(m.dbname,1) = ":"
      m.dbname = m.dbname + justfname(name)
   endif
   m.g_nscreens = m.g_nscreens + 1

   IF MOD(m.g_nscreens,5)=0
      DIMENSION g_screens[ALEN(g_screens,1)+5,7]
      DIMENSION g_wnames [ALEN(g_wnames)+5,C_MAXPLATFORMS]
      DIMENSION g_platforms [ALEN(g_platforms)+5]
      DIMENSION g_firstproc [ALEN(g_firstproc)+5]
   ENDIF

   m.dbalias = LEFT(basename(m.dbname), c_aliaslen)
   IF screenused(m.dbalias, m.dbname)
      g_screens[m.g_nscreens,4] = .T.
   ELSE
      g_screens[m.g_nscreens,4] = .F.
		IF FILE(m.dbname)
         SELECT 0
         USE (m.dbname) AGAIN ALIAS (g_screens[m.g_nscreens,5])
         DO notearea
		ELSE
		   DO errorhandler WITH "Could not find SCX file: "+m.dbname, ;
			   LINENO(),c_error_2
			RETURN .F.
	   ENDIF
   ENDIF

   DO CASE
   CASE FCOUNT() = c_scxflds
      LOCATE FOR platform = m.gen_version
      IF FOUND()
         g_screens[m.g_nscreens,6] = .F.
         g_screens[m.g_nscreens,7] = platform
      ELSE
         g_screens[m.g_nscreens,6] = .F.
         g_screens[m.g_nscreens,7] = getplatform()
      ENDIF
   CASE FCOUNT() = c_20scxflds
      g_screens[m.g_nscreens,6] = .T.
      g_screens[m.g_nscreens,7] = "DOS"
   OTHERWISE
      DO errorhandler WITH "Screen "+m.dbalias+" is invalid",LINENO(),;
         c_error_2
      RETURN .F.
   ENDCASE
   g_screens[m.g_nscreens,1] = m.dbname

   IF NOT EMPTY(STYLE)
      IF EMPTY(name)
         g_screens[m.g_nscreens,2] = LOWER(SYS(2015))
      ELSE
         g_screens[m.g_nscreens,2] = ALLTRIM(LOWER(name))
      ENDIF
      DO prepwnames WITH m.g_nscreens
   ENDIF

   SELECT (m.g_projalias)
   GOTO RECORD m.saverec
   g_screens[m.g_nscreens,3] = m.saverec
ENDSCAN

RETURN m.status

*!*****************************************************************************
*!
*!       Function: NEWWINDOWS
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION newwindows
* Initialize the windows name array and other window-related
* variables for each platform.
g_wndows = ""                  && array of window names
m.g_nwindows = 0               && number of windows
m.g_lastwindow = ""            && name of last window generated for this platform
RETURN

*!*****************************************************************************
*!
*!       Function: NEWSCHEMES
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION newschemes
*)
*) NEWSCHEMES - Initialize the color schemes for each screen/platform
*)
m.g_defasch  = 0
m.g_defasch2 = 0
RETURN

*!*****************************************************************************
*!
*!       Function: NEWDBFS
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION newdbfs
*)
*) NEWDBFS - Initialize the databases name array for each platform
*)
m.g_dbfs = ""
RETURN

*!*****************************************************************************
*!
*!      Procedure: NEWREADCLAUSES
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE newreadclauses
*)
*) NEWREADCLAUSES - Initialize the variables that control which READ and WINDOW clauses are
*)                    emitted.
*)
m.g_validtype  = ""
m.g_validname  = ""
m.g_whentype   = ""
m.g_whenname   = ""
m.g_actitype   = ""
m.g_actiname   = ""
m.g_deattype   = ""
m.g_deatname   = ""
m.g_showtype   = ""
m.g_showname   = ""
m.g_showexpr   = ""
RETURN

*!*****************************************************************************
*!
*!      Procedure: NEWDIRECTIVES
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE newdirectives
m.g_windclauses= ""            && #WCLAUSES directive
m.g_rddir      = .F.           && Is there a #READCLAUSES directive?
m.g_rddirno    = 0             && Number of 1st screen with #READ directive
RETURN

*!*****************************************************************************
*!
*!       Function: GETPLATFORM
*!
*!      Called by: PREPSCREENS()      (function  in GENSCRN.PRG)
*!
*!          Calls: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION getplatform
*)
*) GETPLATFORM - Find which Platform we are supposed to generate for.  If we are trying to
*)               generate for Windows, but there are no windows records in the SCX, use
*)               this function to determine which records to use.
*)
IF m.g_genvers = 'WINDOWS' OR m.g_genvers = 'MAC'
   LOCATE FOR platform = IIF(m.g_genvers = 'WINDOWS', 'MAC', 'WINDOWS')
   IF FOUND()
      RETURN platform
   ELSE
      LOCATE FOR platform = 'DOS'
      IF FOUND()
         RETURN 'DOS'
      ELSE
         LOCATE FOR platform = 'UNIX'
         IF FOUND()
            RETURN 'UNIX'
         ELSE
            DO errorhandler WITH "Screen "+m.dbalias+" is invalid",LINENO(),;
               c_error_2
         ENDIF
      ENDIF
   ENDIF
ELSE
   LOCATE FOR platform = IIF(m.g_genvers = 'DOS', 'UNIX', 'DOS')
   IF FOUND()
      RETURN platform
   ELSE
      LOCATE FOR platform = 'WINDOWS'
      IF FOUND()
         RETURN 'DOS'
      ELSE
         LOCATE FOR platform = 'MAC'
         IF FOUND()
            RETURN 'UNIX'
         ELSE
            DO errorhandler WITH "Screen "+m.dbalias+" is invalid",LINENO(),;
               c_error_2
         ENDIF
      ENDIF
   ENDIF
ENDIF
RETURN ""


*!*****************************************************************************
*!
*!      Procedure: PREPWNAMES
*!
*!      Called by: PREPSCREENS()      (function  in GENSCRN.PRG)
*!
*!          Calls: GETPLATNUM()       (function  in GENSCRN.PRG)
*!               : SKIPWHITESPACE()   (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE prepwnames
*)
*) PREPWNAMES - Store #WNAME directive strings.  They must be in the setup snippet.
*)
PARAMETER m.scrnno
PRIVATE m.lineno, m.textline
m.lineno = ATCLINE('#WNAM',setupcode)
IF m.lineno > 0
   m.textline = MLINE(setupcode,m.lineno)
   DO killcr WITH m.textline
   IF g_screens[m.scrnno,6]   && DOS 2.0 screen
      IF ATC('#WNAM',m.textline) = 1
         g_wnames[m.scrnno, getplatnum("DOS")] = skipwhitespace(m.textline)
      ENDIF
   ELSE
      IF ATC('#WNAM',m.textline) = 1
         g_wnames[m.scrnno, getplatnum(platform)] = skipwhitespace(m.textline)
      ENDIF
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: SCREENUSED
*!
*!      Called by: PREPSCREENS()      (function  in GENSCRN.PRG)
*!
*!          Calls: ILLEGALNAME()      (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION screenused
*)
*) SCREENUSED - Check to see if screen file already opened.
*)
PARAMETER m.dbalias, m.fulldbname
m.dbalias = LEFT(m.dbalias,c_aliaslen)
IF NOT USED(m.dbalias)
   IF illegalname(m.dbalias)
      g_screens[m.g_nscreens,5] = "S"+SUBSTR(LOWER(SYS(3)),2,8)
   ELSE
      g_screens[m.g_nscreens,5] = m.dbalias
   ENDIF
   RETURN .F.
ENDIF
SELECT (m.dbalias)
IF RAT(".SCX",DBF())<>0 AND m.fulldbname=DBF()
   g_screens[m.g_nscreens,5] = m.dbalias
   RETURN .T.
ELSE
   g_screens[m.g_nscreens,5] = "S"+SUBSTR(LOWER(SYS(3)),2,8)
ENDIF
RETURN .F.

*!*****************************************************************************
*!
*!       Function: ILLEGALNAME
*!
*!      Called by: SCREENUSED()       (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION illegalname
*)
*) ILLEGALNAME - Check if default alias will be used when this
*)               database is USEd. (i.e., 1st letter is not A-Z,
*)				a-z or '_', or any one of ramaining letters is not
*)				alphanumeric.)
*)
PARAMETER m.dname
PRIVATE m.start, m.aschar, m.length
m.length = LEN(m.dname)
m.start  = 0
IF m.length = 1
   *
   * If length 1, then check if default alias can be used,
   * i.e., name is different than A-J and a-j.
   *
   m.aschar = ASC(m.dname)
   IF (m.aschar >= 65 AND m.aschar <= 74) OR ;
         (m.aschar >= 97 AND m.aschar <= 106)
      RETURN .T.
   ENDIF
ENDIF
DO WHILE m.start < m.length
   m.start  = m.start + 1
   m.aschar = ASC(SUBSTR(m.dname, m.start, 1))
   IF m.start<>1 AND (m.aschar >= 48 AND m.aschar <= 57)
      LOOP
   ENDIF
   IF NOT ((m.aschar >= 65 AND m.aschar <= 90) OR ;
         (m.aschar >= 97 AND m.aschar <= 122) OR m.aschar = 95)
      RETURN .T.
   ENDIF
ENDDO
RETURN .F.

*!*****************************************************************************
*!
*!       Function: OPENPROJDBF
*!
*!      Called by: GENSCRN.PRG
*!
*!          Calls: NOTEAREA           (procedure in GENSCRN.PRG)
*!               : STRIPEXT()         (function  in GENSCRN.PRG)
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : REFRESHPREFS       (procedure in GENSCRN.PRG)
*!               : GETWITHLIST        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION openprojdbf
*)
*) OPENPROJDBF - Prepare Project dbf for processing.
*)
*) Description:
*) Check to see if projdbf has an appropriate number of fields.
*) Find the screen set record.
*) Extract information from the SETID record.
*)
PARAMETER m.projdbf, m.recno

SELECT 0
IF USED("projdbf")
   m.g_projalias = "P"+SUBSTR(LOWER(SYS(3)),2,8)
ELSE
   m.g_projalias = "projdbf"
ENDIF
USE (m.projdbf) ALIAS (m.g_projalias)
DO notearea
IF versnum() > "2.5"
   SET NOCPTRANS TO devinfo, arranged, symbols, object
ENDIF
m.g_errlog = stripext(m.projdbf)
m.g_projpath = SUBSTR(m.projdbf,1,RAT("\",m.projdbf))

IF FCOUNT() <> c_pjxflds
   IF FCOUNT() = c_pjx20flds
      DO errorhandler WITH "Invalid 2.0 project file passed to GenScrn.",;
         LINENO(), c_error_2
   ELSE
      DO errorhandler WITH "Generator out of date.",;
         LINENO(), c_error_2
   ENDIF
   RETURN .F.
ENDIF

DO refreshprefs
GOTO m.recno
m.g_keyno        = setid
m.g_outfile      = ALLTRIM(SUBSTR(outfile,1,AT(c_null,outfile)-1))
m.g_outfile      = FULLPATH(m.g_outfile, m.g_projpath)
IF RIGHT(m.g_outfile,1) = ":"
   m.g_outfile = m.g_outfile + justfname(outfile)
ENDIF
m.g_openfiles    = openfiles
m.g_closefiles   = closefiles
m.g_defwin       = defwinds
m.g_relwin       = relwinds
m.g_readcycle    = readcycle
m.g_readlock     = NOLOCK
m.g_readmodal    = MODAL
m.g_readborder   = nologo
m.g_multreads    = multreads
m.g_allplatforms = !savecode
DO getwithlist
RETURN

*!*****************************************************************************
*!
*!      Procedure: GETWITHLIST
*!
*!      Called by: OPENPROJDBF()      (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE getwithlist
*)
*) GETWITHLIST - Construct the list for READ level WITH clause.  The
*) window list is in the project file, stored as CR separated strings
*) possibly terminated with a NULL.
*)

m.g_withlist = assocwinds
* Drop any nulls
m.g_withlist = ALLTRIM(CHRTRAN(m.g_withlist, CHR(0), ""))
* Translate any CRs/LFs into commas
m.g_withlist = CHRTRAN(m.g_withlist, c_cret+c_lf, ",,")
* Sanity check for duplicate commas
m.g_withlist = STRTRAN(m.g_withlist, ",,", ",")   && shouldn't be necessary
IF RIGHT(m.g_withlist,1) = ","
   m.g_withlist = LEFT(m.g_withlist, LEN(m.g_withlist) - 1)
ENDIF
IF LEFT(m.g_withlist,1) = ","
   m.g_withlist = RIGHT(m.g_withlist, LEN(m.g_withlist) - 1)
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: REFRESHPREFS
*!
*!      Called by: OPENPROJDBF()      (function  in GENSCRN.PRG)
*!
*!          Calls: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : SUBDEVINFO()       (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE refreshprefs
*)
*) REFRESHPREFS - Refresh Documentation and Developer preferences.
*)
*) Description:
*) Get the newest preferences for documentation style and developer
*) data from the HEADER record.
*)
PRIVATE m.start
LOCATE FOR TYPE = "H"
IF NOT FOUND ()
   DO errorhandler WITH "Missing header record in "+m.projdbf,;
      LINENO(), c_error_2
   RETURN
ENDIF
IF _MAC
	* On the Mac, the home directory will be stored in homedir unless
	* it is in a non-DOS format (e.g., contains spaces), in which case
	* it is stored in the assocwinds field.  This subterfuge is to
	* maintain cross platform compatibility of the projects.
	IF !EMPTY(assocwinds)
		m.g_homedir = ALLTRIM(SUBSTR(assocwinds,1,AT(c_null,assocwinds)-1))
	ELSE
		m.g_homedir = ALLTRIM(SUBSTR(homedir,1,AT(c_null,homedir)-1))
		IF RIGHT(m.g_homedir,1) <> "\"
   		m.g_homedir = m.g_homedir + "\"
		ENDIF
	ENDIF
	* There is a potential problem with the setting of the home directory on the
	* Mac when we generate a screen that isn't inside a true project. The home directory
	* will be set to the temporary file directory, which is not where we want to look for
	* relative paths. Adjust it here.
	IF UPPER(ALLTRIM(justpath(m.g_homedir))) == UPPER(sys(2023)) AND alldigits(juststem(m.g_homedir))
	    SKIP
	    m.g_target = name
	    IF AT(CHR(0), name) > 0
	    	m.g_target = ALLTRIM(justpath(SUBSTR(name,1,AT(c_null,name)-1)))
	    ENDIF
	    m.g_homedir = FULLPATH(m.g_target, m.g_homedir)
   		IF RIGHT(m.g_homedir,1) <> "\"
   			m.g_homedir = m.g_homedir + "\"
		ENDIF
		SKIP -1
	ENDIF
ELSE
	m.g_homedir = ALLTRIM(SUBSTR(homedir,1,AT(c_null,homedir)-1))
	IF RIGHT(m.g_homedir,1) <> "\"
   	m.g_homedir = m.g_homedir + "\"
	ENDIF
ENDIF

m.start = 1
m.g_devauthor = subdevinfo(m.start,c_authorlen,m.g_devauthor)

m.start = m.start + c_authorlen + 1
m.g_devcompany = subdevinfo(m.start,c_complen,m.g_devcompany)

m.start = m.start + c_complen + 1
m.g_devaddress = subdevinfo(m.start,c_addrlen,m.g_devaddress)

m.start = m.start + c_addrlen + 1
m.g_devcity = subdevinfo(m.start,c_citylen,m.g_devcity)

m.start = m.start + c_citylen + 1
m.g_devstate = subdevinfo(m.start,c_statlen,m.g_devstate)

m.start = m.start + c_statlen + 1
m.g_devzip = subdevinfo(m.start,c_ziplen,m.g_devzip)

m.start = m.start + c_ziplen + 1
m.g_devctry = subdevinfo(m.start,c_countrylen,m.g_devctry)

IF cmntstyle = 0
   m.g_corn1 = "Ö"
   m.g_corn2 = "·"
   m.g_corn3 = "Ó"
   m.g_corn4 = "½"
   m.g_corn5 = "Ç"
   m.g_corn6 = "¶"
   m.g_horiz = "Ä"
   m.g_verti1 = "º"
   m.g_verti2= "º"
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: ALLDIGITS
*!
*!*****************************************************************************
FUNCTION alldigits
PARAMETER m.strg
PRIVATE m.i, m.thechar, m.retval
m.retval = .T.
FOR m.i = 1 TO LEN(m.strg)
   m.thechar = SUBSTR(m.strg, m.i , 1)
   IF m.thechar < '0' OR m.thechar > '9'
      m.retval = .F.
   ENDIF
ENDFOR
RETURN m.retval


*!*****************************************************************************
*!
*!       Function: SUBDEVINFO
*!
*!      Called by: REFRESHPREFS       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION subdevinfo
*)
*) SUBDEVINFO - Extract strings from the DEVINFO memo field.
*)
PARAMETER m.start, m.stop, m.default
PRIVATE m.string
m.string = SUBSTR(devinfo, m.start, m.stop+1)
m.string = SUBSTR(m.string, 1, AT(c_null,m.string)-1)
RETURN IIF(EMPTY(m.string), m.default, m.string)

**
** High Level Controlling Structures in Format file generation.
**

*!*****************************************************************************
*!
*!      Procedure: BUILD
*!
*!      Called by: GENSCRN.PRG
*!
*!          Calls: BUILDENABLE        (procedure in GENSCRN.PRG)
*!               : ACTTHERM           (procedure in GENSCRN.PRG)
*!               : UPDTHERM           (procedure in GENSCRN.PRG)
*!               : DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!               : COMBINE            (procedure in GENSCRN.PRG)
*!               : BUILDDISABLE       (procedure in GENSCRN.PRG)
*!               : DEACTTHERMO        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE BUILD
*)
*) BUILD - Controlling procedure for building of a format file.
*)
*) Description:
*) This procedure is a controlling procedure for the process of
*) generating a screen file.  It enables building, activates the
*) thermometer, calls BUILDCTRL and combines two output files,
*) and finally disables building.
*) This procedure also makes calls to UPDTHERM to
*) update the thermometer display.
*)

DO buildenable
DO acttherm WITH "Generating Screen Code..."
DO updtherm WITH c_therm1 * m.g_numplatforms     && 5%

DO dispatchbuild

DO updtherm WITH c_therm7 * m.g_numplatforms     && 95%
DO combine
DO updtherm WITH 100 * m.g_numplatforms   && force thermometer to complete
DO builddisable

DO deactthermo
RETURN

*!*****************************************************************************
*!
*!      Procedure: DISPATCHBUILD
*!
*!      Called by: BUILD              (procedure in GENSCRN.PRG)
*!
*!          Calls: COUNTPLATFORMS     (procedure in GENSCRN.PRG)
*!               : PREPPARAMS         (procedure in GENSCRN.PRG)
*!               : MULTIPLAT()        (function  in GENSCRN.PRG)
*!               : SCANPROC           (procedure in GENSCRN.PRG)
*!               : GENPARAMETER       (procedure in GENSCRN.PRG)
*!               : LOOKUPPLATFORM     (procedure in GENSCRN.PRG)
*!               : VERSIONCAP()       (function  in GENSCRN.PRG)
*!               : PUTMSG             (procedure in GENSCRN.PRG)
*!               : PREPSCREENS()      (function  in GENSCRN.PRG)
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : NEWWINDOWS()       (function  in GENSCRN.PRG)
*!               : NEWDBFS()          (function  in GENSCRN.PRG)
*!               : NEWREADCLAUSES     (procedure in GENSCRN.PRG)
*!               : PUSHINDENT         (procedure in GENSCRN.PRG)
*!               : BUILDCTRL          (procedure in GENSCRN.PRG)
*!               : POPINDENT          (procedure in GENSCRN.PRG)
*!               : UPDTHERM           (procedure in GENSCRN.PRG)
*!               : GENPROCEDURES      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE dispatchbuild
*)
*) DISPATCHBUILD - Determines which platforms are to be generated and
*)                  calls BUILDCTRL for each one.
*)
PRIVATE m.i, m.thisplat, m.j
m.g_numplatforms = countplatforms()

DO prepparams

_TEXT = m.g_orghandle
_PRETEXT = ""

DO CASE
CASE multiplat()
   * Emit code for all common platforms in the screen set and put CASE statements
   * around the code for each one.  The g_platforms array contains the list of
   * platforms to generate for.

   * If generating for multiple platforms, scan all cleanup snippets and assemble an
   * array of unique procedure names.  This process is designed to handle procedure name
   * collisions across platforms.
   DO scanproc

   DO header   && main heading at top of program

   * Special case when there are multiple platforms being sent to the
   * same SPR.  Since the SPR can only have a single parameter statement,
   * and since it has to appear before the CASE _platform code, put it
   * here.
   DO genparameter

   m.thisplat = "X"   && placeholder value
   m.i = 1
   DO WHILE !EMPTY(m.thisplat)
      m.thisplat = lookupplatform(m.i)
      IF !EMPTY(m.thisplat)
         DO putmsg WITH "Generating code for "+versioncap(m.thisplat, m.g_dualoutput)

         IF m.i = 1
            \DO CASE
         ELSE
            \
         ENDIF
         DO gencasestmt WITH m.thisplat
         \

         * Switch the platform to generate for
         m.g_genvers = m.thisplat

         * Update screen array entries for the new platform, unless it's the currently
         * executing platform, in which case we did this just above.
         IF !(m.thisplat == m.g_thisvers)
            * Start with a fresh set of screens.  Prepscreens() fills in the details.
            g_nscreens = 0
            IF !prepscreens(m.thisplat)
               DO errorhandler WITH "Error initializing screens for ";
                  +PROPER(m.thisplat)+".", LINENO(), c_error_3
               CANCEL
            ENDIF
            DO newwindows      && initialize the window array
            DO newdbfs         && initialize the DBF name array
            DO newreadclauses  && initialize the read clause variables
            DO newdirectives   && initialize the directives that change from platform to platform
            DO newschemes      && initialize the scheme variables
         ENDIF

         DO pushindent
         DO buildctrl WITH m.thisplat, m.i, .F.
         DO popindent
      ENDIF
      m.i = m.i + 1
   ENDDO
   \
   \ENDCASE
   \
   _TEXT = m.g_tmphandle
   m.thispretext = _PRETEXT
   _PRETEXT = ""
   DO updtherm WITH c_therm6 * m.g_numplatforms  && 70%
   DO genprocedures
   _TEXT = m.g_orghandle
   _PRETEXT = m.thispretext

OTHERWISE                         && just outputing one platform.
   * If we are generating for a platform other than the one we are running
   * on, run through prepscreens again to assign the right platform
   * name to each of these screens.
   IF (_DOS AND g_platforms[1] <> "DOS") ;
         OR (_WINDOWS AND g_platforms[1] <> "WINDOWS") ;
         OR (_MAC AND g_platforms[1] <> "MAC") ;
         OR (_UNIX AND g_platforms[1] <> "UNIX")
      g_nscreens = 0
      IF !prepscreens(g_platforms[1])
         DO errorhandler WITH "Error initializing screens for ";
            +PROPER(m.thisplat)+".", LINENO(), c_error_3
         CANCEL
      ENDIF
   ENDIF

   m.g_allplatforms = .F.
   m.g_numplatforms = 1
   m.g_genvers      = g_platforms[1]

   DO newwindows      && Initialize the array of window names
   DO newdbfs         && Initialize the array of DBF names
   DO newreadclauses  && Initialize the read clause variables for each platform
   DO newdirectives   && Initialize the directives that change from platform to platform
   DO newschemes      && initialize the scheme variables

   DO header
   DO buildctrl WITH g_platforms[1], 1, .T.

   DO updtherm WITH  c_therm6   && 70%
   DO genprocedures
ENDCASE
RETURN


**
** Code Associated With Building of the Control Program.
**
*!*****************************************************************************
*!
*!      Procedure: BUILDCTRL
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!          Calls: HEADER             (procedure in GENSCRN.PRG)
*!               : GENPARAMETER       (procedure in GENSCRN.PRG)
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : GENSETENVIRON      (procedure in GENSCRN.PRG)
*!               : GENOPENDBFS        (procedure in GENSCRN.PRG)
*!               : UPDTHERM           (procedure in GENSCRN.PRG)
*!               : DEFWINDOWS         (procedure in GENSCRN.PRG)
*!               : GENSECT2           (procedure in GENSCRN.PRG)
*!               : DEFPOPUPS          (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!               : GENCLNENVIRON      (procedure in GENSCRN.PRG)
*!               : GENCLEANUP         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE buildctrl
*)
*) BUILDCTRL - Generate Format control file.
*)
*) Description:
*) Buildctrl controls the generation process.  It invokes procedures
*) which build the output program from a set of screens.
*)
PARAMETERS m.pltfrm, m.pnum, m.putparam, m.dbalias
PRIVATE m.i

IF m.putparam
   * Bracketed code is handled elsewhere.  We are only emitting the parameter
   * from this platform.  Go get it again to make sure we have the right one.
   * At this point, g_parameter could contain the parameter from any platform.

   * Open the database for the first screen since it's the only one we can generate
   * a parameter statement for.
   m.dbalias = g_screens[1,5]
   SELECT (m.dbalias)
   DO seekheader WITH 1

   m.g_parameter = getparam("setupcode")

   DO genparameter
ENDIF
DO gensect1						        && SECTION 1 setup code
DO gensetenviron				        && environment setup code
IF m.g_openfiles
   DO genopendbfs				        && USE ... INDEX ... statements
ENDIF
DO updtherm WITH thermadj(m.pnum,c_therm2,c_therm5)    && and SET RELATIONS

DO defwindows			 		        && window definitions
DO gensect2						        && SECTION 2 setup code
DO defpopups					        && lists
DO updtherm WITH thermadj(m.pnum,c_therm3,c_therm5)

DO buildfmt WITH m.pnum            && @ ... SAY/GET statements

DO updtherm WITH thermadj(m.pnum,c_therm4,c_therm5)
IF m.g_windows AND m.g_relwin AND !m.g_noread
   * If the READ is omitted, don't produce the code to release the window.
   FOR m.i = 1 TO m.g_nwindows
      \RELEASE WINDOW <<g_wndows[m.i,1]>>
   ENDFOR
ENDIF

IF m.g_moddesktop AND m.g_relwin AND INLIST(m.g_genvers,"WINDOWS","MAC")
   \MODIFY WINDOW SCREEN
ENDIF

DO genclnenviron			            && environment cleanup code
DO updtherm WITH thermadj(m.pnum,c_therm5,c_therm5)
DO gencleanup                       && cleanup code, but not procedures/functions

*!*****************************************************************************
*!
*!      Procedure: GENSETENVIRON
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gensetenviron
*)
*) GENSETENVIRON - Generate environment code for the .SPR
*)
IF !m.g_noreadplain
   \
   \#REGION 0
   \REGIONAL m.currarea, m.talkstat, m.compstat
   \
   \IF SET("TALK") = "ON"
   \	SET TALK OFF
   \	m.talkstat = "ON"
   \ELSE
   \	m.talkstat = "OFF"
   \ENDIF
   \m.compstat = SET("COMPATIBLE")
   \SET COMPATIBLE FOXPLUS

   IF INLIST(m.g_genvers,"WINDOWS","MAC")
      \
      \m.rborder = SET("READBORDER")
      \SET READBORDER <<IIF(m.g_readborder, "ON", "OFF")>>
   ENDIF
ENDIF

IF m.g_closefiles
   \
   \m.currarea = SELECT()
   \
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENCLNENVIRON
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: GENCLOSEDBFS       (procedure in GENSCRN.PRG)
*!               : RELPOPUPS          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genclnenviron
*)
*) GENCLNENVIRON - Generate environment code for the .SPR
*)
IF m.g_closefiles
   DO genclosedbfs
ENDIF
IF m.g_somepops
   DO relpopups
ENDIF
IF !m.g_noreadplain
   \
   \#REGION 0
   IF INLIST(m.g_genvers,"WINDOWS","MAC")
      \
      \SET READBORDER &rborder
      \
   ENDIF
   \IF m.talkstat = "ON"
   \	SET TALK ON
   \ENDIF
   \IF m.compstat = "ON"
   \	SET COMPATIBLE ON
   \ENDIF
   \
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENCLEANUP
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: MULTIPLAT()        (function  in GENSCRN.PRG)
*!               : VERSIONCAP()       (function  in GENSCRN.PRG)
*!               : PUTMSG             (procedure in GENSCRN.PRG)
*!               : SEEKHEADER         (procedure in GENSCRN.PRG)
*!               : GETFIRSTPROC()     (function  in GENSCRN.PRG)
*!               : COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!               : GETPLATNAME()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gencleanup
*)
*) GENCLEANUP - Generate Cleanup Code.
*)
PRIVATE m.i, m.dbalias, m.msg

IF m.g_graphic
   m.msg = 'Generating Cleanup Code'
   IF multiplat()
      m.msg = m.msg + " for "+versioncap(m.g_genvers, m.g_dualoutput)
   ENDIF
   DO putmsg WITH  m.msg
ENDIF

* Generate the actual cleanup code--the code that precedes procedures
* and function declarations.
FOR m.i = 1 TO m.g_nscreens
   m.g_screen = m.i
   m.dbalias = g_screens[m.i,5]
   SELECT (m.dbalias)

   DO seekheader WITH m.i
   IF EMPTY (proccode)
      g_firstproc[m.i] = 0
      LOOP
   ENDIF

   * Find the line number where the first procedure or function
   * declaration occurs
   g_firstproc[m.i] = getfirstproc("PROCCODE")

   IF g_firstproc[m.i] <> 1
      * Either there aren't any procedures/functions, or they
      * are below the actual cleanup code.  Emit the cleanup code.
      DO commentblock WITH g_screens[m.i,1], " Cleanup Code"
      \#REGION <<INT(m.i)>>
      DO writecode WITH proccode, getplatname(m.i), c_fromone, g_firstproc[m.i], m.i
   ENDIF
ENDFOR
m.g_screen = 0

RETURN

*!*****************************************************************************
*!
*!      Procedure: GENPROCEDURES
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!          Calls: PUTMSG             (procedure in GENSCRN.PRG)
*!               : SEEKHEADER         (procedure in GENSCRN.PRG)
*!               : PUTPROCHEAD        (procedure in GENSCRN.PRG)
*!               : GETPLATNAME()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!               : MULTIPLAT()        (function  in GENSCRN.PRG)
*!               : ISGENPLAT()        (function  in GENSCRN.PRG)
*!               : EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genprocedures
*)
*) GENPROCEDURES - Generate Procedures and Functions from cleanup code.
*)
PRIVATE m.i, m.dbalias
m.msg = 'Generating Procedures and Functions'
DO putmsg WITH m.msg

* Go back through each of the screens and output any procedures and
* functions that are in the cleanup snippet.
FOR m.i = 1 TO m.g_nscreens
   m.g_screen = m.i
   m.g_isfirstproc = .T.  && reset this for each screen
   m.dbalias = g_screens[m.i,5]
   SELECT (m.dbalias)
   DO seekheader WITH m.i

   DO CASE
   CASE g_screens[m.i,6]    && DOS 2.0 screen
      IF g_firstproc[m.i] > 0
         DO putprochead WITH m.i, g_screens[m.i,1]
         DO writecode WITH proccode, getplatname(m.i), g_firstproc[m.i], c_untilend, m.i
      ENDIF
   CASE multiplat()
      * Multiple 2.5 platforms
      IF m.g_procsmatch   && all cleanup snippets in the file are the same
         * Get all the screen/platform headers from this screen file
         IF g_firstproc[m.i] > 0
            DO putprochead WITH m.i, g_screens[m.i,1]
            DO writecode WITH proccode, getplatname(m.i), g_firstproc[m.i], c_untilend, m.i
         ENDIF
      ELSE
         * The are some differences.  Look for procedure name collisions among the
         * cleanup snippets in the platforms we are generating.
         SCAN FOR objtype = c_otscreen AND isgenplat(platform)
            IF EMPTY(proccode)
               LOOP
            ENDIF
            DO putprochead WITH m.i, g_screens[m.i,1]
            DO extractprocs WITH m.i
         ENDSCAN
      ENDIF
   OTHERWISE  && just generating one 2.5 platform
      IF g_firstproc[m.i] > 0
         DO putprochead WITH m.i, g_screens[m.i,1]
         DO writecode WITH proccode, getplatname(m.i), g_firstproc[m.i], c_untilend, m.i
      ENDIF
   ENDCASE
ENDFOR
m.g_screen = 0
RETURN

*!*****************************************************************************
*!
*!       Function: PROCSMATCH
*!
*!      Called by: SCANPROC           (procedure in GENSCRN.PRG)
*!
*!          Calls: ISGENPLAT()        (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION procsmatch
*)
*) PROCSMATCH - Are the CRCs for the cleanup snippets the same for all platforms in the
*)                current screen that are being generated?
*)
PRIVATE m.crccode, m.thiscode, m.in_rec

m.in_rec = IIF(!EOF(),RECNO(),1)
m.crccode = "0"
* Get the headers for all the platforms we are generating
SCAN FOR objtype = c_otscreen AND isgenplat(platform)
   m.thiscode = ALLTRIM(SYS(2007,proccode))
   DO CASE
   CASE m.crccode = "0"
      m.crccode = m.thiscode
   CASE m.thiscode <> m.crccode AND m.crccode <> "0"
      RETURN .F.
   ENDCASE
ENDSCAN
GOTO m.in_rec
RETURN .T.

*!*****************************************************************************
*!
*!       Function: ISGENPLAT
*!
*!      Called by: GENPROCEDURES      (procedure in GENSCRN.PRG)
*!               : PROCSMATCH()       (function  in GENSCRN.PRG)
*!               : SCANPROC           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION isgenplat
*)
*) ISGENPLAT - Is this platform one of the ones being generated?
*)
PARAMETER m.platname
RETURN IIF(ASCAN(g_platforms,ALLTRIM(UPPER(m.platname))) > 0, .T. , .F. )

*!*****************************************************************************
*!
*!      Procedure: PUTPROCHEAD
*!
*!      Called by: GENPROCEDURES      (procedure in GENSCRN.PRG)
*!
*!          Calls: COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE putprochead
*)
*) PUTPROCHEAD - Emit the procedure and function heading if we haven't done
*)
PARAMETER m.scrnno, m.filname
IF m.g_isfirstproc
   \
   DO commentblock WITH g_screens[m.scrnno,1], " Supporting Procedures and Functions "
   \#REGION <<INT(m.scrnno)>>
   m.g_isfirstproc = .F.
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: EXTRACTPROCS
*!
*!      Called by: GENPROCEDURES      (procedure in GENSCRN.PRG)
*!
*!          Calls: WORDNUM()          (function  in GENSCRN.PRG)
*!               : MATCH()            (function  in GENSCRN.PRG)
*!               : GETPROCNUM()       (function  in GENSCRN.PRG)
*!               : EMITPROC           (procedure in GENSCRN.PRG)
*!               : HASCONFLICT()      (function  in GENSCRN.PRG)
*!               : PUTMSG             (procedure in GENSCRN.PRG)
*!               : UPDTHERM           (procedure in GENSCRN.PRG)
*!               : PROCCOMMENTBLOCK   (procedure in GENSCRN.PRG)
*!               : EMITBRACKET        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE extractprocs
*)
*) EXTRACTPROCS - Output the procedures for the current platform in the current screen
*)
* We only get here if we are emitting for multiple platforms and the cleanup snippets
* for all platforms are not identical.  We are positioned on a screen header record for
* the g_genvers platform.
PARAMETER m.scrnno

PRIVATE m.hascontin, m.iscontin, m.sniplen, m.i, m.thisline, m.pnum, m.word1, m.word2

_MLINE = 0
m.sniplen   = LEN(proccode)
m.numlines  = MEMLINES(proccode)
m.hascontin = .F.
DO WHILE _MLINE < m.sniplen
   m.thisline  = UPPER(ALLTRIM(MLINE(proccode,1, _MLINE)))
   DO killcr WITH m.thisline
   m.iscontin  = m.hascontin
   m.hascontin = RIGHT(m.thisline,1) = ';'
   IF LEFT(m.thisline,1) $ "PF" AND !m.iscontin
      m.word1 = wordnum(m.thisline, 1)
      IF match(m.word1,"PROCEDURE") OR match(m.word1,"FUNCTION")
         m.word2 = wordnum(m.thisline,2)
         * Does this procedure have a name conflict?
         m.pnum = getprocnum(m.word2)
         IF pnum > 0
            DO CASE
            CASE g_procs[m.pnum,C_MAXPLATFORMS+2]
               * This one has already been generated.  Skip past it now.
               DO emitproc WITH .F., m.thisline, m.sniplen, m.scrnno
               LOOP
            CASE hasconflict(pnum)
               * Name collision detected.  Output bracketed code for all platforms
               DO putmsg WITH "Generating code for procedure/function ";
                  +LOWER(g_procs[m.pnum,1])
               DO updtherm WITH thermadj(m.pnum,c_therm6 + (c_therm7-c_therm6)/m.g_procnames,c_therm7)
               DO proccommentblock WITH g_screens[m.scrnno,1], " "+PROPER(word1);
                  +" " + g_procs[m.pnum,1]
               DO emitbracket WITH m.pnum, m.scrnno
            OTHERWISE
               * This procedure has no name collision and has not been emitted yet.
               DO putmsg WITH "Generating code for procedure/function ";
                  +LOWER(g_procs[m.pnum,1])
               DO updtherm WITH thermadj(m.pnum,c_therm6 + (c_therm7-c_therm6)/m.g_procnames,c_therm7)
               *DO updtherm WITH (c_therm6 + ((c_therm7-c_therm6)/g_procnames) * m.pnum) * m.g_numplatforms
               DO proccommentblock WITH g_screens[m.scrnno,1], " "+PROPER(word1);
                  +" " + g_procs[m.pnum,1]
               DO emitproc WITH .T., m.thisline, m.sniplen, m.scrnno
            ENDCASE
            g_procs[pnum,C_MAXPLATFORMS+2] = .T.
         ENDIF
      ENDIF
   ENDIF
ENDDO
RETURN

*!*****************************************************************************
*!
*!      Procedure: EMITPROC
*!
*!      Called by: EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!
*!          Calls: WRITELINE          (procedure in GENSCRN.PRG)
*!               : WORDNUM()          (function  in GENSCRN.PRG)
*!               : MATCH()            (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE emitproc
*)
*) EMITPROC - Scan through the next procedure/function in the current cleanup snippet.
*)            If dowrite is TRUE, emit the code as we go.  Otherwise, just skip over it
*)            and advance _MLINE.
*)
* We are positioned on the PROCEDURE or FUNCTION line now and there isn't a name
* conflict.
PARAMETER m.dowrite, m.thisline, m.sniplen, m.scrnno
PRIVATE m.word1, m.word2, m.line, m.upline, m.done, m.lastmline, ;
   m.iscontin, m.hascontin, m.platnum

m.hascontin = .F.
m.done = .F.

* Write the PROCEDURE/FUNCTION statement
m.upline = UPPER(ALLTRIM(CHRTRAN(m.thisline,chr(9),' ')))

IF g_screens[m.scrnno,6]   && DOS 2.0 screen
   m.platnum = getplatnum("DOS")
ELSE
   m.platnum = getplatnum(m.g_genvers)
ENDIF

IF m.dowrite    && actually emit the procedure?
   DO writeline WITH m.thisline, m.g_genvers, m.platnum, m.upline, m.scrnno
ENDIF

* Write the body of the procedure
DO WHILE !m.done AND _MLINE < m.sniplen
   m.lastmline = _MLINE          && note where this line started

   m.line = MLINE(proccode,1, _MLINE)
   DO killcr WITH m.line
   m.upline = UPPER(ALLTRIM(CHRTRAN(m.line,chr(9),' ')))

   m.iscontin = m.hascontin
   m.hascontin = RIGHT(m.upline,1) = ';'
   IF LEFT(m.upline,1) $ "PF" AND !m.iscontin
      m.word1 = wordnum(m.upline, 1)
      IF match(m.word1,"PROCEDURE") OR match(m.word1,"FUNCTION")
         done = .T.
         _MLINE = m.lastmline    && drop back one line and stop writing
         LOOP
      ENDIF
   ENDIF

   IF m.dowrite    && actually emit the procedure?
      DO writeline WITH m.line, m.g_genvers, m.platnum, m.upline, m.scrnno
   ENDIF

ENDDO
RETURN

*!*****************************************************************************
*!
*!      Procedure: EMITBRACKET
*!
*!      Called by: EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!
*!          Calls: PUSHINDENT         (procedure in GENSCRN.PRG)
*!               : PUTPROC            (procedure in GENSCRN.PRG)
*!               : POPINDENT          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE emitbracket
*)
*) EMITBRACKET - Emit DO CASE/CASE _DOS brackets and call putproc to emit code for this procedure
*)
PARAMETER m.pnum, m.scrnno
PRIVATE m.word1, m.word2, m.line, m.upline, m.done, m.lastmline, ;
   m.iscontin, m.hascontin, m.i
m.hascontin = .F.
m.done = .F.
\
\PROCEDURE <<g_procs[m.pnum,1]>>
IF !EMPTY(g_procs[m.pnum,C_MAXPLATFORMS+3])
   \PARAMETERS <<g_procs[m.pnum,C_MAXPLATFORMS+3]>>
ENDIF
\DO CASE

* Peek ahead and get the parameter statement
FOR m.platnum = 1 TO c_maxplatforms
   IF g_procs[m.pnum,m.platnum+1] < 0
      * There was no procedure for this platform
      LOOP
   ENDIF
   \CASE <<"_"+g_platlist[m.platnum]>>
   DO pushindent
   DO putproc WITH m.platnum, m.pnum, m.scrnno
   DO popindent
ENDFOR
\ENDCASE
RETURN

*!*****************************************************************************
*!
*!      Procedure: PUTPROC
*!
*!      Called by: EMITBRACKET        (procedure in GENSCRN.PRG)
*!
*!          Calls: WORDNUM()          (function  in GENSCRN.PRG)
*!               : MATCH()            (function  in GENSCRN.PRG)
*!               : WRITELINE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE putproc
*)
*) PUTPROC - Write actual code for procedure procnum in platform platnum
*)
PARAMETER m.platnum, m.procnum, m.scrnno
PRIVATE m.in_rec, m.oldmine, m.done, m.line, m.upline, m.iscontin, m.hascontin, ;
   m.word1, m.word2, m.platnum

m.in_rec    = RECNO()
* Store the _MLINE position in the original snippet
m.oldmline  = _MLINE
m.hascontin = .F.       && the previous line was not a continuation line.
LOCATE FOR platform = g_platlist[m.platnum] AND objtype = c_otscreen
IF FOUND()
   * go to the PROCEDURE/FUNCTION statement
   _MLINE = g_procs[m.procnum,m.platnum+1]
   * Skip the PROCEDURE line, since we've already output one.
   m.line = MLINE(proccode,1, _MLINE)
   DO killcr WITH m.line

   * We are now positioned at the line following the procedure statement.
   * Write until the end of the snippet or the next procedure.
   m.done = .F.
   DO WHILE !m.done
      m.line = MLINE(proccode,1, _MLINE)
      DO killcr WITH m.line
      m.upline = UPPER(ALLTRIM(CHRTRAN(m.line,chr(9),' ')))
      m.iscontin = m.hascontin
      m.hascontin = RIGHT(m.upline,1) = ';'
      IF LEFT(m.upline,1) $ "PF" AND !m.iscontin
         m.word1 = wordnum(m.upline, 1)
         IF RIGHT(m.word1,1) = ';'
            m.word1 = LEFT(m.word1,LEN(m.word1)-1)
         ENDIF

         DO CASE
         CASE match(m.word1,"PROCEDURE") OR match(m.word1,"FUNCTION")
            * Stop when we encounter the next snippet
            m.done = .T.
            LOOP
         CASE match(m.word1,"PARAMETERS")
            * Don't output it, but keep scanning for other code
            DO WHILE m.hascontin
               m.line = MLINE(proccode,1, _MLINE)
               DO killcr WITH m.line
               m.upline = UPPER(ALLTRIM(CHRTRAN(m.line,chr(9),' ')))
               m.hascontin = RIGHT(m.upline,1) = ';'
            ENDDO
            LOOP
         ENDCASE
      ENDIF

      DO writeline WITH m.line, g_platlist[m.platnum], m.platnum, m.upline, m.scrnno

      * Stop if we've run out of snippet
      IF _MLINE >= LEN(proccode)
         m.done = .T.
      ENDIF
   ENDDO
ENDIF

GOTO m.in_rec
* Restore the _MLINE position in the main snippet we are outputing
_MLINE = m.oldmline
RETURN

*!*****************************************************************************
*!
*!       Function: GETPROCNUM
*!
*!      Called by: EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!               : UPDPROCARRAY       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION getprocnum
*)
*) GETPROCNUM - Return the g_procs array position of the procedure named pname
*)
PARAMETER m.pname
PRIVATE m.i
FOR m.i = 1 TO g_procnames
   IF g_procs[m.i,1] == m.pname
      RETURN m.i
   ENDIF
ENDFOR
RETURN  0

*!*****************************************************************************
*!
*!       Function: HASCONFLICT
*!
*!      Called by: EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION hasconflict
*)
*) HASCONFLICT - Is there a name collision for procedure number num?
*)
PARAMETER m.num
PRIVATE m.i, m.cnt
m.cnt = 0
FOR m.i = 1 TO c_maxplatforms
   IF g_procs[m.num,m.i+1] > 0
      m.cnt = m.cnt +1
   ENDIF
ENDFOR
RETURN IIF(m.cnt > 1,.T.,.F.)


*!*****************************************************************************
*!
*!       Function: GETFIRSTPROC
*!
*!      Called by: GENCLEANUP         (procedure in GENSCRN.PRG)
*!
*!          Calls: WORDNUM()          (function  in GENSCRN.PRG)
*!               : MATCH()            (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION getfirstproc
*)
*) GETFIRSTPROC - Find first PROCEDURE or FUNCTION statement in a cleanup
*)                snippet and return the line number on which it occurs.
*)
PARAMETER m.snipname
PRIVATE proclineno, numlines, word1, first_space
_MLINE = 0
m.numlines = MEMLINES(&snipname)
FOR m.proclineno = 1 TO m.numlines
   m.line  = MLINE(&snipname, 1, _MLINE)
   DO killcr WITH m.line
   m.line  = UPPER(LTRIM(m.line))
   m.word1 = wordnum(m.line,1)
   IF !EMPTY(m.word1) AND (match(m.word1,"PROCEDURE") OR match(m.word1,"FUNCTION"))
      RETURN m.proclineno
   ENDIF
ENDFOR
RETURN 0

*!*****************************************************************************
*!
*!      Procedure: SCANPROC
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!          Calls: PROCSMATCH()       (function  in GENSCRN.PRG)
*!               : ISGENPLAT()        (function  in GENSCRN.PRG)
*!               : UPDPROCARRAY       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE scanproc
*)
*) SCANPROC - Find unique procedure names in cleanup snippets for all platforms
*)
PRIVATE m.in_rec
* See if all the cleanup snippets are the same.  If so, stop now.
m.g_procsmatch = .T.
FOR m.g_screen = 1 TO m.g_nscreens
   m.dbalias = g_screens[m.g_screen,5]
   SELECT (m.dbalias)
   IF !g_screens[m.g_screen,6]      && not applicable for FoxPro 2.0 screens
      m.g_procsmatch = m.g_procsmatch AND procsmatch()
	ENDIF
ENDFOR

IF !m.g_procsmatch
   FOR m.g_screen = 1 TO m.g_nscreens
      m.dbalias = g_screens[m.g_screen,5]
      SELECT (m.dbalias)

      IF !g_screens[m.g_screen,6]      && not applicable for FoxPro 2.0 screens
         SCAN FOR objtype = c_otscreen AND isgenplat(platform)
            DO updprocarray
         ENDSCAN
      ENDIF
   ENDFOR
   m.g_screen = 0
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: UPDPROCARRAY
*!
*!      Called by: SCANPROC           (procedure in GENSCRN.PRG)
*!
*!          Calls: VERSIONCAP()       (function  in GENSCRN.PRG)
*!               : PUTMSG             (procedure in GENSCRN.PRG)
*!               : WORDNUM()          (function  in GENSCRN.PRG)
*!               : MATCH()            (function  in GENSCRN.PRG)
*!               : ADDPROCNAME        (procedure in GENSCRN.PRG)
*!               : GETPROCNUM()       (function  in GENSCRN.PRG)
*!               : CLEANPARAM()       (function  in GENSCRN.PRG)
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE updprocarray
*)
*) UPDPROCARRAY - Pick out the procedures names in the current cleanup snippet and call
*)                  AddProcName to update the g_procs array.
*)
PRIVATE m.i, m.numlines, m.line, m.upline, m.word1, m.word2, m.iscontin, m.hascontin, ;
   m.lastmline, m.thisproc

DO putmsg WITH "Scanning cleanup snippet for ";
   +versioncap( IIF(TYPE("platform")<>"U",platform,"DOS"), m.g_dualoutput )

_MLINE = 0
m.numlines = MEMLINES(proccode)
m.hascontin = .F.
FOR m.i = 1 TO m.numlines
   m.lastmline = _MLINE                && note starting position of this line
   m.line      = MLINE(proccode,1, _MLINE)
   DO killcr WITH m.line
   m.upline    = UPPER(ALLTRIM(m.line))
   m.iscontin  = m.hascontin
   m.hascontin = RIGHT(m.upline,1) = ';'
   IF LEFT(m.upline,1) $ "PF" AND !m.iscontin
      m.word1 = CHRTRAN(wordnum(m.upline, 1),';','')
      DO CASE
      CASE match(m.word1,"PROCEDURE") OR match(m.word1,"FUNCTION")
         m.word2 = wordnum(m.upline,2)
         DO addprocname WITH m.word2, platform, m.i, m.lastmline
         m.lastproc = m.word2
      CASE match(m.word1,"PARAMETERS")
         * Associate this parameter statement with the last procedure or function
         m.thisproc = getprocnum(m.lastproc)
         IF m.thisproc > 0
            m.thisparam = ALLTRIM(SUBSTR(m.upline,AT(' ',m.upline)+1))
            * Deal with continued PARAMETER lines
            DO WHILE m.hascontin AND m.i <= m.numlines
               m.lastmline = _MLINE                && note the starting position of this line
               m.line   = MLINE(proccode,1, _MLINE)
               DO killcr WITH m.line
               m.upline = UPPER(ALLTRIM(CHRTRAN(m.line,chr(9),' ')))
               m.thisparam = ;
                  m.thisparam + CHR(13)+CHR(10) + m.line
               m.hascontin = RIGHT(m.upline,1) = ';'
               m.i = m.i + 1
            ENDDO
            * Make sure that this parameter matches any others we've seen for this function
            DO CASE
            CASE EMPTY(g_procs[m.thisproc,C_MAXPLATFORMS+3])
               * First occurrence, or one platform has a parameter statement and another doesn't
               g_procs[m.thisproc,C_MAXPLATFORMS+3] = m.thisparam
            CASE cleanparam(m.thisparam) == cleanparam(g_procs[m.thisproc,C_MAXPLATFORMS+3])
               * It matches--do nothing
            CASE cleanparam(m.thisparam) = cleanparam(g_procs[m.thisproc,C_MAXPLATFORMS+3])
               * The new one is a superset of the existing one.  Use the longer one.
               g_procs[m.thisproc,C_MAXPLATFORMS+3] = m.thisparam
            CASE cleanparam(g_procs[m.thisproc,C_MAXPLATFORMS+3]) = cleanparam(m.thisparam)
               * The old one is a superset of the new one.  Keep the longer one.
            OTHERWISE
               DO errorhandler WITH "Different parameters for "+g_procs[m.thisproc,1],;
                  LINENO(),c_error_3
            ENDCASE
         ENDIF
      ENDCASE
   ENDIF
ENDFOR
RETURN

*!*****************************************************************************
*!
*!      Procedure: ADDPROCNAME
*!
*!      Called by: UPDPROCARRAY       (procedure in GENSCRN.PRG)
*!
*!          Calls: GETPLATNUM()       (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE addprocname
*)
*) ADDPROCNAME - Update g_procs with pname data
*)
PARAMETER m.pname, m.platname, m.linenum, m.lastmline
PRIVATE m.rnum, m.platformcol, m.i, m.j
IF EMPTY(m.pname)
   RETURN
ENDIF

* Look up this name in the procedures array
m.rnum = 0
FOR m.i = 1 TO m.g_procnames
   IF g_procs[m.i,1] == m.pname
      m.rnum = m.i
      EXIT
   ENDIF
ENDFOR

IF m.rnum = 0
   * New name
   g_procnames = m.g_procnames + 1
   DIMENSION g_procs[m.g_procnames,C_MAXPLATFORMS+3]
   g_procs[m.g_procnames,1] = UPPER(ALLTRIM(m.pname))
   FOR m.j = 1 TO c_maxplatforms
      g_procs[m.g_procnames,m.j + 1] = -1
   ENDFOR
   g_procs[m.g_procnames,C_MAXPLATFORMS+2] = .F.   && not emitted yet
   g_procs[m.g_procnames,C_MAXPLATFORMS+3] = ""    && parameter statement
   m.rnum = m.g_procnames
ENDIF

m.platformcol = getplatnum(m.platname) + 1
IF m.platformcol > 1
   g_procs[m.rnum, m.platformcol] = m.lastmline
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: GETPLATNUM
*!
*!      Called by: PREPWNAMES         (procedure in GENSCRN.PRG)
*!               : ADDPROCNAME        (procedure in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!               : WRITELINE          (procedure in GENSCRN.PRG)
*!               : ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION getplatnum
*)
*) GETPLATNUM - Return the g_platlist array index given a platform name
*)
PARAMETER m.platname
PRIVATE m.i
FOR m.i = 1 TO c_maxplatforms
   IF g_platlist[m.i] == UPPER(ALLTRIM(m.platname))
      RETURN m.i
   ENDIF
ENDFOR
RETURN 0

*!*****************************************************************************
*!
*!      Procedure: GENCASESTMT
*!
*!*****************************************************************************
PROCEDURE gencasestmt
*)
*) GENCASESTMT - Generate the CASE ... statement
*)
PARAMETER m.thisplat
DO CASE
CASE m.thisplat = "WINDOWS" and !hasrecords("MAC") and hasrecords("WINDOWS")
   \CASE _WINDOWS OR _MAC   && no MAC records in screen
	m.g_dualoutput = .T.
CASE m.thisplat = "MAC" and !hasrecords("WINDOWS") and hasrecords("MAC")
   \CASE _MAC OR _WINDOWS   && no Windows records in screen
	m.g_dualoutput = .T.
CASE m.thisplat = "UNIX" and !hasrecords("DOS") and hasrecords("UNIX")
   \CASE _UNIX OR _DOS      && no DOS records in screen
	m.g_dualoutput = .T.
CASE m.thisplat = "DOS" and !hasrecords("UNIX") and hasrecords("DOS")
   \CASE _DOS OR _UNIX      && no UNIX records in screen
	m.g_dualoutput = .T.
OTHERWISE
   \CASE _<<m.thisplat>>
	m.g_dualoutput = .F.
ENDCASE
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENPARAMETER
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!               : BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genparameter
*)
*) GENPARAMETER - Generate the PARAMETER statement
*)
IF !EMPTY(m.g_parameter)
   \PARAMETERS <<m.g_parameter>>
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENSECT1
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: MULTIPLAT()        (function  in GENSCRN.PRG)
*!               : VERSIONCAP()       (function  in GENSCRN.PRG)
*!               : PUTMSG             (procedure in GENSCRN.PRG)
*!               : SEEKHEADER         (procedure in GENSCRN.PRG)
*!               : FINDSECTION()      (function  in GENSCRN.PRG)
*!               : COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!               : GETPLATNAME()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gensect1
*)
*) GENSECT1 - Generate #SECTION 1 code for all screens.
*)
PRIVATE m.i, m.dbalias, m.string, m.loop, m.j, m.end, m.msg, m.thisline
m.msg =  'Generating Setup Code'
IF multiplat()
   m.msg = m.msg + " for "+versioncap(m.g_genvers, m.g_dualoutput)
ENDIF
DO putmsg WITH m.msg
m.string = " Setup Code - SECTION 1"

FOR m.i = 1 TO m.g_nscreens
   m.g_screen = m.i

   m.dbalias = g_screens[m.i,5]
   SELECT (m.dbalias)
   DO seekheader WITH m.i
   IF EMPTY (setupcode)
      LOOP
   ENDIF

   m.g_sect1start= c_fromone
   m.g_sect2start= c_untilend
   m.loop  = .F.

   IF ATCLINE("#SECT", setupcode) <> 0
      m.g_sect1start = findsection(1, setupcode)+1
      m.g_sect2start = findsection(2, setupcode)
   ENDIF

   DO notedirectives WITH (m.i)

   * See if there are nondirective statements in SECTION 1
   IF m.g_sect2start-m.g_sect1start <= 3
      IF m.g_sect2start = 0
         m.end = MEMLINES(setupcode)
      ELSE
         m.end = m.g_sect2start-1
      ENDIF
      m.loop = .T.
      m.j = m.g_sect1start
      DO WHILE m.j <= m.end
         m.thisline = MLINE(setupcode,m.j)
         DO killcr WITH m.thisline
         IF AT('#',m.thisline) <> 1 OR AT('#INSE',m.thisline) = 1
            m.loop = .F.
            EXIT
         ENDIF
         m.j = m.j + 1
      ENDDO
   ENDIF
   IF m.loop
      LOOP
   ENDIF
   IF NOT (m.g_sect1start=1 OR (m.g_sect1start=m.g_sect2start) OR ;
         (m.g_sect2start<>0 AND m.g_sect1start>m.g_sect2start))

      DO commentblock WITH g_screens[m.i,1], m.string
      \#REGION <<INT(m.i)>>
      _MLINE = 0
      DO writecode WITH setupcode, getplatname(m.i), m.g_sect1start, m.g_sect2start, m.i, 'setup'
   ENDIF
ENDFOR
m.g_screen = 0
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENSECT2
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: SEEKHEADER         (procedure in GENSCRN.PRG)
*!               : FINDSECTION()      (function  in GENSCRN.PRG)
*!               : NOTEDIRECTIVES     (procedure in GENSCRN.PRG)
*!               : COUNTDIRECTIVES()  (function  in GENSCRN.PRG)
*!               : COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!               : GETPLATNAME()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gensect2
*)
*) GENSECT2 - Generate Setup code #SECTION 2.
*)
PRIVATE m.i, m.dbalias, m.string, m.endline, m.srtline, ;
   m.linecnt, m.lcnt, m.sect1, m.sect2
m.string = " Setup Code - SECTION 2"

FOR m.i = 1 TO m.g_nscreens
   m.g_screen = m.i
   m.dbalias = g_screens[m.i,5]
   SELECT (m.dbalias)
   DO seekheader WITH m.i
   IF EMPTY (setupcode)
      LOOP
   ENDIF

   m.g_sect1start= c_fromone
   m.g_sect2start= c_untilend
   m.loop  = .F.

   IF ATCLINE("#SECT", setupcode)<>0
      m.g_sect1start = findsection(1, setupcode)+1
      m.g_sect2start = findsection(2, setupcode)
   ENDIF

   m.sect1 = m.g_sect1start <> 0
   m.sect2 = m.g_sect2start <> 0

   DO notedirectives WITH (m.i)
   m.lcnt = countdirectives(m.sect1, m.sect2, m.i)

   IF m.g_sect2start = 0 AND m.g_sect1start > 1
      * No Section2 to emit
      LOOP
   ENDIF

   m.linecnt = MEMLINES(setupcode)

   IF m.linecnt > m.lcnt AND m.g_sect2start < m.linecnt
      DO commentblock WITH g_screens[m.i,1], m.string
      \#REGION <<INT(m.i)>>
      DO writecode WITH setupcode, getplatname(m.i), m.g_sect2start, c_untilend, m.i, 'setup'
   ENDIF
ENDFOR
m.g_screen = 0
RETURN

*!*****************************************************************************
*!
*!       Function: COUNTDIRECTIVES
*!
*!      Called by: GENSECT2           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION countdirectives
*)
*) COUNTDIRECTIVES - Count directives in setup snippet.
*)
*) This function counts the directives in setup.  It is used to figure out if there
*) are any non-directive statements in the setup snippet.
PARAMETER m.sect1, m.sect2, m.scrnno
PRIVATE m.numlines, m.i, m.lcnt, m.thisline, m.upline
m.lcnt = 0
IF AT('#',setupcode) > 0
   * AT test is optimization to avoid processing the snippet when there are no directives
   m.numlines = MEMLINES(setupcode)
   _MLINE = 0
   FOR m.i = 1 TO m.numlines
      m.thisline = MLINE(setupcode, 1, _MLINE)
      DO killcr WITH m.thisline
      m.upline = UPPER(ALLTRIM(CHRTRAN(m.thisline,chr(9),' ')))
      IF LEFT(m.upline,1) = '#' AND !(LEFT(m.upline,5) = "#INSE")
         m.lcnt = m.lcnt + 1
      ENDIF
   ENDFOR
ENDIF
RETURN m.lcnt

*!*****************************************************************************
*!
*!      Procedure: NOTEDIRECTIVES
*!
*!      Called by: GENSECT2           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE notedirectives
*)
*) NOTEDIRECTIVES - Check for global directives such as #READCLAUSES, #NOREAD
*)
*) This function notes certain directives in the setup snippet and populates various
*) global variables so that we don't have to keep going back to the snippet to find
*) things.
PARAMETERS m.scrnno
PRIVATE m.numlines, m.i, m.thisline, m.upline
m.g_noread    = .F.
m.g_noreadplain = .F.
IF AT('#',setupcode) > 0
   * AT test is optimization to avoid processing the snippet when there are no directives
   m.numlines = MEMLINES(setupcode)
   _MLINE = 0
   FOR m.i = 1 TO m.numlines
      m.thisline = MLINE(setupcode, 1, _MLINE)
      DO killcr WITH m.thisline
      m.upline = UPPER(ALLTRIM(CHRTRAN(m.thisline,chr(9),' ')))
      IF LEFT(m.upline,1) = '#'
         DO CASE
         CASE LEFT(m.upline,5) = "#READ"   && #READCLAUSES - Additional READ clauses
            IF m.g_rddir = .F.
               m.g_rddir = .T.
               m.g_rddirno = m.scrnno
            ENDIF
         CASE LEFT(m.upline,5) = "#NORE"   && #NOREAD - omit the READ statement
            m.g_noread = .T.
            IF AT(m.g_dblampersand,m.upline) > 0
               m.upline = LEFT(m.upline,AT(m.g_dblampersand,m.upline)-1)
            ENDIF
            m.g_noreadplain = IIF(ATC(' PLAI',m.upline) > 0,.T.,.F.)
            IF m.g_noreadplain
	            m.g_openfiles    = .F.
					m.g_closefiles   = .F.
					m.g_defwin       = .F.
					m.g_relwin       = .F.
            ENDIF
         ENDCASE
      ENDIF
   ENDFOR
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: FINDSECTION
*!
*!      Called by: GENSECT1           (procedure in GENSCRN.PRG)
*!               : GENSECT2           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION findsection
*)
*) FINDSECTION - Find #SECT... directive.
*)
*) Description:
*) Locate and return the line on which the generator directive '#SECT'
*) is located on.  If no valid directive found, return 0.
*)
PARAMETER m.sectionid, m.memo
PRIVATE m.line, m.linecnt, m.textline
m.line    = ATCLINE("#SECT", m.memo)
m.linecnt = MEMLINE(m.memo)
DO WHILE m.line <= m.linecnt
   m.textline = LTRIM(MLINE(m.memo, m.line))
   DO killcr WITH m.textline
   IF ATC("#SECT", m.textline)=1
      IF m.sectionid = 1
         IF AT("1", m.textline)<>0
            m.sect1 = .T.
            RETURN m.line
         ELSE
            RETURN 0
         ENDIF
      ELSE
         IF AT("2", m.textline)<>0
            m.sect2 = .T.
            RETURN m.line
         ENDIF
      ENDIF
   ENDIF
   m.line = m.line + 1
ENDDO
RETURN 0

*!*****************************************************************************
*!
*!      Procedure: WRITECODE
*!
*!      Called by: GENCLEANUP         (procedure in GENSCRN.PRG)
*!               : GENPROCEDURES      (procedure in GENSCRN.PRG)
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : GENSECT2           (procedure in GENSCRN.PRG)
*!               : GENVALIDBODY       (procedure in GENSCRN.PRG)
*!               : GENWHENBODY        (procedure in GENSCRN.PRG)
*!               : ACTICLAUSE         (procedure in GENSCRN.PRG)
*!               : DEATCLAUSE         (procedure in GENSCRN.PRG)
*!               : SHOWCLAUSE         (procedure in GENSCRN.PRG)
*!               : INSERTFILE         (procedure in GENSCRN.PRG)
*!
*!          Calls: GETPLATNUM()       (function  in GENSCRN.PRG)
*!               : GENINSERTCODE      (procedure in GENSCRN.PRG)
*!               : ISPARAMETER()      (function  in GENSCRN.PRG)
*!               : ATWNAME()          (function  in GENSCRN.PRG)
*!               : ISCOMMENT()        (function  in GENSCRN.PRG)
*!               : WRITELINE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE writecode
*)
*) WRITECODE - Write contents of a memo to a low level file.
*)
*) Description:
*) Receive a memo field as a parameter and write its contents out
*) to the currently opened low level file whose handle is stored
*) in the system memory variable _TEXT.  Contents of the system
*) memory variable _PRETEXT will affect the positioning of the
*) generated text.
*)
PARAMETER m.memo, m.platname, m.start, m.end, m.scrnno, m.insetup
PRIVATE m.linecnt, m.i, m.line, m.upline, m.expr, m.platnum, m.at, m.in_exact

m.in_exact = SET("EXACT")
SET EXACT OFF

_MLINE = 0

m.start = MAX(1,m.start)  && if zero, start at 1

IF m.end > m.start
   m.linecnt = m.end-1
ELSE
   m.linecnt = MEMLINES(m.memo)
ENDIF

m.platnum = getplatnum(m.platname)

FOR m.i = 1 TO m.start - 1
   m.line = MLINE(m.memo, 1, _MLINE)
ENDFOR

* Window substitution names
m.subwindname = g_wnames[m.scrnno,m.platnum]
m.emptysubwind = IIF(EMPTY(m.subwindname),.T.,.F.)

IF NOT EMPTY(m.insetup)
   FOR m.i = m.start TO m.linecnt
      m.line = MLINE(m.memo, 1, _MLINE)
      DO killcr WITH m.line
      m.upline = UPPER(ALLTRIM(CHRTRAN(m.line,chr(9),' ')))
      IF !geninsertcode(@upline,m.scrnno, m.insetup, m.platname)
         m.isparam =  isparameter(@upline)
         DO CASE
         CASE m.isparam
            * Accumulate continuation line but don't output it.
            DO WHILE RIGHT(m.upline,1) = ';'
               m.line = MLINE(m.memo, 1, _MLINE)
               m.upline = m.upline + ALLTRIM(UPPER(m.line))
               m.i = m.i + 1
            ENDDO
            DO killcr WITH m.line
         CASE m.upline = "#"
			   * don't output a generator directive, but #DEFINES are OK
			   IF LEFT(m.upline,5) = "#DEFI" ;
					OR LEFT(m.upline,3) = "#IF" ;
					OR LEFT(m.upline,5) = "#ELSE" ;
					OR LEFT(m.upline,6) = "#ENDIF" ;
					OR LEFT(m.upline,8) = "#INCLUDE"
            	\<<m.line>>
				ENDIF
		   CASE m.emptysubwind    && the most common case
            \<<m.line>>
         OTHERWISE
            m.at = atwname(m.subwindname, m.line)
            IF m.at <> 0 AND !iscomment(@upline)
               m.expr = STUFF(m.line, m.at, ;
                  LEN(m.subwindname), ;
                  g_screens[m.scrnno,2])
               \<<m.expr>>
            ELSE
               \<<m.line>>
            ENDIF
         ENDCASE
      ENDIF
   ENDFOR
ELSE   && not in setup
   FOR m.i = m.start TO m.linecnt
      m.line = MLINE(m.memo, 1, _MLINE)
      DO killcr WITH m.line
      m.upline = UPPER(LTRIM(CHRTRAN(m.line,chr(9),' ')))
      DO writeline WITH m.line, m.platname, m.platnum, m.upline, m.scrnno
   ENDFOR
ENDIF
SET EXACT &in_exact
RETURN

*!*****************************************************************************
*!
*!      Procedure: WRITELINE
*!
*!      Called by: EMITPROC           (procedure in GENSCRN.PRG)
*!               : PUTPROC            (procedure in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!
*!          Calls: GETPLATNUM()       (function  in GENSCRN.PRG)
*!               : GENINSERTCODE      (procedure in GENSCRN.PRG)
*!               : ATWNAME()          (function  in GENSCRN.PRG)
*!               : ISCOMMENT()        (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE writeline
*)
*) WRITELINE - Emit a single line
*)
PARAMETER m.line, m.platname, m.platnum, m.upline, m.scrnno
PRIVATE m.at, m.expr

IF !geninsertcode(@upline, m.scrnno, .F., m.platname)   && by reference to save time
   IF !EMPTY(g_wnames[m.scrnno, m.platnum])
      m.at = atwname(g_wnames[m.scrnno, m.platnum], m.line)
      IF m.at <> 0 AND !iscomment(@upline)
         m.expr = STUFF(m.line, m.at, ;
            LEN(g_wnames[m.scrnno, m.platnum]), ;
            g_screens[m.scrnno,2])
         \<<m.expr>>
      ELSE
         IF !INLIST(LEFT(m.upline,2),"*!","*:") ;
               AND AT('#NAME', m.upline) <> 1
            \<<m.line>>
         ENDIF
      ENDIF
   ELSE
	   * This code relies upon partial matching (e.g., "*! Comment" will equal "*")
      DO CASE
		CASE m.upline = "*"
		   IF !(m.upline = "*!" OR m.upline = "*:")
            \<<m.line>>
			ENDIF
		CASE m.upline = "#"
		   * don't output a generator directive, but #DEFINES are OK
		   IF LEFT(m.upline,5) = "#DEFI" ;
					OR LEFT(m.upline,3) = "#IF" ;
					OR LEFT(m.upline,5) = "#ELSE" ;
					OR LEFT(m.upline,6) = "#ENDIF" ;
					OR LEFT(m.upline,8) = "#INCLUDE"
            \<<m.line>>
		   ENDIF
		OTHERWISE
         \<<m.line>>
      ENDCASE
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENINSERTCODE
*!
*!      Called by: WRITECODE          (procedure in GENSCRN.PRG)
*!               : WRITELINE          (procedure in GENSCRN.PRG)
*!               : ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: WORDNUM()          (function  in GENSCRN.PRG)
*!               : INSERTFILE         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE geninsertcode
*)
*) GENINSERTCODE - Emit code from the #insert file, if any
*)
*) Strg has to be trimmed before entering GenInsertCode.  It may be passed by reference.
PARAMETER m.strg, m.scrnno, m.insetup, m.platname
PRIVATE m.word1, m.filname
IF AT("#INSE",m.strg) = 1
   m.word1 = wordnum(m.strg,1)
   m.filname = SUBSTR(m.strg,LEN(m.word1)+1)
   m.filname = ALLTRIM(CHRTRAN(m.filname,CHR(9)," "))
   DO insertfile WITH m.filname, m.scrnno, m.insetup, m.platname
   RETURN .T.
ELSE
   RETURN .F.
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: ISPARAMETER
*!
*!      Called by: WRITECODE          (procedure in GENSCRN.PRG)
*!
*!          Calls: MATCH()            (function  in GENSCRN.PRG)
*!               : WORDNUM()          (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION isparameter
*)
*) ISPARAMETER - Determine if strg is a PARAMETERS statement
*)
PARAMETER m.strg
PRIVATE m.ispar
m.ispar = .F.
IF !EMPTY(strg) AND match(CHRTRAN(wordnum(strg,1),';',''),"PARAMETERS")
   m.ispar = .T.
ENDIF
RETURN m.ispar

*!*****************************************************************************
*!
*!       Function: ATWNAME
*!
*!      Called by: WRITECODE          (procedure in GENSCRN.PRG)
*!               : WRITELINE          (procedure in GENSCRN.PRG)
*!               : ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION atwname
*)
*) ATWNAME - Determine if valid m.string is in this line.
*)
*) Description:
*) Make sure that if m.string is in fact the string we want to do
*) the substitution on.
*)
PARAMETER m.string, m.line
PRIVATE m.pos, m.before, m.after
m.pos = AT(m.string,m.line)
IF m.pos = 0
   RETURN 0
ENDIF
IF m.pos = 1
   m.pos = AT(m.string+" ",m.line)
ELSE
   IF m.pos = LEN(m.line) - LEN(m.string) + 1
      m.pos = AT(" "+m.string,m.line)
      m.pos = IIF(m.pos<>0, m.pos+1,m.pos)
   ELSE
      m.before = SUBSTR(m.line,m.pos-1,1)

      IF m.before = c_under OR ;
            (m.before >= '0' AND m.before <= '9') OR ;
            (m.before >= 'a' AND m.before <= 'z') OR ;
            (m.before >= 'A' AND m.before <= 'Z')

         RETURN 0
      ENDIF
      m.after = SUBSTR(m.line,m.pos+LEN(m.string),1)

      IF m.after = c_under OR ;
            (m.after >= '0' AND m.after <= '9') OR ;
            (m.after >= 'a' AND m.after <= 'z') OR ;
            (m.after >= 'A' AND m.after <= 'Z')

         RETURN 0
      ENDIF
   ENDIF
ENDIF
RETURN m.pos

*!*****************************************************************************
*!
*!       Function: ISCOMMENT
*!
*!      Called by: WRITECODE          (procedure in GENSCRN.PRG)
*!               : WRITELINE          (procedure in GENSCRN.PRG)
*!               : ADDTOCTRL          (procedure in GENSCRN.PRG)
*!               : GETPARAM()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION iscomment
*)
*) ISCOMMENT - Determine if textline is a comment line.
*)
PARAMETER m.textline
PRIVATE m.asterisk, m.isnote, m.ampersand, m.statement
IF EMPTY(m.textline)
   RETURN .F.
ENDIF
m.statement = UPPER(LTRIM(m.textline))

m.asterisk  = AT("*", m.statement)
m.ampersand = AT(m.g_dblampersand, m.statement)
m.isnote    = AT("NOTE", m.statement)

DO CASE
CASE (m.asterisk = 1 OR m.ampersand = 1)
   RETURN .T.
CASE (m.isnote = 1 ;
      AND (LEN(m.statement) <= 4 OR SUBSTR(m.statement,5,1) = ' '))
   * Don't be fooled by something like "notebook = 7"
   RETURN .T.
ENDCASE
RETURN .F.

*!*****************************************************************************
*!
*!      Procedure: GENCLAUSECODE
*!
*!      Called by: PLACEREAD          (procedure in GENSCRN.PRG)
*!               : DOPLACECLAUSE      (procedure in GENSCRN.PRG)
*!
*!          Calls: VALICLAUSE         (procedure in GENSCRN.PRG)
*!               : WHENCLAUSE         (procedure in GENSCRN.PRG)
*!               : ACTICLAUSE         (procedure in GENSCRN.PRG)
*!               : DEATCLAUSE         (procedure in GENSCRN.PRG)
*!               : SHOWCLAUSE         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genclausecode
*)
*) GENCLAUSECODE - Generate code for all read-level clauses.
*)
*) Description:
*) Generate functions containing the code from each screen's
*) READ level valid, show, when, activate, and deactivate clauses.
*)
PARAMETER m.screenno
DO valiclause WITH m.screenno
DO whenclause WITH m.screenno
DO acticlause WITH m.screenno
DO deatclause WITH m.screenno
DO showclause WITH m.screenno
RETURN

*!*****************************************************************************
*!
*!      Procedure: VALICLAUSE
*!
*!      Called by: GENCLAUSECODE      (procedure in GENSCRN.PRG)
*!
*!          Calls: GENFUNCHEADER      (procedure in GENSCRN.PRG)
*!               : GENVALIDBODY       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE valiclause
*)
*) VALICLAUSE - Generate Read level Valid clause function.
*)
*) Description:
*) Generate the function containing the code segment(s) provided
*) by the user for the read level VALID clause.
*) If multiple reads have been chosen, then this procedure generates
*) a function for a single screen.
*) If single read has been chosen and there are multiple screens,
*) we will concatenate valid clause code segments form all screens
*) to form a single function.
*)
PARAMETER m.screenno
PRIVATE m.i, m.dbalias, m.thispretext

IF m.g_validtype = "EXPR" OR EMPTY(m.g_validtype)
   RETURN
ENDIF
DO genfuncheader WITH m.g_validname, "Read Level Valid", .T.
\FUNCTION <<m.g_validname>>     && Read Level Valid

m.thispretext = _PRETEXT
_PRETEXT = ""
IF m.g_multreads
   DO genvalidbody WITH m.screenno
ELSE
   FOR m.i = 1 TO m.g_nscreens
      m.g_screen = m.i
      m.dbalias = g_screens[m.i,5]
      SELECT (m.dbalias)
      DO genvalidbody WITH m.i
   ENDFOR
   m.g_screen = 0
ENDIF
_PRETEXT = m.thispretext
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENVALIDBODY
*!
*!      Called by: VALICLAUSE         (procedure in GENSCRN.PRG)
*!
*!          Calls: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : BASENAME()         (function  in GENSCRN.PRG)
*!               : GENCOMMENT         (procedure in GENSCRN.PRG)
*!               : GETPLATNAME()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genvalidbody
*)
*) GENVALIDBODY - Put out contents of a valid memo field.
*)
PARAMETER m.region
PRIVATE m.name, m.pos

IF g_screens[m.region, 6]
   LOCATE FOR objtype = c_otscreen
ELSE
   LOCATE FOR platform = g_screens[m.region, 7] AND objtype = c_otscreen
ENDIF
IF NOT FOUND()
   DO errorhandler WITH "Error in SCX: Objtype=1 not found",;
      LINENO(), c_error_3
   RETURN
ENDIF
IF NOT EMPTY(VALID) AND validtype<>0
   IF NOT m.g_multread
      m.name  = basename(DBF())
      DO gencomment WITH "Valid Code from screen: "+m.name
   ENDIF
   \#REGION <<INT(m.region)>>
   DO writecode WITH VALID, getplatname(m.region), c_fromone, c_untilend, m.region
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: WHENCLAUSE
*!
*!      Called by: GENCLAUSECODE      (procedure in GENSCRN.PRG)
*!
*!          Calls: GENFUNCHEADER      (procedure in GENSCRN.PRG)
*!               : GENWHENBODY        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE whenclause
*)
*) WHENCLAUSE - Generate Read level When clause function.
*)
*) Description:
*) Generate the function containing the code segment(s) provided
*) by the user for the read level WHEN clause.
*) If multiple reads have been chosen, then this procedure generates
*) a function for a single screen (i.e., the one it has been called for).
*) If single read has been chosen and there are multiple screens,
*) we will concatenate when clause code segments from all screens
*) to form a single function.
*)
PARAMETER m.screenno
PRIVATE m.i, m.dbalias, m.thispretext

IF m.g_whentype = "EXPR" OR EMPTY(m.g_whentype)
   RETURN
ENDIF
DO genfuncheader WITH m.g_whenname, "Read Level When", .T.
\FUNCTION <<m.g_whenname>>     && Read Level When

m.thispretext = _PRETEXT
_PRETEXT = ""
IF m.g_multreads
   DO genwhenbody WITH m.screenno
ELSE
   FOR m.i = 1 TO m.g_nscreens
      m.g_screen = m.i
      m.dbalias = g_screens[m.i,5]
      SELECT (m.dbalias)
      DO genwhenbody WITH m.i
   ENDFOR
   m.g_screen = 0
ENDIF
_PRETEXT = m.thispretext
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENWHENBODY
*!
*!      Called by: WHENCLAUSE         (procedure in GENSCRN.PRG)
*!
*!          Calls: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : BASENAME()         (function  in GENSCRN.PRG)
*!               : GENCOMMENT         (procedure in GENSCRN.PRG)
*!               : GETPLATNAME()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genwhenbody
*)
*) GENWHENBODY - Put out contents of when memo field.
*)
PARAMETER m.region
PRIVATE m.name, m.pos

IF g_screens[m.region, 6]
   LOCATE FOR objtype = c_otscreen
ELSE
   LOCATE FOR platform = g_screens[m.region, 7] AND objtype = c_otscreen
ENDIF
IF NOT FOUND()
   DO errorhandler WITH "Error in SCX: Objtype=1 not found",;
      LINENO(), c_error_3
   RETURN
ENDIF

IF NOT EMPTY(WHEN) AND whentype<>0
   IF NOT m.g_multread
      m.name = basename(DBF())
      DO gencomment WITH "When Code from screen: "+m.name
   ENDIF
   \#REGION <<INT(m.region)>>
   DO writecode WITH WHEN, getplatname(m.region), c_fromone, c_untilend, m.region
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ACTICLAUSE
*!
*!      Called by: GENCLAUSECODE      (procedure in GENSCRN.PRG)
*!
*!          Calls: GENFUNCHEADER      (procedure in GENSCRN.PRG)
*!               : GETPLATNAME()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : BASENAME()         (function  in GENSCRN.PRG)
*!               : GENCOMMENT         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE acticlause
*)
*) ACTICLAUSE - Generate Read level Activate clause function.
*)
*) Description:
*) Generate the function containing the code segment(s) provided
*) by the user for the read level ACTIVATE clause.
*) If multiple reads have been chosen, then this procedure generates
*) a function for a single screen (i.e., the one it has been called for).
*) If single read has been chosen and there are multiple screens,
*) we will concatenate activate clause code segments from all screens
*) to form a single function.  Each individual screen's code
*) segment will be enclosed in "IF WOUTPUT('windowname')" statement.
*) Desk top will be represented by a null character. The above
*) mentioned is performed by the procedure genactibody.
*)
PARAMETER m.screenno
PRIVATE m.i, m.name

IF m.g_actitype = "EXPR" OR EMPTY(m.g_actitype)
   RETURN
ENDIF
DO genfuncheader WITH m.g_actiname, "Read Level Activate", .T.
\FUNCTION <<m.g_actiname>>     && Read Level Activate

IF m.g_multreads
   IF NOT EMPTY(ACTIVATE) AND activtype<>0
      \#REGION <<INT(m.screenno)>>
      DO writecode WITH ACTIVATE, getplatname(m.screenno), c_fromone, c_untilend, m.screenno
   ENDIF
ELSE
   FOR m.i = 1 TO m.g_nscreens
      m.g_screen = m.i
      m.dbalias = g_screens[m.i,5]
      SELECT (m.dbalias)
      IF g_screens[m.i, 6]
         LOCATE FOR objtype = c_otscreen
      ELSE
         LOCATE FOR platform = g_screens[m.i, 7] AND objtype = c_otscreen
      ENDIF
      IF NOT FOUND()
         DO errorhandler WITH "Error in SCX: Objtype=1 not found",;
            LINENO(), c_error_3
         RETURN
      ENDIF
      IF NOT EMPTY(ACTIVATE) AND activtype<>0
         m.name = basename(g_screens[m.i,1])
         DO gencomment WITH "Activate Code from screen: "+;
            m.name
      ENDIF
      IF NOT EMPTY(ACTIVATE) AND activtype<>0
         \#REGION <<INT(m.i)>>
         DO writecode WITH ACTIVATE, getplatname(m.i), c_fromone, c_untilend, m.i
      ENDIF
   ENDFOR
   m.g_screen = 0
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: DEATCLAUSE
*!
*!      Called by: GENCLAUSECODE      (procedure in GENSCRN.PRG)
*!
*!          Calls: GENFUNCHEADER      (procedure in GENSCRN.PRG)
*!               : GETPLATNAME()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : BASENAME()         (function  in GENSCRN.PRG)
*!               : GENCOMMENT         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE deatclause
*)
*) DEATCLAUSE - Generate Read level deactivate clause function.
*)
*) Description:
*) Generate the function containing the code segment(s) provided
*) by the user for the read level DEACTIVATE clause.
*) If multiple reads have been chosen, then this procedure generates
*) a function for a single screen (i.e., the one it has been called for).
*) If single read has been chosen and there are multiple screens,
*) we will concatenate deactivate clause code segments from all screens
*) to form a single function.  Each individual screen's code
*) segment will be enclosed in "IF WOUTPUT('windowname')" statement.
*) Desk top will be represented by a null character. The above
*) mentioned is performed by the procedure gendeatbody.
*)
PARAMETER m.screenno
PRIVATE m.i, m.name

IF m.g_deattype = "EXPR" OR EMPTY(m.g_deattype)
   RETURN
ENDIF
DO genfuncheader WITH m.g_deatname, "Read Level Deactivate", .T.
\FUNCTION <<m.g_deatname>>     && Read Level Deactivate

IF m.g_multreads
   IF NOT EMPTY(DEACTIVATE) AND deacttype<>0
      \#REGION <<INT(m.screenno)>>
      DO writecode WITH DEACTIVATE, getplatname(m.screenno), c_fromone, c_untilend, m.screenno
   ENDIF
ELSE
   FOR m.i = 1 TO m.g_nscreens
      m.g_screen = m.i
      m.dbalias = g_screens[m.i,5]
      SELECT (m.dbalias)
      IF g_screens[m.i,6]
         LOCATE FOR objtype = c_otscreen
      ELSE
         LOCATE FOR platform = g_screens[m.i, 7] AND objtype = c_otscreen
      ENDIF
      IF NOT FOUND()
         DO errorhandler WITH "Error in SCX: Objtype=1 not found",;
            LINENO(), c_error_3
         RETURN
      ENDIF
      IF NOT EMPTY(DEACTIVATE) AND deacttype<>0
         m.name = basename(g_screens[m.i,1])
         DO gencomment WITH "Deactivate Code from screen: "+;
            m.name
      ENDIF
      IF NOT EMPTY(DEACTIVATE) AND deacttype<>0
         \#REGION <<INT(m.i)>>
         DO writecode WITH DEACTIVATE, getplatname(m.i), c_fromone, c_untilend, m.i
      ENDIF
   ENDFOR
   m.g_screen = 0
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: SHOWCLAUSE
*!
*!      Called by: GENCLAUSECODE      (procedure in GENSCRN.PRG)
*!
*!          Calls: GENFUNCHEADER      (procedure in GENSCRN.PRG)
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : GETPLATNAME()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!               : PLACESAYS          (procedure in GENSCRN.PRG)
*!               : BASENAME()         (function  in GENSCRN.PRG)
*!               : GENCOMMENT         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE showclause
*)
*) SHOWCLAUSE - Generate Read level Show clause procedure.
*)
*) Description:
*) Generate the function containing the code segment(s) provided
*) by the user for the read level SHOW clause.  The function generated
*) for the show clause will consist of refreshable @...SAY code and
*) code segment(s) if applicable. If multiple reads have been chosen,
*) then this procedure generates a function for a single screen
*) (i.e., the one it has been called for).  If single read has been
*) chosen and there are multiple screens, we will concatenate show
*) clause code segments from all screens to form a single function.
*) Each individual screen's refreshable SAYs will be enclosed in
*) "IF SYS(2016)=('windowname') OR SYS(2016) = '*'" statement.
*) (Desk top will be represented by a null character.)
*)
PARAMETER m.screenno
PRIVATE m.i, m.comment, m.name, m.thispretext, m.oldshow, m.showmod

IF m.g_showtype = "EXPR" OR EMPTY(m.g_showtype)
   RETURN
ENDIF
DO genfuncheader WITH m.g_showname, "Read Level Show", .T.

\FUNCTION <<m.g_showname>>     && Read Level Show
\PRIVATE currwind

\STORE WOUTPUT() TO currwind
m.thispretext = _PRETEXT
_PRETEXT = ""

IF m.g_multreads
   DO seekheader WITH m.screenno
   m.oldshow = Show

   m.showmod = ChkShow()

   m.comment = .T.
   \#REGION <<INT(m.screenno)>>
   IF NOT EMPTY(show) AND showtype<>0
      DO writecode WITH show, getplatname(m.screenno), c_fromone, c_untilend, m.screenno
   ENDIF
   DO placesays WITH m.comment, m.g_showname, m.screenno
   IF m.showmod
      REPLACE show WITH m.oldshow
   ENDIF
ELSE
   FOR m.i = 1 TO m.g_nscreens
      m.g_screen = m.i
      m.dbalias = g_screens[m.i,5]
      SELECT (m.dbalias)
      m.comment = .F.

      DO seekheader WITH m.i

      m.name = basename(g_screens[m.i,1])
      IF NOT EMPTY(show) AND showtype<>0
         m.oldshow = Show   && record show snippet
         m.showmod = ChkShow()         && may modify show snippet directly

         DO gencomment WITH "Show Code from screen: "+m.name
         \#REGION <<INT(m.i)>>
         m.comment = .T.
         DO writecode WITH show, getplatname(m.i), c_fromone, c_untilend, m.i
         IF m.showmod
            REPLACE show WITH m.oldshow
         ENDIF
      ENDIF
      DO seekheader WITH m.i
      DO placesays WITH m.comment, m.name, m.i
   ENDFOR
   m.g_screen = 0
ENDIF
_PRETEXT = m.thispretext

IF !m.g_noreadplain
   \IF NOT EMPTY(currwind)
   \	ACTIVATE WINDOW (currwind) SAME
   \ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Function: CHKSHOW
*!
*!*****************************************************************************
FUNCTION chkshow
PRIVATE m.thelineno, m.theline, m.oldmline, m.upline, m.newshow, m.found_one, m.leadspace, ;
   m.oldtext, m.theword, m.getsonly, m.j
* Check for a poisonous SHOW GETS in the SHOW snippet.  If one if executed
* there, runaway recursion results.
IF c_checkshow == 0   && check to see if this safety feature is enabled.
   RETURN .F.
ENDIF
m.thelineno = ATCLINE("SHOW GETS",show)
m.oldmline = _MLINE
m.oldtext = _TEXT
m.found_one = .F.
IF m.thelineno > 0
   * Step through the SHOW snippet a line at a time, commenting out any SHOW GETS or
   * SHOW GETS OFF statements.
   m.newshow = ""
   _MLINE = 0
   DO WHILE _MLINE < LEN(show)
      m.theline = MLINE(show,1,_MLINE)
      DO killcr WITH m.theline
      m.upline  = UPPER(LTRIM(m.theline))
      IF wordnum(m.upline,1) == "SHOW" AND wordnum(m.upline,2) == "GETS" ;
             AND (EMPTY(wordnum(m.upline,3)) OR wordnum(m.upline,3) == "OFF")
         m.leadspace = LEN(m.theline) - LEN(m.upline)
         m.newshow = m.newshow + SPACE(m.leadspace) + ;
            "* Commented out by GENSCRN: " + LTRIM(m.theline) + CHR(13) + CHR(10)
         DO errorhandler WITH "SHOW GETS statement commented out of SHOW snippet.",;
              LINENO(),c_error_1
         m.found_one = .T.
      ELSE
         m.newshow = m.newshow + m.theline + CHR(13) + CHR(10)
      ENDIF
   ENDDO
   IF m.found_one
      REPLACE show WITH m.newshow
   ENDIF
ENDIF
_MLINE = m.oldmline
_TEXT  = m.oldtext
RETURN m.found_one

*!*****************************************************************************
*!
*!      Procedure: PLACESAYS
*!
*!      Called by: SHOWCLAUSE         (procedure in GENSCRN.PRG)
*!
*!          Calls: GENCOMMENT         (procedure in GENSCRN.PRG)
*!               : GENPICTURE         (procedure in GENSCRN.PRG)
*!               : PUSHINDENT         (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYPICTURE         (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!               : POPINDENT          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE placesays
*)
*) PLACESAYS - Generate @...SAY for refreshable says in the .PRG file.
*)
*) Description:
*) Place @...SAY code for all refreshable say statements into
*) the generated SHOW clause function.
*)
PARAMETER m.comment, m.scrnname, m.g_thisscreen
PRIVATE m.iswindow, m.sayfound, m.windowname, m.theexpr, m.occur, m.pos

IF EMPTY(STYLE)
   m.iswindow = .F.
ELSE
   m.iswindow = .T.
   m.windowname = g_screens[m.g_thisscreen,2]
ENDIF
m.sayfound = .T.
SCAN FOR ((objtype = c_otfield AND objcode = c_sgsay) OR ;
      (objtype = c_otpicture)) AND ;
      REFRESH = .T. AND (g_screens[m.g_thisscreen, 6] OR platform = g_screens[m.g_thisscreen, 7])
   IF m.sayfound
      IF NOT m.comment
         DO gencomment WITH "Show Code from screen: "+m.scrnname
         \#REGION <<INT(m.g_thisscreen)>>
      ENDIF
      IF !m.g_noreadplain    && not just emitting plain @ SAYs/GETs
         \IF SYS(2016) =
         IF m.iswindow
            \\ "<<UPPER(m.windowname)>>" OR SYS(2016) = "*"
            \	ACTIVATE WINDOW <<m.windowname>> SAME
         ELSE
            \\ "" OR SYS(2016) = "*"
            \	ACTIVATE SCREEN
         ENDIF
      ENDIF
      m.sayfound = .F.
   ENDIF

   IF objtype = c_otpicture
      DO genpicture
   ELSE
      m.theexpr = expr
      IF g_screens[m.g_thisscreen, 7] = 'WINDOWS' OR g_screens[m.g_thisscreen, 7] = 'MAC'
         SET DECIMALS TO 3
         m.occur = 1
         m.pos = AT(CHR(13), m.theexpr, m.occur)

         * Sometimes the screen builder surrounds text with single quotes and other
         * times with double quotes.
         q1 = LEFT(LTRIM(m.theexpr),1)

         DO WHILE m.pos > 0
            IF q1 = "'"
               m.theexpr = LEFT(m.theexpr, m.pos -1) + ;
                  "' + CHR(13) + ;" + CHR(13)  + CHR(9) + CHR(9) + "'" ;
                  + SUBSTR(m.theexpr, m.pos + 1)
            ELSE
               m.theexpr = LEFT(m.theexpr, m.pos -1) + ;
                  '" + CHR(13) + ;' + CHR(13)  + CHR(9) + CHR(9) + '"' ;
                  + SUBSTR(m.theexpr, m.pos + 1)
            ENDIF
            m.occur = m.occur + 1
            m.pos = AT(CHR(13), m.theexpr, m.occur)
         ENDDO
         IF mode = 1 AND objtype = c_otfield  AND objcode = c_sgsay    && transparent SAY text
            * Clear the space that the SAY is going into.  This makes refreshable SAYS
            * work with transparent fonts.
            \	@ <<Vpos>>,<<Hpos>> CLEAR TO <<Vpos+Height>>,<<Hpos+Width>>
         ENDIF
      ENDIF
      \	@ <<Vpos>>,<<Hpos>> SAY <<m.theexpr>> ;
      \		SIZE <<Height>>,<<Width>>, <<Spacing>>
      SET DECIMALS TO 0
      DO pushindent
      DO anyfont
      DO anystyle
      DO anypicture
      DO anyscheme
      DO popindent
   ENDIF
ENDSCAN
IF NOT m.sayfound
   \ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENCLOSEDBFS
*!
*!      Called by: GENCLNENVIRON      (procedure in GENSCRN.PRG)
*!
*!          Calls: COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!               : UNIQUEDBF()        (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genclosedbfs
*)
*) GENCLOSEDBFS - Generate code to close all previously opened databases.
*)
PRIVATE m.i, m.dbalias, m.dbfcnt, m.firstfound
m.firstfound = .T.
m.dbfcnt = 0
g_dbfs = ""
FOR m.i = 1 TO m.g_nscreens
   m.g_screen = m.i
   m.dbalias = g_screens[m.i,5]
   SELECT (m.dbalias)
   SCAN FOR objtype = c_otworkarea AND (g_screens[m.i, 6] OR platform = g_screens[m.i, 7])
      IF m.firstfound
         DO commentblock WITH ""," Closing Databases"
         m.firstfound = .F.
      ENDIF
      IF uniquedbf(TAG)
         m.dbfcnt = m.dbfcnt + 1
         DIMENSION g_dbfs[m.dbfcnt]
         g_dbfs[m.dbfcnt] = TAG
      ELSE
         LOOP
      ENDIF
      \IF USED("<<LOWER(stripext(strippath(Tag)))>>")
      \	SELECT <<LOWER(stripext(strippath(Tag)))>>
      \	USE
      \ENDIF
      \
   ENDSCAN
ENDFOR
m.g_screen = 0
IF m.g_closefiles
   \SELECT (m.currarea)
   \
ENDIF
DIMENSION g_dbfs[1]
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENOPENDBFS
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!               : UNIQUEDBF()        (function  in GENSCRN.PRG)
*!               : GENUSESTMTS        (procedure in GENSCRN.PRG)
*!               : STRIPPATH()        (function  in GENSCRN.PRG)
*!               : ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : GENRELATIONS       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genopendbfs
*)
*) GENOPENDBFS - Generate USE... statement(s).
*)
*) Description:
*) Generate code to open databases, set indexes, and relations as
*) specified by the user.
*)
PRIVATE m.dbalias, m.i, m.dbfcnt, m.string, m.msg, m.firstfound
m.firstfound = .T.
FOR m.i = 1 TO m.g_nscreens
   m.g_screen = m.i
   m.dbalias = g_screens[m.i,5]
   SELECT (m.dbalias)
   m.dbfcnt = 0
   SCAN FOR objtype = c_otworkarea AND (g_screens[m.i, 6] OR platform = g_screens[m.i, 7])
      IF m.firstfound
         DO commentblock WITH m.dbalias, ;
            " Databases, Indexes, Relations"
         m.firstfound = .F.
      ENDIF
      IF uniquedbf(TAG)
         m.dbfcnt = m.dbfcnt + 1
         DIMENSION g_dbfs[m.dbfcnt]
         g_dbfs[m.dbfcnt] = TAG
      ELSE
         LOOP
      ENDIF
      DO genusestmts WITH m.i
   ENDSCAN

   IF m.dbfcnt > 1
      IF NOT EMPTY(m.g_current)
         \SELECT <<m.g_current>>
      ELSE
         m.msg = "Please RE-SAVE screen environment... SCREEN: "+;
            strippath(g_screens[m.i,1])
         DO errorhandler WITH m.msg, LINENO(), c_error_1
      ENDIF
      \
   ENDIF
ENDFOR
m.g_screen = 0
DO genrelations
RETURN

*!*****************************************************************************
*!
*!       Function: UNIQUEDBF
*!
*!      Called by: GENCLOSEDBFS       (procedure in GENSCRN.PRG)
*!               : GENOPENDBFS        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION uniquedbf
*)
*) UNIQUEDBF - Check if database name already seen.
*)
PARAMETER m.dbfname
RETURN IIF(ASCAN(g_dbfs, m.dbfname)=0,.T.,.F.)

*!*****************************************************************************
*!
*!      Procedure: GENUSESTMTS
*!
*!      Called by: GENOPENDBFS        (procedure in GENSCRN.PRG)
*!
*!          Calls: FINDRELPATH()      (function  in GENSCRN.PRG)
*!               : GENORDER           (procedure in GENSCRN.PRG)
*!               : GENINDEXES()       (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genusestmts
*)
*) GENUSESTMTS - Generate USE... statements
*)
*) Description:
*) Generate USE... statements for each database encoded in the
*) screen database.  Generate ORDER statement if appropriate.
*)
PARAMETER m.i
PRIVATE m.workarea, saverecno, MARGIN, m.name, m.order, m.tag
m.workarea  = objcode
saverecno = RECNO()
m.order   = LOWER(ALLTRIM(ORDER))
m.tag     = LOWER(ALLTRIM(tag2))
m.name    = LOWER(TAG)
m.relpath = LOWER(findrelpath(name))

IF UNIQUE AND EMPTY(m.g_current)
   m.g_current = m.name
ENDIF

MARGIN = 4
IF EMPTY(name)
   \SELECT <<m.name>>
   RETURN
ENDIF
\IF USED("<<m.name>>")
\	SELECT <<m.name>>
IF genindexes ("select", m.i)=0
   indexfound = 0
   \	SET ORDER TO
   DO genorder WITH indexfound,m.order,m.tag,m.name
ELSE
   indexfound = 1
   \\ ADDITIVE ;
   \		ORDER
   DO genorder WITH indexfound,m.order,m.tag,m.name
ENDIF

\ELSE
\	SELECT 0
\	USE (LOCFILE("<<m.relpath>>","DBF",
\\"Where is <<basename(m.relpath)>>?"));
\		AGAIN ALIAS <<m.name>>
MARGIN = 42+LEN(m.relpath)+2*LEN(m.name)
= genindexes("use", m.i)

GOTO saverecno
\\ ;
\		ORDER
DO genorder WITH indexfound,m.order,m.tag,m.name
\ENDIF
\
RETURN

*!*****************************************************************************
*!
*!       Function: FINDRELPATH
*!
*!      Called by: GENUSESTMTS        (procedure in GENSCRN.PRG)
*!               : GENINDEXES()       (function  in GENSCRN.PRG)
*!               : GENPICTURE         (procedure in GENSCRN.PRG)
*!               : ANYBITMAPCTRL      (procedure in GENSCRN.PRG)
*!               : ANYWALLPAPER       (procedure in GENSCRN.PRG)
*!               : ANYICON            (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION findrelpath
*)
*) FINDRELPATH - Find relative path for DATABASES.
*)
PARAMETER m.name
PRIVATE m.fullpath, m.relpath
m.fullpath = UPPER(FULLPATH(m.name, g_screens[1,1]))
m.relpath  = SYS(2014, m.fullpath, UPPER(m.g_homedir))
RETURN m.relpath

*!*****************************************************************************
*!
*!      Procedure: GENORDER
*!
*!      Called by: GENUSESTMTS        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genorder
*)
*) GENORDER - Generate ORDER clause.
*)
PARAMETER m.indexfound, m.order, m.tag, m.dbfname
IF EMPTY(m.order) AND EMPTY(m.tag)
   \\ 0
   RETURN
ENDIF
IF m.indexfound=0
   \\ TAG "<<m.tag>>"
ELSE
   IF EMPTY(m.tag)
      \\ <<basename(m.order)>>
   ELSE
      \\ TAG "<<m.tag>>"
      IF NOT EMPTY (m.order)
         \\ OF <<m.order>>
      ENDIF
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: GENINDEXES
*!
*!      Called by: GENUSESTMTS        (procedure in GENSCRN.PRG)
*!
*!          Calls: FINDRELPATH()      (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION genindexes
*)
*) GENINDEXES - Generate index names for a USE statement.
*)
PARAMETER m.placement, m.i
PRIVATE m.idxcount, m.relpath
m.idxcount = 0

SCAN FOR objtype = c_otindex AND objcode = WORKAREA AND;
      (g_screens[m.i, 6] OR platform = g_screens[m.i, 7])
   m.relpath = LOWER(findrelpath(name))
   IF m.idxcount > 0
      IF MARGIN > 55
         MARGIN = 8 + LEN(m.relpath)
         \\, ;
         \		<<m.relpath>>
      ELSE
         \\, <<m.relpath>>
         MARGIN = MARGIN + 2 + LEN(m.relpath)
      ENDIF
   ELSE
      IF m.placement = "use"
         \\ ;
         \		INDEX <<m.relpath>>
         MARGIN = 8 + LEN(m.relpath)
      ELSE
         \	SET INDEX TO <<m.relpath>>
         MARGIN = 17
         MARGIN = MARGIN + LEN(m.relpath)
      ENDIF
   ENDIF
   m.idxcount = m.idxcount + 1
ENDSCAN
RETURN m.idxcount

*!*****************************************************************************
*!
*!      Procedure: GENRELATIONS
*!
*!      Called by: GENOPENDBFS        (procedure in GENSCRN.PRG)
*!
*!          Calls: SEEKHEADER         (procedure in GENSCRN.PRG)
*!               : GENRELSTMTS        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genrelations
*)
*) GENRELATIONS - Generate code to set all existing relations as they
*)				 are encoded in the screen file(s).
*)
*) Description:
*) Generate code for all relations as encoded in the screen database.
*)
PRIVATE m.dbalias, m.i
FOR m.i = 1 TO m.g_nscreens
   m.g_screen = m.i
   m.dbalias  = g_screens[m.i,5]
   SELECT (m.dbalias)

   DO seekheader WITH m.i
   DO genrelstmts WITH m.i
ENDFOR
m.g_screen = 0
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENRELSTMTS
*!
*!      Called by: GENRELATIONS       (procedure in GENSCRN.PRG)
*!
*!          Calls: BASENAME()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genrelstmts
*)
*) GENRELSTMTS - Generate relation statements.
*)
PARAMETER m.i
PRIVATE m.saverec, m.last, m.firstrel, m.firstsel, m.dbalias, m.setskip
m.dbalias  = ""
m.firstrel = .T.
m.firstsel = .T.
m.last     = 0
m.setskip  = ""

SCAN FOR objtype = c_otrel AND ;
      (g_screens[m.i, 6] OR platform = g_screens[m.i, 7])
   IF m.last<> objcode
      IF NOT (m.firstrel OR EMPTY(m.setskip))
         \SET SKIP TO <<m.setskip>>
         \
      ENDIF
      m.saverec = RECNO()
      m.last= objcode

      SCAN FOR objtype = c_otworkarea AND objcode = m.last AND ;
            (g_screens[m.i, 6] OR platform = g_screens[m.i, 7])
         m.dbalias = LOWER(basename(TAG))
         IF NOT (m.firstrel AND m.g_current = m.dbalias)
            \SELECT <<m.dbalias>>
         ENDIF
         m.setskip = ALLTRIM(LOWER(expr))
      ENDSCAN

      GOTO RECORD m.saverec
      m.firstrel = .F.
   ENDIF

   IF !(m.firstsel AND LOWER(tag2) == LOWER(m.g_current))
      \SELECT <<LOWER(Tag2)>>
      \
   ENDIF
   \SET RELATION OFF INTO <<LOWER(Tag)>>
   \SET RELATION TO <<LOWER(Expr)>> INTO <<LOWER(Tag)>> ADDITIVE
   \

   m.firstsel = .F.
ENDSCAN

IF m.last<> 0
   IF NOT EMPTY(m.setskip)
      \SET SKIP TO <<m.setskip>>
      \
   ENDIF
   IF NOT EMPTY(m.g_current)
      \SELECT <<m.g_current>>
   ENDIF
ENDIF
RETURN

**
** Code Associated With Building of the Format file statements.
**

*!*****************************************************************************
*!
*!      Procedure: BUILDFMT
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: MULTIPLAT()        (function  in GENSCRN.PRG)
*!               : VERSIONCAP()       (function  in GENSCRN.PRG)
*!               : PUTMSG             (procedure in GENSCRN.PRG)
*!               : SEEKHEADER         (procedure in GENSCRN.PRG)
*!               : COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!               : GENDIRECTIVE       (procedure in GENSCRN.PRG)
*!               : UPDTHERM           (procedure in GENSCRN.PRG)
*!               : ANYWINDOWS         (procedure in GENSCRN.PRG)
*!               : GENTEXT            (procedure in GENSCRN.PRG)
*!               : GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENBOXES           (procedure in GENSCRN.PRG)
*!               : GENLINES           (procedure in GENSCRN.PRG)
*!               : GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENINVBUT          (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENPICTURE         (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENACTISTMTS       (procedure in GENSCRN.PRG)
*!               : PLACEREAD          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE buildfmt
*)
*) BUILDFMT - Build Format file statements.
*)
*) Description:
*) Generate all boxes, text, fields, push buttons, radio buttons,
*) popups, check boxes and scrollable lists encoded in a screen set.
*)
PARAMETER pnum   && platform number
PRIVATE m.pos, m.dbalias, m.adjuster, m.recadjust, m.increment, m.i, m.sn
m.msg = 'Generating Screen Code'
IF multiplat()
   m.msg = m.msg + " for "+versioncap(m.g_genvers, m.g_dualoutput)
ENDIF
DO putmsg WITH m.msg
m.g_nwindows = 0
m.adjuster   = INT((c_therm4-c_therm3)/m.g_nscreens)  && total therm. range to cover
m.recadjust  = c_therm3                 && starting position for thermometer
FOR m.sn = 1 TO m.g_nscreens
   m.g_screen = m.sn
   m.dbalias = g_screens[m.sn,5]
   SELECT (m.dbalias)
   DO seekheader WITH m.sn

   DO commentblock WITH g_screens[m.sn,1], " Screen Layout"
   \#REGION <<INT(m.sn)>>
   IF ATC('#ITSE',setupcode)<>0
      DO gendirective WITH ;
         MLINE(setupcode,ATCLINE('#ITSE',setupcode)),;
         '#ITSE'
   ENDIF

   * Figure out thermometer increment
   IF g_screens[m.sn, 6] OR m.g_numplatforms = 1
      m.recs = RECCOUNT()
   ELSE
      GOTO TOP
      COUNT FOR platform = g_screens[m.sn, 7] TO m.recs
   ENDIF
   m.increment = m.adjuster/m.recs

   SCAN FOR (g_screens[m.sn, 6] OR platform = g_screens[m.sn, 7])
      m.recadjust = m.recadjust + m.increment

      DO updtherm WITH thermadj(m.pnum,INT(m.recadjust),c_therm5)

	  DO genusercode WITH c_premode

      DO CASE
      CASE objtype = c_otscreen
         DO anywindows WITH (m.sn)
      CASE objtype = c_ottext
         DO gentext
      CASE objtype = c_otfield
         DO genfields
      CASE objtype = c_otbox
         DO genboxes
      CASE objtype = c_otline
         DO genlines
      CASE objtype = c_ottxtbut
         DO genpush
      CASE objtype = c_otradbut
         DO genradbut
      CASE objtype = c_otinvbut
         DO geninvbut
      CASE objtype = c_otpopup
         DO genpopup
      CASE objtype = c_otchkbox
         DO genchkbox
      CASE objtype = c_otlist
         DO genlist
      CASE objtype = c_otpicture
         DO genpicture
      CASE objtype = c_otspinner
         DO genspinner
      ENDCASE

      DO genusercode WITH c_postmode

   ENDSCAN
   DO genactistmts WITH (m.sn)
   IF !m.g_noread
      DO placeread WITH (m.sn)
   ENDIF
ENDFOR
m.g_screen = 0
RETURN


*!*****************************************************************************
*!
*!      Procedure: GENUSERCODE
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genusercode
PARAMETER usermode
PRIVATE m.thelinenum, m.theline, m.thecommand, m.tagline

IF m.usermode = c_premode
	m.tagline = c_userprecode
ELSE
 	m.tagline = c_userpostcode
ENDIF

m.thelinenum = ATCLINE(m.tagline, comment)
IF m.thelinenum > 0
	m.theline = MLINE(comment, m.thelinenum)
	m.thecommand = ALLTRIM(SUBSTR(m.theline, LEN(m.tagline)+1))
	\<<m.thecommand>>
ENDIF

*!*****************************************************************************
*!
*!      Procedure: ANYWINDOWS
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: GENACTWINDOW       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anywindows
*)
*) ANYWINDOWS - Issue ACTIVATE WINDOW ... SAME.
*)
*) Description:
*) If windows present issue ACTIVATE WINDOW...SAME to make sure
*) that the windows stack on screen in the correct order.
*)
PARAMETER m.scrnno
PRIVATE m.pos
IF m.g_noreadplain
   RETURN
ENDIF

IF NOT EMPTY(STYLE)
   DO genactwindow WITH m.scrnno

   m.g_lastwindow = g_screens[m.scrnno,2]
   m.pos = ASCAN(g_wndows, m.g_lastwindow)
   * m.pos contains the element number (not the row) that matches.
   * The element number + 1 is a number representing window sequence.
   IF EMPTY(g_wndows[m.pos+1])
      m.g_nwindows = m.g_nwindows + 1
      g_wndows[m.pos+1] = m.g_nwindows
   ENDIF

   m.g_defasch1 = SCHEME
   m.g_defasch2 = scheme2
ELSE
   m.g_defasch1 = 0
   m.g_defasch2 = 0

   IF m.g_lastwindow<>""
      \HIDE WINDOW ALL
      \ACTIVATE SCREEN
      m.g_lastwindow = ""
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENACTISTMTS
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genactistmts
*)
*) GENACTISTMTS - Generate Activate window statements.
*)
*) Description:
*) Generate ACTIVATE WINDOW... statements in order to activate all
*) windows which have been previously activated with SAME clause.
*)
PARAMETER m.scrnno
PRIVATE m.j, m.pos
\
IF m.scrnno=m.g_nscreens AND NOT m.g_multreads AND NOT m.g_noreadplain
   IF m.g_nwindows = 1
      \IF NOT WVISIBLE("<<g_wndows[1,1]>>")
      \	ACTIVATE WINDOW <<g_wndows[1,1]>>
      \ENDIF
      RETURN
   ENDIF
   FOR m.j = m.g_nwindows TO 1 STEP -1
      m.pos = ASCAN(g_wndows, m.j)
      * pos contains the element *numbered* j.  This will be somewhere in g_wndows[*,2].
      * Look to the preceding element to get the window name.
      IF m.pos<>0
         \IF NOT WVISIBLE("<<g_wndows[m.pos-1]>>")
         \	ACTIVATE WINDOW <<g_wndows[m.pos-1]>>
         \ENDIF
      ENDIF
   ENDFOR
   \
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: PLACEREAD
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYMODAL           (procedure in GENSCRN.PRG)
*!               : ANYLOCK            (procedure in GENSCRN.PRG)
*!               : DOPLACECLAUSE      (procedure in GENSCRN.PRG)
*!               : GENWITHCLAUSE      (procedure in GENSCRN.PRG)
*!               : GENGIVENREAD       (procedure in GENSCRN.PRG)
*!               : COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!               : FINDREADCLAUSES    (procedure in GENSCRN.PRG)
*!               : GENREADCLAUSES     (procedure in GENSCRN.PRG)
*!               : GENCLAUSECODE      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE placeread
*)
*) PLACEREAD - Generate a 'READ' statement.
*)
*) Description:
*) Called once per screen in the screen set.
*) Generate a READ statement.  Depending on whether this is a single
*) or multiread the read statement may be generated between @...SAY/GETs
*) from each screen or at the end of a set of all @...SAY/GETs.
*)
PARAMETER m.scrnno
PRIVATE thispretext

\
IF m.g_multreads
   DO newreadclauses
   \READ
   IF m.g_readcycle AND m.scrnno = m.g_nscreens
      \\ CYCLE
   ENDIF
   DO anymodal
   DO anylock
   DO doplaceclause WITH m.scrnno
   DO genwithclause
   DO gengivenread WITH m.scrnno
ELSE
   IF NOT EMPTY(m.g_rddir) AND m.scrnno = m.g_nscreens
      DO commentblock WITH "","READ contains clauses from SCREEN "+;
         LOWER(g_screens[m.g_rddirno,5])
   ENDIF
   DO findreadclauses WITH m.scrnno
   IF m.scrnno = m.g_nscreens
      \READ
      IF m.g_readcycle
         \\ CYCLE
      ENDIF
      DO anymodal
      DO anylock
      DO genreadclauses
      DO genwithclause
      DO gengivenread WITH m.scrnno
      _TEXT = m.g_tmphandle
      m.thispretext = _PRETEXT
      _PRETEXT = ""
      DO genclausecode WITH m.scrnno
      _TEXT = m.g_orghandle
      _PRETEXT = m.thispretext
   ENDIF
ENDIF
\
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYMODAL
*!
*!      Called by: PLACEREAD          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
*)
*) ANYMODAL - Generate MODAL clause on READ.
*)
PROCEDURE anymodal
IF m.g_readmodal
   \\ MODAL
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYLOCK
*!
*!      Called by: PLACEREAD          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anylock
*)
*) ANYLOCK - Generate LOCK/NOLOCK clause on READ.
*)
IF m.g_readlock
   \\ NOLOCK
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENWITHCLAUSE
*!
*!      Called by: PLACEREAD          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genwithclause
*)
*) GENWITHCLAUSE - Generate WITH clause on a READ.
*)
IF NOT EMPTY(m.g_withlist)
   \\ ;
   \	WITH <<m.g_withlist>>
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: DOPLACECLAUSE
*!
*!      Called by: PLACEREAD          (procedure in GENSCRN.PRG)
*!
*!          Calls: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : FINDREADCLAUSES    (procedure in GENSCRN.PRG)
*!               : GENREADCLAUSES     (procedure in GENSCRN.PRG)
*!               : GENCLAUSECODE      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE doplaceclause
*)
*) DOPLACECLAUSE - Place READ level clauses for multiple reads.
*)
*) Description:
*) According to the read level clauses encoded in the screen file
*) set variables holding information about each clause.
*)
PARAMETER m.scrnno
PRIVATE thispretext
IF g_screens[m.scrnno, 6]
   LOCATE FOR objtype = c_otscreen
ELSE
   LOCATE FOR platform = g_screens[m.scrnno, 7] AND objtype = c_otscreen
ENDIF
IF NOT FOUND()
   DO errorhandler WITH "Error in SCX: Objtype=1 not found",;
      LINENO(), c_error_3
   RETURN
ENDIF

DO findreadclauses WITH m.scrnno
DO genreadclauses
_TEXT = m.g_tmphandle
m.thispretext = _PRETEXT
_PRETEXT = ""

DO genclausecode WITH m.scrnno
_TEXT = m.g_orghandle
_PRETEXT = m.thispretext
RETURN

*!*****************************************************************************
*!
*!      Procedure: FINDREADCLAUSES
*!
*!      Called by: PLACEREAD          (procedure in GENSCRN.PRG)
*!               : DOPLACECLAUSE      (procedure in GENSCRN.PRG)
*!
*!          Calls: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : SETCLAUSEFLAGS     (procedure in GENSCRN.PRG)
*!               : ORCLAUSEFLAGS      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE findreadclauses
*)
*) FINDREADCLAUSES - Find clauses for the final READ statement.
*)
*) Description:
*) Keep track of clauses that were already seen to determine what
*) clauses are placed on final read.  If this procedure is called for
*) a multiple read setting, flag's settings apply only to the current
*) screen.
*)
PARAMETER m.scrnno
PRIVATE m.dbalias, m.cur_rec
IF g_screens[m.scrnno,6]
   LOCATE FOR objtype = c_otscreen
ELSE
   LOCATE FOR platform = g_screens[m.scrnno, 7] AND objtype = c_otscreen
ENDIF
IF NOT FOUND()
   DO errorhandler WITH "Error in SCX: Objtype=1 not found",;
      LINENO(), c_error_3
   RETURN
ENDIF

IF EMPTY(m.g_validtype) AND !EMPTY(VALID)
   DO setclauseflags WITH validtype, VALID, m.g_validname,;
      m.g_validtype
ENDIF
IF EMPTY(m.g_whentype) AND !EMPTY(WHEN)
   DO setclauseflags  WITH whentype, WHEN, m.g_whenname,;
      m.g_whentype
ENDIF
IF EMPTY(m.g_actitype) AND !EMPTY(ACTIVATE)
   DO setclauseflags WITH activtype, ACTIVATE, m.g_actiname,;
      m.g_actitype
ENDIF
IF EMPTY(m.g_deattype) AND !EMPTY(DEACTIVATE)
   DO setclauseflags WITH deacttype, DEACTIVATE, m.g_deatname,;
      m.g_deattype
ENDIF

* SHOW is a special case since it can be generated with both procedures (for refreshable
* SAYs or just regular procedures) and expressions.  OR the flags together.
IF !EMPTY(SHOW)
   IF showtype != c_genexpr
      DO orclauseflags WITH showtype, SHOW, m.g_showname, m.g_showtype
   ELSE
      m.cur_rec = RECNO()
      * It's an expression, but look for refreshable SAYs too.
      LOCATE FOR ((objtype = c_otfield AND objcode = c_sgsay) OR (objtype = c_otpicture)) AND ;
         REFRESH = .T. AND (g_screens[m.scrnno, 6] OR platform = g_screens[m.scrnno, 7])
      IF FOUND()
         GOTO m.cur_rec
         DO orclauseflags WITH c_genboth, SHOW,   m.g_showname, m.g_showtype
      ELSE
         GOTO m.cur_rec
         DO orclauseflags WITH c_genexpr, SHOW,   m.g_showname, m.g_showtype
      ENDIF
      m.g_showexpr = m.g_showname
   ENDIF
ELSE
   * Look for refreshable SAYS
   LOCATE FOR ((objtype = c_otfield AND objcode = c_sgsay) OR (objtype = c_otpicture)) AND ;
      REFRESH = .T. AND (g_screens[m.scrnno, 6] OR platform = g_screens[m.scrnno, 7])
   IF FOUND()
      DO orclauseflags WITH c_gencode, SHOW,   m.g_showname, m.g_showtype
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: SETCLAUSEFLAGS
*!
*!      Called by: FINDREADCLAUSES    (procedure in GENSCRN.PRG)
*!
*!          Calls: GETCNAME()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE setclauseflags
*)
*) SETCLAUSEFLAGS - Load global flags with information about clauses.
*)
*) Description:
*) If a clause is a snippet then a generic name is provided for the
*) clause call statement in the READ and that same name is used to
*) construct the corresponding function.
*)
*) The BOTH setting is used for SHOW clauses that are defined as expressions,
*) in screens that also contain refreshable SAYS.  We have to generate a
*) procedure to contain the code to refresh the SAYS.
*)
PARAMETER m.flagtype, m.memo, m.name, m.type
DO CASE
CASE m.flagtype = c_genexpr
   m.name = m.memo
   m.type = "EXPR"
CASE m.flagtype = c_genboth
   m.name = m.memo
   m.type = "BOTH"
OTHERWISE
   m.name = getcname(m.memo)
   m.type = "CODE"
ENDCASE
RETURN

*!*****************************************************************************
*!
*!      Procedure: ORCLAUSEFLAGS
*!
*!      Called by: FINDREADCLAUSES    (procedure in GENSCRN.PRG)
*!
*!          Calls: GETCNAME()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE orclauseflags
*)
*) ORCLAUSEFLAGS - Logical OR two flagtypes
*)
PARAMETER m.flagtype, m.memo, m.name, m.type
DO CASE
CASE m.flagtype = c_genexpr
   m.name = m.memo
   IF INLIST(m.type,"BOTH","CODE")
      m.type = "BOTH"
   ELSE
      m.type = "EXPR"
   ENDIF
CASE m.flagtype = c_genboth
   m.name = m.memo
   m.type = "BOTH"
OTHERWISE
   * Code of some sort.  The expr code is different for expanded snippets, closed snippets, etc.
   * It is 2 for expanded snippets and 3 for minimized snippets, for example.
   m.name = getcname(m.memo)
   IF INLIST(m.type,"BOTH","EXPR")
      m.type = "BOTH"
   ELSE
      m.type = "CODE"
   ENDIF
ENDCASE
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENREADCLAUSES
*!
*!      Called by: PLACEREAD          (procedure in GENSCRN.PRG)
*!               : DOPLACECLAUSE      (procedure in GENSCRN.PRG)
*!
*!          Calls: GENCLAUSE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genreadclauses
*)
*) GENREADCLAUSES - Generate Clauses on a READ.
*)
*) Description:
*) Check if clause is appropriate, if so call GENCLAUSE to
*) generate the clause keyword.
*)
IF NOT EMPTY(m.g_validtype)
   DO genclause WITH "VALID", m.g_validname, m.g_validtype
ENDIF
IF NOT EMPTY(m.g_whentype)
   DO genclause WITH "WHEN", m.g_whenname, m.g_whentype
ENDIF
IF NOT EMPTY(m.g_actitype)
   DO genclause WITH "ACTIVATE", m.g_actiname, m.g_actitype
ENDIF
IF NOT EMPTY(m.g_deattype)
   DO genclause WITH "DEACTIVATE", m.g_deatname, m.g_deattype
ENDIF
IF NOT EMPTY(m.g_showtype)
   DO genclause WITH "SHOW", m.g_showname, m.g_showtype, m.g_showexpr
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENCLAUSE
*!
*!      Called by: GENREADCLAUSES     (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genclause
*)
*) GENCLAUSE - Generate Read Level Clause keyword.
*)
*) Description:
*) Generate SHOW,ACTIVATE,WHEN, or VALID clause keyword for a
*) READ statement.
*)
PARAMETER m.keyword, m.name, m.type, m.expr
PRIVATE m.codename
\\ ;
\	<<m.keyword>>
DO CASE
CASE m.type = "CODE"
   \\ <<m.name>>
   \\()
CASE m.type = "EXPR"
   \\ <<stripCR(m.name)>>
CASE m.type = "BOTH"
   * This is tricky.  We need to generate the user's expression followed by
   * a procedure, presumably containing code to handle refreshable SAYS in
   * a READ ... SHOW clause.  Right now, the name variable contains the
   * expression.  Emit it, generate a random name for the SHOW snippet, then
   * record that random name in the m.name field so that we can remember it
   * later.  The expression needs to come second (due to the boolean short-cutting
   * optimization in the interpreter).
   IF EMPTY(m.expr)
      m.codename = LOWER(SYS(2015))
      \\ <<m.codename>>() AND (<<stripCR(m.name)>>)
      m.name     = m.codename
   ELSE
      * There was an explicit expression passed to us.  Use it.
      m.codename = LOWER(SYS(2015))
      \\ <<m.codename>>() AND (<<stripCR(m.expr)>>)
      m.name     = m.codename
   ENDIF
ENDCASE
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENGIVENREAD
*!
*!      Called by: PLACEREAD          (procedure in GENSCRN.PRG)
*!
*!          Calls: SEEKHEADER         (procedure in GENSCRN.PRG)
*!               : GENDIRECTIVE       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gengivenread
*)
*) GENGIVENREAD - Generate another clause on the READ.
*)
PARAMETER m.screen
PRIVATE m.i, m.dbalias
IF m.g_multreads
   DO seekheader WITH m.screen

   IF ATC('#READ',setupcode) <> 0
      DO gendirective WITH ;
         MLINE(setupcode,ATCLINE('#READ',setupcode)),'#READ'
   ENDIF
ELSE
   FOR m.i = 1 TO m.g_nscreens
      m.g_screen = m.i
      m.dbalias = g_screens[m.i,5]
      SELECT (m.dbalias)
      DO seekheader WITH m.i

      IF ATC('#READ',setupcode)<>0
         DO gendirective WITH ;
            MLINE(setupcode,ATCLINE('#READ',setupcode)),'#READ'
         RETURN
      ENDIF
   ENDFOR
   m.g_screen = 0
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENDIRECTIVE
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!               : GENGIVENREAD       (procedure in GENSCRN.PRG)
*!               : DEFWINDOWS         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!          Calls: SKIPWHITESPACE()   (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gendirective
*)
*) GENDIRECTIVE - Process #ITSEXPRESSION, #READCLAUSES generator directives.
*)
PARAMETER m.line, m.directive
PRIVATE m.newline
IF ATC(m.directive,m.line)=1
   IF UPPER(m.directive) = '#REDE'
      m.g_redefi = .T.
      RETURN
   ENDIF
   m.newline = skipwhitespace(m.line)
   IF NOT EMPTY(m.newline)
      DO CASE
      CASE UPPER(m.directive) = '#READ'
         \\ ;
         \	<<UPPER(m.newline)>>
      CASE UPPER(m.directive) = '#WCLA'
         \\ ;
         \	<<UPPER(m.newline)>>
      CASE UPPER(m.directive) = '#ITSE'
         m.g_itse = SUBSTR(m.newline,1,1)
      ENDCASE
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: SKIPWHITESPACE
*!
*!      Called by: PREPWNAMES         (procedure in GENSCRN.PRG)
*!               : GENDIRECTIVE       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION skipwhitespace
*)
*) SKIPWHITESPACE - Trim all white space from parameter string.
*)
PARAMETER m.line
PRIVATE m.whitespace
m.whitespace = AT(' ',m.line)
IF m.whitespace = 0
   m.whitespace = AT(CHR(9),m.line)
ENDIF
m.line = ALLTRIM(SUBSTR(m.line,m.whitespace))
DO WHILE SUBSTR(m.line,1,1) = CHR(9)
   m.line = ALLTRIM(SUBSTR(m.line, 2))
ENDDO
RETURN m.line

**
** Code Generating Various Screen Objects
**

*!*****************************************************************************
*!
*!      Procedure: DEFPOPUPS
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: GENPOPDEFI         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE defpopups
*)
*) DEFPOPUPS - Define popups used in scrollable list definition.
*)
*) Description:
*) Define popup which is later used in the definition of a
*) scrollable list.
*)
PRIVATE m.i, m.dbalias, m.cnt, m.anylists
m.cnt = 0
FOR m.i = 1 TO m.g_nscreens
   m.g_screen = m.i
   m.anylists = .F.
   m.dbalias = g_screens[m.i,5]
   SELECT (m.dbalias)
   SCAN FOR objtype = c_otlist AND STYLE > 1 AND ;
         (g_screens[m.i, 6] OR platform = g_screens[m.i, 7])
      IF NOT m.anylists
         \
         \#REGION <<INT(m.i)>>
         m.anylists = .T.
         m.g_somepops = .T.
      ENDIF
      m.cnt = m.cnt + 1
      g_popups[m.cnt,1] = m.dbalias
      g_popups[m.cnt,2] = RECNO()
      g_popups[m.cnt,3] = LOWER(SYS(2015))

      IF MOD(m.cnt,25)=0
         DIMENSION g_popups[ALEN(g_popups,1)+25,3]
      ENDIF

      DO genpopdefi
   ENDSCAN
ENDFOR
m.g_screen = 0
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENPOPDEFI
*!
*!      Called by: DEFPOPUPS          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genpopdefi
*)
*) GENPOPDEFI
*)
IF m.g_noreadplain
   RETURN
ENDIF

\DEFINE POPUP <<g_popups[m.cnt,3]>> ;
DO CASE
CASE STYLE = 2
   \	PROMPT STRUCTURE
CASE STYLE = 3
   \	PROMPT FIELD <<ALLTRIM(Expr)>>
CASE STYLE = 4
   \	PROMPT FILES
   IF NOT EMPTY(expr)
      \\ LIKE <<ALLTRIM(Expr)>>
   ENDIF
ENDCASE
\\ ;
\	SCROLL
IF m.g_genvers = 'DOS' OR m.g_genvers = 'UNIX'
   \\ ;
   \	MARGIN ;
   \	MARK ""
   \
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: RELPOPUPS
*!
*!      Called by: GENCLNENVIRON      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE relpopups
*)
*) RELPOPUPS - Generate code to release generated popups.
*)
*) Description:
*) Generate code to release all popups defined by the generator
*) in conjunction with generating scrollable lists.
*)
PRIVATE m.popcnt, m.i, m.margin
m.popcnt = ALEN(g_popups,1)
m.margin = 16

IF EMPTY(g_popups[1,1]) OR m.g_noreadplain
   RETURN
ENDIF

\RELEASE POPUPS <<g_popups[1,3]>>
m.i = 2
DO WHILE m.i <= m.popcnt
   IF EMPTY(g_popups[m.i,1])
      RETURN
   ENDIF
   IF m.margin > 60
      m.margin = 4
      \\,;
      \	<<g_popups[m.i,3]>>
   ELSE
      \\, <<g_popups[m.i,3]>>
   ENDIF
   m.margin = m.margin + 3 + LEN(g_popups[m.i,3])
   m.i = m.i + 1
ENDDO
\
RETURN

*!*****************************************************************************
*!
*!      Procedure: DEFWINDOWS
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!               : GENDIRECTIVE       (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!               : GENDESKTOP         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE defwindows
*)
*) DEFWINDOWS - Generate code for windows.
*)
*) Description:
*) Generate code to define windows designed in the screen builder.
*) Process all SCX databases and if window definitions found
*) call GENWINDEFI to define the windows.
*)
PRIVATE m.dbalias, m.pos, m.savearea, m.row, m.col, m.firstfound, m.i
m.firstfound = .T.
m.savearea = SELECT()
FOR m.i = 1 TO m.g_nscreens
   m.g_screen = m.i
   m.dbalias = g_screens[m.i,5]
   SELECT (m.dbalias)

   SCAN FOR objtype = c_otscreen AND ;
         (g_screens[m.i, 6] OR platform = g_screens[m.i, 7])

      IF m.firstfound AND !m.g_noreadplain
         DO commentblock WITH ""," Window definitions"
         m.firstfound = .F.
      ENDIF

      IF NOT EMPTY(STYLE)
         IF ATC('#ITSE',setupcode)<>0
            DO gendirective WITH ;
               MLINE(setupcode,ATCLINE('#ITSE',setupcode)),'#ITSE'
         ENDIF
         IF ATC('#REDE',setupcode)<>0
            DO gendirective WITH ;
               MLINE(setupcode,ATCLINE('#REDE',setupcode)),'#REDE'
         ENDIF
         DO genwindefi WITH m.i
      ELSE
         IF ATC('#ITSE',setupcode)<>0
            DO gendirective WITH ;
               MLINE(setupcode,ATCLINE('#ITSE',setupcode)),'#ITSE'
         ENDIF
         DO gendesktop WITH m.i
      ENDIF
   ENDSCAN
ENDFOR
m.g_screen = 0
SELECT (m.savearea)
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENDESKTOP
*!
*!      Called by: DEFWINDOWS         (procedure in GENSCRN.PRG)
*!
*!          Calls: WINDOWFROMTO       (procedure in GENSCRN.PRG)
*!               : GETARRANGE         (procedure in GENSCRN.PRG)
*!               : ANYTITLEORFOOTER   (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYWINDOWCHARS     (procedure in GENSCRN.PRG)
*!               : ANYBORDER          (procedure in GENSCRN.PRG)
*!               : ANYWALLPAPER       (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!               : ANYICON            (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gendesktop
*)
*) GENDESKTOP - Generate statements to change the desktop font
*)
*) Description:
*) Generate code to change the desktop font if this screen is on
*) the desktop.  This is done only if the user chose the define window
*) option in the generate dialog.
*)
PARAMETER m.g_screen
PRIVATE m.center_flag, m.arrange_flag, m.row, m.col, m.j, m.entries

IF (g_screens[m.g_screen, 7] != 'WINDOWS' AND g_screens[m.g_screen, 7] != 'MAC')
   RETURN
ENDIF

m.center_flag = .F.
m.arrange_flag = .F.

IF NOT m.g_defwin
   RETURN
ENDIF

m.g_moddesktop = .T.

\MODIFY WINDOW SCREEN ;

IF g_screens[m.g_screen,6]
   DO windowfromto
   IF m.g_genvers = "WINDOWS" OR m.g_genvers = "MAC"
      \\ ;
      \	FONT "FoxFont", 9
   ENDIF
ELSE
   SELECT (m.g_projalias)
   GOTO RECORD g_screens[m.g_screen,3]

   DO getarrange WITH m.dbalias, m.arrange_flag, m.center_flag

   DO anytitleorfooter
   DO anyfont
   DO anystyle
   DO anywindowchars
   DO anyborder

   IF  !EMPTY(PICTURE)
      DO anywallpaper
   ELSE
      DO anyscheme
   ENDIF
   DO anyicon

   IF (CENTER OR m.center_flag) AND !m.arrange_flag
      \MOVE WINDOW SCREEN CENTER
   ENDIF
ENDIF
\CLEAR
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENWINDEFI
*!
*!      Called by: DEFWINDOWS         (procedure in GENSCRN.PRG)
*!
*!          Calls: UNIQUEWIN()        (function  in GENSCRN.PRG)
*!               : PUSHINDENT         (procedure in GENSCRN.PRG)
*!               : GETARRANGE         (procedure in GENSCRN.PRG)
*!               : ANYTITLEORFOOTER   (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYWINDOWCHARS     (procedure in GENSCRN.PRG)
*!               : ANYBORDER          (procedure in GENSCRN.PRG)
*!               : ANYWALLPAPER       (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!               : ANYICON            (procedure in GENSCRN.PRG)
*!               : GENDIRECTIVE       (procedure in GENSCRN.PRG)
*!               : POPINDENT          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genwindefi
*)
*) GENWINDEFI - Generate window definition
*)
*) Description:
*) Check to see if window name is unique, if not provide a unique name
*) with the use of SYS(2015) and display a warning message if
*) appropriate.  The window definition is generated only if the
*) user selected that option in the generator dialog.
*)
PARAMETER m.g_screen
PRIVATE m.name, m.pos, m.dupname, m.arrange_flag, m.center_flag, m.in_parms, m.j
m.arrange_flag = .F.
m.center_flag = .F.
m.dupname = .F.
m.name = IIF(!EMPTY(g_screens[m.g_screen,2]), g_screens[m.g_screen,2], LOWER(SYS(2015)))
m.pos = uniquewin(LOWER(m.name), m.g_nwindows, @g_wndows)
IF m.pos = 0
   m.dupname = .T.
   m.name = LOWER(SYS(2015))
   g_screens[m.g_screen,2] = m.name
   m.pos = uniquewin(m.name, m.g_nwindows, @g_wndows)
ENDIF

* Insert one row (two elements)
= AINS(g_wndows, m.pos)
g_wndows[m.pos,1] = m.name
g_wndows[m.pos,2] = .F.  && it will get a sequence number in AnyWindows
m.g_nwindows = m.g_nwindows + 1

m.g_windows = .T.
IF NOT m.g_defwin
   RETURN
ENDIF

IF NOT m.g_redefi
   \IF NOT WEXIST("<<m.name>>")
   * We can safely omit this extra code if the name was a randomly generated one
   IF  UPPER(LEFT(m.name,2)) <> UPPER(LEFT(SYS(2015),2))
      \\ ;
      \	OR UPPER(WTITLE("<<UPPER(m.name)>>")) == "<<UPPER(forceext(m.name,'PJX'))>>" ;
      \	OR UPPER(WTITLE("<<UPPER(m.name)>>")) == "<<UPPER(forceext(m.name,'SCX'))>>" ;
      \	OR UPPER(WTITLE("<<UPPER(m.name)>>")) == "<<UPPER(forceext(m.name,'MNX'))>>" ;
      \	OR UPPER(WTITLE("<<UPPER(m.name)>>")) == "<<UPPER(forceext(m.name,'PRG'))>>" ;
      \	OR UPPER(WTITLE("<<UPPER(m.name)>>")) == "<<UPPER(forceext(m.name,'FRX'))>>" ;
      \	OR UPPER(WTITLE("<<UPPER(m.name)>>")) == "<<UPPER(forceext(m.name,'QPR'))>>"
   ENDIF
   DO pushindent
ENDIF
\DEFINE WINDOW <<m.name>> ;

SELECT (m.g_projalias)
GOTO RECORD g_screens[m.g_screen,3]

DO getarrange WITH m.dbalias, m.arrange_flag, m.center_flag

DO anytitleorfooter
DO anyfont
DO anystyle
DO anywindowchars
DO anyborder

IF (g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC')
   IF TAB
      \\ ;
      \	HALFHEIGHT
   ENDIF
   IF  !EMPTY(PICTURE)
      DO anywallpaper
   ELSE
      DO anyscheme
   ENDIF
   DO anyicon
ELSE
   DO anyscheme
ENDIF

* If the user defined additional window clauses, put them here
IF ATC("#WCLA",setupcode) > 0
   DO gendirective WITH ;
      MLINE(setupcode,ATCLINE('#WCLA',setupcode)),'#WCLA'
ENDIF

* Emit the MOVE WINDOW ... CENTER after all the window clauses have been emitted
IF (g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC')
   IF (CENTER OR m.center_flag) AND !m.arrange_flag
      \MOVE WINDOW <<m.name>> CENTER
   ENDIF
ENDIF

IF !m.g_redefi
   DO popindent
   \ENDIF
ENDIF
\
RETURN

*!*****************************************************************************
*!
*!      Procedure: GETARRANGE
*!
*!      Called by: GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!          Calls: WINDOWFROMTO       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE getarrange
PARAMETER m.dbalias, m.arrange_flag, m.center_flag
PRIVATE m.j, m.pname, m.entries, m.row, m.col
IF !EMPTY(arranged)
   m.entries = INT(LEN(arranged)/26)
   m.j = 1
   DO WHILE m.j <= m.entries
      m.pname = ALLTRIM(UPPER(SUBSTR(arranged,(m.j-1)*26+1,8)))
      m.pname = ALLTRIM(CHRTRAN(m.pname,CHR(0)," "))
      IF m.pname == m.g_genvers    && found the right one
         IF INLIST(UPPER(SUBSTR(arranged,(m.j-1)*26 + 9,1)),'Y','T')    && is it arranged?
            IF INLIST(UPPER(SUBSTR(arranged,(m.j-1)*26 +10,1)),'Y','T') && is it centered?
               m.center_flag = .T.
            ELSE
               m.arrange_flag = .T.
               m.row = VAL(SUBSTR(arranged,(m.j-1)*26 + 11,8))
               m.col = VAL(SUBSTR(arranged,(m.j-1)*26 + 19,8))
            ENDIF
         ENDIF
         EXIT
      ENDIF
      m.j = m.j + 1
   ENDDO
ENDIF
SELECT (m.dbalias)
IF m.arrange_flag
   DO windowfromto WITH m.row, m.col
ELSE
   DO windowfromto
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENBOXES
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYPATTERN         (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!               : ANYPEN             (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genboxes
*)
*) GENBOXES - Generate code for boxes.
*)
*) Description:
*) Generate code to display all boxes as they appear on the painted
*) screen(s).  Note since there is no FILL clause on @...TO command
*) we use the command @...BOX whenever the fill option has been chosen.
*) If Fill option is not chosen, then we use the simpler form for
*) generating boxes, @...TO command which supplies us with clauses
*) DOUBLE and PANEL for the box borders.
*)
PRIVATE m.bottom, m.right, m.thisbox
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
   m.bottom = HEIGHT+vpos
   m.right = WIDTH+hpos
ELSE
   m.bottom = HEIGHT+vpos-1
   m.right = WIDTH+hpos-1
ENDIF
IF (m.g_genvers = 'WINDOWS' OR m.g_genvers = 'MAC')
   IF fillchar <> c_null AND fillchar <> " "
      \@ <<Vpos>>,<<Hpos>>,<<m.bottom>>,<<m.right>>
      DO CASE
      CASE objcode = c_sgbox
         m.thisbox = c_single
         \\ BOX "<<m.thisbox>><<Fillchar>>"
      CASE objcode = c_sgboxd
         m.thisbox = c_double
         \\ BOX "<<m.thisbox>><<Fillchar>>"
      CASE objcode = c_sgboxp
         m.thisbox = c_panel
         \\ BOX "<<m.thisbox>><<Fillchar>>"
      CASE objcode = c_sgboxc
         IF boxchar = '"'
            \\ BOX REPLICATE('<<Boxchar>>',8)
         ELSE
            \\ BOX REPLICATE("<<Boxchar>>",8)
         ENDIF
         IF fillchar = '"'
            \\+'<<Fillchar>>'
         ELSE
            \\+"<<Fillchar>>"
         ENDIF
      ENDCASE
      SET DECIMALS TO 0
      RETURN
   ELSE
      \@ <<Vpos>>,<<Hpos>> TO <<m.bottom>>,<<m.right>>
   ENDIF
ELSE
   IF fillchar <> c_null
      \@ <<Vpos>>,<<Hpos>>,<<m.bottom>>,<<m.right>>
      DO CASE
      CASE objcode = c_sgbox
         m.thisbox = c_single
         \\ BOX "<<m.thisbox>><<Fillchar>>"
      CASE objcode = c_sgboxd
         m.thisbox = c_double
         \\ BOX "<<m.thisbox>><<Fillchar>>"
      CASE objcode = c_sgboxp
         m.thisbox = c_panel
         \\ BOX "<<m.thisbox>><<Fillchar>>"
      CASE objcode = c_sgboxc
         IF boxchar = '"'
            \\ BOX REPLICATE('<<Boxchar>>',8)
         ELSE
            \\ BOX REPLICATE("<<Boxchar>>",8)
         ENDIF
         IF fillchar = '"'
            \\+'<<Fillchar>>'
         ELSE
            \\+"<<Fillchar>>"
         ENDIF
      ENDCASE

      IF (!EMPTY(colorpair) OR SCHEME <> 0)
         * Color the inside of the box if it is filled with something.
         \@ <<Vpos>>,<<Hpos>> FILL TO <<m.bottom>>,<<m.right>>
         DO anypattern
         DO anyscheme
      ENDIF
      SET DECIMALS TO 0
      RETURN
   ELSE
      \@ <<Vpos>>,<<Hpos>> TO <<m.bottom>>,<<m.right>>
   ENDIF
ENDIF

SET DECIMALS TO 0
DO CASE
CASE objcode = c_sgboxd
   \\ DOUBLE
CASE objcode = c_sgboxp
   \\ PANEL
CASE objcode = c_sgboxc
   IF boxchar = '"'
      \\ '<<Boxchar>>'
   ELSE
      \\ "<<Boxchar>>"
   ENDIF
ENDCASE
DO anypattern
DO anypen
DO anystyle
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENLINES
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYPEN             (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genlines
*)
*) GENLINES - Generate code for lines.
*)
*) Description:
*) Generate code to display all lines as they appear on the painted
*) screen(s).
*)
PRIVATE m.x, m.y
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
   IF STYLE = 0
      m.x = HEIGHT+vpos
      m.y = hpos
   ELSE
      m.x = vpos
      m.y = WIDTH+hpos
   ENDIF
ELSE
   m.x = HEIGHT+vpos-1
   m.y = WIDTH+hpos-1
ENDIF

\@ <<Vpos>>,<<Hpos>> TO <<m.x>>,<<m.y>>
SET DECIMALS TO 0
IF BORDER = 1
   \\ DOUBLE
ENDIF
DO anypen
DO anystyle
DO anyscheme
RETURN


*!*****************************************************************************
*!
*!      Procedure: GENTEXT
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYPICTURE         (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gentext
*)
*) GENTEXT - Generate code for text.
*)
*) Description:
*) Generate code that will display the text exactly as it appears
*) in the painted screen(s).
*)
PRIVATE m.theexpr, m.occur, m.pos
m.theexpr = expr
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
   m.occur = 1
   m.pos = AT(CHR(13), m.theexpr, m.occur)
   * Sometimes the screen builder surrounds text with single quotes and other
   * times with double quotes.
   q1 = LEFT(LTRIM(m.theexpr),1)

   DO WHILE m.pos > 0
      DO CASE
      CASE q1 = "'"
         m.theexpr = LEFT(m.theexpr, m.pos -1) + ;
            "' + CHR(13) + ;" + CHR(13)  + CHR(9) + CHR(9) + "'" ;
            + SUBSTR(m.theexpr, m.pos + 1)
      CASE q1 = '['
         m.theexpr = LEFT(m.theexpr, m.pos -1) + ;
            "] + CHR(13) + ;" + CHR(13)  + CHR(9) + CHR(9) + "[" ;
            + SUBSTR(m.theexpr, m.pos + 1)
      OTHERWISE
         m.theexpr = LEFT(m.theexpr, m.pos -1) + ;
            '" + CHR(13) + ;' + CHR(13)  + CHR(9) + CHR(9) + '"' ;
            + SUBSTR(m.theexpr, m.pos + 1)
      ENDCASE
      m.occur = m.occur + 1
      m.pos = AT(CHR(13), m.theexpr, m.occur)
   ENDDO
   \@ <<Vpos>>,<<Hpos>> SAY <<m.theexpr>>
   IF height > 1
      \\ ;
      \	SIZE <<Height>>,<<Width>>, <<Spacing>>
   ENDIF
ELSE
   \@ <<Vpos>>,<<Hpos>> SAY <<m.theexpr>> ;
   \	SIZE <<Height>>,<<Width>>, <<Spacing>>
ENDIF

SET DECIMALS TO 0
DO anypicture
DO anyfont
DO anystyle
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENFIELDS
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYPICTURE         (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!               : ELEMRANGE          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENDEFAULT         (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!               : ANYDISABLED        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genfields
*)
*) GENFIELDS - Generate fields.
*)
*) Description:
*) Generate code to display SAY, GET, and EDIT statements exactly as they
*) appear in the painted screen(s).
*)
PRIVATE m.theexpr
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF
DO CASE
CASE objcode = c_sgsay
   m.theexpr = expr
   \@ <<Vpos>>,<<Hpos>> SAY <<m.theexpr>> ;
   \	SIZE <<Height>>,<<Width>>
   SET DECIMALS TO 0
   DO anyfont
   DO anystyle
   DO anypicture
   DO anyscheme
   RETURN
CASE objcode = c_sgget
   \@ <<Vpos>>,<<Hpos>> GET <<Name>> ;
   \	SIZE <<Height>>,<<Width>>
   DO elemrange
CASE objcode = c_sgedit
   DO gentxtrgn
   RETURN
ENDCASE
SET DECIMALS TO 0

DO gendefault
DO anyfont
DO anystyle
DO anypicture
DO anywhen
DO anyvalid
DO anymessage
DO anyerror
DO anydisabled
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENINVBUT
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYDISABLED        (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE geninvbut
*)
*) GENINVBUT - Generate Invisible buttons.
*)
*) Description:
*) Generate code to display invisible buttons exactly as they appear
*) in the painted screen(s).
*)

IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF
\@ <<Vpos>>,<<Hpos>> GET <<Name>> ;
\	PICTURE <<Picture>> ;
\	SIZE <<Height>>,<<Width>>,<<Spacing>> ;
\	DEFAULT 0
SET DECIMALS TO 0

DO anyfont
DO anystyle
DO anywhen
DO anyvalid
DO anydisabled
DO anymessage
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENTXTRGN
*!
*!      Called by: GENFIELDS          (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYPICTURE         (procedure in GENSCRN.PRG)
*!               : GENDEFAULT         (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYTAB             (procedure in GENSCRN.PRG)
*!               : ANYSCROLL          (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!               : ANYDISABLED        (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gentxtrgn
*)
*) GENTXTRGN - Generate some statements for text edit region.
*)
*) Description:
*) Generate code to display text edit regions exactly as they
*) appear on the painted screen(s).
*)
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF
\@ <<Vpos>>,<<Hpos>> EDIT <<Name>> ;
\	SIZE <<IIF(Height < 1, 1, Height)>>,<<Width>>,<<Initialnum>>
SET DECIMALS TO 0

IF NOT EMPTY(PICTURE)
   DO anypicture
ENDIF
DO gendefault
DO anyfont
DO anystyle
DO anytab
DO anyscroll
DO anywhen
DO anyvalid
DO anymessage
DO anyerror
DO anydisabled
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENPUSH
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYBITMAPCTRL      (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYDISABLED        (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genpush
*)
*) GENPUSH - Generate Push buttons.
*)
*) Description:
*) Generate code to display push buttons exactly as they appear
*) in the painted screen(s).
*)
PRIVATE m.thepicture

m.thepicture = PICTURE
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF
\@ <<Vpos>>,<<Hpos>> GET <<Name>> ;
DO anybitmapctrl WITH m.thepicture
\	SIZE <<Height>>,<<Width>>,<<Spacing>> ;
SET DECIMALS TO 0
\	DEFAULT <<Initialnum>>
DO anyfont
DO anystyle
DO anywhen
DO anyvalid
DO anydisabled
DO anymessage
DO anyerror
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENRADBUT
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYBITMAPCTRL      (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYDISABLED        (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genradbut
*)
*) GENRADBUT - Generate Radio Buttons.
*)
*) Description:
*) Generate code to display radio buttons exactly as they appear
*) in the painted screen(s).
*)
PRIVATE m.thepicture

m.thepicture = PICTURE
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF
\@ <<Vpos>>,<<Hpos>> GET <<Name>> ;
DO anybitmapctrl WITH m.thepicture
\	SIZE <<Height>>,<<Width>>,<<Spacing>> ;
SET DECIMALS TO 0
\	DEFAULT <<Initialnum>>
DO anyfont
DO anystyle
DO anywhen
DO anyvalid
DO anydisabled
DO anymessage
DO anyerror
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENCHKBOX
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ANYBITMAPCTRL      (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYDISABLED        (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genchkbox
*)
*) GENCHKBOX - Generate Check Boxes
*)
*) Description:
*) Generate code to display check boxes exactly as they appear
*) in the painted screen(s).
*)
PRIVATE m.thepicture

m.thepicture = PICTURE
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF

\@ <<Vpos>>,<<Hpos>> GET <<Name>> ;
DO anybitmapctrl WITH m.thepicture
\	SIZE <<Height>>,<<Width>> ;
SET DECIMALS TO 0
\	DEFAULT <<Initialnum>>
DO anyfont
DO anystyle
DO anywhen
DO anyvalid
DO anydisabled
DO anymessage
DO anyerror
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENLIST
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: CHOPPICTURE        (procedure in GENSCRN.PRG)
*!               : ELEMRANGE          (procedure in GENSCRN.PRG)
*!               : FROMPOPUP          (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYDISABLED        (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genlist
*)
*) GENLIST - Generate Scrollable Lists.
*)
*) Description:
*) Generate code to display scrollable lists exactly as they appear
*) in the painted screen(s).
*)
PRIVATE m.pos, m.start
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF
\@ <<Vpos>>,<<Hpos>> GET <<Name>> ;
SET DECIMALS TO 0
IF NOT EMPTY(PICTURE)
   \ 	PICTURE
   DO choppicture WITH PICTURE
   \\ ;
ENDIF
IF STYLE = 0
   \	FROM <<Expr>>
   DO elemrange
   \\ ;
   IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
      SET DECIMALS TO 3
   ENDIF
   \	SIZE <<Height>>,<<Width>> ;
   SET DECIMALS TO 0
   \	DEFAULT 1
ELSE
   DO frompopup
ENDIF

DO anyfont
DO anystyle
DO anywhen
DO anyvalid
DO anydisabled
DO anymessage
DO anyerror
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENPICTURE
*!
*!      Called by: PLACESAYS          (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: FINDRELPATH()      (function  in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genpicture
*)
*) GENPICTURE - Generate code for pictures.
*)
*) Description:
*) Generate code to display pictures (bitmaps or bitmaps in general fields).
*)
PRIVATE m.relpath
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
   \@ <<Vpos>>,<<Hpos>> SAY
   IF STYLE = 0
      m.relpath = LOWER(findrelpath(SUBSTR(PICTURE,2,LEN(PICTURE)-2)))
		IF EMPTY(justext(m.relpath))
		   m.relpath = m.relpath + "."
		ENDIF
      \\ (LOCFILE("<<m.relpath>>",<<bitmapstr(c_all)>>, "Where is <<basename(m.relpath)>>?"
		IF _MAC
			* Use the "type" parameter to get all PICT files on the Mac,
			* regardless of extension.
			\\, "PICT"
		ENDIF
		\\ )) BITMAP ;
   ELSE
      \\ <<Name>> ;
   ENDIF
   \	SIZE <<Height>>,<<Width>>

   IF CENTER
      \\ ;
      \	CENTER
   ENDIF

   DO CASE
   CASE BORDER = 1
      \\ ;
      \	ISOMETRIC
   CASE BORDER = 2
      \\ ;
      \	STRETCH
   ENDCASE

   SET DECIMALS TO 0
   DO anystyle
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENSPINNER
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: CHOPPICTURE        (procedure in GENSCRN.PRG)
*!               : GENDEFAULT         (procedure in GENSCRN.PRG)
*!               : ELEMRANGE          (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYDISABLED        (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genspinner
*)
*) GENSPINNER - Generate Spinners
*)
*) Description:
*) Generate code to display spinners exactly as they appear
*) in the painted screen(s).
*)
PRIVATE m.thepicture

m.thepicture = PICTURE
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF

\@ <<Vpos>>,<<Hpos>> GET <<Name>> ;
\	SPINNER

** Generate the increment value
IF !EMPTY(initialval)
   IF INT(VAL(initialval)) <> VAL(initialval)
      SET DECIMALS TO LEN(initialval) - AT('.',initialval)
   ENDIF
   \\ <<VAL(Initialval)>>
   SET DECIMALS TO 3
ELSE
   \\ 1.000
ENDIF

** Generate the minimum value.
IF !EMPTY(TAG)
   \\, <<Tag>>
ELSE
   IF !EMPTY(tag2)
      \\,
   ENDIF
ENDIF

** Generate the maximum value.
IF !EMPTY(tag2)
   \\, <<Tag2>>
ENDIF
\\ ;

IF !EMPTY(m.thepicture)
   \	PICTURE
   DO choppicture WITH m.thepicture
   \\ ;
ENDIF
\	SIZE <<Height>>, <<Width>>

** Put out a default which corresponds to the range of valid values.
DO CASE
CASE !EMPTY(TAG)
   \\ ;
   \	DEFAULT <<VAL(Tag)>>
CASE !EMPTY(tag2)
   \\ ;
   \	DEFAULT <<VAL(Tag2)>>
CASE EMPTY(TRIM(initialval))
   \\ ;
   \	DEFAULT 1
OTHERWISE
   DO gendefault
ENDCASE

DO elemrange
DO anywhen
DO anyvalid
DO anydisabled
DO anymessage
DO anyerror
SET DECIMALS TO 0
DO anyfont
DO anystyle
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: FROMPOPUP
*!
*!      Called by: GENLIST            (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE frompopup
*)
*) FROMPOPUP - Generate code for scrollable list defined from a popup.
*)
*) Description:
*) Generate POPUP <popup name> code as part of a scrollable list
*) definition.  Popup name may either be name explicitly provided by
*) the user or a unique name generated by SYS(2015) function.
*)
PRIVATE m.start, m.pos
\	POPUP
IF STYLE < 2
   IF NOT EMPTY(expr)
      \\ <<Expr>> ;
   ENDIF
ELSE
   m.start = 1
   m.pos   = 0
   DO WHILE .T.
      m.pos = ASCAN(g_popups, m.dbalias, m.start)
      IF g_popups[m.pos+1] = RECNO()
         EXIT
      ENDIF
      m.start = m.pos + 3
   ENDDO
   \\ <<g_popups[m.pos+2]>> ;
ENDIF

IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF
\	SIZE <<Height>>,<<Width>> ;
\	DEFAULT " "
SET DECIMALS TO 0
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENPOPUP
*!
*!      Called by: BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!          Calls: ELEMRANGE          (procedure in GENSCRN.PRG)
*!               : ANYFONT            (procedure in GENSCRN.PRG)
*!               : ANYSTYLE           (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYDISABLED        (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!               : ANYSCHEME          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genpopup
*)
*) GENPOPUP - Generate Popups.
*)
*) Description:
*) Generate code to display popups exactly as they appear in the
*) painted screen(s).
*)
PRIVATE m.thepicture, m.theinitval

IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF
\@ <<Vpos>>,<<Hpos>> GET <<Name>> ;
IF objcode = c_sgget
   m.thepicture = PICTURE
   m.theinitval = initialval
   \	PICTURE <<m.thepicture>> ;
   \	SIZE <<Height>>,<<Width>> ;
   \	DEFAULT <<IIF(EMPTY(m.theinitval), '" "', m.theinitval)>>
ELSE
	* e.g., popup from array
   \	PICTURE "<<ctrlclause(picture)>>" ;
   \	FROM <<Expr>> ;
   \	SIZE <<Height>>,<<Width>>
   DO elemrange
   \\ ;
   \	DEFAULT 1
ENDIF
SET DECIMALS TO 0

DO anyfont
DO anystyle
DO anywhen
DO anyvalid
DO anydisabled
DO anymessage
DO anyerror
DO anyscheme
RETURN

*!*****************************************************************************
*!
*!      Procedure: ELEMRANGE
*!
*!      Called by: GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!
*!          Calls: ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE elemrange
*)
*) ELEMRANGE - Element range clause for popup and scrollable list
*)				defined form an array.
*)
PRIVATE m.firstelem, m.genericname
m.firstelem = .F.
IF NOT EMPTY(rangelo)
   m.firstelem = .T.
   \\ ;
   \	RANGE
   IF lotype = 0
      \\ <<ALLTRIM(CHRTRAN(Rangelo,CHR(13)+CHR(10),""))>>
   ELSE
      m.genericname = LOWER(SYS(2015))
      \\ <<m.genericname>>()
      DO CASE
      CASE objtype = c_otfield
         DO addtoctrl WITH m.genericname, "GET Low RANGE", rangelo, name
      CASE objtype = c_otspinner
         DO addtoctrl WITH m.genericname, "SPINNER Low RANGE", rangelo, name
      OTHERWISE
         DO addtoctrl WITH m.genericname, "Popup From", rangelo, name
      ENDCASE
   ENDIF
ENDIF
IF NOT EMPTY(rangehi)
   IF NOT m.firstelem
      \\ ;
      \	RANGE ,
   ELSE
      \\,
   ENDIF
   IF hitype = 0
      \\ <<CHRTRAN(ALLTRIM(Rangehi),CHR(13)+CHR(10),"")>>
   ELSE
      m.genericname = LOWER(SYS(2015))
      \\ <<m.genericname>>()
      DO CASE
      CASE objtype = c_otfield
         DO addtoctrl WITH m.genericname, "GET High RANGE", rangehi, name
      CASE objtype = c_otspinner
         DO addtoctrl WITH m.genericname, "SPINNER High RANGE", rangehi, name
      OTHERWISE
         DO addtoctrl WITH m.genericname, "Popup From", rangehi, name
      ENDCASE
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENACTWINDOW
*!
*!      Called by: ANYWINDOWS         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genactwindow
*)
*) GENACTWINDOW - Generate Activate Window Command.
*)
*) Description:
*) Generate the ACTIVATE WINDOW... command.
*)
PARAMETER m.cnt
IF !m.g_noreadplain
   IF m.g_lastwindow == g_screens[m.cnt,2]
      \@ 0,0 CLEAR
   ENDIF
   IF m.g_multreads
      \ACTIVATE WINDOW <<g_screens[m.cnt,2]>>
      RETURN
   ENDIF

   \IF WVISIBLE("<<g_screens[m.cnt,2]>>")
   \	ACTIVATE WINDOW <<g_screens[m.cnt,2]>> SAME
   \ELSE
   \	ACTIVATE WINDOW <<g_screens[m.cnt,2]>> NOSHOW
   \ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENDEFAULT
*!
*!      Called by: GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gendefault
*)
*) GENDEFAULT - Generate Default Clause.
*)
PRIVATE m.theinitval
IF EMPTY(TRIM(initialval)) AND EMPTY(fillchar)
   RETURN
ENDIF
\\ ;
\	DEFAULT
IF EMPTY(TRIM(initialval))
   DO CASE
   CASE fillchar = "D"
      \\ {  /  /  }
   CASE fillchar = "C" OR fillchar = "M" OR fillchar = "G"
      \\ " "
   CASE fillchar = "L"
      \\ .F.
   CASE fillchar = "N"
      \\ 0
   CASE fillchar = "F"
      \\ 0.0
   ENDCASE
ELSE
   m.theinitval = initialval
   \\ <<ALLTRIM(m.theinitval)>>
ENDIF
RETURN

**
**  Procedures Generating Various Clauses for Screen Objects
**

*!*****************************************************************************
*!
*!      Procedure: ANYBITMAPCTRL
*!
*!      Called by: GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!
*!          Calls: FINDRELPATH()      (function  in GENSCRN.PRG)
*!               : CHOPPICTURE        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anybitmapctrl
*)
*) ANYBITMAPCTRL - Parse the picture clause for a bitmap control (Push button, radio button, checkbox) and return it
*)		with LOCAFILE and a relative path in place of each absolute path.
*)
PARAMETER m.picture
PRIVATE m.name, m.relpath, m.count

IF AT("B", SUBSTR(m.picture,1, AT(" ",m.picture))) <> 0
   \	PICTURE <<LEFT(m.picture, AT(" ",m.picture))>>"

   m.picture = SUBSTR(m.picture, AT(" ", m.picture)+1)
   m.picture = LEFT(m.picture, LEN(m.picture)-1)
   m.count = 0

   DO WHILE LEN(m.picture) <> 0
      m.count = m.count + 1
      IF AT(";", m.picture) <> 0
         m.name = LEFT(m.picture, AT(";", m.picture)-1)
         m.picture = SUBSTR(m.picture, AT(";",m.picture)+1)
      ELSE
         m.name = m.picture
         m.picture = ""
      ENDIF

      m.relpath = LOWER(findrelpath(m.name))

      IF m.count = 1
         \\ + ;
      ELSE
         \\ + ";" + ;
      ENDIF
		IF EMPTY(justext(m.relpath))
		   m.relpath = m.relpath + "."
		ENDIF
      \		(LOCFILE("<<m.relpath>>",<<bitmapstr(c_all)>>,"Where is <<basename(m.relpath)>>?"
		IF _MAC
			\\,"PICT"
		ENDIF
		\\))
   ENDDO

   \\ ;
ELSE
   \	PICTURE
   DO choppicture WITH m.picture
   \\ ;
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: CHOPPICTURE
*!
*!      Called by: GENLIST            (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : ANYBITMAPCTRL      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE choppicture
*)
*) CHOPPICTURE - Breaks a Picture clause into multiple 250 character segments to avoid
*)		the maximum string length limit.
*)
PARAMETER m.pict
PRIVATE m.quotechar, m.first
m.quotechar = LEFT(m.pict,1)
m.first = .T.

DO WHILE LEN(m.pict) > 250
   IF m.first
      \\ <<LEFT(m.pict,250) + m.quotechar>> + ;
      m.first = .F.
   ELSE
      \		<<LEFT(m.pict,250) + m.quotechar>> + ;
   ENDIF
   m.pict = m.quotechar + SUBSTR(m.pict,251)
ENDDO

IF m.first
   \\ <<m.pict>>
ELSE
   \	<<m.pict>>
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYDISABLED
*!
*!      Called by: GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENINVBUT          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anydisabled
*)
*) ANYDISABLED - Place ENABLE/DISABLE clause.
*)
IF disabled
   \\ ;
   \	DISABLE
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYPICTURE
*!
*!      Called by: PLACESAYS          (procedure in GENSCRN.PRG)
*!               : GENTEXT            (procedure in GENSCRN.PRG)
*!               : GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anypicture
*)
*) ANYPICTURE
*)
PRIVATE m.string, m.expr_pos, m.newstring
IF NOT EMPTY(PICTURE) AND PICTURE <> '" "'
   \\ ;
   m.string = SUBSTR(PICTURE,2)   && drop opening quotation mark
   DO CASE
   CASE SUBSTR(m.string,1,1) = m.g_itse
      \	PICTURE <<SUBSTR(m.string,2,RAT(LEFT(picture,1),m.string)-2)>>
   CASE hasexpr(m.string) > 0 && an #ITSEXPRESSION character somewhere in the middle
   	m.expr_pos = hasexpr(picture)
   	* Emit the first part of the PICTURE
   	\	PICTURE <<LEFT(picture,expr_pos-1)>>
   	* Emit a closing quotation mark, which will be the same as the opening one
   	\\<<LEFT(picture,1)>>
   	* Now emit the expression portion of the picture clause, not including a closing quote
   	\\ + <<SUBSTR(picture,expr_pos+1,LEN(picture)-expr_pos-1))>>
   OTHERWISE
      \	PICTURE <<Picture>>
   ENDCASE
ENDIF


FUNCTION hasexpr
PARAMETER m.thepicture
RETURN ATC(m.g_itse,m.thepicture)

*!*****************************************************************************
*!
*!      Procedure: ANYSCROLL
*!
*!      Called by: GENTXTRGN          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anyscroll
*)
*) ANYSCROLL - Place Scroll clause if applicable.
*)
IF scrollbar
   \\ ;
   \	SCROLL
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYTAB
*!
*!      Called by: GENTXTRGN          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anytab
*)
*) ANYTAB - Place Tab clause on an @...EDIT command.
*)
IF TAB
   \\ ;
   \	TAB
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYFONT
*!
*!      Called by: PLACESAYS          (procedure in GENSCRN.PRG)
*!               : GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!               : GENTEXT            (procedure in GENSCRN.PRG)
*!               : GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENINVBUT          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anyfont
*)
*) ANYFONT - Place font clause on an object if in a graphical
*)		environment
*)
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   \\ ;
   \	FONT "<<Fontface>>", <<Fontsize>>
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYSTYLE
*!
*!      Called by: PLACESAYS          (procedure in GENSCRN.PRG)
*!               : GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!               : GENBOXES           (procedure in GENSCRN.PRG)
*!               : GENLINES           (procedure in GENSCRN.PRG)
*!               : GENTEXT            (procedure in GENSCRN.PRG)
*!               : GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENINVBUT          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENPICTURE         (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anystyle
*)
*) ANYSTYLE - Place a Style clause in an object.
*)
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   IF NOT EMPTY(fontstyle) OR mode != 0 OR ;
         (NOT EMPTY(STYLE) AND objtype != c_otscreen AND ;
         objtype != c_ottext )
      \\ ;
      \	STYLE "
		\\<<num2style(fontstyle)>>

		* Is it transparent?
      IF mode = 1
         \\T
      ENDIF

      IF NOT EMPTY(STYLE) AND objtype != c_otscreen AND ;
            objtype != c_otlist AND objtype != c_ottext AND ;
						objtype != c_otpicture
         \\<<Style>>
      ENDIF
      \\"
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYPATTERN
*!
*!      Called by: GENBOXES           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anypattern
*)
*) ANYPATTERN - Place a PATTERN clause for boxes.
*)
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   IF fillpat != 0
      \\ ;
      \	PATTERN <<Fillpat>>
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYSCHEME
*!
*!      Called by: PLACESAYS          (procedure in GENSCRN.PRG)
*!               : GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!               : GENBOXES           (procedure in GENSCRN.PRG)
*!               : GENLINES           (procedure in GENSCRN.PRG)
*!               : GENTEXT            (procedure in GENSCRN.PRG)
*!               : GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENINVBUT          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anyscheme
*)
*) ANYSCHEME - Place Color Scheme clause if applicable.
*)

IF NOT EMPTY(colorpair)
   \\ ;
   \	COLOR <<Colorpair>>
   RETURN
ENDIF
IF SCHEME <> 0
   \\ ;
   \	COLOR SCHEME <<Scheme>>
   IF objtype = c_otpopup AND scheme2<>0
      \\, <<Scheme2>>
   ENDIF
ELSE
   IF m.g_defasch2 <> 0
      DO CASE
      CASE objtype = c_ottext AND HEIGHT > 1
         \\ ;
         \	COLOR SCHEME <<m.g_defasch2>>
      CASE objtype = c_otlist
         \\ ;
         \	COLOR SCHEME <<m.g_defasch2>>
      CASE objtype = c_otpopup
         \\ ;
         \	COLOR SCHEME <<m.g_defasch1>>, <<m.g_defasch2>>
      ENDCASE
   ELSE
      IF (g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC' ) ;
            AND ((ObjTYpe = c_otscreen AND fillred >=0) ;
             OR (ObjType <> c_otscreen AND (penred >= 0 OR fillred >= 0)) )
         m.ctrlflag = .F.   && .T. if this is a control-type object (e.g., radio button)
         \\ ;
         \	COLOR
         DO CASE
         CASE INLIST(objtype,c_otfield,c_otspinner)
            ** Field or spinner - color pair 2
            DO CASE
            CASE objcode = c_sgget OR objcode = c_sgedit
               \\ ,RGB(
            CASE objcode = c_sgsay
               \\ RGB(
            CASE objcode = c_sgfrom
               \\ ,,,,,,,,RGB(
            ENDCASE

         CASE objtype = c_otlist
            m.ctrlflag = .T.    && remember that this is a control object
            \\ RGB(


         CASE objtype = c_ottext OR objtype = c_otscreen OR ;
               objtype = c_otbox OR objtype = c_otline
            ** Text, Box, Line, or Screen - color pair 1
            \\ RGB(

         OTHERWISE
            m.ctrlflag = .T.    && remember that this is a control object
            \\ ,,,,,,,,RGB(
         ENDCASE

         IF penred >= 0
            \\<<Penred>>,<<Pengreen>>,<<Penblue>>,
         ELSE
            \\,,,
         ENDIF
         IF fillred >= 0
            \\<<Fillred>>,<<Fillgreen>>,<<Fillblue>>)
         ELSE
            \\,,,)
         ENDIF

         IF m.ctrlflag AND INLIST(objtype, c_otradbut, c_otchkbox, c_otpopup,c_otlist)
            * Add one more RGB clause to control the disabled colors for control
            * objects such as radio buttons, check boxes, popups, etc.
            \\,RGB(
            IF penred >= 0
               \\<<Penred>>,<<Pengreen>>,<<Penblue>>,
            ELSE
               \\,,,
            ENDIF
            IF fillred >= 0
               \\<<Fillred>>,<<Fillgreen>>,<<Fillblue>>)
            ELSE
               \\,,,)
            ENDIF
         ENDIF
      ENDIF
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYPEN
*!
*!      Called by: GENBOXES           (procedure in GENSCRN.PRG)
*!               : GENLINES           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anypen
*)
*) ANYPEN - Place Color Scheme clause if applicable.
*)
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   \\ ;
   \	PEN <<Pensize>>, <<Penpat>>
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYVALID
*!
*!      Called by: GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENINVBUT          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!
*!          Calls: GETCNAME()         (function  in GENSCRN.PRG)
*!               : ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anyvalid
*)
*) ANYVALID - Place Valid clause if applicable.
*)
PRIVATE m.genericname, m.valid
IF NOT EMPTY(VALID)
   \\ ;
   IF validtype = 0
      m.valid = VALID
      \	VALID <<stripcr(m.valid)>>
   ELSE
      m.genericname = getcname(VALID)
      \	VALID <<m.genericname>>()
      DO addtoctrl WITH m.genericname, "VALID", VALID, name
   ENDIF
ENDIF

*!*****************************************************************************
*!
*!      Procedure: ANYTITLEORFOOTER
*!
*!      Called by: GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anytitleorfooter
*)
*) ANYTITLEORFOOTER - Place Window Title/Footer clause.
*)
PRIVATE m.string, m.thetag
IF NOT EMPTY(TAG)
   \\ ;
   m.string = SUBSTR(TAG,2)
   IF SUBSTR(m.string,1,1) = m.g_itse
      \	TITLE <<SUBSTR(m.string, 2, RAT('"',m.string)-2)>>
   ELSE
      m.thetag = TAG
      \	TITLE <<m.thetag>>
   ENDIF
ENDIF
IF NOT EMPTY(tag2)
   \\ ;
   m.string = SUBSTR(tag2,2)
   IF SUBSTR(m.string,1,1) = m.g_itse
      \	FOOTER <<SUBSTR(m.string, 2, RAT('"',m.string)-2)>>
   ELSE
      m.thetag = tag2
      \	FOOTER <<m.thetag>>
   ENDIF
ENDIF
RETURN


*!*****************************************************************************
*!
*!      Procedure: ANYWHEN
*!
*!      Called by: GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENINVBUT          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!
*!          Calls: GETCNAME()         (function  in GENSCRN.PRG)
*!               : ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anywhen
*)
*) ANYWHEN - Place a When clause in a Get field.
*)
PRIVATE m.genericname, m.when
IF EMPTY(WHEN)
   RETURN
ENDIF
\\ ;
IF whentype = 0
   m.when = WHEN
   \	WHEN <<stripcr(m.when)>>
ELSE
   m.genericname = getcname(WHEN)
   \	WHEN <<m.genericname>>()
   DO addtoctrl WITH m.genericname, "WHEN", WHEN, name
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYMESSAGE
*!
*!      Called by: GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENINVBUT          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!
*!          Calls: GETCNAME()         (function  in GENSCRN.PRG)
*!               : ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anymessage
*)
*) ANYMESSAGE - Place a message clause whenever appropriate.
*)
PRIVATE m.genericname, m.mess
IF EMPTY(MESSAGE)
   RETURN
ENDIF
\\ ;
IF messtype = 0
   m.mess = MESSAGE
   \	MESSAGE
   \\ <<stripcr(m.mess)>>
ELSE
   m.genericname = getcname(MESSAGE)
   \	MESSAGE <<m.genericname>>()
   DO addtoctrl WITH m.genericname, "MESSAGE", MESSAGE, name
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYERROR
*!
*!      Called by: GENFIELDS          (procedure in GENSCRN.PRG)
*!               : GENTXTRGN          (procedure in GENSCRN.PRG)
*!               : GENPUSH            (procedure in GENSCRN.PRG)
*!               : GENRADBUT          (procedure in GENSCRN.PRG)
*!               : GENCHKBOX          (procedure in GENSCRN.PRG)
*!               : GENLIST            (procedure in GENSCRN.PRG)
*!               : GENSPINNER         (procedure in GENSCRN.PRG)
*!               : GENPOPUP           (procedure in GENSCRN.PRG)
*!
*!          Calls: GETCNAME()         (function  in GENSCRN.PRG)
*!               : ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anyerror
*)
*) ANYERROR - Place an error clause whenever appropriate.
*)
PRIVATE m.genericname, m.err
IF EMPTY(ERROR)
   RETURN
ENDIF
\\ ;
IF errortype = 0
   m.err = ERROR
   \	ERROR
   \\ <<stripcr(m.err)>>
ELSE
   m.genericname = getcname(ERROR)
   \	ERROR <<m.genericname>>()
   DO addtoctrl WITH m.genericname, "ERROR", ERROR, name
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYFILL
*!
*!*****************************************************************************
PROCEDURE anyfill
*)
*) ANYFILL - Place the Fill clause whenever appropriate.
*)
IF fillchar <> c_null
   \\ ;
   \	FILL "<<Fillchar>>"
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYWINDOWCHARS
*!
*!      Called by: GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anywindowchars
*)
*) ANYWINDOWCHARS - Place window characteristics options.
*)
*) Description:
*) Place the FLOAT, GROW, CLOSE, ZOOM, SHADOW, and MINIMIZE clauses
*) for a window painted by the user.
*)
\\ ;
\	<<IIF(Float, "FLOAT ;", "NOFLOAT ;")>>
\	<<IIF(Close, "CLOSE", "NOCLOSE")>>
IF SHADOW
   \\ ;
   \	SHADOW
ENDIF
IF m.g_genvers <> "MAC"
	IF MINIMIZE
   	\\ ;
   	\	MINIMIZE
	ELSE
   	\\ ;
   	\	NOMINIMIZE
	ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYBORDER
*!
*!      Called by: GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anyborder
*)
*) ANYBORDER - Place Border type clause on a box.
*)
*) Description:
*) Place border type clause on a box depending on the setting of
*) the field Border.
*)
IF BORDER<>1
   \\ ;
ENDIF

DO CASE
CASE BORDER = 0
   \	NONE
CASE BORDER = 2
   \	DOUBLE
CASE BORDER = 3
   \	PANEL
CASE BORDER = 4
   \	SYSTEM
ENDCASE
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYWALLPAPER
*!
*!      Called by: GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!          Calls: FINDRELPATH()      (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anywallpaper
*)
*) ANYWALLPAPER - Place FILL FILE clause on any window.
*)
IF !EMPTY(PICTURE)
   m.relpath = findrelpath(SUBSTR(PICTURE, 2, LEN(PICTURE) - 2))
	IF !EMPTY(basename(m.relpath))
      \\ ;
      \	FILL FILE LOCFILE("<<m.relpath>>",<<bitmapstr(c_all)>>, ;
      \		"Where is <<LOWER(basename(m.relpath))>>?")
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ANYICON
*!
*!      Called by: GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!          Calls: FINDRELPATH()      (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE anyicon
*)
*) ANYICON - Place ICON FILE clause on any window.
*)
IF !EMPTY(ORDER) AND ORDER <> '""'
   m.relpath = findrelpath(SUBSTR(ORDER, 2, LEN(ORDER) - 2))
	IF !EMPTY(basename(m.relpath))
      \\ ;
      \	ICON FILE LOCFILE("<<m.relpath>>","<<iconstr()>>", ;
      \		"Where is <<LOWER(basename(m.relpath))>>?")
   ENDIF
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: WINDOWFROMTO
*!
*!      Called by: GENDESKTOP         (procedure in GENSCRN.PRG)
*!               : GETARRANGE         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE windowfromto
*)
*) WINDOWFROMTO - Place FROM...TO clause on any window.
*)
*) Description:
*) Place FROM...TO clause on any window designed in the screen
*) painter.  If window is to be centered, then adjust the coordinates
*) accordingly.
*)
PARAMETER m.xcoord, m.ycoord
IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
   SET DECIMALS TO 3
ENDIF
IF PARAMETERS() = 0
   IF CENTER
      IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
         \	AT  <<Vpos>>, <<Hpos>>  ;
         \	SIZE <<Height>>,<<Width>>
      ELSE
         \	FROM INT((SROW()-<<Height>>)/2),
         \\INT((SCOL()-<<Width>>)/2) ;
         \	TO INT((SROW()-<<Height>>)/2)+<<Height-1>>,
         \\INT((SCOL()-<<Width>>)/2)+<<Width-1>>
      ENDIF
   ELSE
      IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
         \	AT <<Vpos>>, <<Hpos>> ;
         \	SIZE <<Height>>,<<Width>>
      ELSE
         \	FROM <<Vpos>>, <<Hpos>> ;
         \	TO <<Height+Vpos-1>>,<<Width+Hpos-1>>
      ENDIF
   ENDIF
ELSE
   IF g_screens[m.g_screen, 7] = 'WINDOWS' OR g_screens[m.g_screen, 7] = 'MAC'
      \	AT <<m.xcoord>>, <<m.ycoord>> ;
      \	SIZE <<Height>>,<<Width>>
   ELSE
      \	FROM <<m.xcoord>>, <<m.ycoord>> ;
      \	TO <<Height+m.xcoord-1>>,<<Width+m.ycoord-1>>
   ENDIF
ENDIF
SET DECIMALS TO 0
RETURN

**
** Code Generating Documentation in Control and Format files.
**

*!*****************************************************************************
*!
*!      Procedure: HEADER
*!
*!      Called by: BUILDCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE HEADER
*)
*) HEADER - Generate application program's header.
*)
*) Description:
*) As a part of the application's header generate program name, name
*) of the author of the program, copyright notice, company name and
*) address, and the word 'Description:' which will be followed with
*) the application description generated by a separate procedure.
*)
IF LEN(_PRETEXT) <> 0
   \
ENDIF
\\*       <<m.g_corn1>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_verti1>> <<DATE()>>
\\<<PADC(UPPER(ALLTRIM(strippath(m.g_outfile))),IIF(SET("CENTURY")="ON",35,37))," ")>>
\\  <<TIME()>> <<m.g_verti2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_corn5>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn6>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_verti1>> <<m.g_devauthor>>
\\<<SAFEREPL(" ",56-LEN(m.g_devauthor))>><<m.g_verti2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_verti1>>
\\ Copyright (c) <<YEAR(DATE())>>
IF LEN(ALLTRIM(m.g_devcompany)) <= 36
   \\ <<ALLTRIM(m.g_devcompany)>>
   \\<<SAFEREPL(" ",37-LEN(ALLTRIM(m.g_devcompany)))>>
   \\<<m.g_verti2>>
ELSE
   \\ <<SAFEREPL(" ",37)>><<m.g_verti2>>
   \*       <<m.g_verti1>> <<m.g_devcompany>>
   \\<<SAFEREPL(" ",56-LEN(m.g_devcompany))>><<m.g_verti2>>
ENDIF
\*       <<m.g_verti1>> <<m.g_devaddress>>
\\<<SAFEREPL(" ",56-LEN(m.g_devaddress))>><<m.g_verti2>>

\*       <<m.g_verti1>> <<ALLTRIM(m.g_devcity)>>, <<m.g_devstate>>
\\  <<ALLTRIM(m.g_devzip)>>
\\<<SAFEREPL(" ",50-(LEN(ALLTRIM(m.g_devcity)+ALLTRIM(m.g_devzip))))>>
\\<<m.g_verti2>>

IF !INLIST(ALLTRIM(UPPER(m.g_devctry)),"USA","COUNTRY") AND !EMPTY(m.g_devctry)
   \*       <<m.g_verti1>> <<ALLTRIM(m.g_devctry)>>
   \\<<SAFEREPL(" ",50-(LEN(ALLTRIM(m.g_devctry))))>>
   \\<<m.g_verti2>>
ENDIF

\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_verti1>> Description:
\\                                            <<m.g_verti2>>
\*       <<m.g_verti1>>
\\ This program was automatically generated by GENSCRN.
\\    <<m.g_verti2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_corn3>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn4>>
\
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENFUNCHEADER
*!
*!      Called by: VALICLAUSE         (procedure in GENSCRN.PRG)
*!               : WHENCLAUSE         (procedure in GENSCRN.PRG)
*!               : ACTICLAUSE         (procedure in GENSCRN.PRG)
*!               : DEATCLAUSE         (procedure in GENSCRN.PRG)
*!               : SHOWCLAUSE         (procedure in GENSCRN.PRG)
*!               : ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE genfuncheader
*)
*) GENFUNCHEADER - Generate Comment for Function/Procedure.
*)
PARAMETER m.procname, m.from, m.readlevel, m.varname
m.g_snippcnt = m.g_snippcnt + 1
\
\*       <<m.g_corn1>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
IF m.readlevel
   \*       <<m.g_verti1>>
   \\ <<UPPER(m.procname)>>           <<m.from>>
   \\<<SAFEREPL(" ",45-LEN(m.procname+m.from))>><<m.g_verti2>>
ELSE
   \*       <<m.g_verti1>>
   \\ <<UPPER(m.procname)>>           <<m.varname>> <<m.from>>
   \\<<SAFEREPL(" ",44-LEN(m.procname+m.varname+m.from))>><<m.g_verti2>>
ENDIF
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_verti1>> Function Origin:
\\<<SAFEREPL(" ",40)>><<m.g_verti2>>
IF m.readlevel
   \*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
   \*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
   \*       <<m.g_verti1>> From Platform:
   \\       <<VersionCap(m.g_genvers, .F.)>>
   \\<<SAFEREPL(" ",35-LEN(VersionCap(m.g_genvers, .F.)))>>
   \\<<m.g_verti2>>
   \*       <<m.g_verti1>> From Screen:
   IF m.g_nscreens > 1 AND NOT m.g_multread
      \\         Multiple Screens
      \\<<SAFEREPL(" ",19)>><<m.g_verti2>>
   ELSE
      \\         <<basename(SYS(2014,DBF()))>>
      \\<<SAFEREPL(" ",35-LEN(basename(SYS(2014,DBF()))))>>
      \\<<m.g_verti2>>
   ENDIF
   \*       <<m.g_verti1>> Called By:           READ Statement
   \\<<SAFEREPL(" ",21)>><<m.g_verti2>>
   \*       <<m.g_verti1>> Snippet Number:
   \\      <<ALLTRIM(STR(m.g_snippcnt,2))>>
   \\<<SAFEREPL(" ",35-LEN(ALLTRIM(STR(m.g_snippcnt,2))))>><<m.g_verti2>>
   \*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
   \*       <<m.g_corn3>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn4>>
   \*
   RETURN
ENDIF
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_verti1>> From Platform:
\\       <<VersionCap(m.g_genvers, .F.)>>
\\<<SAFEREPL(" ",35-LEN(VersionCap(m.g_genvers, .F.)))>>
\\<<m.g_verti2>>
\*       <<m.g_verti1>> From Screen:
\\         <<basename(SYS(2014,DBF()))>>
\\,     Record Number:  <<STR(RECNO(),3)>>
\\<<SAFEREPL(" ",10-LEN(basename(SYS(2014,DBF())+STR(RECNO(),3))))>>
\\<<m.g_verti2>>
IF NOT EMPTY(m.varname)
   \*       <<m.g_verti1>> Variable:            <<m.varname>>
   \\<<SAFEREPL(" ",35-LEN(m.varname))>><<m.g_verti2>>
ENDIF
\*       <<m.g_verti1>> Called By:           <<m.from+" Clause">>
\\<<SAFEREPL(" ",35-LEN(m.from+" Clause"))>><<m.g_verti2>>
IF OBJECT(objtype) <> ""
   \*       <<m.g_verti1>> Object Type:
   \\         <<Object(Objtype)>>
   \\<<SAFEREPL(" ",35-LEN(Object(Objtype)))>><<m.g_verti2>>
ENDIF
\*       <<m.g_verti1>> Snippet Number:
\\      <<ALLTRIM(STR(m.g_snippcnt,3))>>
\\<<SAFEREPL(" ",35-LEN(ALLTRIM(STR(m.g_snippcnt,3))))>><<m.g_verti2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_corn3>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn4>>
\*
RETURN

*!*****************************************************************************
*!
*!      Procedure: COMMENTBLOCK
*!
*!      Called by: GENCLEANUP         (procedure in GENSCRN.PRG)
*!               : PUTPROCHEAD        (procedure in GENSCRN.PRG)
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : GENSECT2           (procedure in GENSCRN.PRG)
*!               : GENCLOSEDBFS       (procedure in GENSCRN.PRG)
*!               : GENOPENDBFS        (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!               : PLACEREAD          (procedure in GENSCRN.PRG)
*!               : DEFWINDOWS         (procedure in GENSCRN.PRG)
*!
*!          Calls: BASENAME()         (function  in GENSCRN.PRG)
*!               : VERSIONCAP()       (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE commentblock
*)
*) COMMENTBLOCK - Generate a comment block.
*)
PARAMETER m.dbalias, m.string
PRIVATE m.msg
IF !EMPTY(basename(m.dbalias))
   m.msg = basename(m.dbalias)+"/"+versioncap(m.g_genvers, .F.)+m.string
ELSE
   m.msg = versioncap(m.g_genvers, .F.)+m.string
ENDIF
\
\*       <<m.g_corn1>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_verti1>>
\\ <<PADC(m.msg,55," ")>>
\\ <<m.g_verti2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_corn3>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn4>>
\*
\

*!*****************************************************************************
*!
*!      Procedure: PROCCOMMENTBLOCK
*!
*!      Called by: EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!
*!          Calls: BASENAME()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE proccommentblock
*)
*) PROCCOMMENTBLOCK - Generate a procedure comment block.
*)
PARAMETER m.dbalias, m.string
PRIVATE m.msg
m.msg = basename(m.dbalias)+m.string
\
\*       <<m.g_corn1>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_verti1>>
\\ <<PADC(m.msg,55," ")>>
\\ <<m.g_verti2>>
\*       <<m.g_verti1>><<SAFEREPL(" ",57)>><<m.g_verti2>>
\*       <<m.g_corn3>><<SAFEREPL(m.g_horiz,57)>><<m.g_corn4>>
\*
\
RETURN

*!*****************************************************************************
*!
*!      Procedure: GENCOMMENT
*!
*!      Called by: GENVALIDBODY       (procedure in GENSCRN.PRG)
*!               : GENWHENBODY        (procedure in GENSCRN.PRG)
*!               : ACTICLAUSE         (procedure in GENSCRN.PRG)
*!               : DEATCLAUSE         (procedure in GENSCRN.PRG)
*!               : SHOWCLAUSE         (procedure in GENSCRN.PRG)
*!               : PLACESAYS          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE gencomment
*)
*) GENCOMMENT - Generate a comment.
*)
PARAMETER m.msg
\*
\* <<m.msg>>
\*

*!*****************************************************************************
*!
*!      Procedure: SAFEREPL
*!
*!*****************************************************************************
FUNCTION saferepl
* REPLICATE shell
PARAMETER m.strg, m.num
RETURN REPLICATE(m.strg, max(m.num, 0))

**
** General Supporting Routines
**

*!*****************************************************************************
*!
*!       Function: BASENAME
*!
*!      Called by: PREPSCREENS()      (function  in GENSCRN.PRG)
*!               : GENVALIDBODY       (procedure in GENSCRN.PRG)
*!               : GENWHENBODY        (procedure in GENSCRN.PRG)
*!               : ACTICLAUSE         (procedure in GENSCRN.PRG)
*!               : DEATCLAUSE         (procedure in GENSCRN.PRG)
*!               : SHOWCLAUSE         (procedure in GENSCRN.PRG)
*!               : GENRELSTMTS        (procedure in GENSCRN.PRG)
*!               : COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!               : PROCCOMMENTBLOCK   (procedure in GENSCRN.PRG)
*!
*!          Calls: STRIPPATH()        (function  in GENSCRN.PRG)
*!               : STRIPEXT()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION basename
PARAMETER m.filename
RETURN strippath(stripext(m.filename))

*!*****************************************************************************
*!
*!       Function: STRIPEXT
*!
*!      Called by: OPENPROJDBF()      (function  in GENSCRN.PRG)
*!               : BASENAME()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION stripext
*)
*) STRIPEXT - Strip the extension from a file name.
*)
*) Description:
*) Use the algorithm employed by FoxPRO itself to strip a
*) file of an extension (if any): Find the rightmost dot in
*) the filename.  If this dot occurs to the right of a "\"
*) or ":", then treat everything from the dot rightward
*) as an extension.  Of course, if we found no dot,
*) we just hand back the filename unchanged.
*)
*) Parameters:
*) filename - character string representing a file name
*)
*) Return value:
*) The string "filename" with any extension removed
*)
PARAMETER m.filename
PRIVATE m.dotpos, m.terminator
m.dotpos = RAT(".", m.filename)
m.terminator = MAX(RAT("\", m.filename), RAT(":", m.filename))
IF m.dotpos > m.terminator
   m.filename = LEFT(m.filename, m.dotpos-1)
ENDIF
RETURN m.filename

*!*****************************************************************************
*!
*!       Function: STRIPPATH
*!
*!      Called by: GENOPENDBFS        (procedure in GENSCRN.PRG)
*!               : BASENAME()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION strippath
*)
*) STRIPPATH - Strip the path from a file name.
*)
*) Description:
*) Find positions of backslash in the name of the file.  If there is one
*) take everything to the right of its position and make it the new file
*) name.  If there is no slash look for colon.  Again if found, take
*) everything to the right of it as the new name.  If neither slash
*) nor colon are found then return the name unchanged.
*)
*) Parameters:
*) filename - character string representing a file name
*)
*) Return value:
*) The string "filename" with any path removed
*)
PARAMETER m.filename
PRIVATE m.slashpos, m.namelen, m.colonpos
m.slashpos = RAT("\", m.filename)
IF m.slashpos > 0
   m.namelen  = LEN(m.filename) - m.slashpos
   m.filename = RIGHT(m.filename, m.namelen)
ELSE
   m.colonpos = RAT(":", m.filename)
   IF m.colonpos > 0
      m.namelen  = LEN(m.filename) - m.colonpos
      m.filename = RIGHT(m.filename, m.namelen)
   ENDIF
ENDIF
RETURN m.filename

*!*****************************************************************************
*!
*!       Function: STRIPCR
*!
*!*****************************************************************************
FUNCTION stripcr
*)
*) STRIPCR - Strip off terminating carriage returns and line feeds
*)
PARAMETER m.strg
* Don't use a CHRTRAN since it's remotely possible that the CR or LF might
* be in a user's quoted string.
strg = ALLTRIM(strg)
i = LEN(strg)
DO WHILE i >= 0 AND INLIST(SUBSTR(strg,i,1),CHR(13),CHR(10))
   i = i - 1
ENDDO
RETURN LEFT(strg,i)

*!*****************************************************************************
*!
*!       Function: ADDBS
*!
*!      Called by: FORCEEXT()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION addbs
*)
*) ADDBS - Add a backslash unless there is one already there.
*)
PARAMETER m.pathname
PRIVATE m.separator
m.separator = IIF(_MAC,":","\")
m.pathname = ALLTRIM(UPPER(m.pathname))
IF !(RIGHT(m.pathname,1) $ '\:') AND !EMPTY(m.pathname)
   m.pathname = m.pathname + m.separator
ENDIF
RETURN m.pathname

*!*****************************************************************************
*!
*!       Function: JUSTFNAME
*!
*!      Called by: FORCEEXT()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION justfname
*)
*) JUSTFNAME - Return just the filename (i.e., no path) from "filname"
*)
PARAMETERS m.filname
IF RAT('\',m.filname) > 0
   m.filname = SUBSTR(m.filname,RAT('\',m.filname)+1,255)
ENDIF
IF AT(':',m.filname) > 0
   m.filname = SUBSTR(m.filname,AT(':',m.filname)+1,255)
ENDIF
RETURN ALLTRIM(UPPER(m.filname))

*!*****************************************************************************
*!
*!       Function: JUSTSTEM
*!
*!*****************************************************************************
FUNCTION juststem
* Return just the stem name from "filname"
PARAMETERS m.filname
IF RAT('\',m.filname) > 0
   m.filname = SUBSTR(m.filname,RAT('\',m.filname)+1,255)
ENDIF
IF RAT(':',m.filname) > 0
   m.filname = SUBSTR(m.filname,RAT(':',m.filname)+1,255)
ENDIF
IF AT('.',m.filname) > 0
   m.filname = SUBSTR(m.filname,1,AT('.',m.filname)-1)
ENDIF
RETURN ALLTRIM(UPPER(m.filname))

*!*****************************************************************************
*!
*!       Function: JUSTPATH
*!
*!      Called by: FORCEEXT()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION justpath
*)
*) JUSTPATH - Returns just the pathname.
*)
PARAMETERS m.filname
m.filname = ALLTRIM(UPPER(m.filname))
IF '\' $ m.filname
   m.filname = SUBSTR(m.filname,1,RAT('\',m.filname))
   IF RIGHT(m.filname,1) = '\' AND LEN(m.filname) > 1 ;
            AND SUBSTR(m.filname,LEN(m.filname)-1,1) <> ':'
         filname = SUBSTR(m.filname,1,LEN(m.filname)-1)
   ENDIF
   RETURN m.filname
ELSE
   RETURN ''
ENDIF


*!*****************************************************************************
*!
*!       Function: JUSTEXT
*!
*!*****************************************************************************
FUNCTION justext
* Return just the extension from "filname"
PARAMETERS m.filname
PRIVATE m.ext
filname = justfname(m.filname)   && prevents problems with ..\ paths
m.ext = ""
IF AT('.',m.filname) > 0
   m.ext = SUBSTR(m.filname,AT('.',m.filname)+1,3)
ENDIF
RETURN UPPER(m.ext)

*!*****************************************************************************
*!
*!       Function: FORCEEXT
*!
*!          Calls: JUSTPATH()         (function  in GENSCRN.PRG)
*!               : JUSTFNAME()        (function  in GENSCRN.PRG)
*!               : ADDBS()            (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION forceext
*)
*) FORCEEXT - Force filename to have a particular extension.
*)
PARAMETERS m.filname,m.ext
PRIVATE m.ext
IF SUBSTR(m.ext,1,1) = "."
   m.ext = SUBSTR(m.ext,2,3)
ENDIF

m.pname = justpath(m.filname)
m.filname = justfname(UPPER(ALLTRIM(m.filname)))
IF AT('.',m.filname) > 0
   m.filname = SUBSTR(m.filname,1,AT('.',m.filname)-1) + '.' + m.ext
ELSE
   m.filname = m.filname + '.' + m.ext
ENDIF
RETURN addbs(m.pname) + m.filname

*!*****************************************************************************
*!
*!       Function: UNIQUEWIN
*!
*!      Called by: GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION uniquewin
*)
*) UNIQUEWIN - Check if a window name is unique.
*)
PARAMETER m.windowname, m.windcnt, m.arry
EXTERNAL ARRAY arry
PRIVATE m.found, m.i, m.first, m.middle
m.found  = .F.
m.first  = 1
m.last   = m.windcnt
m.middle = 0

IF EMPTY(arry[1,1])
   RETURN 1
ENDIF
DO WHILE (m.last >= m.first) AND NOT m.found
   m.middle = INT((m.first+m.last) / 2)
   DO CASE
   CASE m.windowname < arry[m.middle,1]
      m.last = m.middle - 1
   CASE m.windowname > arry[m.middle,1]
      m.first = m.middle + 1
   OTHERWISE
      m.found = .T.
   ENDCASE
ENDDO
IF m.found
   RETURN 0
ELSE
   RETURN m.first
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: ADDTOCTRL
*!
*!      Called by: ELEMRANGE          (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!
*!          Calls: GETPLATNUM()       (function  in GENSCRN.PRG)
*!               : GENFUNCHEADER      (procedure in GENSCRN.PRG)
*!               : OKTOGENERATE()     (function  in GENSCRN.PRG)
*!               : ATWNAME()          (function  in GENSCRN.PRG)
*!               : ISCOMMENT()        (function  in GENSCRN.PRG)
*!               : GENINSERTCODE      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE addtoctrl
*)
*) ADDTOCTRL - Generate clause code for object level cluses.
*)
PARAMETER m.procname, m.from, m.memo, m.varname
PRIVATE m.linecnt, m.count, m.textline, m.genfunction, m.notcomnt, m.at, ;
   m.thispretext, m.in_dec, m.platnum, m.wnamelen, m.upline, m.thisplat

m.thisplat = IIF(TYPE("platform") <> "U",platform,"DOS")
m.platnum = getplatnum(m.thisplat)

* Write this clause to the temporary file
_TEXT = m.g_tmphandle
m.thispretext = _PRETEXT
_PRETEXT = ""

m.genfunction = .F.
m.notcomnt = 0
m.linecnt = MEMLINES(m.memo)
_MLINE = 0
DO genfuncheader WITH m.procname, m.from, .F., ALLTRIM(m.varname)
FOR m.count = 1 TO m.linecnt
   m.textline = MLINE(m.memo, 1, _MLINE)
   DO killcr WITH m.textline
   m.upline = UPPER(LTRIM(CHRTRAN(m.textline,chr(9),' ')))
   IF oktogenerate(@upline, @notcomnt)
      IF m.notcomnt > 0 AND NOT m.genfunction
         \FUNCTION <<m.procname>>     &&  <<m.varname>> <<m.from>>
         in_dec = SET("DECIMALS")
         SET DECIMALS TO 0
         \#REGION <<INT(m.g_screen)>>
         SET DECIMALS TO in_dec
         m.genfunction = .T.
      ENDIF

      IF NOT EMPTY(g_wnames[m.g_screen, m.platnum])
         m.at = atwname(g_wnames[m.g_screen, m.platnum], m.textline)
         IF m.at <> 0 AND !iscomment(@textline)
            m.wnamelen = LEN(g_wnames[m.g_screen, m.platnum])
            \<<STUFF(m.textline, m.at, m.wnamelen,g_screens[m.g_screen,2])>>
         ELSE
            IF !geninsertcode(@upline,m.g_screen, .F., m.thisplat)
               \<<m.textline>>
            ENDIF
         ENDIF
      ELSE
         IF !geninsertcode(@upline,m.g_screen, .F., m.thisplat)
            \<<m.textline>>
         ENDIF
      ENDIF
   ENDIF
ENDFOR
IF m.notcomnt = 0
   \FUNCTION <<m.procname>>     &&  <<m.varname>> <<m.from>>
ENDIF
_TEXT = m.g_orghandle
_PRETEXT = m.thispretext
RETURN

*!*****************************************************************************
*!
*!       Function: OKTOGENERATE
*!
*!      Called by: ADDTOCTRL          (procedure in GENSCRN.PRG)
*!
*!          Calls: WORDNUM()          (function  in GENSCRN.PRG)
*!               : MATCH()            (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION oktogenerate
*)
*) OKTOGENERATE - Ok to generate this line?
*)
*) Description:
*) Check if the code segment provided by the user for the object level
*) VALID, MESSAGE, and WHEN clauses does not contain 'FUNCTION',
*) 'PROCEDURE' or 'PARAMETER' statements as its first non-comment
*) statements.  Further, do not output #NAME directives. This is done on line by
*) line basis.
*)
*) "notcomnt" needs to be passed by reference, and is changed in this module
*) m.statement must already be in upper case and trimmed.  It may be passed by reference.
PARAMETER m.statement, m.notcomnt

PRIVATE m.asterisk, m.ampersand, m.isnote, m.name, m.word1
IF EMPTY(m.statement)
   RETURN .T.
ENDIF

DO CASE
CASE AT("*", m.statement) = 1 ;
      OR AT(m.g_dblampersand, m.statement) = 1 ;
      OR AT("NOTE", m.statement) = 1
   RETURN .T.
OTHERWISE
   * OK, it's not a comment
   m.notcomnt = m.notcomnt + 1
   * Make a quick test to see if we may exclude this line
   IF AT(LEFT(statement,1),"PF#") > 0
      * Postpone the expensive wordnum and match functions as long as possible
      word1 = CHRTRAN(wordnum(statement,1),';','')
      DO CASE
      CASE match(word1,"PROCEDURE") OR match(word1,"FUNCTION") OR match(word1,"PARAMETERS")
         *
         * If the first non-comment line is a FUNCTION, PROCEDURE, or
         * a PARAMETER statement then do not generate it.
         *
         IF m.notcomnt = 1
            RETURN .F.
         ENDIF
      CASE LEFT(statement,5) == "#NAME"   && Don't ever emit a #NAME directive
         RETURN .F.
      ENDCASE
   ENDIF
ENDCASE
RETURN .T.

*!*****************************************************************************
*!
*!       Function: OBJECT
*!
*!*****************************************************************************
FUNCTION OBJECT
*)
*) OBJECT - Return name of an object.
*)
PARAMETER m.objecttype
PRIVATE m.objname
DO CASE
CASE m.objecttype = 11
   m.objname = "List"
CASE m.objecttype = 12
   m.objname = "Push Button"
CASE m.objecttype = 13
   m.objname = "Radio Button"
CASE m.objecttype = 14
   m.objname = "Check Box"
CASE m.objecttype = 15
   m.objname = "Field"
CASE m.objecttype = 16
   m.objname = "Popup"
OTHERWISE
   m.objname = ""
ENDCASE
RETURN m.objname

*!*****************************************************************************
*!
*!      Procedure: COMBINE
*!
*!      Called by: BUILD              (procedure in GENSCRN.PRG)
*!
*!          Calls: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE combine
*)
*) COMBINE - Combine the original and the temp files.
*)
PRIVATE m.size, m.top, m.end, m.status, m.chunk

IF m.g_graphic
   SET MESSAGE TO 'Merging Files'
ENDIF
m.size = FSEEK(m.g_tmphandle,0,2)
m.top  = FSEEK(m.g_tmphandle,0)

DO WHILE .T.
   m.chunk = IIF(m.size>65000, 65000, m.size)
   m.end   = FSEEK(m.g_orghandle,0,2)
   m.status = FWRITE(m.g_orghandle,FREAD(m.g_tmphandle,m.chunk))
   IF m.status = 0 AND m.size > 0
      DO errorhandler WITH "Unsuccessful file merge...",;
         LINENO(), c_error_2
   ENDIF
   m.size = m.size - 65000
   IF m.size < 0
      EXIT
   ENDIF
ENDDO
IF m.g_graphic
   SET MESSAGE TO 'Generation Complete'
ELSE
   WAIT CLEAR
ENDIF
RETURN

**
** Code Associated With Displaying of the Thermometer
**

*!*****************************************************************************
*!
*!      Procedure: ACTTHERM
*!
*!      Called by: BUILD              (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE acttherm
*)
*) ACTTHERM(<text>) - Activate thermometer.
*)
*) Activates thermometer.  Update the thermometer with UPDTHERM().
*) Thermometer window is named "thermometer."  Be sure to RELEASE
*) this window when done with thermometer.  Creates the global
*) m.g_thermwidth.
*)
PARAMETER m.text
PRIVATE m.prompt

IF m.g_graphic
   m.prompt = LOWER(m.g_outfile)
	m.prompt = thermfname(m.prompt)

   DO CASE
   CASE _WINDOWS
      DEFINE WINDOW thermomete ;
         AT  INT((SROW() - (( 5.615 * ;
         FONTMETRIC(1, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
         FONTMETRIC(1, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2), ;
         INT((SCOL() - (( 63.833 * ;
         FONTMETRIC(6, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
         FONTMETRIC(6, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2) ;
         SIZE 5.615,63.833 ;
         FONT m.g_dlgface, m.g_dlgsize ;
         STYLE m.g_dlgstyle ;
         NOFLOAT ;
         NOCLOSE ;
         NONE ;
         COLOR RGB(0, 0, 0, 192, 192, 192)
      MOVE WINDOW thermomete CENTER
      ACTIVATE WINDOW thermomete NOSHOW

      @ 0.5,3 SAY m.text FONT m.g_dlgface, m.g_dlgsize STYLE m.g_dlgstyle
      @ 1.5,3 SAY m.prompt FONT m.g_dlgface, m.g_dlgsize STYLE m.g_dlgstyle
      @ 0.000,0.000 TO 0.000,63.833 ;
         COLOR RGB(255, 255, 255, 255, 255, 255)
      @ 0.000,0.000 TO 5.615,0.000 ;
         COLOR RGB(255, 255, 255, 255, 255, 255)
      @ 0.385,0.667 TO 5.231,0.667 ;
         COLOR RGB(128, 128, 128, 128, 128, 128)
      @ 0.308,0.667 TO 0.308,63.167 ;
         COLOR RGB(128, 128, 128, 128, 128, 128)
      @ 0.385,63.000 TO 5.308,63.000 ;
         COLOR RGB(255, 255, 255, 255, 255, 255)
      @ 5.231,0.667 TO 5.231,63.167 ;
         COLOR RGB(255, 255, 255, 255, 255, 255)
      @ 5.538,0.000 TO 5.538,63.833 ;
         COLOR RGB(128, 128, 128, 128, 128, 128)
      @ 0.000,63.667 TO 5.615,63.667 ;
         COLOR RGB(128, 128, 128, 128, 128, 128)
      @ 3.000,3.333 TO 4.231,3.333 ;
         COLOR RGB(128, 128, 128, 128, 128, 128)
      @ 3.000,60.333 TO 4.308,60.333 ;
         COLOR RGB(255, 255, 255, 255, 255, 255)
      @ 3.000,3.333 TO 3.000,60.333 ;
         COLOR RGB(128, 128, 128, 128, 128, 128)
      @ 4.231,3.333 TO 4.231,60.333 ;
         COLOR RGB(255, 255, 255, 255, 255, 255)
      m.g_thermwidth = 56.269
   CASE _MAC
      DEFINE WINDOW thermomete ;
         AT  INT((SROW() - (( 5.62 * ;
         FONTMETRIC(1, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
         FONTMETRIC(1, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2), ;
         INT((SCOL() - (( 63.83 * ;
         FONTMETRIC(6, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
         FONTMETRIC(6, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2) ;
         SIZE 5.62,63.83 ;
         FONT m.g_dlgface, m.g_dlgsize ;
         STYLE m.g_dlgstyle ;
         NOFLOAT ;
         NOCLOSE ;
			NONE ;
         COLOR RGB(0, 0, 0, 192, 192, 192)
      MOVE WINDOW thermomete CENTER
      ACTIVATE WINDOW thermomete NOSHOW

      IF ISCOLOR()
         @ 0.000,0.000 TO 5.62,63.83 PATTERN 1;
             COLOR RGB(192, 192, 192, 192, 192, 192)
      	@ 0.000,0.000 TO 0.000,63.83 ;
         	COLOR RGB(255, 255, 255, 255, 255, 255)
      	@ 0.000,0.000 TO 5.62,0.000 ;
         	COLOR RGB(255, 255, 255, 255, 255, 255)
      	@ 0.385,0.67 TO 5.23,0.67 ;
         	COLOR RGB(128, 128, 128, 128, 128, 128)
      	@ 0.31,0.67 TO 0.31,63.17 ;
         	COLOR RGB(128, 128, 128, 128, 128, 128)
      	@ 0.385,63.000 TO 5.31,63.000 ;
         	COLOR RGB(255, 255, 255, 255, 255, 255)
      	@ 5.23,0.67 TO 5.23,63.17 ;
         	COLOR RGB(255, 255, 255, 255, 255, 255)
      	@ 5.54,0.000 TO 5.54,63.83 ;
         	COLOR RGB(128, 128, 128, 128, 128, 128)
      	@ 0.000,63.67 TO 5.62,63.67 ;
         	COLOR RGB(128, 128, 128, 128, 128, 128)
      	@ 3.000,3.33 TO 4.23,3.33 ;
         	COLOR RGB(128, 128, 128, 128, 128, 128)
      	@ 3.000,60.33 TO 4.31,60.33 ;
         	COLOR RGB(255, 255, 255, 255, 255, 255)
      	@ 3.000,3.33 TO 3.000,60.33 ;
         	COLOR RGB(128, 128, 128, 128, 128, 128)
      	@ 4.23,3.33 TO 4.23,60.33 ;
         	COLOR RGB(255, 255, 255, 255, 255, 255)
      ELSE
         @ 0.000, 0.000 TO 5.62, 63.830  PEN 2
	      @ 0.230, 0.500 TO 5.39, 63.333  PEN 1
	   ENDIF
      @ 0.5,3 SAY m.text FONT m.g_dlgface, m.g_dlgsize STYLE m.g_dlgstyle+"T" ;
         COLOR RGB(0,0,0,192,192,192)
      @ 1.5,3 SAY m.prompt FONT m.g_dlgface, m.g_dlgsize STYLE m.g_dlgstyle+"T" ;
         COLOR RGB(0,0,0,192,192,192)

      m.g_thermwidth = 56.27
		IF !ISCOLOR()
			@ 3.000,3.33 TO 4.23,m.g_thermwidth + 3.33
		ENDIF
   ENDCASE
   SHOW WINDOW thermomete TOP
ELSE
   m.prompt = SUBSTR(SYS(2014,m.g_outfile),1,48)+;
      IIF(LEN(m.g_outfile)>48,"...","")

   DEFINE WINDOW thermomete;
      FROM INT((SROW()-6)/2), INT((SCOL()-57)/2) ;
      TO INT((SROW()-6)/2) + 6, INT((SCOL()-57)/2) + 57;
      DOUBLE COLOR SCHEME 5
   ACTIVATE WINDOW thermomete NOSHOW

   m.g_thermwidth = 50
   @ 0,3 SAY m.text
   @ 1,3 SAY UPPER(m.prompt)
   @ 2,1 TO 4,m.g_thermwidth+4 &g_boxstrg

   SHOW WINDOW thermomete TOP
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: UPDTHERM
*!
*!      Called by: BUILD              (procedure in GENSCRN.PRG)
*!               : DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!               : BUILDCTRL          (procedure in GENSCRN.PRG)
*!               : EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE updtherm
*)
*) UPDTHERM(<percent>) - Update thermometer.
*)
PARAMETER m.percent
PRIVATE m.nblocks, m.percent

ACTIVATE WINDOW thermomete

* Map to the number of platforms we are generating for
m.percent = MIN(INT(m.percent / m.g_numplatforms) ,100)

m.nblocks = (m.percent/100) * (m.g_thermwidth)
DO CASE
CASE _WINDOWS
   @ 3.000,3.333 TO 4.231,m.nblocks + 3.333 ;
      PATTERN 1 COLOR RGB(128, 128, 128, 128, 128, 128)
CASE _MAC
   *@ 3.000,3.33 TO 4.23,m.nblocks + 3.33 ;
   *   PATTERN 1 COLOR RGB(0, 0, 0, 220, 140, 120)
   @ 3.000,3.33 TO 4.23,m.nblocks + 3.33 ;
      PATTERN 1 COLOR RGB(0, 0, 128, 0, 0, 128)
OTHERWISE
   @ 3,3 SAY REPLICATE("Û",m.nblocks)
ENDCASE
RETURN

*!*****************************************************************************
*!
*!      Procedure: DEACTTHERMO
*!
*!      Called by: BUILD              (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE deactthermo
*)
*) DEACTTHERMO - Deactivate and Release thermometer window.
*)
IF WEXIST("thermomete")
   RELEASE WINDOW thermomete
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: THERMADJ
*!
*!*****************************************************************************
FUNCTION thermadj
* Map the local thermometer from local (this platform) to global (all platforms)
* When all platforms have been accounted for, we want to show m.finish percent.
PARAMETERS m.pnum, m.current, m.finish
=assert(m.current <= m.finish,"Thermometer error!  Current > finish.")
=assert(BETWEEN(m.finish,0,100),"Thermometer error! Finish out of range.")
RETURN (m.finish * (m.pnum - 1)) + m.current


*!*****************************************************************************
*!
*!      Procedure: THERMFNAME
*!
*!*****************************************************************************
FUNCTION thermfname
PARAMETER m.fname
PRIVATE m.addelipse, m.g_pathsep, m.g_thermfface, m.g_thermfsize, m.g_thermfstyle

#define c_space 50
IF _MAC
	m.g_thermfface = "Geneva"
	m.g_thermfsize = 10
	m.g_thermfstyle = "B"
ELSE
	m.g_thermfface = "MS Sans Serif"
	m.g_thermfsize = 8
	m.g_thermfstyle = "B"
ENDIF

* Translate the filename into Mac native format
IF _MAC
	m.g_pathsep = ":"
	m.fname = SYS(2027, m.fname)
ELSE
    m.g_pathsep = "\"
ENDIF

IF TXTWIDTH(m.fname,m.g_thermfface,m.g_thermfsize,m.g_thermfstyle) > c_space
	* Make it fit in c_space
	m.fname = partialfname(m.fname, c_space - 1)
	m.addelipse = .F.
	DO WHILE TXTWIDTH(m.fname+'...',m.g_thermfface,m.g_thermfsize,m.g_thermfstyle) > c_space
		m.fname = LEFT(m.fname, LEN(m.fname) - 1)
		m.addelipse = .T.
	ENDDO
	IF m.addelipse
		m.fname = m.fname + "..."
   ENDIF
ENDIF
RETURN m.fname



*!*****************************************************************************
*!
*!      Procedure: PARTIALFNAME
*!
*!*****************************************************************************
FUNCTION partialfname
PARAMETER m.filname, m.fillen
* Return a filname no longer than m.fillen characters.  Take some chars
* out of the middle if necessary.  No matter what m.fillen is, this function
* always returns at least the file stem and extension.
PRIVATE m.bname, m.elipse, m.remain
m.elipse = "..." + m.g_pathsep
IF _MAC
    m.bname = SUBSTR(m.filname, RAT(":",m.filname)+1)
ELSE
	m.bname = justfname(m.filname)
ENDIF
DO CASE
CASE LEN(m.filname) <= m.fillen
   m.retstr = m.filname
CASE LEN(m.bname) + LEN(m.elipse) >= m.fillen
   m.retstr = m.bname
OTHERWISE
   m.remain = MAX(m.fillen - LEN(m.bname) - LEN(m.elipse), 0)
   IF _MAC
	   m.retstr = LEFT(SUBSTR(m.filname,1,RAT(":",m.filname)-1),m.remain) ;
		    +m.elipse+m.bname
   ELSE
  	   m.retstr = LEFT(justpath(m.filname),m.remain)+m.elipse+m.bname
   ENDIF
ENDCASE
RETURN m.retstr

**
** Error Handling Code
**

*!*****************************************************************************
*!
*!      Procedure: ERRORHANDLER
*!
*!      Called by: GENSCRN.PRG
*!               : OPENPROJDBF()      (function  in GENSCRN.PRG)
*!               : PREPSCREENS()      (function  in GENSCRN.PRG)
*!               : CHECKPARAM()       (function  in GENSCRN.PRG)
*!               : PREPFILE           (procedure in GENSCRN.PRG)
*!               : CLOSEFILE          (procedure in GENSCRN.PRG)
*!               : GETPLATFORM()      (function  in GENSCRN.PRG)
*!               : REFRESHPREFS       (procedure in GENSCRN.PRG)
*!               : DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!               : UPDPROCARRAY       (procedure in GENSCRN.PRG)
*!               : GENVALIDBODY       (procedure in GENSCRN.PRG)
*!               : GENWHENBODY        (procedure in GENSCRN.PRG)
*!               : ACTICLAUSE         (procedure in GENSCRN.PRG)
*!               : DEATCLAUSE         (procedure in GENSCRN.PRG)
*!               : SHOWCLAUSE         (procedure in GENSCRN.PRG)
*!               : GENOPENDBFS        (procedure in GENSCRN.PRG)
*!               : DOPLACECLAUSE      (procedure in GENSCRN.PRG)
*!               : FINDREADCLAUSES    (procedure in GENSCRN.PRG)
*!               : COMBINE            (procedure in GENSCRN.PRG)
*!
*!          Calls: CLEANUP            (procedure in GENSCRN.PRG)
*!               : ERRLOG             (procedure in GENSCRN.PRG)
*!               : ERRSHOW            (procedure in GENSCRN.PRG)
*!               : CLOSEFILE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE errorhandler
*)
*) ERRORHANDLER - Error Processing Center.
*)
PARAMETERS m.msg, m.linenum, m.errcode
IF ERROR() = 22   && too many memory variables--just bomb out as fast as we can
   ON ERROR
   DO cleanup
   CANCEL
ENDIF

DO CASE
CASE errcode == "Minor"
   DO errlog WITH m.msg, m.linenum
   m.g_status = 1
CASE errcode == "Serious"
   DO errlog  WITH m.msg, m.linenum
   DO errshow WITH m.msg, m.linenum
   m.g_status = 2
   ON ERROR
CASE errcode == "Fatal"
   ON ERROR
   IF m.g_havehand = .T.
      DO errlog WITH m.msg, m.linenum
      DO closefile WITH m.g_orghandle
      DO closefile WITH m.g_tmphandle
   ENDIF
   DO errshow WITH m.msg, m.linenum
   IF WEXIST("Thermomete") AND WVISIBLE("Thermomete")
      RELEASE WINDOW thermometer
   ENDIF
   DO cleanup
   CANCEL
ENDCASE
RETURN

*!*****************************************************************************
*!
*!      Procedure: ESCHANDLER
*!
*!      Called by: BUILDENABLE        (procedure in GENSCRN.PRG)
*!
*!          Calls: BUILDDISABLE       (procedure in GENSCRN.PRG)
*!               : CLEANUP            (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE eschandler
*)
*) ESCHANDLER - Escape handler.
*)
ON ERROR
WAIT WINDOW "Generation process stopped." NOWAIT
DO builddisable
IF m.g_havehand
   ERASE (m.g_outfile)
   ERASE (m.g_tmpfile)
ENDIF
IF WEXIST("Thermomete") AND WVISIBLE("Thermomete")
   RELEASE WINDOW thermometer
ENDIF
DO cleanup
CANCEL

*!*****************************************************************************
*!
*!      Procedure: ERRLOG
*!
*!      Called by: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!
*!          Calls: OPENERRFILE        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE errlog
*)
*) ERRLOG - Save an error message in the error log file.
*)
PARAMETER m.msg, m.linenum
DO openerrfile

SET CONSOLE OFF
\\GENERATOR: <<ALLTRIM(m.msg)>>
IF NOT EMPTY(m.linenum)
   \\ LINE NUMBER: <<m.linenum>>
ENDIF
\
= FCLOSE(_TEXT)
_TEXT = m.g_orghandle
RETURN

*!*****************************************************************************
*!
*!      Procedure: ERRSHOW
*!
*!      Called by: ERRORHANDLER       (procedure in GENSCRN.PRG)
*!               : OPENERRFILE        (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE errshow
*)
*) ERRSHOW - Show error in an alert box on the screen.
*)
PARAMETER m.msg, m.lineno
PRIVATE m.curcursor

IF m.g_graphic
	IF _MAC
   	DEFINE WINDOW ALERT ;
      	AT  INT((SROW() - (( 6.615 * ;
      	FONTMETRIC(1, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
      	FONTMETRIC(1, WFONT(1,""), WFONT(2,""), WFONT(3,"")))) / 2), ;
      	INT((SCOL() - (( 63.833 * ;
      	FONTMETRIC(6, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
      	FONTMETRIC(6, WFONT(1,""), WFONT(2,""), WFONT(3,"")))) / 2) ;
      	SIZE 6.615,63.833 ;
      	FONT m.g_dlgface, m.g_dlgsize ;
      	STYLE m.g_dlgstyle ;
      	NOCLOSE ;
      	DOUBLE ;
      	TITLE "Genscrn Error" ;
      	COLOR RGB(0, 0, 0, 255, 255, 255)
	ELSE
   	DEFINE WINDOW ALERT ;
      	AT  INT((SROW() - (( 6.615 * ;
      	FONTMETRIC(1, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
      	FONTMETRIC(1, WFONT(1,""), WFONT(2,""), WFONT(3,"")))) / 2), ;
      	INT((SCOL() - (( 63.833 * ;
      	FONTMETRIC(6, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
      	FONTMETRIC(6, WFONT(1,""), WFONT(2,""), WFONT(3,"")))) / 2) ;
      	SIZE 6.615,63.833 ;
      	FONT m.g_dlgface, m.g_dlgsize ;
      	STYLE m.g_dlgstyle ;
      	NOCLOSE ;
      	DOUBLE ;
      	TITLE "Genscrn Error" ;
      	COLOR RGB(0, 0, 0, 255, 255, 255)
   ENDIF
   MOVE WINDOW ALERT CENTER
   ACTIVATE WINDOW ALERT NOSHOW

   m.dispmsg = m.msg
   IF TXTWIDTH(m.dispmsg) > WCOLS()
      * Make sure it isn't too long.
      DO WHILE TXTWIDTH(m.dispmsg+'...') > WCOLS()
         m.dispmsg = LEFT(m.dispmsg,LEN(m.dispmsg)-1)
      ENDDO
      IF m.msg <> m.dispmsg    && Has display message been shortened?
         m.dispmsg = m.dispmsg + '...'
      ENDIF
   ENDIF

   @ 1,MAX((WCOLS()-TXTWIDTH( m.dispmsg ))/2,1) SAY m.dispmsg

   m.msg = "Genscrn Line Number: "+STR(m.lineno, 4)
   @ 2,(WCOLS()-TXTWIDTH( m.msg ))/2 SAY m.msg

   IF TYPE("m.g_screen") <> "U" AND m.g_screen <> 0
      m.msg = "Generating from: "+LOWER(g_screens[m.g_screen,1])
      @ 3,MAX((WCOLS()-TXTWIDTH( m.msg ))/2,1) SAY m.msg
   ENDIF

   m.msg = "Press any key to cleanup and exit..."
   @ 4,(WCOLS()-TXTWIDTH( m.msg ))/2 SAY m.msg

   SHOW WINDOW ALERT
ELSE
   DEFINE WINDOW ALERT;
      FROM INT((SROW()-7)/2), INT((SCOL()-50)/2) TO INT((SROW()-7)/2) + 6, INT((SCOL()-50)/2) + 50 ;
      FLOAT NOGROW NOCLOSE NOZOOM SHADOW DOUBLE;
      COLOR SCHEME 7

   ACTIVATE WINDOW ALERT

   @ 0,0 CLEAR
   @ 1,0 SAY PADC(SUBSTR(m.msg,1,44)+;
      IIF(LEN(m.msg)>44,"...",""), WCOLS())
   @ 2,0 SAY PADC("Line Number: "+STR(m.lineno, 4), WCOLS())

   IF TYPE("m.g_screen") <> "U" AND m.g_screen <> 0
      m.msg = "Working on screen: "+LOWER(g_screens[m.g_screen])
      @ 3,0 SAY PADC(m.msg,WCOLS())
   ENDIF

   @ 4,0 SAY PADC("Press any key to cleanup and exit...", WCOLS())
ENDIF

m.curcursor = SET( "CURSOR" )
SET CURSOR OFF

WAIT ""

RELEASE WINDOW ALERT
SET CURSOR &curcursor

RELEASE WINDOW ALERT
RETURN

*!*****************************************************************************
*!
*!      Procedure: OPENERRFILE
*!
*!      Called by: ERRLOG             (procedure in GENSCRN.PRG)
*!
*!          Calls: ERRSHOW            (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE openerrfile
*)
*) OPENERRFILE - Open error file.
*)
PRIVATE m.errfile, m.errhandle
m.errfile   = m.g_errlog+".ERR"
m.errhandle = FOPEN(m.errfile,2)
IF m.errhandle < 0
   m.errhandle = FCREATE(m.errfile)
   IF m.errhandle < 0
      DO errshow WITH ".ERR could not be opened...", LINENO()
      m.g_status = 2
      IF WEXIST("Thermomete") AND WVISIBLE("Thermomete")
         RELEASE WINDOW thermometer
      ENDIF
      ON ERROR
      RETURN TO MASTER
   ENDIF
ELSE
   = FSEEK(m.errhandle,0,2)
ENDIF
IF SET("TEXTMERGE") = "OFF"
   SET TEXTMERGE ON
ENDIF
_TEXT = m.errhandle

*!*****************************************************************************
*!
*!      Procedure: PUSHINDENT
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!               : EMITBRACKET        (procedure in GENSCRN.PRG)
*!               : PLACESAYS          (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE pushindent
*)
*) PUSHINDENT - Add another indentation level
*)
_PRETEXT = CHR(9) + _PRETEXT
RETURN

*!*****************************************************************************
*!
*!      Procedure: POPINDENT
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!               : EMITBRACKET        (procedure in GENSCRN.PRG)
*!               : PLACESAYS          (procedure in GENSCRN.PRG)
*!               : GENWINDEFI         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE popindent
*)
*) POPINDENT - Remove one indentation level
*)
IF LEFT(_PRETEXT,1) = CHR(9)
   _PRETEXT = SUBSTR(_PRETEXT,2)
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Procedure: COUNTPLATFORMS
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION countplatforms
*)
*) COUNTPLATFORMS - Count the number of platforms in this SCX that are in common across
*)                    all the SCXs in this screen set.
*)
PRIVATE m.cnt, m.i
IF TYPE("g_platforms") <> "U"
   m.cnt = 0
   FOR m.i = 1 TO ALEN(g_platforms)
      IF !EMPTY(g_platforms[m.i])
         m.cnt = m.cnt + 1
      ENDIF
   ENDFOR
   RETURN m.cnt
ENDIF
RETURN 0

*!*****************************************************************************
*!
*!      Function: LOOKUPPLATFORM
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION lookupplatform
*)
*) LOOKUPPLATFORM - Return the n-th platform name
*)
PARAMETER m.n
IF TYPE("g_platforms") <> "U" AND ALEN(g_platforms) >= m.n ;
      AND m.n > 0 AND TYPE("g_platforms[m.n]") = "C"
   RETURN UPPER(g_platforms[m.n])
ENDIF
RETURN ""

*!*****************************************************************************
*!
*!      Function: HASRECORDS
*!
*!*****************************************************************************
FUNCTION hasrecords
*)
*) HASRECORDS - Return .T. if plat records are in the screen.
*)
PARAMETER m.plat
IF TYPE("g_platforms") = "U"
   RETURN IIF(m.plat = "DOS",.T.,.F.)
ELSE
   RETURN IIF(ASCAN(g_platforms,m.plat) > 0,.T.,.F.)
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: GETPARAM
*!
*!      Called by: CHECKPARAM()       (function  in GENSCRN.PRG)
*!
*!          Calls: ISCOMMENT()        (function  in GENSCRN.PRG)
*!               : WORDNUM()          (function  in GENSCRN.PRG)
*!               : MATCH()            (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION getparam
*)
*) GETPARAM - Return the PARAMETER statement from a setup snippet, if one is there
*)
PARAMETER m.snipname
PRIVATE m.i, m.thisparam, m.numlines, m.thisline, m.word1, m.contin

* Do a quick check to see if we need to search further.
IF ATC("PARA",&snipname) = 0
   RETURN ""
ENDIF

m.numlines = MEMLINES(&snipname)
_MLINE = 0
m.i = 1
DO WHILE m.i <= m.numlines
   m.thisline = UPPER(LTRIM(MLINE(&snipname, 1, _MLINE)))
   DO killcr WITH m.thisline

   * Drop any double-ampersand comment
   IF AT(m.g_dblampersand,m.thisline) > 0
      m.thisline = LEFT(m.thisline,AT(m.g_dblampersand,m.thisline)-1)
   ENDIF

   IF !EMPTY(m.thisline) AND !iscomment(@thisline)
      * See if the first non-blank, non-comment, non-directive, non-EXTERNAL
      * line is a #SECTION 1
      DO CASE
      CASE LEFT(m.thisline,5) = "#SECT" AND AT('1',m.thisline) <> 0
         * Read until we find a #SECTION 2, the end of the snippet or a
         * PARAMETER statement.
         DO WHILE m.i <= m.numlines
            m.thisline = UPPER(LTRIM(MLINE(&snipname, 1, _MLINE)))
            DO killcr WITH m.thisline

            * Drop any double-ampersand comment
            IF AT(m.g_dblampersand,m.thisline) > 0
               m.thisline = LEFT(m.thisline,AT(m.g_dblampersand,m.thisline)-1)
            ENDIF

            m.word1 = wordnum(CHRTRAN(m.thisline,CHR(9)+';',' '),1)
            DO CASE
            CASE match(m.word1,"PARAMETERS")

               * Replace tabs with spaces
               m.thisline = LTRIM(CHRTRAN(m.thisline,CHR(9)," "))

               * Process continuation lines.  Replace tabs in incoming lines with spaces.
               DO WHILE RIGHT(RTRIM(m.thisline),1) = ';'
                  m.thisline = m.thisline + ' '+ CHR(13)+CHR(10)+CHR(9)
                  m.contin = MLINE(&snipname, 1, _MLINE)
                  DO killcr WITH m.contin
                  m.contin = CHRTRAN(LTRIM(m.contin),CHR(9)," ")
                  m.thisline = m.thisline + UPPER(m.contin)
               ENDDO

               * Clean up the parameters so that minor differences in
               * spacing don't cause the comparisons to fail.

               * Take the parameters but not the PARAMETER keyword itself
               m.thisparam = SUBSTR(m.thisline,AT(' ',m.thisline)+1)
               DO WHILE INLIST(LEFT(m.thisparam,1),CHR(10),CHR(13),CHR(9),' ')
                  m.thisparam = SUBSTR(m.thisparam,2)
               ENDDO

               * Force single spacing in the param string
               DO WHILE AT('  ',m.thisparam) > 0
                  m.thisparam = STRTRAN(m.thisparam,'  ',' ')
               ENDDO

               * Drop "m." designations so that they don't make the variables look different
               m.thisparam = STRTRAN(m.thisparam,'m.','')
               m.thisparam = STRTRAN(m.thisparam,'m->','')

               RETURN LOWER(m.thisparam)
            CASE LEFT(m.thisline,5) = "#SECT" AND AT('2',m.thisline) <> 0
               * No parameter statement, since we found #SECTION 2 first
               RETURN ""
            ENDCASE
            m.i = m.i + 1
         ENDDO
      CASE LEFT(m.thisline,1) = "#"   && some other directive
         * Do nothing.  Get next line.
      CASE match(wordnum(m.thisline,1),"EXTERNAL")
         * Ignore it.  This doesn't disqualify a later statement from being a PARAMETER
         * statement.
      OTHERWISE
         * no #SECTION 1, so no parameters
         RETURN ""
      ENDCASE
   ENDIF
   m.i = m.i + 1
ENDDO
RETURN ""


*!*****************************************************************************
*!
*!       Function: MATCH
*!
*!      Called by: EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!               : EMITPROC           (procedure in GENSCRN.PRG)
*!               : PUTPROC            (procedure in GENSCRN.PRG)
*!               : GETFIRSTPROC()     (function  in GENSCRN.PRG)
*!               : UPDPROCARRAY       (procedure in GENSCRN.PRG)
*!               : ISPARAMETER()      (function  in GENSCRN.PRG)
*!               : OKTOGENERATE()     (function  in GENSCRN.PRG)
*!               : GETPARAM()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION match
*)
*) MATCH - Returns TRUE is candidate is a valid 4-or-more-character abbreviation of keyword
*)
PARAMETER m.candidate, m.keyword
PRIVATE m.in_exact, m.retlog

m.in_exact = SET("EXACT")
SET EXACT OFF
DO CASE
CASE EMPTY(m.candidate)
   m.retlog = EMPTY(m.keyword)
CASE LEN(m.candidate) < 4
   m.retlog = IIF(m.candidate == m.keyword,.T.,.F.)
OTHERWISE
   m.retlog = IIF(m.keyword = m.candidate,.T.,.F.)
ENDCASE
IF m.in_exact != "OFF"
   SET EXACT ON
ENDIF

RETURN m.retlog

*!*****************************************************************************
*!
*!       Function: WORDNUM
*!
*!      Called by: EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!               : EMITPROC           (procedure in GENSCRN.PRG)
*!               : PUTPROC            (procedure in GENSCRN.PRG)
*!               : GETFIRSTPROC()     (function  in GENSCRN.PRG)
*!               : UPDPROCARRAY       (procedure in GENSCRN.PRG)
*!               : GENINSERTCODE      (procedure in GENSCRN.PRG)
*!               : ISPARAMETER()      (function  in GENSCRN.PRG)
*!               : OKTOGENERATE()     (function  in GENSCRN.PRG)
*!               : GETPARAM()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION wordnum
*)
*) WORDNUM - Returns w_num-th word from string strg
*)
PARAMETERS m.strg,m.w_num
PRIVATE strg,s1,w_num,ret_str

m.s1 = ALLTRIM(m.strg)

* Replace tabs with spaces
m.s1 = CHRTRAN(m.s1,CHR(9)," ")

* Reduce multiple spaces to a single space
DO WHILE AT('  ',m.s1) > 0
   m.s1 = STRTRAN(m.s1,'  ',' ')
ENDDO

ret_str = ""
DO CASE
CASE m.w_num > 1
   DO CASE
   CASE AT(" ",m.s1,m.w_num-1) = 0   && No word w_num.  Past end of string.
      m.ret_str = ""
   CASE AT(" ",m.s1,m.w_num) = 0     && Word w_num is last word in string.
      m.ret_str = SUBSTR(m.s1,AT(" ",m.s1,m.w_num-1)+1,255)
   OTHERWISE                         && Word w_num is in the middle.
      m.strt_pos = AT(" ",m.s1,m.w_num-1)
      m.ret_str  = SUBSTR(m.s1,strt_pos,AT(" ",m.s1,m.w_num)+1 - strt_pos)
   ENDCASE
CASE m.w_num = 1
   IF AT(" ",m.s1) > 0               && Get first word.
      m.ret_str = SUBSTR(m.s1,1,AT(" ",m.s1)-1)
   ELSE                              && There is only one word.  Get it.
      m.ret_str = m.s1
   ENDIF
ENDCASE
RETURN ALLTRIM(m.ret_str)


*!*****************************************************************************
*!
*!       Function: GETCNAME
*!
*!      Called by: SETCLAUSEFLAGS     (procedure in GENSCRN.PRG)
*!               : ORCLAUSEFLAGS      (procedure in GENSCRN.PRG)
*!               : ANYVALID           (procedure in GENSCRN.PRG)
*!               : ANYWHEN            (procedure in GENSCRN.PRG)
*!               : ANYMESSAGE         (procedure in GENSCRN.PRG)
*!               : ANYERROR           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION getcname
*) GETCNAME - Generates a name for a clause.  Will take name from a
*)              generator directive stored in a snippet if present,
*)              or generates a generic name otherwise.  The name is
*)              designated by a #NAME name directive
*)
PARAMETERS m.snippet
PRIVATE dirname
IF ATC("#NAME",m.snippet) > 0
   m.dirname = MLINE(m.snippet, ATCLINE('#NAME',m.snippet))
   DO killcr WITH m.dirname
   m.dirname = UPPER(ALLTRIM(SUBSTR(m.dirname,AT(' ',m.dirname)+1)))
   IF !EMPTY(m.dirname)
      RETURN m.dirname
   ENDIF
ENDIF
RETURN LOWER(SYS(2015))

*!*****************************************************************************
*!
*!      Procedure: NOTEAREA
*!
*!      Called by: OPENPROJDBF()      (function  in GENSCRN.PRG)
*!               : PREPSCREENS()      (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE notearea
*)
*) NOTEAREA - Note that we are using this area so that we can clean up at exit
*)
g_areas[m.g_areacount] = SELECT()
m.g_areacount = m.g_areacount + 1
RETURN

*!*****************************************************************************
*!
*!      Procedure: CLEARAREAS
*!
*!      Called by: CLEANUP            (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE clearareas
*)
*) CLEARAREAS - Clear the ones we opened.
*)
FOR i = 1 TO m.g_areacount
   SELECT g_areas[m.i]
   USE
ENDFOR
RETURN

*!*****************************************************************************
*!
*!      Procedure: INITTICK
*!
*!      Called by: GENSCRN.PRG
*!
*!*****************************************************************************
PROCEDURE inittick
*)
*) INITTICK, TICK, and TOCK - Profiling functions
*)
IF TYPE("ticktock") = "U"
   PUBLIC ticktock[10]
ENDIF
ticktock = 0
RETURN

*!*****************************************************************************
*!
*!       Function: TICK
*!
*!      Called by: GENSCRN.PRG
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : GENSECT2           (procedure in GENSCRN.PRG)
*!               : FINDSECTION()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION tick
*)
*) INITTICK, TICK, and TOCK - Profiling functions
*)
PARAMETER m.bucket
ticktock[bucket] = ticktock[bucket] - SECONDS()
RETURN

*!*****************************************************************************
*!
*!       Function: TOCK
*!
*!      Called by: CLEANUP            (procedure in GENSCRN.PRG)
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : GENSECT2           (procedure in GENSCRN.PRG)
*!               : FINDSECTION()      (function  in GENSCRN.PRG)
*!               : WRITECODE          (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION tock
*)
*) INITTICK, TICK, and TOCK - Profiling functions
*)
PARAMETER m.bucket
ticktock[bucket] = ticktock[bucket] + SECONDS()
RETURN

*!*****************************************************************************
*!
*!      Procedure: PUTMSG
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!               : GENCLEANUP         (procedure in GENSCRN.PRG)
*!               : GENPROCEDURES      (procedure in GENSCRN.PRG)
*!               : EXTRACTPROCS       (procedure in GENSCRN.PRG)
*!               : UPDPROCARRAY       (procedure in GENSCRN.PRG)
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE putmsg
*)
*) Display a status message on the status bar at the bottom of the screen
*)
PARAMETER m.msg
IF m.g_graphic
   SET MESSAGE TO msg
ENDIF

*!*****************************************************************************
*!
*!       Function: VERSIONCAP
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!               : GENCLEANUP         (procedure in GENSCRN.PRG)
*!               : UPDPROCARRAY       (procedure in GENSCRN.PRG)
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!               : COMMENTBLOCK       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION versioncap
*)
*) VERSIONCAP - Return platform name suitable for display
*)
PARAMETER m.strg, m.dual
DO CASE
CASE m.strg = "DOS"
   m.retstrg = "MS-DOS"
	IF m.dual
	   m.retstrg = m.retstrg + " and UNIX"
	ENDIF
CASE m.strg = "WINDOWS"
   m.retstrg = "Windows"
	IF m.dual
	   m.retstrg = m.retstrg + " and Macintosh"
	ENDIF
CASE m.strg = "MAC"
   m.retstrg = "Macintosh"
	IF m.dual
	   m.retstrg = m.retstrg + " and Windows"
	ENDIF
CASE m.strg = "UNIX"
   m.retstrg = "UNIX"
	IF m.dual
	   m.retstrg = m.retstrg + " and MS-DOS"
	ENDIF
OTHERWISE
   m.retstrg = m.strg
ENDCASE
RETURN m.retstrg

*!*****************************************************************************
*!
*!       Function: MULTIPLAT
*!
*!      Called by: DISPATCHBUILD      (procedure in GENSCRN.PRG)
*!               : GENCLEANUP         (procedure in GENSCRN.PRG)
*!               : GENPROCEDURES      (procedure in GENSCRN.PRG)
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION multiplat
*)
*) MULTIPLAT - Returns TRUE if we are generating for multiple platforms
*)
RETURN IIF(m.g_allplatforms AND m.g_numplatforms > 1, .T. , .F.)

*!*****************************************************************************
*!
*!      Procedure: SEEKHEADER
*!
*!      Called by: GENCLEANUP         (procedure in GENSCRN.PRG)
*!               : GENPROCEDURES      (procedure in GENSCRN.PRG)
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : GENSECT2           (procedure in GENSCRN.PRG)
*!               : GENRELATIONS       (procedure in GENSCRN.PRG)
*!               : BUILDFMT           (procedure in GENSCRN.PRG)
*!               : GENGIVENREAD       (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE seekheader
*)
*) SEEKHEADER - Find the header for this screen/platform
*)
PARAMETER m.i
IF g_screens[m.i,6]
   GO TOP
ELSE
   LOCATE FOR platform = g_screens[m.i,7] AND objtype = c_otscreen
ENDIF
RETURN

*!*****************************************************************************
*!
*!       Function: GETPLATNAME
*!
*!      Called by: GENCLEANUP         (procedure in GENSCRN.PRG)
*!               : GENPROCEDURES      (procedure in GENSCRN.PRG)
*!               : GENSECT1           (procedure in GENSCRN.PRG)
*!               : GENSECT2           (procedure in GENSCRN.PRG)
*!               : GENVALIDBODY       (procedure in GENSCRN.PRG)
*!               : GENWHENBODY        (procedure in GENSCRN.PRG)
*!               : ACTICLAUSE         (procedure in GENSCRN.PRG)
*!               : DEATCLAUSE         (procedure in GENSCRN.PRG)
*!               : SHOWCLAUSE         (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION getplatname
*)
*) GETPLATNAME - Return the platform for a screen
*)
PARAMETER m.plnum
IF g_screens[m.plnum,6]
   RETURN "DOS"
ELSE
   RETURN platform
ENDIF
RETURN


*!*****************************************************************************
*!
*!      Procedure: INSERTFILE
*!
*!      Called by: GENINSERTCODE      (procedure in GENSCRN.PRG)
*!
*!          Calls: WRITECODE          (procedure in GENSCRN.PRG)
*!
*!*****************************************************************************
PROCEDURE insertfile
PARAMETER m.incfn, m.scrnno, m.insetup, m.platname
PRIVATE m.oldals, m.insdbfname, m.oldmline, m.fptname

* Search for the file in the current directory, along the FoxPro path, and along
* the DOS path.
IF !FILE(m.incfn)
   DO CASE
   CASE FILE(FULLPATH(m.incfn))
      m.incfn = FULLPATH(m.incfn)
   CASE FILE(FULLPATH(m.incfn,1))
      m.incfn = FULLPATH(m.incfn,1)
   ENDCASE
ENDIF

IF FILE((m.incfn))
   m.oldals = ALIAS()
   m.insdbfname = SYS(3)+".DBF"
   m.oldmline = _MLINE

   * The following lines create a temporary file with a single memo field
   * and appends the inserted file into the memo field. Effectively creating
   * a code snippet. This allows the standard procedure for generating code
   * snippets to be call to process the inserted file. This in turn allows
   * the include file to contain generator directives.
   CREATE TABLE (m.insdbfname) (inscode m)
   APPEND BLANK
   APPEND MEMO inscode FROM (m.incfn)

   \** Start of inserted file <<m.incfn>> <<REPLICATE(m.g_horiz,32)+"start">>

   * Make a recursive call to the standard snippet generation procedure
   DO writecode WITH inscode, m.platname, 1, 0, m.scrnno, m.insetup

   \** End of inserted file <<m.incfn>> <<REPLICATE(m.g_horiz,36)+"end">>
   \

   USE
   DELETE FILE (m.insdbfname)
   m.fptname = forceext(m.insdbfname,"FPT")
   IF FILE(m.fptname)
      DELETE FILE (m.fptname)
   ENDIF

   SELECT (m.oldals)
   _MLINE=oldmline
ELSE
   \*
   \* Inserted file <<m.incfn>> not found!
   \*
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Function: VERSNUM
*!
*!*****************************************************************************
FUNCTION versnum
* Return string corresponding to FoxPro version number
RETURN wordnum(vers(),2)


*!*****************************************************************************
*!
*!      Function: SHOWSTAT
*!
*!*****************************************************************************
PROCEDURE showstat
PARAMETER m.strg
WAIT WINDOW m.strg NOWAIT
RETURN

*!*****************************************************************************
*!
*!      Function: KILLCR
*!
*!*****************************************************************************
PROCEDURE killcr
PARAMETER m.strg
IF _MAC
   m.strg = CHRTRAN(m.strg,CHR(13)+CHR(10),"")
ENDIF
RETURN

*!*****************************************************************************
*!
*!      Function: ASSERT
*!
*!*****************************************************************************
FUNCTION assert
PARAMETER m.bool, m.strg
IF !m.bool
   WAIT WINDOW m.strg
ENDIF

*!*****************************************************************************
*!
*!      Function: BITMAPSTR
*!
*!*****************************************************************************
FUNCTION bitmapstr
* Return a string of bitmap file extensions, suitable for LOCFILE, etc.
PARAMETER whichone
DO CASE
CASE whichone = c_all AND _MAC
   RETURN '"'+m.g_picext+"|"+m.g_bmpext+"|"+m.g_icnext+"|"+m.g_icoext+'"'
CASE whichone = c_all AND !_MAC
   RETURN '"'+m.g_bmpext+"|"+m.g_icoext+"|"+m.g_picext+"|"+m.g_icnext+'"'
OTHERWISE
   RETURN '"'+IIF(_MAC,m.g_picext,m.g_bmpext)+'"'
ENDCASE

*!*****************************************************************************
*!
*!      Function: ICONSTR
*!
*!*****************************************************************************
FUNCTION iconstr
DO CASE
CASE _MAC
	RETURN m.g_icnext
OTHERWISE
	RETURN m.g_icoext
ENDCASE

*!*****************************************************************************
*!
*!      Function: STYLE2NUM
*!
*!*****************************************************************************
FUNCTION style2num
* Translate a font style string to its equivalent numerical representation
PARAMETER m.strg
PRIVATE m.i, m.num
m.num = 0
m.strg= UPPER(ALLTRIM(m.strg))
FOR m.i = 1 TO LEN(m.strg)
   DO CASE
   CASE SUBSTR(m.strg,i,1) = "B"      && bold
      m.num = m.num + 1
   CASE SUBSTR(m.strg,i,1) = "I"	     && italic
      m.num = m.num + 2
   CASE SUBSTR(m.strg,i,1) = "U"      && underlined
      m.num = m.num + 4
   CASE SUBSTR(m.strg,i,1) = "O"      && outline
      m.num = m.num + 8
   CASE SUBSTR(m.strg,i,1) = "S"      && shadow
      m.num = m.num + 16
   CASE SUBSTR(m.strg,i,1) = "C"	     && condensed
      m.num = m.num + 32
   CASE SUBSTR(m.strg,i,1) = "E"      && extended
      m.num = m.num + 64
   CASE SUBSTR(m.strg,i,1) = "-"      && strikeout
      m.num = m.num + 128
   ENDCASE
ENDFOR
RETURN m.num

*!*****************************************************************************
*!
*!      Function: NUM2STYLE
*!
*!*****************************************************************************
FUNCTION num2style
* Translate a font style number to its equivalent string representation
PARAMETER m.num
PRIVATE m.i, m.strg, m.pow, m.stylechars, m.outstrg
m.strg = ""
* These are the style characters.  Their position in the string matches the bit
* position in the num byte.
m.stylechars = "BIUOSCE-"

* Look at each of the bits in the num byte
FOR m.i = 8 TO 1 STEP -1
   m.pow = ROUND(2^(i-1),0)
	IF m.num >= m.pow
	   m.strg = m.strg + SUBSTR(stylechars,m.i,1)
	ENDIF
	m.num = m.num % m.pow
ENDFOR

* Now reverse the string so that style codes appear in the traditional order
m.outstrg = ""
FOR m.i = 1 TO LEN(m.strg)
   m.outstrg = m.outstrg + SUBSTR(m.strg,LEN(m.strg)+1-m.i,1)
ENDFOR
RETURN m.outstrg


FUNCTION ctrlclause
PARAMETER m.pictstrg
* Return the control portion of a picture string
m.pictstrg = LTRIM(m.pictstrg)
m.spos = AT(' ',m.pictstrg)
IF m.spos > 1
	IF INLIST(LEFT(m.pictstrg,1),'"',"'")
	   m.pictstrg = STRTRAN(m.pictstrg,LEFT(m.pictstrg,1),"")
	ENDIF
   RETURN ALLTRIM(LEFT(m.pictstrg,m.spos - 1))
ELSE
   RETURN m.pictstrg
ENDIF


*: EOF: GENSCRN.PRG
