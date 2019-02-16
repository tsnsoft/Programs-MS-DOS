*
* GENMENU - Menu code generator.
*
* Copyright (c) 1990 - 1993 Microsoft Corp.
* 1 Microsoft Way
* Redmond, WA 98052
*
* Description:
* This program generates menu code which was designed in the
* FoxPro 2.5 MENU BUILDER.
*
* Notes:
* In this program, for clarity/readability reasons, we use variable
* names that are longer than 10 characters.  Note, however, that only
* the first 10 characters are significant.
*
* Modification History:
* December 13, 1990		JAC		Program Created
*
* Modifed for FoxPro 2.5 by WJK.
*
PARAMETER m.projdbf, m.recno
PRIVATE ALL
IF SET("TALK") = "ON"
    SET TALK OFF
    m.talkstate = "ON"
ELSE
    m.talkstate = "OFF"
ENDIF
m.escape = SET("ESCAPE")
SET ESCAPE OFF

m.trbetween = SET("TRBET")
SET TRBET OFF
m.comp = SET("COMPATIBLE")
SET COMPATIBLE OFF
mdevice = SET("DEVICE")
SET DEVICE TO SCREEN

*
* Declare Constants
*
#DEFINE c_esc	CHR(27)
#DEFINE c_null	CHR(0)
#DEFINE c_aliaslen 10
*
* Possible values of Objtype field in SCX database.
*
#DEFINE c_menu		1
#DEFINE c_submenu	2
#DEFINE c_item		3

*
* Some of the values of Objcode field in SCX database.
*
#DEFINE	c_global	1
#DEFINE c_proc		80

#DEFINE c_maxsnippets	25
#DEFINE c_maxpads		25
#DEFINE c_pjx20flds		33
#DEFINE c_pjxflds		31
#DEFINE c_mnxflds		23
#DEFINE c_20mnxflds		22

#DEFINE c_authorlen		45
#DEFINE c_complen		45
#DEFINE c_addrlen		45
#DEFINE c_citylen		20
#DEFINE c_statlen		5
#DEFINE c_ziplen		10
#DEFINE c_countrylen 40

#DEFINE c_error_1		"Minor"
#DEFINE c_error_2		"Serious"
#DEFINE c_error_3		"Fatal"

IF _MAC
   m.g_dlgface	 =	"Geneva"
   m.g_dlgsize	 =	10.000
   m.g_dlgstyle =		""
ELSE
   m.g_dlgface	 =	"MS Sans Serif"
   m.g_dlgsize	 =	8.000
   m.g_dlgstyle =		"B"
ENDIF

#DEFINE c_replace		0
#DEFINE c_append		1
#DEFINE c_before		2
#DEFINE c_after			3

#DEFINE c_pathsep  "\"

*
* Declare Variables
*
STORE "" TO m.cursor, m.consol, m.bell, m.onerror, m.fields, mfieldsto, ;
    m.exact, m.print, m.fixed, m.delimiters, m.mpoint, m.mcollate,m.mmacdesk
STORE 0 TO m.deci, m.memowidth

m.g_error      = .F.
m.g_errlog     = ""
m.g_homedir    = ""
m.g_location   = 0
m.g_menucolor  = 0
m.g_menumark   = ""
m.g_nohandle   = .T.
m.g_nsnippets  = 0
m.g_outfile    = ""
m.g_padloca    = ""
m.g_projalias  = ""
m.g_projdbf    = m.projdbf
m.g_projpath   = ""
m.g_status     = 0
m.g_snippcnt   = 0
m.g_thermwidth = 0
m.g_workarea   = 0
m.g_graphic    = .F.
m.g_20mnx	   = .F.

m.g_devauthor  = PADR("Author's Name",45," ")
m.g_devcompany = PADR("Company Name",45, " ")
m.g_devaddress = PADR("Address",45," ")
m.g_devcity    = PADR("City",20," ")
m.g_devstate   = "  "
m.g_devzip     = PADR("Zip",10," ")
m.g_devctry    = PADR("Country",40," ")

m.g_boxstrg = ['Ä','Ä','³','³','Ú','¿','À','Ù','Ä','Ä','³','³','Ú','¿','À','Ù']

STORE "" TO m.g_corn1, m.g_corn2, m.g_corn3, m.g_corn4, m.g_corn5, ;
    m.g_corn6, m.g_verti2
STORE "*" TO  m.g_horiz, m.g_verti1

*
* Array Declarations
*
* g_mnxfile [1] - Normalized path + name
* g_mnxfile [2] - Basename
* g_mnxfile [3] - Opened originally?
* g_mnxfile [4] - Alias
*
DIMENSION g_mnxfile[4]
g_mnxfile[1] = ""
g_mnxfile[2] = ""
g_mnxfile[3] = .F.
g_mnxfile[4] = ""

*
* g_pads - names of generated menu pads
*
DIMENSION g_pads(c_maxpads)

*
* g_snippets [*,1] - generated snippet procedure name
* g_snippets [*,2] - recno()
*

DIMENSION g_snippets (c_maxsnippets,2)
g_snippets = ""

IF AT("WINDOWS", UPPER(VERSION())) <> 0 OR ;
        AT("MAC", UPPER(VERSION())) <> 0
    m.g_graphic = .T.
ELSE
    m.g_graphic = .F.
ENDIF

*
* Main program
*
m.onerror = ON("ERROR")
ON ERROR DO errorhandler WITH MESSAGE(), LINENO(), c_error_3

IF PARAMETERS()=2
    DO setup
    IF validparams()
        ON ESCAPE DO eschandler
        SET ESCAPE ON
        DO refreshprefs
        DO BUILD
    ENDIF
    DO cleanup
ELSE
    DO errorhandler WITH "Invalid number of parameters passed to"+;
        " the generator",LINENO(),c_error_3
ENDIF
ON ERROR &onerror

RETURN m.g_status

**
** Setup, Cleanup, Validparams, and Refreshprefs of Main Program
**

*
* STARTUP - Create program's environment.
*
* Description:
* Save the user's environment so that we can set it back when
* we are done, then issue various SET commands. The only state
* we cannot conveniently save is SET TALK, because storing the
* state involves an assignment statement, and assignments
* generate unwanted output if TALK is set ON.
*
* Side Effects:
* Creates a temporary file which is deleted in the Cleanup
* procedure executed at the end of MENUGEN.
*
PROCEDURE setup
    CLEAR PROGRAM
    CLEAR GETS
    m.g_workarea = SELECT()
    m.delimiters = SET('TEXTMERGE',1)
    SET TEXTMERGE DELIMITERS TO
    SET UDFPARMS TO VALUE

	m.mfieldsto = SET("FIELDS",1)
	m.fields = SET("FIELDS")
	SET FIELDS TO
	SET FIELDS OFF
    m.bell = SET("BELL")
    SET BELL OFF
    m.consol = SET("CONSOLE")
    SET CONSOLE OFF
    m.cursor = SET("CURSOR")
    SET CURSOR OFF
    m.deci = SET("DECIMALS")
    SET DECIMALS TO 0
    mdevice = SET("DEVICE")
    SET DEVICE TO SCREEN
    m.memowidth = SET("MEMOWIDTH")
    SET MEMOWIDTH TO 256
    m.exact = SET("EXACT")
    SET EXACT ON
    m.print = SET("PRINT")
    SET PRINT OFF
    m.fixed = SET("FIXED")
    SET FIXED ON
    mpoint = SET("POINT")
    SET POINT TO "."
    mcollate = SET("COLLATE")
    SET COLLATE TO "machine"
	 #if "MAC" $ UPPER(VERSION(1))
	    IF _MAC
      	 m.mmacdesk = SET("MACDESKTOP")
      	 SET MACDESKTOP ON
       ENDIF
	 #endif
