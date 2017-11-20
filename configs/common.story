# Storyboard example file for referencing in e2guardianfn.conf
#
# This example file is built to largely duplicate the logic in V4
# 
# Many e2guardian[f1].conf flags are replaced by commenting in/out lines 
# in the storyboard file
#
# Simple functions are defined which control the logic flow and the
# lists that are used.  See notes/Storyboard for details.
#
# The entry point in the test v5 for standard filtering is 'checkrequest'
#
# Entry function called by proxy module to check http request
function(checkrequest)
if(viruscheckset) checknoscanlists
if(bypassset) checknobypasslists
if(exceptionset) return true
#if(true) setgodirect
# comment out the following line if you do not use 'local' list files
ifnot(greyset) returnif localcheckrequest
#if(connect) return setblock
if(connect) return sslrequestcheck
ifnot(greyset) returnif exceptioncheck
ifnot(greyset) greycheck
ifnot(greyset) returnif bannedcheck
if(fullurlin, change) setmodurl
if(true) returnif embeddedcheck
# uncomment next line if local lists NOT used
#if(fullurlin,searchterms) setsearchterm
if(headerin,headermods) setmodheader
if(fullurlin, addheader) setaddheader
if(searchin,override) return setgrey
if(searchin,banned) return setblock
if(true) setgrey


# Entry function called by proxy module to check http response
function(checkresponse)
if(viruscheckset) checknoscantypes
if(mimein, exceptionmime) return setexception
if(mimein, bannedmime) return setblock
if(extensionin, exceptionextension) setexception
if(extensionin, bannedextension) setblock

# Entry function called by THTTPS module to check https request
function(thttps-checkrequest)
# comment out the following line if you do not use 'local' list files
if(true) returnif localsslrequestcheck
if(true) returnif sslrequestcheck
if(fullurlin, change) setmodurl

# Entry function called by ICAP module to check reqmod
function(icap-checkrequest)
#unless blocked or redirect or connect - leave logging for RESPMOD
if(connect) return icapsslrequestcheck
ifnot(greyset) icap-checkrequest2
if(redirectset) return true
ifnot(blockset) setnolog

function(icap-checkrequest2)
if(viruscheckset) checknoscanlists
if(bypassset) checknobypasslists
if(exceptionset) return true
# comment out the following line if you do not use 'local' list files
#ifnot(greyset) returnif localcheckrequest
ifnot(greyset) returnif exceptioncheck
ifnot(greyset) greycheck
#ifnot(greyset) return setblock
ifnot(greyset) returnif bannedcheck
if(fullurlin, change) setmodurl
if(true) returnif embeddedcheck
# uncomment next line if local lists NOT used
if(fullurlin,searchterms) setsearchterm
if(headerin,headermods) setmodheader
if(fullurlin, addheader) setaddheader
if(searchin,override) return setgrey
if(searchin,banned) return setblock
if(true) setgrey

# Entry function called by ICAP module to check respmod
function(icap-checkresponse)
if(viruscheckset) checknoscanlists
if(true) return checkresponse

# Checks embeded urls
#  returns true if blocked, otherwise false
function(embeddedcheck)
if(embeddedin, localexception) return false
if(embeddedin, localgrey) return false
if(embeddedin, localbanned) return setblock
if(embeddedin, exception) return false
if(embeddedin, grey) return false
if(embeddedin, banned) return setblock

# Local checks
#  returns true if matches local exception or banned
function(localcheckrequest)
if(connect) return localsslrequestcheck
ifnot(greyset) returnif localexceptioncheck
ifnot(greyset) localgreycheck
ifnot(greyset) returnif localbannedcheck
if(fullurlin,searchterms) setsearchterm
if(searchin,localbanned) return setblock
#if(true) return false


# Local SSL checks
#  returns true if matches local exception 
function(localsslrequestcheck)
if(sitein, localexception) return setexception
#if(returnset) return sslreplace

# SSL site replace (used instead of dns kulge)
#  always returns true 
function(sslreplace)
if(fullurlin,sslreplace) return setmodurl
if(true) return true

# Local grey check
#  returns true on match
function(localgreycheck)
if(urlin, localgrey) return setgrey

# Local banned check
#  returns true on match
function(localbannedcheck)
if(urlin, localbanned) return setblock

# Local exception check
#  returns true on match
function(localexceptioncheck)
if(urlin, localexception) return setexception

# Exception check
#  returns true on match
function(exceptioncheck)
if(urlin, exception) return setexception
if(headerin, exceptionheader) return setexception

# SSL Exception check
#  returns true on match
function(sslexceptioncheck)
if(sitein, exception) setexception
ifnot(returnset) return false
#if(true) sslreplace
if(true) return true

# Greylist check
#  returns true on match
function(greycheck)
if(urlin, grey) return setgrey

# Banned list check
#  returns true on match
function(bannedcheck)
if(true) returnif checkblanketblock
if(urlin, banned) return setblock
if(headerin, bannedheader) return setblock

# Local SSL list(s) check
#  returns true on match
function(localsslcheckrequest)
if(sitein, localexception) return setexception
#if(sitein, localbanned) return setblock

# Check whether to go MITM
#  returns true if yes, false if no
function(sslcheckmitm)
# use next line to have general MITM
if(true) setgomitm
# use next line instead of last to limit MITM to greylist
#if(sitein, greyssl) setgomitm
ifnot(returnset) return false
if(sitein, nocheckcert) setnocheckcert
if(true) return true

# SSL request check
#  returns true if exception or gomitm
function(sslrequestcheck)
if(true) returnif sslexceptioncheck
if(true) returnif sslcheckmitm
if(true) returnif sslcheckblanketblock
if(sitein, banned) return setblock
if(true) sslreplace
if(true) setgrey

function(checknoscanlists)
if(urlin,exceptionvirus) unsetviruscheck

function(checknoscantypes)
if(mimein,exceptionvirus) return unsetviruscheck
if(extensionin,exceptionvirus) return unsetviruscheck

function(checknobypasslists)
if(urlin,overridebypass) unsetbypass

# ICAP SSL request check
#  returns true if exception 
function(icapsslrequestcheck)
if(true) returnif sslexceptioncheck
if(true) sslreplace
if(sitein, banned) return setblock

# Blanket block
#  returns true if to block
#  Placeholder function - overide in fn.story
function(checkblanketblock)

# SSL Blanket block
#  returns true if to block
#  Placeholder function - overide in fn.story
function(sslcheckblanketblock)


