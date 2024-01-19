*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.FileSystem
Library             RPA.Archive
Library             String


*** Variables ***
${body_var}         id-body-
${path_screen}      ${OUTPUT_DIR}${/}screens


*** Tasks ***
Orders of the robot
    # Download the csv
    Open the webpage
    ${orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${row}    IN    @{orders}
        Wait Until Keyword Succeeds    10x    2s    Order the robot    ${row}
        Log    ${row}
    END

Archive the PDFs
    Create ZIP package from PDF files
    [Teardown]    Close the browser


*** Keywords ***
Download the csv
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}

# Order the robots from the store

Order the robot
    [Arguments]    ${row}
    ${index}=    Set Variable    ${row}[Order number]
    ${Head}=    Set Variable    ${row}[Head]
    ${Body}=    Set Variable    ${row}[Body]
    ${Legs}=    Set Variable    ${row}[Legs]
    ${Address}=    Set Variable    ${row}[Address]
    ### head
    Select From List By Value    head    ${Head}
    ### body
    ${elem_to_click}=    Catenate    SEPARATOR=    ${body_var}    ${body}
    Click Element    ${elem_to_click}
    ### legs
    Click Element    xpath=//*[@placeholder="Enter the part number for the legs"]
    Input Text    xpath=//*[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    ### address
    Input Text    address    ${Address}
    ### preview
    Wait Until Keyword Succeeds    10x    2s    Preview robot
    ### order
    Click Element When Clickable    xpath=//*[@id="order"]
    # Wait Until Page Contains Element    xpath=//*[@id="receipt"]
    # Wait Until Element Is Visible    xpath=//*[@id="receipt"]
    Wait Until Keyword Succeeds    10x    2s    Take the screenshot of the robot    ${index}
    Reload Page
    # Click Element When Clickable    OK
    Click Button    OK
    # Log    ${element}

Preview robot
    Click Element    id:preview
    Wait Until Element Is Visible    xpath=//img[@alt="Head"]
    Wait Until Element Is Visible    xpath=//img[@alt="Body"]
    Wait Until Element Is Visible    xpath=//img[@alt="Legs"]

Open the webpage
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    OK

Take the screenshot of the robot
    [Arguments]    ${index}
    Wait Until Element Is Visible    xpath=//*[@id="receipt"]
    ${rob_receipt}=    Get Element Attribute    xpath=//*[@id="receipt"]    outerHTML
    Html To Pdf    ${rob_receipt}    ${path_screen}${/}${index}.pdf

Close the browser
    Close Browser

Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}${/}PDFs.zip
    Archive Folder With Zip
    ...    ${path_screen}
    ...    ${zip_file_name}

# ${path_screen}    ${CURDIR}${/}output${/}screen
