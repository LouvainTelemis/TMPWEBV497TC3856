*** Settings ***

Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    SeleniumLibrary
Library    DateTime
Library    BuiltIn



*** Variables ***

${MyHostname}    demo5757
${MyRepositoryName}    TMPWEBV497TC3856
# You must create the folder "MyFolderWorkspace" manually in the computer of Jenkins master, in case you test the script with the computer of Jenkins master
${MyFolderWorkspace}    C:/000/jenkins/workspace
${MyDirectoryDownload}    C:\\temp\\zDownload
${base_url_smtp_server}    http://localhost:8070

${MyPatient1FamilyName}    AZ127431
${MyPatient1FirstName}    ALBERT
${MyPatient1SeriesDescription}    CTOP127431
${MyPatient1BirthdateYYYY}    1945
${MyPatient1BirthdateMM}    11
${MyPatient1BirthdateDD}    27
${MyPatient1AccessionNumber}    CTEF127431

${MyPatient2FamilyName}    AZ138542
${MyPatient2FirstName}    ALBERT
${MyPatient2SeriesDescription}    CTOP138542
${MyPatient2BirthdateYYYY}    1956
${MyPatient2BirthdateMM}    12
${MyPatient2BirthdateDD}    28
${MyPatient2AccessionNumber}    CTEF138542

${MyPatient3FamilyName}    AZ250764
${MyPatient3FirstName}    BERNARD
${MyPatient3SeriesDescription}    CTOP250764
${MyPatient3BirthdateYYYY}    1958
${MyPatient3BirthdateMM}    11
${MyPatient3BirthdateDD}    30
${MyPatient3AccessionNumber}    CTEF250764

${MyPatient4FamilyName}    AZ149653
${MyPatient4FirstName}    ALBERT
${MyPatient4SeriesDescription}    CTOP149653
${MyPatient4BirthdateYYYY}    1967
${MyPatient4BirthdateMM}    10
${MyPatient4BirthdateDD}    29
${MyPatient4AccessionNumber}    CTEF149653

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

