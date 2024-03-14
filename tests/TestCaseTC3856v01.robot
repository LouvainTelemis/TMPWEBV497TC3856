*** Settings ***

Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    SeleniumLibrary
Library    DateTime
Library    BuiltIn



*** Variables ***

${MyHostname}    demo5757
${MyRepositoryName}    TMPWEBV497TC3855
# You must create the folder "MyFolderWorkspace" manually in the computer of Jenkins master, in case you test the script with the computer of Jenkins master
${MyFolderWorkspace}    C:/000/jenkins/workspace
${MyDirectoryDownload}    C:\\temp\\zDownload
${base_url_smtp_server}    http://localhost:8070

${MyPatient1FamilyName}    AZ127431
${MyPatient1FirstName}    ALBERT
${MyPatient1SeriesDescription}    CTOP127431

${MyPatient2FamilyName}    AZ138542
${MyPatient2FirstName}    ALBERT
${MyPatient2SeriesDescription}    CTOP138542
${MyPatient2BirthdateYYYY}    1956
${MyPatient2BirthdateMM}    12
${MyPatient2BirthdateDD}    28
${MyPatient2AccessionNumber}    CTEF138542

${MyPortNumber}    10000
#  Do not use the brackets to define the variable of bearer token
${bearerToken}    Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJJbnN0YWxsZXIiLCJuYW1lIjoiSW5zdGFsbGVyIiwiaXNzIjoiVGVsZW1pcyIsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxODYxOTIwMDAwfQ.pynnZ69Qx50wuz0Gh4lx-FHZznrcQkbMm0o-PLhb3S0

${MyBrowser1}    chrome
${MyBrowser2}    firefox
${MyBrowser3}    edge

${TmpWebAdministratorLogin}    telemis_webadmin
${TmpWebAdministratorPassword}    KEYCLOAKTastouk!

${TmpWebUser1Login}    anthony
${TmpWebUser1Password}    Videogames2024
${TmpWebUser1Email}    anthony@hospital8.com

${TmpWebUser2Login}    albert
${TmpWebUser2Password}    Videogames2024
${TmpWebUser2Email}    albert@hospital8.com

${TmpWebUser3Login}    mary
${TmpWebUser3Password}    Videogames2024
${TmpWebUser3Email}    mary@hospital8.com

# NOT USEFUL ${MyFolderResults}    results
${MyLogFile}    MyLogFile.log
${MyFolderCertificate}    security
${MyDicomPath}    C:/VER497TMP1/telemis/dicom

${MyEntityName1}    audit
${MyEntityPort1}    9940
${MyEntityName2}    dicomgate
${MyEntityPort2}    9920
${MyEntityName3}    hl7gate
${MyEntityPort3}    9930
${MyEntityName4}    patient
${MyEntityPort4}    9990
${MyEntityName5}    registry
${MyEntityPort5}    9960
${MyEntityName6}    repository
${MyEntityPort6}    9970
${MyEntityName7}    user
${MyEntityPort7}    9950
${MyEntityName8}    worklist
${MyEntityPort8}    9980

${VersionSiteManager}    4.1.2-228



*** Keywords ***

