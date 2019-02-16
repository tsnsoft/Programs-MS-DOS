BLOOD(TM) v 1.00 README.TXT
April 22nd, 1997

Other useful files: 

bloodhlp.txt    the text version of the printed manual
monolith.txt    A personal note (and challenge) from Jason Hall, 
                Monolith's CEO

BLOOD CUTSCENES
In order to preserve space on your hard drive, we have not copied
the Blood cutscenes. Therefore, you must have the Blood CD in your
CD-ROM drive to view the cutscenes. Copying the cutscene's video and 
audio from the CD to your Blood directory may improve video 
performance and will eliminate the need to keep the CD in the drive.

If you copy the cutscenes, you must modify the BLOOD.INI file to
point the program at the video and audio files for each episode. 
For example, CutSceneA in the [episode1] section should point to 
CS1.SMK and CutSceneB in that section should point to CS2.SMK.

For example:

CutSceneA=c:\blood\cs1.smk
CutWavA=c:\blood\cs1822m.wav

INTRO MOVIES
If you wish to skip the intro movies when starting Blood, use the
"-quick" command line parameter.

CD AUDIO
CD Audio will only play if the CD is in the drive. If you wish to
view the cutscenes but don't want to listen to CD audio, use the
"-nocd" command line parameter.

SOUND & MUSIC
You should test your SOUND FX card before testing your MUSIC FX card. 

AWE32
If you have problems with your AWE32 card while in DOS mode, make
sure that you have run the SBDIAGNOSE utility that comes with your 
audio card. If you are still having problems playing music, try
switching your music card to SoundBlaster.

PROAUDIO 16
Although the Proaudio 16 is listed in the setup program, it is not
currently supported.

MODEM
When choosing the modem type from the Blood-Setup menu both players should 
use the default modem setting.

FOR MS SIDEWINDER 3D PRO USERS
Configure the Setup Joystick options as normal.  If you wish to use the 
rudder feature, make sure to click the Enable Rudder option.  In the Advanced
Joystick Setup, delete all analog references, and use the digital settings to 
configure the stick to your preferences.  Under Advanced Rudder/Throttle 
Setup, delete all analog references and set the Digital Setup to your 
preferences.  The MS Game Device Profiler software that ships with the 
Sidewinder can be used to configure the four base buttons to your liking, 
and works well with Blood.

BLOODBATH LEVELS
These levels are for Bloodbath and Team play only.  There are no monsters,
so co-op play will be pretty boring.

See the TROUBLESHOOTING section below before calling for technical support.

=============================================================================

TECHNICAL SUPPORT (U.S. & CANADA)

ASSISTANCE VIA WORLD WIDE WEB

Get up-to-the-minute technical information at the GT Interactive
Software website, at http://www.gtinteractive.com, 24 hours a day,
seven days a week. In the Support section you'll have access to our
FAQs (Frequently Asked Questions), which contain our latest
troubleshooting information. You can also visit our Forums area,
where you can swap email with other gamers, our FTP (File Transfer
Protocol) area where you can download patches and new enhancements
as soon as they become available, our Hints/Cheat Codes area, an
E-Mail area where you can leave us your tech support problems and
questions, and other areas where you can get valuable information
on GT Interactive Software products.

HELP VIA TELEPHONE IN THE UNITED STATES & CANADA

For phone assistance, call GT Interactive Software's Tech Support
at 716-871-6646. We have an Interactive Voice Response and Faxback
system that is available 24 hours a day, seven days a week. If
you should need live support, we are available Monday through
Friday, 8 AM until Midnight (EST). Please note that live Tech
Support may be closed on major holidays. We ask that you do the
following when calling: be at your computer; have your system
information ready for our technicians, including system make and
model; RAM; video and sound card data and drivers; and any screen
or error messages you've encountered and where (if not currently
displayed on your screen). It will expedite your handling
significantly.

HELP VIA MAIL IN THE UNITED STATES & CANADA 

In the event our technicians at 716-871-6646 determine that you will
need to forward materials directly to us, please include a brief
letter explaining what is enclosed and why. Make sure you include
the Return Authorization Number supplied you by the technician and
your telephone number in case we need to call you. Any materials
not containing this RMA# will be returned to you un-processed.
Your mail should be sent to the following address:

GT Interactive Software
Attn: TS/QA
1 Nixon Lane
Edison, NJ  08817

TECHNICAL SUPPORT (EUROPE)

HELP VIA TELEPHONE IN EUROPE

Technical Assistance: English speaking customers call 01923 209145

Assistance Technique: Remarque: Notre service de soutien technique
se trouve en Angleterre. Clients  francophones appelez le
00 44 1923 209148

Technischer Kundendienst: Beachten Sie bitte dass sich unser
technischer kundendienst in England befindet. Den deutschsprachigen
Kundendienst erreichen Sie unter folgender Nummer: 00 44 1923 209151

This program is protected by federal and international copyright.

All trademarks mentioned herein are the property of their respective owners.

