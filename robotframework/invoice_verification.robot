** Settings ***
Library    String
Library    Dialogs
Library    Collections
Library    OperatingSystem
Library    DateTime
Library    BuiltIn
Library    RPA.Tables
Library    RPA.Excel.Application
Library    RPA.Word.Application
Library    CSVLibrary
Library    DatabaseLibrary
Library    RPA.SAP



*** Variables ***
${db_host}   127.0.0.1
${db_user}    root
${db_pass}    root
${db_name}    RPAdb
${db_port}    3306
    

*** Test Cases ***
Invoice Verification

    #Loading .csv
    ${excel_filepath}=    Set Variable    temp.csv

    ${loaded_data}    Read Table From CSV    ${excel_filepath}    header=True

    FOR    ${row}    IN    @{loaded_data}
        ${amount}=    Get From Dictionary    ${row}    Amount
        ${refnum}=    Get From Dictionary    ${row}    Reference Number
        ${iban}=    Get From Dictionary    ${row}    IBAN
        ${date}=    Get From Dictionary    ${row}    Date
        ${invNumber}=    Get From Dictionary    ${row}    Invoice Number
 
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

        #Rules regarding the iban verification are: the iban has to start with "FI", needs to have 16 numbers after the "FI", total of 18 characters
        ${iban}    Evaluate    str("${iban}").replace(" ", "")
        Set To Dictionary    ${row}    IBAN=${iban}  
        ${iban_length}    Get Length    ${iban}

        ${iban_first_char}    Get Substring    ${iban}    0    2
        IF    "${iban_first_char}" != "FI" or ${iban_length} != 18
            Set To Dictionary    ${row}    IBAN=invalid
        END
        ${iban_validation}    Run Keyword And Return Status    Should Match Regexp    ${iban}    ^FI[0-9]{16}$
        IF    not ${iban_validation}
            Set To Dictionary    ${row}    IBAN=invalid
            Log    ${iban_validation}
        END 
        
        #Date validation is pretty simple - the main goal is to create a correct regex
        ${date_validation}    Run Keyword And Return Status    Should Match Regexp    ${date}     ^((0?[1-9])|1[0-2])/((0?[1-9])|[12][0-9]|30|31)/[0-9]{4}$

        IF    not ${date_validation}
            Set To Dictionary    ${row}    Date=invalid
            Log    ${date_validation}
        ELSE
        #In order to parse these dates into a database, we need to adjust the date format to fit the database requirements 
            ${formatted_date}=    Convert Date    ${date}    result_format=%Y-%m-%d    date_format=%m/%d/%Y
            Log    ${formatted_date}
            Set To Dictionary    ${row}    Date=${formatted_date}
        END
        
        #export to db
        Connect To Database  pymysql  ${DB_NAME}  ${DB_USER}  ${DB_PASS}  ${DB_HOST}  ${DB_PORT}
        ${result}  Execute Sql String   INSERT INTO invoices (amount,refnum,iban,date,invoicenr) VALUES (${amount}, ${refnum}, '${iban}', '${formatted_date}', ${invNumber});
        Log  ${result}
        Disconnect From Database

    END

Invoice Product Verification
    ${excel_filepath}=    Set Variable    tempProds.csv

    ${loaded_data}    Read Table From CSV    ${excel_filepath}    header=True 
    FOR    ${row}    IN    @{loaded_data}
    # get values
        ${desc}=    Get From Dictionary    ${row}    Description
        ${quan}=    Get From Dictionary    ${row}    Quantity
        ${unit}=    Get From Dictionary    ${row}    Unit
        ${unitPrice}=    Get From Dictionary    ${row}    Unit Price
        ${vatPerc}=    Get From Dictionary    ${row}    VAT %
        ${vatTot}=    Get From Dictionary    ${row}    VAT Total
        ${priceTot}=    Get From Dictionary    ${row}    Total Price
        ${invNumber}=    Get From Dictionary    ${row}    Invoice number


    #verifying if the price checks out
        ${calcTotal}=     Evaluate     ${quan} * ${unitPrice} * ((${vatPerc}/100) + 1)
        Should Be Equal As Numbers   ${calcTotal}    ${priceTot}
        
        Connect To Database  pymysql  ${DB_NAME}  ${DB_USER}  ${DB_PASS}  ${DB_HOST}  ${DB_PORT}
        ${result}  Execute Sql String   INSERT INTO products (description,quantity,unit,unitprice,vatPerc,varTot,priceTot,invoiceNr) VALUES ('${desc}', ${quan}, '${unit}', ${unitPrice},${vatPerc},${vatTot},${priceTot},${invNumber});
        Log  ${result}
        Disconnect From Database

    END    