Remove The Previous Results
    [Documentation]    Delete the previous results and log files
    # Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/geckodriver*
    # Delete the previous screenshots
    Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/*.png
    Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/${MyLogFile}
    ${Time} =    Get Current Date
    Create file  ${MyFolderWorkspace}/${MyRepositoryName}/results/${MyLogFile}    ${Time}${SPACE}Start the tests \n
    # Remove DICOM files from dicomPath of TMAA
    Remove Files    ${MyDicomPath}/*.dcm


Check That Watchdog Is Running
    [Documentation]    Check that Watchdog is running
    create session    mysession    https://${MyHostname}:${MyPortNumber}/watchdog/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /ping    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    3s


Check Version Of Watchdog
    [Documentation]    Check the version number of Watchdog
    create session    mysession    https://${MyHostname}:${MyPortNumber}/watchdog/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /version    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    ${Time} =    Get Current Date
    Append To File    ${MyLogFile}    ${Time}${SPACE}Version number of Watchdog ${response.text} \n

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    3s
    # Should Contain    ${response.text}    ${VersionSiteManager}


Check That Site Manager Is Running
    [Documentation]    Check that Site Manager is running
    create session    mysession    https://${MyHostname}:${MyPortNumber}/site/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /ping    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    3s


Check Version Of Site Manager
    [Documentation]    Check the version number of Site Manager
    create session    mysession    https://${MyHostname}:${MyPortNumber}/site/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /version    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    ${Time} =    Get Current Date
    Append To File    ${MyLogFile}    ${Time}${SPACE}Version number of Site Manager ${response.text} \n

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    2s

    ${response} =    GET On Session    mysession    /identity    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    200
    Should Contain    ${response.text}    sitemanager
    Sleep    3s


Check That Telemis Entity Is Running
    [Documentation]    Check that Telemis Entity is running
    [Arguments]    ${MyEntityPort}
    create session    mysession    https://${MyHostname}:${MyEntityPort}/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /ping    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    3s


Check Version Of Telemis Entity
    [Documentation]    Check the version number of entity
    [Arguments]    ${MyEntityName}    ${MyEntityPort}
    create session    mysession    https://${MyHostname}:${MyEntityPort}/api/admin

    ${headers}    create dictionary    Authorization=${bearerToken}

    ${response} =    GET On Session    mysession    /version    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    ${Time} =    Get Current Date
    Append To File    ${MyLogFile}    ${Time}${SPACE}Version number of Telemis-${MyEntityName}${SPACE}${response.text} \n

    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    2s

    ${response} =    GET On Session    mysession    /identity    headers=${headers}    verify=${MyFolderWorkspace}/${MyRepositoryName}/tests/${MyFolderCertificate}/telemis_ca.cer
    log    ${response.status_code}
    log    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    200
    Should Contain    ${response.text}    ${MyEntityName}
    Sleep    3s


Take My Screenshot
    ${MyCurrentDateTime} =    Get Current Date    result_format=%Y%m%d%H%M%S
    Log    ${MyCurrentDateTime}
    # Keyword of SeleniumLibrary, you do not need to use the library Screenshot
    Capture Page Screenshot    selenium-screenshot-${MyCurrentDateTime}.png
    Sleep    2s


Open My Site Manager
    Open Browser    https://${MyHostname}:10000/site    Chrome    options=add_argument("--disable-infobars");add_argument("--lang\=en");binary_location=r"C:\\000\\chromeWin64ForTests\\chrome.exe"
    Wait Until Element Is Visible    id=kc-login    timeout=15s
    Maximize Browser Window
    Sleep    2s
    Input Text    id=username    local_admin    clear=True
    Input Text    id=password    KEYCLOAKTastouk!    clear=True
    Sleep    2s
    Click Button    id=kc-login
    # Locator of Selenium IDE
    Wait Until Element Is Visible    xpath=//strong[contains(.,'Site Manager')]    timeout=15s
    Element Should Be Visible    xpath=//strong[contains(.,'Site Manager')]
    Sleep    2s


Log Out My User Session Of Site Manager
    Click Link    link:Sign out
    Wait Until Element Is Visible    id=kc-login    timeout=15s
    Element Should Be Visible    id=kc-login
    Sleep    2s


My User Opens Internet Browser And Connects To My TMP Web
    [Documentation]    The user opens Internet browser and then connects to the website of TMP Web
    [Arguments]    ${MyUserLogin}    ${MyUserPassword}
    Open Browser    https://${MyHostname}.telemiscloud.com/tmpweb/patients.app    Chrome    options=add_argument("--disable-infobars");add_argument("--lang\=en");binary_location=r"C:\\000\\chromeWin64ForTests\\chrome.exe"
    Wait Until Page Contains    TM-Publisher web    timeout=15s
    Maximize Browser Window
    Wait Until Element Is Visible    id=username    timeout=15s
    Wait Until Element Is Visible    id=password    timeout=15s
    Input Text    id=username    ${MyUserLogin}    clear=True
    Input Text    id=password    ${MyUserPassword}    clear=True
    Sleep    2s
    Click Button    id=kc-login
    Wait Until Page Contains    Telemis Media Publisher Web    timeout=15s
    Sleep    3s


Log Out My User Session Of TMP Web
    Click Link    link=Logout
    Wait Until Element Is Visible    xpath=//*[@id="doctor-button"]    timeout=15s
    Sleep    2s


Delete All My Email Messages In SMTP Server
    [Documentation]    Delete all the email messages in SMTP server
    Create Session    AppAccess    ${base_url_smtp_server}
    ${response} =    Delete On Session    AppAccess    /api/emails
    log    ${response.status_code}
    log    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    200
    Sleep    2s



*** Test Cases ***

Test01
    [Documentation]    Reset the test results
    [Tags]    CRITICALITY LOW
    # Do not start SMTP server because no email is sent if user account has been created by the administrator
    Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/*.png
    Sleep    3s


Test02
    [Documentation]    Administrator connects to the website of TMP Web
    [Tags]    CRITICALITY NORMAL
    My User Opens Internet Browser And Connects To My TMP Web    ${TmpWebAdministratorLogin}    ${TmpWebAdministratorPassword}


Test03
    [Documentation]    Select the language
    [Tags]    CRITICALITY LOW
    Wait Until Element Is Visible    id=languageSelect    timeout=15s
    Select From List By Label    id=languageSelect    English
    Sleep    2s
    Wait Until Element Is Visible    id=searchInput    timeout=15s
    Click Element    id=searchInput


Test04
    [Documentation]    Select and open the table "Manage users"
    [Tags]    CRITICALITY NORMAL
    Wait Until Page Contains    Admin    timeout=15s
    Click Link    link=Admin
    Sleep    3s
    Wait Until Page Contains    Manage users    timeout=15s
    Click Link    link=Manage users
    Wait Until Page Contains    telemis_webadmin    timeout=15s
    Page Should Contain Link    link=telemis_webadmin    None    TRACE
    Wait Until Element Is Visible    link=Create new user    timeout=15s
    Element Should Be Visible    link=Create new user
    Click Element    link=Create new user
    Take My Screenshot


Test05
    [Documentation]    Click the button "Create new user"
    [Tags]    CRITICALITY HIGH
    Log    After clicking the button Create new user, Internet browser opens the page Create an account
    Wait Until Page Contains    Create an account    timeout=19s


Test06
    [Documentation]    Fill out the form
    [Tags]    CRITICALITY HIGH
    Wait Until Element Is Visible    id=userlogin    timeout=15s
    Wait Until Page Contains    Login    timeout=15s
    Input Text    id=userlogin    ${TmpWebUser3Login}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=userlogin    ${TmpWebUser3Login}

    Wait Until Element Is Visible    id=firstname    timeout=15s
    Wait Until Page Contains    First Name    timeout=15s
    Input Text    id=firstname    Mary    clear=True
    Sleep    1s
    Textfield Value Should Be    id=firstname    Mary

    Wait Until Element Is Visible    id=lastname    timeout=15s
    Wait Until Page Contains    Last Name    timeout=15s
    Input Text    id=lastname    Morton    clear=True
    Sleep    1s
    Textfield Value Should Be    id=lastname    Morton

    Wait Until Element Is Visible    id=password    timeout=15s
    Wait Until Page Contains    Password    timeout=15s
    Input Text    id=password    ${TmpWebUser3Password}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=password    ${TmpWebUser3Password}

    Wait Until Element Is Visible    id=passwordConfirm    timeout=15s
    Wait Until Page Contains    Enter your password again    timeout=15s
    Input Text    id=passwordConfirm    ${TmpWebUser3Password}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=passwordConfirm    ${TmpWebUser3Password}

    Wait Until Element Is Visible    id=email    timeout=15s
    Wait Until Page Contains    Email Address    timeout=15s
    Input Text    id=email    ${TmpWebUser3Email}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=email    ${TmpWebUser3Email}

    Click element    id=login-register
    Press Keys    None    PAGE_DOWN
    Sleep    2s

    Wait Until Element Is Visible    id=phone    timeout=15s
    Wait Until Page Contains    Phone number    timeout=15s
    Input Text    id=phone    030123456    clear=True
    Sleep    1s
    Textfield Value Should Be    id=phone    030123456

    Wait Until Element Is Visible    id=pro.phone    timeout=15s
    Wait Until Page Contains    Professionnal Phone number    timeout=15s
    Input Text    id=pro.phone    030456789    clear=True
    Sleep    1s
    Textfield Value Should Be    id=pro.phone    030456789

    Wait Until Element Is Visible    id=mob.phone    timeout=15s
    Wait Until Page Contains    Mobile Phone number    timeout=15s
    Input Text    id=mob.phone    0478123456    clear=True
    Sleep    1s
    Textfield Value Should Be    id=mob.phone    0478123456

    Wait Until Element Is Visible    id=address    timeout=15s
    Wait Until Page Contains    Address    timeout=15s
    Input Text    id=address    5 rue Mimosa 5000 Namur    clear=True
    Sleep    1s
    Textfield Value Should Be    id=address    5 rue Mimosa 5000 Namur

    Wait Until Element Is Visible    id=med-number    timeout=15s
    Wait Until Page Contains    Medical number    timeout=15s
    Input Text    id=med-number    12341001    clear=True
    Sleep    1s
    Textfield Value Should Be    id=med-number    12341001

    Wait Until Page Contains    Send notification for new study    timeout=15s
    Wait Until Element Is Visible    id=wantsNotification    timeout=15s
    Select Checkbox    id=wantsNotification
    Sleep    1s


Test07
    [Documentation]    Enter a pre-existing medical number and check that the page shows the warning message "Medical number already exists"
    [Tags]    CRITICALITY HIGH
    Click Button    name=submit
    Sleep    2s
    Click element    id=login-register
    Press Keys    None    PAGE_DOWN
    Wait Until Page Contains    Medical number already exists    timeout=15s
    Take My Screenshot


Test08
    [Documentation]    Leave the field "Medical number" empty and check that the page shows the warning message "Required field"
    [Tags]    CRITICALITY HIGH
    Wait Until Element Is Visible    id=password    timeout=15s
    Wait Until Page Contains    Password    timeout=15s
    Input Text    id=password    ${TmpWebUser3Password}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=password    ${TmpWebUser3Password}

    Wait Until Element Is Visible    id=passwordConfirm    timeout=15s
    Wait Until Page Contains    Enter your password again    timeout=15s
    Input Text    id=passwordConfirm    ${TmpWebUser3Password}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=passwordConfirm    ${TmpWebUser3Password}

    Click element    id=login-register
    Press Keys    None    PAGE_DOWN
    Sleep    2s

    Clear element Text    id=med-number
    Sleep    1s
    ${MyValue} =    Get Text    id=med-number
    Should Be Empty    ${MyValue}

    Click Button    name=submit
    Sleep    2s
    Click element    id=login-register
    Press Keys    None    PAGE_DOWN
    Wait Until Page Contains    Required field    timeout=15s
    Take My Screenshot


Test09
    [Documentation]    Enter the valid medical number and then click the button "Submit"
    [Tags]    CRITICALITY HIGH
    Wait Until Element Is Visible    id=password    timeout=15s
    Wait Until Page Contains    Password    timeout=15s
    Input Text    id=password    ${TmpWebUser3Password}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=password    ${TmpWebUser3Password}

    Wait Until Element Is Visible    id=passwordConfirm    timeout=15s
    Wait Until Page Contains    Enter your password again    timeout=15s
    Input Text    id=passwordConfirm    ${TmpWebUser3Password}    clear=True
    Sleep    1s
    Textfield Value Should Be    id=passwordConfirm    ${TmpWebUser3Password}

    Click element    id=login-register
    Press Keys    None    PAGE_DOWN
    Sleep    2s

    Wait Until Element Is Visible    id=med-number    timeout=15s
    Wait Until Page Contains    Medical number    timeout=15s
    Input Text    id=med-number    12341003    clear=True
    Sleep    1s
    Textfield Value Should Be    id=med-number    12341003

    Click Button    name=submit
    Take My Screenshot
    Wait Until Page Contains    Manage users    timeout=15s
    Click Link    link=Manage users
    Wait Until Page Contains    ${TmpWebUser3Login}    timeout=15s
    Page Should Contain Link    link=${TmpWebUser3Login}    None    TRACE
    Click Link    link=${TmpWebUser3Login}
    Wait Until Page Contains    Personal details    timeout=15s
    Sleep    1s
    Take My Screenshot
    Log Out My User Session Of TMP Web
    Close Browser


Test10
    [Documentation]    The limited user account connects to the website for the very first time
    [Tags]    CRITICALITY NORMAL
    My User Opens Internet Browser And Connects To My TMP Web    ${TmpWebUser3Login}    ${TmpWebUser3Password}


Test11
    [Documentation]    The limited user account accesses the website of TMP Web
    [Tags]    CRITICALITY NORMAL
    Wait Until Page Contains    Settings    timeout=15s
    Page Should Contain Link    link=Settings    None    TRACE
    Click Link    link=Settings
    Sleep    3s
    Wait Until Page Contains    Personal details    timeout=15s
    Sleep    2s
    Take My Screenshot
    Log Out My User Session Of TMP Web
    Close Browser


Test12
    [Documentation]    Administrator deletes the user account
    [Tags]    CRITICALITY NORMAL
    My User Opens Internet Browser And Connects To My TMP Web    ${TmpWebAdministratorLogin}    ${TmpWebAdministratorPassword}
    Wait Until Page Contains    Admin    timeout=15s
    Click Link    link=Admin
    Sleep    3s
    Wait Until Page Contains    Manage users    timeout=15s
    Click Link    link=Manage users
    Sleep    3s
    Page Should Contain Link    link=${TmpWebUser3Login}    None    TRACE
    Click Link    link=${TmpWebUser3Login}
    Wait Until Page Contains    Personal details    timeout=15s
    Wait Until Page Contains    Delete user    timeout=15s
    Sleep    4s
    Click Element    link=Delete user
    # Do NOT use both keyword (Handle Alert) and (Alert Should Be Present) together because the keyword (Alert Should Be Present) accepts the message automatically
    ${message} =    Handle Alert    action=ACCEPT    timeout=15s
    Sleep    3s
    Take My Screenshot
    # Synchronize two servers (TMP Web and Keycloak) to make sure that the user account does not exist anymore for the next tests
    Go To    https://${MyHostname}.telemiscloud.com/tmpweb/keycloak_synchro.app
    Sleep    2s
    Log Out My User Session Of TMP Web


Test13
    [Documentation]    Shut down the browser and reset the cache
    [Tags]    CRITICALITY LOW
    Close All Browsers
