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
        #Dont forget that the "cleaned" data from Set To Dictionary still needs to be rewritten to the actual csv file
        IF    ${amount} <= 0
            Set To Dictionary    ${row}    Amount=invalid
        END
        
        #According to the rules, the RefNum needs to consists of 3 to 20 digits and it cannot start with 0
        ${refnum_length}    Get Length    ${refnum}
        ${refnum_first_char}    Get Substring    ${refnum}    0    1

        IF    ${refnum_length} < 3 or ${refnum_length} > 20 or ${refnum_first_char} == 0
            Set To Dictionary    ${row}    RefNum=invalid
        END




        ${iban}    Evaluate    str("${iban}").replace(" ", "")
        Set To Dictionary    ${row}    IBAN=${iban}
        
        ${iban_length}    Get Length    ${iban}
        ${iban_first_char}    Get Substring    ${iban}    0    2
        IF    "${iban_first_char}" != "FI" or ${iban_length} != 18
            Set To Dictionary    ${row}    IBAN=invalid
        END
        ${iban_validation}    Run Keyword And Return Status    Should Match Regexp    ${iban}    ^FI[0-9]{16}$
        IF    ${iban_validation} == "False"
            Set To Dictionary    ${row}    IBAN=invalid
        END 
        

        #Log    ${row}
        Log    ${iban}
        Log    ${iban_length}
        Log    ${iban_validation}
    END
   