*
* CLEANUP - restore environment to pre-execution state.
*
* Description:
* Close all databases opened in the course of the execution of MENUGEN.
* Restore the environment to the pre-execution of MENUGEN.  Delete
* the VIEW file since there is no further use for it.
*
* Side Effects:
* Closes databases.
* Deletes the temporary view file.
*
PROCEDURE cleanup
    PRIVATE m.delilen, m.ldelimi, m.rdelimi
    IF EMPTY(m.g_projalias)
        RETURN
    ENDIF
    SELECT (m.g_projalias)
    USE
    IF NOT EMPTY(g_mnxfile[3])
        IF USED(g_mnxfile[4])
            SELECT (g_mnxfile[4])
            USE
        ENDIF
    ENDIF
    SELECT (m.g_workarea)

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
    IF m.bell = "ON"
        SET BELL ON
    ENDIF
    IF m.cursor = "ON"
        SET CURSOR ON
    ELSE
        SET CURSOR OFF
    ENDIF
    IF m.consol = "ON"
        SET CONSOLE ON
    ENDIF
    IF m.escape = "ON"
        SET ESCAPE ON
    ELSE
        SET ESCAPE OFF
    ENDIF
    IF m.print = "ON"
        SET PRINT ON
    ENDIF
    IF m.exact = "OFF"
        SET EXACT OFF
    ENDIF
    IF m.fixed = "OFF"
        SET FIXED OFF
    ENDIF
    SET DECIMALS TO m.deci
    SET MEMOWIDTH TO m.memowidth
    SET DEVICE TO &mdevice
    IF m.trbetween = "ON"
        SET TRBET ON
    ENDIF
    IF m.comp = "ON"
        SET COMPATIBLE ON
    ENDIF
    IF m.talkstate = "ON"
        SET TALK ON
    ENDIF
    SET POINT TO "&mpoint"
    SET COLLATE TO "&mcollate"
    SET MESSAGE TO
    #if "MAC" $ UPPER(VERSION(1))
	    IF _MAC
          SET MACDESKTOP &mmacdesk
	    ENDIF
    #endif

    ON ERROR &onerror