${TmpWebUser4Login}    thomas
${TmpWebUser4Password}    Videogames2024
${TmpWebUser4Email}    thomas@hospital8.com

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
    Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/geckodriver*
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
    Wait Until Keyword Succeeds    15s    3s    Textfield Value Should Be    id=username    ${MyUserLogin}
    Input Text    id=password    ${MyUserPassword}    clear=True
    Wait Until Keyword Succeeds    15s    3s    Textfield Value Should Be    id=password    ${MyUserPassword}
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
    # Do not start SMTP server because no email is sent for this test
    Remove Files    ${MyFolderWorkspace}/${MyRepositoryName}/results/*.png
    # Delete the links between the user accounts and the studies with this batch file
    Run    C:\\Users\\albert\\Desktop\\DELETE\\zBATCHzFILES\\DeleteLink.bat


Test02
    [Documentation]    Administrator connects to the website of TMP Web
    [Tags]    CRITICALITY NORMAL
    My User Opens Internet Browser And Connects To My TMP Web    ${TmpWebAdministratorLogin}    ${TmpWebAdministratorPassword}


Test03
    [Documentation]    Select the language
    [Tags]    CRITICALITY LOW
    Wait Until Element Is Visible    id=languageSelect    timeout=15s
    Select From List By Label    id=languageSelect    English
    Wait Until Element Is Visible    id=searchInput    timeout=15s
    Click Element    id=searchInput


Test04
    [Documentation]    Open the table "Studies"
    [Tags]    CRITICALITY NORMAL
    Wait Until Page Contains    Admin    timeout=15s
    Wait Until Element Is Visible    link=Admin    timeout=15s
    Click Link    link=Admin
    Wait Until Page Contains    Assign studies    timeout=15s
    Wait Until Element Is Visible    link=Assign studies    timeout=15s
    Click Link    link=Assign studies


Test05
    [Documentation]    Find and select the first study
    [Tags]    CRITICALITY NORMAL
    Wait Until Page Contains    Studies    timeout=15s
    Wait Until Element Is Visible    id=searchedValue    timeout=15s
    Input Text    id=searchedValue     BC250764    clear=True
    Wait Until Keyword Succeeds    15s    3s    Textfield Value Should Be    id=searchedValue     BC250764
    Press Keys    id=searchedValue    ENTER
    # Please not check that this study exists because TMP Tool Web is probably still processing the study (do not use "Wait Until Page Contains ...")


Test06
    [Documentation]    Click the button "Delete" to remove the study from the server
    [Tags]    CRITICALITY HIGH
    ${ContentsOfTable} =    Get Text  id=command
    Log    ${ContentsOfTable}
    Take My Screenshot
    # ${StudyExists} =    Should Contain    ${ContentsOfTable}    BC250764
    # Log    ${StudyExists}
    # Locator of the link "Delete": xpath=(//a[contains(text(),'Delete')])[2] OR css=tbody a
    Run Keyword If    'BC250764' in '''${ContentsOfTable}'''    Wait Until Element Is Visible    xpath=(//a[contains(text(),'Delete')])[2]    timeout=15s
    Run Keyword If    'BC250764' in '''${ContentsOfTable}'''    Click Element    xpath=(//a[contains(text(),'Delete')])[2]
    Run Keyword If    'BC250764' in '''${ContentsOfTable}'''    Handle Alert    action=ACCEPT    timeout=15s
    Copy File    C:/000/jenkins/dicom/CT250764.dcm    ${MyDicomPath}
    Sleep    4s
    Element Should Be Visible    link=My Patients
    Click Link    link=My Patients
    Wait Until Page Contains   Birth Date    timeout=15s
    Take My Screenshot


Test07
    [Documentation]    Find and select the second study
    [Tags]    CRITICALITY NORMAL
    Wait Until Element Is Visible    link=Admin    timeout=15s
    Click Link    link=Admin
    Wait Until Page Contains    Assign studies    timeout=15s
    Wait Until Element Is Visible    link=Assign studies    timeout=15s
    Click Link    link=Assign studies
    Wait Until Page Contains    Studies    timeout=15s
    Wait Until Element Is Visible    id=searchedValue    timeout=15s
    Input Text    id=searchedValue     BC149653    clear=True
    Wait Until Keyword Succeeds    15s    3s    Textfield Value Should Be    id=searchedValue     BC149653
    Press Keys    id=searchedValue    ENTER
    Wait Until Page Contains    ${MyPatient4FamilyName}^${MyPatient4FirstName}    timeout=15s


Test08
    [Documentation]    Administrator assigns the study to the doctor's name
    [Tags]    CRITICALITY HIGH
    Wait Until Element Is Visible    id=displayedStudies0.isSelected1    timeout=15s
    Element Should Be Visible    id=displayedStudies0.isSelected1
    Click Element    id=displayedStudies0.isSelected1
    Take My Screenshot
    Wait Until Element Is Visible    id=txtSearch    timeout=15s
    Element Should Be Visible    id=txtSearch
    Input Text    id=txtSearch     Taylor ^ Thomas ^ (thomas)    clear=True
    Wait Until Keyword Succeeds    15s    3s    Textfield Value Should Be    id=txtSearch     Taylor ^ Thomas ^ (thomas)
    Press Keys    id=txtSearch    ENTER
    Wait Until Element Is Visible    name=assign    timeout=15s
    Element Should Be Visible    name=assign
    # Do not click the button "Assign" because the list of doctor names hides the button, please press ENTER key after selecting the doctor name from the list
    # Click Button    name=assign
    Sleep    3s


Test09
    [Documentation]    Administrator opens the second study
    [Tags]    CRITICALITY NORMAL
    Element Should Be Visible    link=My Patients
    Click Link    link=My Patients
    Wait Until Page Contains   Birth Date    timeout=15s
    Wait Until Element Is Visible    id=searchInput    timeout=15s
    Element Should Be Visible    id=searchInput
    Input Text    id=searchInput    ${MyPatient4FamilyName}    clear=True
    Wait Until Keyword Succeeds    15s    3s    Textfield Value Should Be    id=searchInput    ${MyPatient4FamilyName}
    Press Keys    id=searchInput    ENTER
    Wait Until Page Contains    ${MyPatient4FamilyName} ${MyPatient4FirstName}    timeout=15s
    Click Link    link=${MyPatient4FamilyName} ${MyPatient4FirstName}


Test10
    [Documentation]    Administrator checks that the study has been assigned properly to the doctor's name
    [Tags]    CRITICALITY HIGH
    Wait Until Page Contains    ${MyPatient4BirthdateDD}-${MyPatient4BirthdateMM}-${MyPatient4BirthdateYYYY}    timeout=15s
    Wait Until Page Contains    Download the following study    timeout=15s
    Wait Until Element Is Visible    link=DCM    timeout=15s
    Wait Until Element Is Visible    link=JPG    timeout=15s
    Wait Until Element Is Visible    link=${MyPatient4SeriesDescription}    timeout=15s
    Wait Until Page Contains    Anonymous link:    timeout=15s
    Wait Until Page Contains    Ordering physician:    timeout=15s
    Wait Until Page Contains    Users allowed to view this study:    timeout=15s
    Wait Until Page Contains    Thomas Taylor ( thomas )    timeout=15s
    Take My Screenshot
    Log Out My User Session Of TMP Web
    Close Browser


Test11
    [Documentation]    The limited user account connects to the website of TMP Web
    [Tags]    CRITICALITY NORMAL
    My User Opens Internet Browser And Connects To My TMP Web    ${TmpWebUser4Login}    ${TmpWebUser4Password}


Test12
    [Documentation]    The limited user account searchs the study
    [Tags]    CRITICALITY NORMAL
    Wait Until Page Contains   My Patients    timeout=15s
    Element Should Be Visible    link=My Patients
    Click Link    link=My Patients
    Wait Until Page Contains   Birth Date    timeout=15s
    Wait Until Element Is Visible    id=searchInput    timeout=15s
    Element Should Be Visible    id=searchInput
    Input Text    id=searchInput    ${MyPatient4FamilyName}    clear=True
    Wait Until Keyword Succeeds    15s    3s    Textfield Value Should Be    id=searchInput    ${MyPatient4FamilyName}
    Press Keys    id=searchInput    ENTER
    Wait Until Page Contains    ${MyPatient4FamilyName} ${MyPatient4FirstName}    timeout=15s
    Click Link    link=${MyPatient4FamilyName} ${MyPatient4FirstName}


Test13
    [Documentation]    Check that the second study has been assigned to the limited user account
    [Tags]    CRITICALITY HIGH
    Wait Until Page Contains    ${MyPatient4BirthdateDD}-${MyPatient4BirthdateMM}-${MyPatient4BirthdateYYYY}    timeout=15s
    Wait Until Page Contains    Download the following study    timeout=15s
    Wait Until Element Is Visible    link=DCM    timeout=15s
    Wait Until Element Is Visible    link=JPG    timeout=15s
    Wait Until Element Is Visible    link=${MyPatient4SeriesDescription}    timeout=15s
    Wait Until Page Contains    Anonymous link:    timeout=15s
    Wait Until Page Contains    Ordering physician:    timeout=15s
    Take My Screenshot


Test14
    [Documentation]    Open the series with the image viewer
    [Tags]    CRITICALITY NORMAL
    Element Should Be Visible    link=${MyPatient4SeriesDescription}
    Click Link    link=${MyPatient4SeriesDescription}
    Wait Until Page Contains    Non-diagnostic quality    timeout=19s
    Wait Until Element Is Visible    link=Full screen    timeout=15s
    Wait Until Page Contains    ${MyPatient4FamilyName} ${MyPatient4FirstName}    timeout=15s
    Wait Until Element Is Visible    link=DICOM download    timeout=15s
    Wait Until Element Is Visible    link=JPEG download    timeout=15s
    Sleep    4s
    Take My Screenshot
    Log Out My User Session Of TMP Web


Test15
    [Documentation]    Shut down the browser and reset the cache
    [Tags]    CRITICALITY LOW
    Close All Browsers
