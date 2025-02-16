** Settings ***
Library    String
Library    Dialogs
Library    Collections
Library    OperatingSystem
Library    SeleniumLibrary
Library    DateTime
Library    BuiltIn
Library    RPA.Tables


*** Variables ***
${excel_filepath}    ${CURDIR}/temptest.csv


*** Test Cases ***
Invoice Verification
    ${loaded_data}    Read Table From CSV    ${excel_filepath}    header=True

    FOR    ${row}    IN    @{loaded_data}
        ${amount}=    Get From Dictionary    ${row}    Amount
        Log    ${row}
    END
   