*
* VALIDPARAMS - Validate generator parameters.
*
* Description:
* Attempt to open the project database.  If error encountered then
* on error routine takes over and issues 'CANCEL'.  The output file
* cannot be erased, name not known.
*
FUNCTION validparams
    SELECT 0
    m.g_projalias = IIF(USED("projdbf"),"P"+;
        SUBSTR(LOWER(SYS(3)),2,8),"projdbf")
    USE (m.projdbf) ALIAS (m.g_projalias)
    IF versnum() > "2.5"
       SET NOCPTRANS TO devinfo, arranged, symbols, object
    ENDIF

    m.g_errlog = stripext(m.projdbf)
    m.g_projpath = SUBSTR(m.projdbf,1,RAT("\",m.projdbf))

    IF FCOUNT() <> c_pjxflds
        DO errorhandler WITH "Generator out of date.",;
            LINENO(), c_error_2
        RETURN .F.
    ENDIF

    GOTO RECORD m.recno

    m.g_outfile = ALLTRIM(SUBSTR(outfile,1,AT(c_null,outfile)-1))
    m.g_outfile = FULLPATH(m.g_outfile, m.g_projpath)
    IF _MAC AND RIGHT(m.g_outfile,1) = ":"
       m.g_outfile = m.g_outfile + justfname(SUBSTR(outfile,1,AT(c_null,outfile)-1))
    ENDIF
    g_mnxfile[1] = FULLPATH(ALLTRIM(name), m.g_projpath)
    IF _MAC AND RIGHT(g_mnxfile[1],1) = ":"
       g_mnxfile[1] = g_mnxfile[1] + justfname(name)
    ENDIF
    g_mnxfile[2] = basename(g_mnxfile[1])

*
* REFRESHPREFS - Refresh comment style and developer preferences.
*
* Description:
* Get the newest preferences for documentation style and developer
* data from the project database.
*
PROCEDURE refreshprefs
    PRIVATE m.start, m.savrecno
    m.savrecno = RECNO()
    LOCATE FOR TYPE = "H"
    IF NOT FOUND ()
        DO errorhandler WITH "Missing header record in "+m.g_projdbf,;
            LINENO(), c_error_2
        GOTO RECORD m.savrecno
        RETURN
    ENDIF

    m.g_homedir = ALLTRIM(SUBSTR(homedir,1,AT(c_null,homedir)-1))

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
        m.g_corn6	= "¶"
        m.g_horiz = "Ä"
        m.g_verti1 = "º"
        m.g_verti2 = "º"
    ENDIF
    GOTO RECORD m.savrecno

*
* SUBDEVINFO - Substring the DEVINFO memo filed.
*
FUNCTION subdevinfo
    PARAMETER m.start, m.stop, m.default
    PRIVATE m.string
    m.string = SUBSTR(devinfo, m.start, m.stop+1)
    m.string = SUBSTR(m.string, 1, AT(c_null,m.string)-1)
    RETURN IIF(EMPTY(m.string), m.default, m.string)

**
** Menu Code Generator's Main Module.
**

*
* BUILD - Generate code for a menu.
*
* Description:
* Call BUILDENABLE to open .MNX database specified by the user.
* If the above is successfully accomplished, then proceed to generate
* the menu code.  After the menu code is generated, call BUILDDISABLE
* to disable code generation between SET TEXTMERGE ON and
* SET TEXTMERGE OFF.
*
PROCEDURE BUILD
    IF NOT buildenable()
        RETURN
    ENDIF
    DO acttherm WITH "Generating Menu Code..."
    DO updtherm WITH 10

    DO HEADER
    DO gensetupcleanup WITH "setup"
    DO definemenu
    DO definepopups
    DO updtherm WITH 75
    DO globaldefaults
    DO updtherm WITH 95
    DO gensetupcleanup WITH "cleanup"
    DO genprocedures

    IF m.g_graphic
        SET MESSAGE TO 'Generation Complete'
    ENDIF
    DO builddisable
    DO updtherm WITH 100
    DO deactthermo

*
* BUILDENABLE - Enable code generation.
*
* Description:
* Call opendb to open .MNX database.
* Call openfile to open file to hold the generated program.
* If error(s) encountered in opendb or openfile then don't do
* anything and exit, otherwise enable code generation with the
* SET TEXTMERGE ON command.
*
* Returns:
* .T. on success; .F. on failure
*
FUNCTION buildenable
    PRIVATE m.stat
    m.stat = opendb(g_mnxfile[1]) AND openfile()
    IF m.stat
        SET TEXTMERGE ON
    ENDIF
    RETURN m.stat

*
* BUILDDISABLE - Disable code generation.
*
* Description:
* Issue the command SET TEXTMERGE OFF.
* Close the generated menu code output file.
* If anything goes wrong display appropriate message to the user.
*
PROCEDURE builddisable
    SET ESCAPE OFF
    ON ESCAPE
    SET TEXTMERGE OFF
    IF NOT FCLOSE(_TEXT)
        DO errorhandler WITH "Unable to Close the Application File",;
            LINENO(), c_error_2
    ENDIF

*
* OPENDB - Prepare database for processing.
*
* Description:
* Attempt to USE a database.  If attempt fails and error is reported
* call ERRORHANDLER routine to display a friendly message.  Return
* with a status of .F..  If attempt succeeds, return with status of .T.
*
* Returns:
* .T. on success; .F. on failure
*
FUNCTION opendb
    PARAMETER m.dbname
    PRIVATE m.dbalias
    ON ERROR DO errorhandler WITH MESSAGE(), LINENO(), c_error_2

    m.dbalias = LEFT(basename(m.dbname),c_aliaslen)
    IF USED (m.dbalias)
        SELECT (m.dbalias)
        IF RAT(".MNX",DBF())<>0
            g_mnxfile[3] = .F.
            g_mnxfile[4] = m.dbalias
        ELSE
            g_mnxfile[4] = "M"+SUBSTR(LOWER(SYS(3)),2,8)
            SELECT 0
            USE (m.dbname) AGAIN ALIAS (g_mnxfile[4])
            g_mnxfile[3] = .T.
        ENDIF
    ELSE
        IF illegalname(m.dbalias)
            g_mnxfile[4] = "M"+SUBSTR(LOWER(SYS(3)),2,8)
        ELSE
            g_mnxfile[4] = m.dbalias
        ENDIF
        SELECT 0
        USE (m.dbname) AGAIN ALIAS (g_mnxfile[4])
        g_mnxfile[3] = .T.
    ENDIF

    IF FCOUNT() <> c_mnxflds
        IF FCOUNT() = c_20mnxflds
            m.g_20mnx = .T.
        ELSE
            DO errorhandler WITH "Menu "+m.dbalias+" is invalid",LINENO(),;
                c_error_2
            RETURN .F.
        ENDIF
    ELSE
        m.g_20mnx = .F.
    ENDIF

    ON ERROR DO errorhandler WITH MESSAGE(), LINENO(), c_error_3
    IF m.g_error = .T.
        RETURN .F.
    ENDIF

*
* ILLEGALNAME - Check if default alias will be used when this
*               database is USEd. (i.e., 1st letter is not A-Z,
*				a-z or '_', or any one of ramaining letters is not
*				alphanumeric.)
*
FUNCTION illegalname
    PARAMETER m.menuname
    PRIVATE m.start, m.aschar, m.length
    m.length = LEN(m.menuname)
    m.start  = 0
    IF m.length = 1
        *
        * If length 1, then check if default alias can be used,
        * i.e., name is different than A-J and a-j.
        *
        m.aschar = ASC(m.menuname)
        IF (m.aschar >= 65 AND m.aschar <= 74) OR ;
                (m.aschar >= 97 AND m.aschar <= 106)
            RETURN .T.
        ENDIF
    ENDIF
    DO WHILE m.start < m.length
        m.start  = m.start + 1
        m.aschar = ASC(SUBSTR(m.menuname, m.start, 1))
        IF m.start<>1 AND (m.aschar >= 48 AND m.aschar <= 57)
            LOOP
        ENDIF
        IF NOT ((m.aschar >= 65 AND m.aschar <= 90) OR ;
                (m.aschar >= 97 AND m.aschar <= 122) OR m.aschar = 95)
            RETURN .T.
        ENDIF
    ENDDO
    RETURN .F.

*
* OPENFILE - Create and open the application output file.
*
* Description:
* Create a file that will hold the generated menu code.
* Open the newly created file.  If error(s) encountered
* at any time issue an error message and return .F.
*
* Returns:
* .T. on success; .F. on failure
*
FUNCTION openfile
    PRIVATE m.msg
    _TEXT = FCREATE(m.g_outfile)
    IF (_TEXT = -1)
        m.msg = "Cannot open file "+m.g_outfile
        DO errorhandler WITH m.msg, LINENO(), c_error_3
        m.g_nohandle = .T.
        RETURN .F.
    ENDIF
    m.g_nohandle = .F.

*
* DEFINEMENU - Define main menu and its pads.
*
* Description:
* Issue DEFINE MENU ... command.
* Call a procedure to define all menu pads.
* Call a procedure to generate ON PAD statements when appropriate.
*
PROCEDURE definemenu

    IF m.g_graphic
        SET MESSAGE TO 'Generating menu definitions...'
    ENDIF
    DO commentblock WITH "menu"
    SELECT (g_mnxfile[4])
    LOCATE FOR objtype = c_menu
    m.g_location = location
    m.g_padloca  = ALLTRIM(name)

    LOCATE FOR objtype = c_submenu AND objcode = c_global

    m.g_menucolor = SCHEME
    m.g_menumark  = MARK
    IF m.g_location = c_replace
        \SET SYSMENU TO
        \
    ENDIF
    \SET SYSMENU AUTOMATIC
    \

    DO updtherm WITH 25
    DO defmenupads
    DO updtherm WITH 35
    DO defonpad
    \
    DO updtherm WITH 45

*
* DEFMENUPADS - Define all pads for the menu bar.
*
* Description:
* Scan the menu database for all objects of the type item which
* have the levelname=_MSYSMENU.
* For each such item, generate a statement DEFINE PAD... where
* the name of the pad is the contents of NAME field or (if Name
* field is empty) an automatically generated name.
* Call procedures addkey, addskipfor, and mark to generate
* KEY, SKIPFOR, or MARK clauses when appropriate.
*
PROCEDURE defmenupads
    PRIVATE m.padname, m.prompt
    SCAN FOR objtype=c_item AND UPPER(levelname)="_MSYSMENU"
        IF NOT EMPTY(ALLTRIM(name))
            g_pads[VAL(Itemnum)] = name
        ELSE
            g_pads[VAL(Itemnum)] = LOWER(SYS(2015))
        ENDIF
        \DEFINE PAD <<g_pads[VAL(Itemnum)]>> OF _MSYSMENU

        IF MOD(VAL(itemnum),25)=0
            DIMENSION g_pads[VAL(Itemnum)+25]
        ENDIF
        m.prompt = SUBSTR(PROMPT,1,LEN(PROMPT))
        \\ PROMPT "<<m.prompt>>"
        \\ COLOR SCHEME <<m.g_menucolor>>

        IF m.g_menumark<>c_null AND m.g_menumark<>""
            \\ ;
            \	MARK "<<m.g_menumark>>"
        ENDIF

        DO CASE
            CASE m.g_location = c_before
                \\ ;
                \	BEFORE <<m.g_padloca>>
            CASE m.g_location = c_after
                \\ ;
                \	AFTER
                IF VAL(itemnum) = 1
                    \\ <<m.g_padloca>>
                ELSE
                    \\ <<g_pads[VAL(Itemnum)-1]>>
                ENDIF
        ENDCASE

        DO addkey
        DO addskipfor
        DO addmessage

    ENDSCAN

*
* DEFONPAD - Generate ON PAD... statements.
*
* Description:
* Generate ON PAD statements for each pad off of the main menu which
* has a submenu associated with it.
* For pads which have no submenus, but there is a command associated
* with them, issue ON SELECTION PAD... statements.  If the code
* associated with a pad is a snippet, then issue a call to the
* generated procedure and place the snippet code in it.
*
PROCEDURE defonpad
    PRIVATE m.padname
    SCAN FOR objtype=c_item AND UPPER(levelname)="_MSYSMENU"
         IF NOT EMPTY(ALLTRIM(name))
               m.padname = name
         ELSE
               m.padname = g_pads[VAL(Itemnum)]
         ENDIF
         m.therec = RECNO()
         SKIP
         IF objtype=c_submenu AND numitems<>0
               \ON PAD <<m.padname>> OF _MSYSMENU
               \\ ACTIVATE POPUP <<LOWER(Name)>>
               GOTO m.therec
         ELSE
               GOTO m.therec
               DO onselection WITH "pad", m.padname, '_MSYSMENU'
         ENDIF
    ENDSCAN

*
* DEFINEPOPUPS - Define popups and their bars.
*
* Description:
* Scan the Menu database to find all objecttypes = submenu.
* They all correspond to popups.  For each such object found, issue
* command DEFINE POPUP....  Add MARK, KEY, and SKIP FOR clauses
* if appropriate by calling procedures to handle these tasks.  Call
* procedure Defbars to define all bars of each popup.
*
PROCEDURE definepopups
    PRIVATE m.savrecno, m.popname, m.sch
    IF m.g_graphic
        SET MESSAGE TO 'Generating popup definitions...'
    ENDIF
    SCAN FOR objtype=c_submenu AND UPPER(levelname)<>"_MSYSMENU" ;
            AND numitems <> 0

        m.savrecno = RECNO()
        m.popname  = ALLTRIM(LOWER(levelname))
        m.sch      = SCHEME

        \DEFINE POPUP <<LOWER(Name)>> MARGIN RELATIVE SHADOW
        \\ COLOR SCHEME <<m.sch>>

        DO addmark
        DO addkey
        DO defbars WITH m.popname, numitems
        DO defonbar WITH m.popname
        \
        GOTO RECORD m.savrecno
    ENDSCAN

*
* DEFBARS - Define bars for each popup.
*
* Description:
* Scan the menu database for all objects of the type item whose
* name equals to the current popup name.
* For each such item, generate a statement DEFINE BAR....
* Call procedures addkey, addskipfor, and addmark to generate
* KEY, SKIPFOR, or MARK clauses when appropriate.
*
PROCEDURE defbars
    PARAMETER m.popname, m.howmany, m.name
    PRIVATE m.itemno, m.prompt
    SCAN FOR objtype=c_item AND LOWER(levelname)=m.popname
        m.itemno = ALLTRIM(itemnum)

        IF NOT EMPTY(ALLTRIM(name))
            m.name = name
            \DEFINE BAR <<m.name>> OF <<LOWER(m.popname)>>
        ELSE
            \DEFINE BAR <<m.itemno>> OF <<LOWER(m.popname)>>
        ENDIF
        m.prompt = SUBSTR(PROMPT, 1,LEN(PROMPT))
        \\ PROMPT "<<m.prompt>>"

        DO addmark
        DO addkey
        DO addskipfor
        DO addmessage

        IF VAL(m.itemno)=m.howmany
            RETURN
        ENDIF
    ENDSCAN

*
* DEFONBAR - Generate ON BAR... statements.
*
* Description:
* Generate ON BAR statements for each popup.
* For bars which have no submenus, but there is a command associated
* with them, issue ON SELECTION BAR... statements.  If a snippet is
* associated with the code then generate a call statement to the
* generated procedure containing the snippet code.
*
PROCEDURE defonbar
    PARAMETER m.popname
    PRIVATE m.itemno
    SCAN FOR objtype=c_item AND LOWER(levelname)=m.popname
        IF EMPTY(ALLTRIM(name))
            m.itemno = ALLTRIM(itemnum)
        ELSE
            m.itemno = name
        ENDIF
        SKIP
        IF objtype=c_submenu AND numitems<>0
            \ON BAR <<m.itemno>> OF <<LOWER(m.popname)>>
            \\ ACTIVATE POPUP <<LOWER(Name)>>
            SKIP -1
        ELSE
            SKIP -1
            DO onselection WITH "BAR", m.itemno, m.popname
        ENDIF
    ENDSCAN

*
* GLOBALDEFAULTS - Generate global default statements
*
* Description:
* Search the menu database for information needed to generate any of
* the following commands:
* ON SELECTION MENU <name> DO <action>
* ON SELECTION POPUP ALL DO <action>
* ON SELECTION POPUP <name> DO <action>
* It is possible that none of the above mentioned statements will be
* generated.  It is also possible that the action is a snippet of
* code and a call to the generated procedure containing the snippet
* will be generated.
*
* First try to generate ON SELECTION MENU...
* Then try to generate ON POPUP ALL...
* Lastly, try to generate ON SELECTION POPUP...
*
PROCEDURE globaldefaults
    LOCATE FOR objtype = c_menu
    m.mrk = MARK
    IF FOUND() AND MARK <> ""
        IF MARK = c_null
            \SET MARK OF MENU _MSYSMENU TO " "
        ELSE
            \SET MARK OF MENU _MSYSMENU TO "<<Mark>>"
        ENDIF
    ENDIF
    IF FOUND() AND NOT EMPTY(PROCEDURE)
        \ON SELECTION MENU _MSYSMENU
        DO genproccall
    ENDIF
    LOCATE FOR objtype = c_submenu AND objcode = c_global
    IF FOUND() AND NOT EMPTY(PROCEDURE)
        \ON SELECTION POPUP ALL
        DO genproccall
    ENDIF
    SCAN FOR (objtype=c_submenu AND UPPER(levelname)<>"_MSYSMENU";
            AND NOT EMPTY(PROCEDURE))
        \ON SELECTION POPUP <<ALLTRIM(LOWER(Levelname))>>
        DO genproccall
    ENDSCAN

**
** Subroutines for processing menu clause options.
**

*
* ADDMARK - Generate a MARK clause whenever appropriate.
*
* Description:
* Add a MARK clause to the current PAD or BAR definition.
* If a field named Mark is not empty, then add the continuation
* character, ";", to the previous line, and then add the MARK... clause.
*
PROCEDURE addmark
    IF MARK<>c_null AND MARK<>""
        \\ ;
            \	MARK "<<Mark>>"
    ENDIF

*
* ADDKEY - Generate KEY... clause whenever appropriate.
*
* Description:
* Add a KEY clause to the current PAD or BAR definition.
* If a field named Keyname is not empty, then add the continuation
* character, ";", to the previous line, and then add the KEY... clause.
*
PROCEDURE addkey
    IF NOT EMPTY(keyname)
        \\ ;
        \	KEY <<Keyname>>, "<<Keylabel>>"
    ENDIF

*
* ADDSKIPFOR - Generate SKIP FOR... clause whenever appropriate.
*
* Description:
* Add a ADDSKIPFOR clause to the current PAD or BAR definition.
* If a field named Addskipfor is not empty, then add the continuation
* character, ";", to the previous line, and then add the SKIP FOR...
* clause.
*
PROCEDURE addskipfor
    PRIVATE m.skip
    m.skip = skipfor
    IF NOT EMPTY(skipfor)
        \\ ;
        \	SKIP FOR <<m.skip>>
    ENDIF

*
* ADDMESSAGE - Generate MESSAGE clause whenever appropriate.
*
* Description:
* Add a MESSAGE clause to the current PAD or BAR definition.
* If a field named MESSAGE is not empty and it is not a 2.0 menu,
* then add the continuation character, ";", to the previous line,
* and then add the MESSAGE clause.
*
PROCEDURE addmessage

    IF !m.g_20mnx AND NOT EMPTY(MESSAGE)
        \\ ;
        \	MESSAGE <<Message>>
    ENDIF

*
* HEADER - Generate generated program's header.
*
* Description:
* As a part of the automatically generated program's header generate
* program name, name of the author of the program, copyright notice,
* company name and address, and the word 'Description:' which will be
* followed with a short description of the generated code.
*
PROCEDURE HEADER
    \\*       <<m.g_corn1>><<REPLICATE(m.g_horiz,57)>><<m.g_corn2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_verti1>> <<DATE()>>
    \\<<PADC(UPPER(ALLTRIM(strippath(m.g_outfile))),IIF(SET("CENTURY")="ON",35,37))," ")>>
    \\ <<TIME()>>  <<m.g_verti2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_corn5>><<REPLICATE(m.g_horiz,57)>><<m.g_corn6>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_verti1>> <<m.g_devauthor>>
    \\<<REPLICATE(" ",56-LEN(m.g_devauthor))>><<m.g_verti2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_verti1>>
    \\ Copyright (c) <<YEAR(DATE())>>
    IF LEN(ALLTRIM(m.g_devcompany)) <= 36
        \\ <<ALLTRIM(m.g_devcompany)>>
        \\<<REPLICATE(" ",37-LEN(ALLTRIM(m.g_devcompany)))>>
        \\<<m.g_verti2>>
    ELSE
        \\ <<REPLICATE(" ",37)>><<m.g_verti2>>
        \*       <<m.g_verti1>> <<m.g_devcompany>>
        \\<<REPLICATE(" ",56-LEN(m.g_devcompany))>><<m.g_verti2>>
    ENDIF

    \*       <<m.g_verti1>> <<m.g_devaddress>>
    \\<<REPLICATE(" ",56-LEN(m.g_devaddress))>><<m.g_verti2>>

    \*       <<m.g_verti1>> <<ALLTRIM(m.g_devcity)>>, <<m.g_devstate>>
    \\  <<ALLTRIM(m.g_devzip)>>
    \\<<REPLICATE(" ",50-(LEN(ALLTRIM(m.g_devcity)+ALLTRIM(m.g_devzip))))>>
    \\<<m.g_verti2>>

    IF !INLIST(ALLTRIM(UPPER(m.g_devctry)),"USA","COUNTRY") AND !EMPTY(m.g_devctry)
       \*       <<m.g_verti1>> <<ALLTRIM(m.g_devctry)>>
       \\<<REPLICATE(" ",50-(LEN(ALLTRIM(m.g_devctry))))>>
       \\<<m.g_verti2>>
    ENDIF

    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_verti1>> Description:
    \\                                            <<m.g_verti2>>
    \*       <<m.g_verti1>>
    \\ This program was automatically generated by GENMENU.
    \\    <<m.g_verti2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_corn3>><<REPLICATE(m.g_horiz,57)>><<m.g_corn4>>
    \

*
* GENFUNCHEADER - Generate Comment for Function/Procedure.
*
PROCEDURE genfuncheader
    PARAMETER m.procname
    PRIVATE m.place, m.prompt
    m.g_snippcnt = m.g_snippcnt + 1
    DO CASE
        CASE objtype = c_menu
            m.place = "ON SELECTION MENU _MSYSMENU"
        CASE objtype = c_submenu AND objcode = c_global
            m.place = "ON SELECTION POPUP ALL"
        CASE objtype = c_submenu AND objcode <> c_global
            m.place = "ON SELECTION POPUP "+LOWER(ALLTRIM(name))
        CASE objtype = c_item AND UPPER(levelname) = "_MSYSMENU"
            m.place = "ON SELECTION PAD "
        CASE objtype = c_item AND UPPER(levelname) <> "_MSYSMENU"
            m.place = "ON SELECTION BAR "+ALLTRIM(itemnum)+;
                +" OF POPUP "+LOWER(ALLTRIM(levelname))
        OTHERWISE
            m.place = ""
    ENDCASE
    \
    \*       <<m.g_corn1>><<REPLICATE(m.g_horiz,57)>><<m.g_corn2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_verti1>> <<UPPER(PADR(m.procname,10))>>  <<m.place>>
    \\<<REPLICATE(" ",44-LEN(m.place))>><<m.g_verti2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_verti1>> Procedure Origin:
    \\<<REPLICATE(" ",39)>><<m.g_verti2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_verti1>> From Menu:
    \\  <<ALLTRIM(strippath(m.g_outfile))>>
    \\,            Record:  <<STR(RECNO(),3)>>
    \\<<REPLICATE(" ",22-LEN(ALLTRIM(strippath(m.g_outfile))+STR(RECNO(),3))))>>
    \\<<m.g_verti2>>
    \*       <<m.g_verti1>> Called By:  <<m.place>>
    \\<<REPLICATE(" ",44-LEN(m.place))>><<m.g_verti2>>
    IF NOT EMPTY(PROMPT)
        m.prompt = removemeta()
        \*       <<m.g_verti1>> Prompt:     <<ALLTRIM(m.prompt)>>
        \\<<REPLICATE(" ",44-LEN(ALLTRIM(m.prompt)))>><<m.g_verti2>>
    ENDIF
    \*       <<m.g_verti1>> Snippet:
    \\    <<ALLTRIM(STR(m.g_snippcnt,2))>>
    \\<<REPLICATE(" ",44-LEN(ALLTRIM(STR(m.g_snippcnt,2))))>><<m.g_verti2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_corn3>><<REPLICATE(m.g_horiz,57)>><<m.g_corn4>>
    \*

