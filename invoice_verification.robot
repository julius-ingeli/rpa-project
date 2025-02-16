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
        ${refnum}=    Get From Dictionary    ${row}    RefNum
        ${iban}=    Get From Dictionary    ${row}    IBAN
        ${date}=    Get From Dictionary    ${row}    Date

        IF    ${amount} <= 0
            Set To Dictionary    ${row}    Amount=invalid
        END
        
        #According to the rules, the RefNum needs to consists of 3 to 20 digits and it cannot start with 0
        ${refnum_length}    Get Length    ${refnum}
        ${first_char}    Get Substring    ${refnum}    0    1

        IF    ${refnum_length} < 3 or ${refnum_length} > 20 or ${first_char} == 0
            Set To Dictionary    ${row}    RefNum=invalid
        END

        #Log    ${amount}
        Log    ${row}
        #Log    ${iban}
        #Log    ${date}


    END
   