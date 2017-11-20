*** Settings ***
Documentation     This example demonstrates executing commands on a remote machine
...               and getting their output and the return code.
...
...               Notice how connections are handled as part of the suite setup and
...               teardown. This saves some time when executing several test cases.
Suite Setup       Open Connection And Log In
Suite Teardown    Close All Connections
Library           SSHLibrary
Library           String

*** Variables ***
${TEST}                172.16.0.164
${HOST}                172.16.1.230
${USERNAME_SR}         svcusr 
${USERNAME_HOST}       vishwajeet 
${PASSWORD_SR}         inventumfpnas
${PASSWORD_HOST}       vishugate
${PASSWORD_SR_ROOT}    inventum
*** Test Cases ***

1.Checking License
    [Documentation]     This test is performed to check license

    Switch Connection     testsr
    Write       cli
    ${output}=    Read    delay=0.5s
    Write       enable
    ${output}=    Read    delay=0.5s
    Should Contain    ${output}    Password:
    Write   ${PASSWORD_SR_ROOT} 
    ${output}=    Read    delay=0.5s
    Write    	  show license
    ${output}=    Read    delay=0.5s
    Should Contain      ${output}       BNG-UCL

2.Checking Time
    
    [Documentation]     This test is performed to check current system time as IST

    Write       show clock
    ${output}=          Read    delay=0.5s
    Should Contain      ${output}       IST

3.Checking Integrity of firmware

    Write	firmware
    ${output}=    Read    delay=0.5s
    Write	integrity-check 
    ${output}=    Read    delay=1s
    Should Not Contain		${output}	FAILED
	
4.Checking IP configuration <Add/Remove> on cpeth12
    
    [Documentation]     This test is performed to add/remove IP on cpeth12 port

    Write	exit
    ${output}=		Read 	delay=0.5s
    Write	  configure terminal
    ${output}=    Read    delay=0.5s
    Write	  interface ethernet cpeth12
    ${output}=    Read    delay=0.5s
    Write	  ip address 142.16.0.160 netmask 255.255.255.0

    ${output}=    Read    delay=0.5s
    Write	  no ip address 142.16.0.160 netmask 255.255.255.0
   
    ${output}=    Read    delay=0.5s
    Write	  do show interface cpeth12
    ${output}=    Read    delay=0.5s
    Should Not Contain	 ${output}	 inet 142.16.0.160/24 scope global cpeth12
    Write	  ip address 142.16.0.160 netmask 255.255.255.0
    ${output}=    Read    delay=0.5s
    Write	  do show interface cpeth12 
    ${output}=    Read    delay=0.5s
    Should Contain	 ${output}	 inet 142.16.0.160/24 scope global cpeth12
    Write	  no ip address 142.16.0.160 netmask 255.255.255.0
    ${output}=    Read    delay=0.5s
    Should Not Contain	 ${output}	 inet 142.16.0.160/24 scope global cpeth12
 
5.Checking vlan on cpeth12 <Creating/Removing>

    [Documentation]     This test is performed to add/remove vlan1 on port cpeth12
    Write	  vlan 1
    ${output}	  Read	delay=0.5s
    Write	  no ip address 192.168.10.1 netmask 255.255.255.0
    ${output}=    Read    delay=0.5s
    Write	  do show interface cpeth12.1
    ${output}=    Read    delay=0.5s
    Should Not Contain	 ${output}	inet 192.168.10.1/24 brd 192.168.10.255 scope global cpeth12.1
    Write	  ip address 192.168.10.1 netmask 255.255.255.0
    ${output}=    Read    delay=0.5s
    Write	  do show interface cpeth12.1 
    ${output}=    Read    delay=0.5s
    Should Contain	 ${output}	inet 192.168.10.1/24 brd 192.168.10.255 scope global cpeth12.1
    Write	  no ip address 192.168.10.1 netmask 255.255.255.0
    ${output}=    Read    delay=0.5s
    Write	  do show running-config
    ${output}=    Read    delay=0.5s
    Should Not Contain	 ${output}	inet 192.168.10.1/24 brd 192.168.10.255 scope global cpeth12.1
    Write	exit
    ${output}=    Read    delay=0.5s
    Write	no vlan 1
    ${output}=    Read    delay=0.5s
    Write	  do show interface cpeth12.1
    ${output}=    Read    delay=0.5s
    Should Contain	 ${output}	 Device "cpeth12.1" does not exist

6.Checking ipset

    Write	exit
    ${output}=    Read    delay=0.5s
    Write	ipset num 5 ip 1.1.1.1
    ${output}=    Read    delay=0.5s
    Should Contain 	${output}	success
    Write	no ipset num 5 ip 1.1.1.1
    ${output}=    Read    delay=0.5s
    Should Contain 	${output}	success
   
7.Checking Network
    
    [Documentation]     Checking basic network connectivity across Network
    Write	exit
    ${output}=          Read    delay=0.5s
    Write	exit
    ${output}=          Read    delay=0.5s
    Write	exit
    ${output}=          Read    delay=0.5s
    Write	        ping -c 4 www.google.com
    ${output}=          Read    delay=0.5s
    Should Not Contain    ${output}     unknown host
    

*** Keywords ***
    
Open Connection And Log In
    
    Open Connection    ${HOST}	   alias=testpc	
    Login    ${USERNAME_HOST}      ${PASSWORD_HOST}
    Open Connection    ${TEST}	   alias=testsr
    Login    ${USERNAME_SR}        ${PASSWORD_SR}
   