--------------------------------------------------------------------------
TROUBLESHOOTING

1. If you have enough memory installed but cannot get Blood to run:
 
* If you are running in Windows '95, shut down and restart in MS-DOS mode 
 and install Blood in DOS instead. This will free up a lot of the 
 memory that is being used by Windows.
 
* If you are running in DOS, or Windows'95 DOS mode, and still do not have
 enough free memory to run Blood, you may need to create a boot disk that 
 only loads your CD-ROM, sound card, and mouse drivers, and use it to boot 
 your computer each time you play Blood. There is a boot disk FAQ available
 on GT's website (www.gtinteractive.com) and via faxback at GT tech support
 number that can help you to create a boot disk.
 
2. If you have sound problems:
 
* If you have not already run the SETUP utility after installation, do so 
 now.  You need to specify what brand of sound hardware you are using before
 Blood can run. 
 
* If you are playing from DOS and not Windows '95, you will need to have your
 sound card drivers loaded in config.sys before playing Blood for your sound
 card to work.  
 
* Be sure that the settings you choose in SETUP for your sound card match 
 those found in your SET BLASTER environment variable in the autoexec.bat 
 file.
 
* Make sure that the sound card setup utilities are set up in AUTOEXEC.BAT 
 when you boot your computer into DOS.
 
* Don't run under a Win95 full-screen DOS box unless you absolutely have to.
 
3. If you are having mouse problems:
 
* Using a 3-button mouse requires the latest drivers
 from the vendor, especially if running under Win95.
 
* If all else fails, configure as a two-button mouse,
 or keyboard only.
 
4. If Blood crashes unexpectedly with or without an error message:
 
* Don't run Blood under Windows or Win95.  Shut down and restart in true 
 MS-DOS.
 
* Make sure your system meets the minimum system requirements for Blood 
 listed on the Box.
 
* Be sure that your mouse driver is loaded prior to playing Blood.
 
5. If you experience "Out of sync" errors when playing a network or modem game:

* Be sure all of the players have the same version of Blood as well as the 
  same version of any user map you might be using.

* Net game - Make sure your network card drivers are set up properly and that 
  all cards are using the same version of the IPX protocol.
 
* Modem game - Be sure that both modems are set to the same baud rate and 
  that error compression, data compression and flow control are turned off.

============================================================================
TECHNICAL SUPPORT (U.S. & CANADA)

Assistance Via World Wide Web

Get up-to-the-minute technical information at the GT Interactive Software 
web-site, at http://www.gtinteractive.com, 24 hours a day, seven days a week. 
In the Support section you'll have access to our FAQs (Frequently Asked 
Questions), which contains our latest troubleshooting information.  You can 
also visit our Forums area, where you can swap email with other gamers, our 
FTP (File Transfer Protocol) area where you can download patches and new 
enhancements as soon as they become available, our Hints/Cheat Codes area, 
an E-Mail area where you can leave us your tech support problems and 
questions, and other areas where you can get valuable information on GT 
Interactive Software products.

Help Via Telephone In The United States & Canada

For phone assistance, call GT Interactive Software's Tech Support at 
716-871-6646. We have an Interactive Voice Response and Faxback system that 
is available 24 hours a day, seven days a week. If you should need live 
support, we are available Monday through Friday, 8 AM until Midnight (EST).  
Please note that live Tech Support may be closed on major holidays.  We ask 
that you do the following when calling: be at your computer; have your system 
information ready for our technicians including system make and model; RAM; 
video and sound card data and drivers; and any screen or error messages 
you've encountered and where (if not currently displayed on your screen). 
It will expedite your handling significantly.

Help Via Mail In The United States & Canada 

In the event our technicians at 716-871-6646 determine that you will need to 
forward materials directly to us, please include a brief letter explaining 
what is enclosed and why.  Make sure you include the Return Authorization 
Number supplied you by the technician and your telephone number in case we 
need to call you.  Any materials not containing this RMA# will be returned 
to you un-processed.  Your mail should be sent to the following address:  

GT Interactive Software
Attn: TS/QA
1 Nixon Lane
Edison, NJ  08817

Technical Support (Europe)

Help Via Telephone In Europe

Technical Assistance: English speaking customers call 01923 209145

Assistance Technique: Remarque: Notre service de soutien technique se trouve 
en Angleterre. Clients  francophones appelez le 00 44 1923 209148

Technischer Kundendienst: Beachten Sie bitte dass sich unser technischer 
kundendienst in England befindet. Den deutschsprachigen Kundendienst 
erreichen Sie unter folgender Nummer: 00 44 1923 209151

Please do not make copies  The program you've purchased was produced through
the efforts of many people. Don't make copies for others who have not paid 
for the right to use it. To report copyright violations to the Software 
Publishers Association, call 1-800-388-PIR8 or write:
Software Publishers Association
1101 Connecticut Ave., Suite 901
NW Washington, DC 20036

This program is protected by federal and international copyright.

All trademarks mentioned in this manual are the property of their 
respective owners.

=============================================================================