*
* REMOVEMETA - Remove meta characters for documentation.
*
FUNCTION removemeta
    PRIVATE m.prompt, m.hotkey
    m.prompt = PROMPT
    m.hotkey = AT("\<",m.prompt)

    IF m.hotkey <> 0
        m.prompt = STUFF(m.prompt,m.hotkey,2,"")
    ENDIF

    m.disabl = AT("\",m.prompt)
    IF m.disabl <> 0
        m.prompt = STUFF(m.prompt,m.disabl,1,"")
    ENDIF
    RETURN m.prompt

*
* COMMENTBLOCK - Generate a comment block.
*
PROCEDURE commentblock
    PARAMETER m.snippet
    \
    \*       <<m.g_corn1>><<REPLICATE(m.g_horiz,57)>><<m.g_corn2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    DO CASE
        CASE m.snippet == "setup"
            \*       <<m.g_verti1>>
            \\ <<PADC(" Setup Code",56," ")>>
        CASE m.snippet == "cleanup"
            \*       <<m.g_verti1>>
            \\ <<PADC(" Cleanup Code & Procedures",56," ")>>
        CASE m.snippet == "init"
            \*       <<m.g_verti1>>
            \\ <<PADC(" Initializing Code",56," ")>>
        CASE m.snippet == "menu"
            \*       <<m.g_verti1>>
            \\ <<PADC(" Menu Definition",56," ")>>
    ENDCASE
    \\<<m.g_verti2>>
    \*       <<m.g_verti1>><<REPLICATE(" ",57)>><<m.g_verti2>>
    \*       <<m.g_corn3>><<REPLICATE(m.g_horiz,57)>><<m.g_corn4>>
    \*
    \

**
** Supporting routines
**

*
* ONSELECTION - Generate ON SELECTION... statements for menu items.
*
* Description:
* For pads and bars which have no submenu associated with them but
* instead have a non-empty Command field in the database, issue
* the ON SELECTION <command> statements.  If a snippet is associated
* with a pad then issue a call statement to the generated procedure
* containing the snippet.  Generated snippet procedure will be
* appended to the end of the output file.
*
PROCEDURE onselection
    PARAMETER m.which, m.name, m.ofname, m.commd
    PRIVATE m.trimname, m.basename
    IF EMPTY(PROCEDURE) AND EMPTY(COMMAND)
        RETURN
    ENDIF
    DO CASE
        CASE m.which == "pad"
            \ON SELECTION PAD <<m.name>>
        CASE m.which == "BAR"
            \ON SELECTION <<m.which+" "+m.name>>
    ENDCASE
    \\ OF <<m.ofname>>
    IF objcode = c_proc
        DO gensnippname
        m.trimname = SYS(2014,UPPER(m.g_outfile),UPPER(m.g_homedir))
        m.trimname = stripext(m.trimname)
        m.basename = basename(m.trimname)
        \\ ;
        \	DO <<g_snippets[g_nsnippets,1]>> ;
        \	IN LOCFILE("<<m.trimname>>"
        \\ ,"MPX;MPR|FXP;PRG"
        \\ ,"Where is <<m.basename>>?")
    ELSE
        m.commd = COMMAND
        \\ <<m.commd>>
    ENDIF

*
* GENSNIPPNAME - Generate a unique name for snippet procedure.
*
* Description:
* Lookup the #NAME name of this snippet, or alternatively
* provide a unique name for a snippet of code associated with the
* generated menu.  Save this name in an array g_snippets.
*
PROCEDURE gensnippname
    g_nsnippets = g_nsnippets + 1
    g_snippets[g_nsnippets,1] = getcname(procedure)
    g_snippets[g_nsnippets,2] = RECNO()

    IF MOD(g_nsnippets,25) = 0
        DIMENSION g_snippets [g_nsnippets+25,2]
    ENDIF

*
* GENPROCCALL - Generate a call statement to snippet procedure.
*
* Description:
* Generate a call to the snippet procedure in the menu definition
* code.
*
PROCEDURE genproccall
    PRIVATE m.trimname, m.basename, m.proc
    IF singleline()
        m.proc = PROCEDURE
        \\ <<MLINE(m.proc,1)>>
    ELSE
        DO gensnippname
        m.trimname = SYS(2014,UPPER(m.g_outfile),UPPER(m.g_homedir))
        m.trimname = stripext(m.trimname)
        m.basename = basename(m.trimname)
        \\ ;
        \	DO <<g_snippets[m.g_nsnippets,1]>> ;
        \	IN LOCFILE("<<m.trimname>>"
        \\ ,"MPX;MPR|FXP;PRG"
        \\ ,"Where is <<m.basename>>?")
    ENDIF

*
* SINGLELINE - Determine if Memo contains only one line.
*
* Description:
* This procedure is used to decide if an ON SELECTION... statement
* and a snippet procedure will be needed (i.e., if more than one
* line of snippet code then its a snippet, otherwise its a command)
*
FUNCTION singleline
    PRIVATE m.size, m.i
    m.size = MEMLINES(PROCEDURE)
    IF m.size = 1
        RETURN .T.
    ENDIF
    m.i = m.size
    DO WHILE m.i > 1
        m.line = MLINE(PROCEDURE, m.i)
        IF NOT EMPTY(m.line)
            RETURN .F.
        ENDIF
        m.i = m.i - 1
    ENDDO

*
* GENPROCEDURES - Generate procedure/snippet code.
*
* Description:
* Generate 'PROCEDURE procedurename' statement and its body.
*
PROCEDURE genprocedures
    PRIVATE m.i
    IF m.g_graphic
        SET MESSAGE TO 'Generating procedures...'
    ENDIF
    FOR m.i = 1 TO m.g_nsnippets
        GOTO RECORD (g_snippets[m.i,2])
        DO genfuncheader WITH g_snippets[m.i,1]
        \PROCEDURE <<g_snippets[m.i,1]>>
        DO writecode WITH procedure
        \
    ENDFOR

*
* WRITECODE - Write contents of a memo to a low level file.
*
* Description:
* Receive a memo field as a parameter and write its contents out
* to the currently opened low level file whose handle is stored
* in the system memory variable _TEXT.  Contents of the system
* memory variable _pretext will affect the positioning of the
* generated text.
*
PROCEDURE writecode
    PARAMETER m.memo
    PRIVATE m.lines, m.i, m.thisline
    m.lines = MEMLINES(m.memo)
    _MLINE = 0
    FOR m.i = 1 TO m.lines
        m.thisline = MLINE(m.memo, 1, _MLINE)
        IF LEFT(UPPER(LTRIM(m.thisline)),5) == "#INSE"   && #INSERT
           DO GenInsertCode WITH m.thisline
        ELSE
           IF LEFT(UPPER(LTRIM(m.thisline)),5) <> "#NAME"
              \<<m.thisline>>
           ENDIF
        ENDIF
    ENDFOR

*
* GENSETUPCLEANUP - Generate setup/cleanup code.
*
PROCEDURE gensetupcleanup
    PARAMETER m.choice
    LOCATE FOR objtype = c_menu
    DO CASE
        CASE m.choice == "setup"
            IF EMPTY(setup)
                RETURN
            ENDIF
            IF m.g_graphic
                SET MESSAGE TO 'Generating Menu Setup Code...'
            ENDIF
            DO commentblock WITH m.choice
            DO writecode WITH setup
        CASE m.choice == "cleanup"
            IF EMPTY(cleanup)
                RETURN
            ENDIF
            IF m.g_graphic
                SET MESSAGE TO 'Generating Menu Cleanup Code...'
            ENDIF
            DO commentblock WITH m.choice
            DO writecode WITH cleanup
    ENDCASE

*
* STRIPEXT - Strip the extension from a file name.
*
* Description:
* Use the algorithm employed by FoxPRO itself to strip a
* file of an extension (if any): Find the rightmost dot in
* the filename.  If this dot occurs to the right of a "\"
* or ":", then treat everything from the dot rightward
* as an extension.  Of course, if we found no dot,
* we just hand back the filename unchanged.
*
* Parameters:
* filename - character string representing a file name
*
* Return value:
* The string "filename" with any extension removed
*
FUNCTION stripext
    PARAMETER m.filename
    PRIVATE m.dotpos, m.terminator
    m.dotpos = RAT(".", m.filename)
    m.terminator = MAX(RAT("\", m.filename), RAT(":", m.filename))
    IF m.dotpos > m.terminator
        m.filename = LEFT(m.filename, m.dotpos-1)
    ENDIF
    RETURN m.filename

*
* STRIPPATH - Strip the path from a file name.
*
* Description:
* Find positions of backslash in the name of the file.  If there is one
* take everything to the right of its position and make it the new file
* name.  If there is no slash look for colon.  Again if found, take
* everything to the right of it as the new name.  If neither slash
* nor colon are found then return the name unchanged.
*
* Parameters:
* filename - character string representing a file name
*
* Return value:
* The string "filename" with any path removed
*
FUNCTION strippath
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

*
* BASENAME - returns strippath(stripext(filespec))
*
FUNCTION basename
    PARAMETER m.filespec
    RETURN strippath(stripext(m.filespec))

*
* GENINSERTCODE - Emit code from the #insert file, if any
*
PROCEDURE GenInsertCode
PARAMETER strg
PRIVATE m.word1, m.filname, m.ins_fp, m.buffer

IF UPPER(LEFT(LTRIM(m.strg),5)) == "#INSE"
   m.word1 = wordnum(m.strg,1)
   m.filname = SUBSTR(m.strg,LEN(m.word1)+1)
   m.filname = ALLTRIM(CHRTRAN(m.filname,CHR(9),""))

   * Bail out if we can't find the file either explicitly or on the DOS path
   IF !FILE(m.filname)
      filname = FULLPATH(m.filname,1)
      IF !FILE(m.filname)
         \*Insert file <<m.filname>> could not be found
         RETURN
      ENDIF
   ENDIF

   ins_fp = FOPEN(m.filname)
   IF ins_fp > 0
      \* Inserted from <<strippath(m.filname)>>
      DO WHILE !feof(ins_fp)
         m.buffer = fgets(ins_fp)
         \<<m.buffer>>
      ENDDO
      =fclose(m.ins_fp)
      \* End of inserted lines
   ENDIF
ENDIF
*!*****************************************************************************
*!
*!       Function: JUSTPATH
*!
*!      Called by: FORCEEXT()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION justpath
* Return just the path name from "filname"
PARAMETERS m.filname
PRIVATE ALL
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

**
** Code Associated with the Thermometer
**

*
* ACTTHERM(<text>) - Activate thermometer.
*
* Description:
* Activates thermometer.  Update the thermometer with UPDTHERM().
* Thermometer window is named "thermometer."  Be sure to RELEASE
* this window when done with thermometer.  Creates the global
* m.g_thermwidth.
*
PROCEDURE acttherm
    PARAMETER m.text
    PRIVATE m.prompt

    IF m.g_graphic
        m.prompt = m.g_outfile
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
           @ 0.000,0.000 TO 5.62,63.83 PATTERN 1;
              COLOR RGB(192, 192, 192, 192, 192, 192)
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
   				@ 3.000,3.33 TO 4.23, (m.g_thermwidth + 1) + 3.33
				ENDIF
        ENDCASE
        SHOW WINDOW thermomete TOP
    ELSE
        m.prompt = SUBSTR(SYS(2014,UPPER(m.g_outfile)),1,48)+;
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

*
* UPDTHERM(<percent>) - Update thermometer.
*
PROCEDURE updtherm
PARAMETER m.percent
PRIVATE m.nblocks, m.percent
ACTIVATE WINDOW thermomete
m.nblocks = (m.percent/100) * (m.g_thermwidth)
DO CASE
CASE _WINDOWS
   @ 3.000,3.333 TO 4.231,m.nblocks + 3.333 ;
      PATTERN 1 COLOR RGB(128, 128, 128, 128, 128, 128)
CASE _MAC
   @ 3.000,3.33 TO 4.23,m.nblocks + 3.33 ;
      PATTERN 1 COLOR RGB(0, 0, 128, 0, 0, 128)
OTHERWISE
   @ 3,3 SAY REPLICATE("Û",m.nblocks)
ENDCASE

*
* DEACTTHERMO - Deactivate and Release thermometer window.
*
PROCEDURE deactthermo
    RELEASE WINDOW thermomete


*!*****************************************************************************
*!
*!      Procedure: THERMFNAME
*!
*!*****************************************************************************
FUNCTION thermfname
PARAMETER m.fname
PRIVATE m.addelipse, m.g_pathsep, m.g_thermfface, m.g_thermfsize, m.g_thermfstyle

#define c_space 40
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
	m.fname = LOWER(SYS(2027, m.fname))
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

*
* ERRORHANDLER - Error Processing Center.
*
PROCEDURE errorhandler
    PARAMETERS m.messg, m.lineno, m.code
    IF ERROR() = 22
        ON ERROR &onerror
        DO cleanup
        CANCEL
    ENDIF

    DO CASE
        CASE m.code == "Minor"
            DO errlog WITH m.messg, m.lineno
            m.g_status = 1
        CASE m.code == "Serious"
            DO errlog  WITH m.messg, m.lineno
            DO errshow WITH m.messg, m.lineno
            m.g_error = .T.
            m.g_status = 2
            ON ERROR
        CASE m.code == "Fatal"
            IF NOT m.g_nohandle
                DO errlog  WITH m.messg, m.lineno
            ENDIF
            DO errshow WITH m.messg, m.lineno
            IF WEXIST("Thermomete") AND WVISIBLE("Thermomete")
                RELEASE WINDOW thermometer
            ENDIF
            ON ERROR
            DO cleanup
            CANCEL
    ENDCASE

*
* ESCHANDLER - Escape handler.
*
PROCEDURE eschandler
    ON ERROR
    WAIT WINDOW "Generation process stopped." NOWAIT
    DO builddisable
    IF m.g_status > 0
        ERASE (m.g_outfile)
    ENDIF
    IF WEXIST("Thermomete") AND WVISIBLE("Thermomete")
        RELEASE WINDOW thermometer
    ENDIF
    DO cleanup
    CANCEL

*
* ERRLOG - Insert error message into the error log.
*
PROCEDURE errlog
    PARAMETER m.messg, m.lineno
    PRIVATE m.savehandle
    m.savehandle = _TEXT
    DO openerrfile
    SET CONSOLE OFF

    \\GENERATOR: <<ALLTRIM(m.messg)>>
    IF NOT EMPTY(m.lineno)
        \\ LINE NUMBER: <<m.lineno>>
    ENDIF
    \
    = FCLOSE(_TEXT)
    _TEXT = m.savehandle

*
* ERRSHOW - Display error message in the alert box.
*
PROCEDURE errshow
    PARAMETER m.msg, m.lineno
    PRIVATE m.curcursor

    IF m.g_graphic
        DEFINE WINDOW alert ;
            AT  INT((SROW() - (( 5.615 * ;
            fontmetric(1, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
            fontmetric(1, wfont(1,""), wfont(2,""), wfont(3,"")))) / 2), ;
            INT((SCOL() - (( 63.833 * ;
            fontmetric(6, m.g_dlgface, m.g_dlgsize, m.g_dlgstyle )) / ;
            fontmetric(6, wfont(1,""), wfont(2,""), wfont(3,"")))) / 2) ;
            SIZE 5.615,63.833 ;
            font m.g_dlgface, m.g_dlgsize ;
            STYLE m.g_dlgstyle ;
            NOCLOSE ;
            DOUBLE ;
            TITLE "Genmenu Error" ;
            COLOR rgb(0, 0, 0, 255, 255, 255)

        ACTIVATE WINDOW alert NOSHOW

        m.msg = SUBSTR(m.msg,1,44)+IIF(LEN(m.msg)>44,"...","")
        @ 1,(WCOLS()-txtwidth( m.msg ))/2 SAY m.msg

        m.msg = "Line Number: "+STR(m.lineno, 4)
        @ 2,(WCOLS()-txtwidth( m.msg ))/2 SAY m.msg

        m.msg = "Press any key to cleanup and exit..."
        @ 3,(WCOLS()-txtwidth( m.msg ))/2 SAY m.msg

        SHOW WINDOW alert
    ELSE
        DEFINE WINDOW alert;
            FROM INT((SROW()-6)/2), INT((SCOL()-50)/2) TO INT((SROW()-6)/2) + 6, INT((SCOL()-50)/2) + 50 ;
            FLOAT NOGROW NOCLOSE NOZOOM	SHADOW DOUBLE;
            COLOR SCHEME 7

        ACTIVATE WINDOW alert

        @ 0,0 CLEAR
        @ 1,0 SAY PADC(SUBSTR(m.msg,1,44)+;
            IIF(LEN(m.msg)>44,"...",""), WCOLS())
        @ 2,0 SAY PADC("Line Number: "+STR(m.lineno, 4), WCOLS())
        @ 3,0 SAY PADC("Press any key to cleanup and exit...", WCOLS())
    ENDIF

    m.curcursor = SET( "CURSOR" )
    SET CURSOR OFF

    WAIT ""

    RELEASE WINDOW alert
    SET CURSOR &curcursor

    RELEASE WINDOW alert

*
* OPENERRFILE - Open error file.
*
PROCEDURE openerrfile
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

*
* GETCNAME - Manufacture a procedure name, unless there is a #NAME directive
*
FUNCTION getcname
PARAMETERS snippet
PRIVATE ALL
IF proctype = 1
   numlines = MEMLINES(snippet)
   IF m.numlines > 0
      _MLINE = 0
      m.i = 1
      DO WHILE m.i <= m.numlines
         m.thisline = UPPER(ALLTRIM(MLINE(snippet,1, _MLINE)))
         DO CASE
         CASE LEFT(m.thisline,5) == "#NAME"
            RETURN ALLTRIM(SUBSTR(m.thisline,6))
         CASE EMPTY(m.thisline) OR iscomment(m.thisline)
            * Do nothing.  Get next line.
         OTHERWISE
            EXIT
         ENDCASE
         m.i = m.i + 1
      ENDDO
   ENDIF
ENDIF
RETURN LOWER(SYS(2015))

*
* ISCOMMENT - Determine if textline is a comment line.
*
FUNCTION IsComment
PARAMETER m.textline
PRIVATE m.asterisk, m.isnote, m.ampersand, m.statement
IF EMPTY(m.textline)
   RETURN .F.
ENDIF
m.statement = UPPER(ALLTRIM(m.textline))

m.asterisk  = AT("*", LEFT(m.statement,1))
m.ampersand = AT(CHR(38)+CHR(38), LEFT(m.statement,2))
m.isnote    = AT("NOTE", LEFT(m.statement,4))

DO CASE
CASE (m.asterisk = 1 OR m.ampersand = 1)
   RETURN .T.
CASE (m.isnote = 1 ;
        AND (LEN(m.statement) <= 4 OR SUBSTR(m.statement,5,1) = ' '))
   * Don't be fooled by something like "notebook = 7"
   RETURN .T.
ENDCASE
RETURN .F.
*
* WORDNUM - Returns w_num-th word from string strg
*
FUNCTION wordnum
PARAMETERS strg,w_num
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
*!      Function: VERSNUM
*!
*!*****************************************************************************
FUNCTION versnum
* Return string corresponding to FoxPro version number
RETURN wordnum(vers(),2)

*!*****************************************************************************
*!
*!       Function: JUSTFNAME
*!
*!      Called by: FORCEEXT()         (function  in GENSCRN.PRG)
*!
*!*****************************************************************************
FUNCTION justfname
PARAMETERS m.filname
PRIVATE ALL
IF RAT('\',m.filname) > 0
   m.filname = SUBSTR(m.filname,RAT('\',m.filname)+1,255)
ENDIF
IF AT(':',m.filname) > 0
   m.filname = SUBSTR(m.filname,AT(':',m.filname)+1,255)
ENDIF
RETURN ALLTRIM(UPPER(m.filname))

