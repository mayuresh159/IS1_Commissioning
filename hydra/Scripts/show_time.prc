; Sample code to derive current time in hours, minutes and seconds from system time
; This requires an update of ephemeris date and time.xml sheet every month
; However it avoids the manual error introduced in uploading the ephemeris to the spacecraft during a ground Pass

declare currTimemSec dn32b
declare currTimeDay dn32b

declare ephYear dn32b
declare ephMonth dn32b
declare ephDay dn32b
declare ephHour dn32b
declare ephMinute dn32b
declare ephSecond dn32b

; extra variables
declare ephMinuteexcess dn32b
declare ephSecexcess dn32b
declare ephTotSec dn32b

set ephYear = 2021
set ephMonth = 07

; Stamp current time and day
set currTimemSec = systemTimemSec
set currTimeDay = systemTimeDay

; Convert current time into ephemeris time
set ephDay = currTimeDay

set ephTotSec =  currTimemSec / 1000
set ephHour = ephTotSec / 3600

set ephMinuteexcess = ephTotSec % 3600
set ephMinute = ephMinuteexcess / 60

set ephSecond = ephTotSec % 60

; Print current time
print ephYear
print ephMonth
print ephDay
print ephHour
print ephMinute
print ephSecond
