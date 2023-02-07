import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/uuid;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;
import ballerina/log;

# A service representing a network-accessible API
# bound to port `9090`.
configurable string dbHost = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbPort = ?;

table<PaymentConsent> key(consentId) paymentConsents = table [

];

type PaymentConsent record {|
    readonly string consentId;
    string status;
    string statusUpdateDateTime;
    string creationDateTime;
    string permission;
    InitiationRecord initiation;
|};

type InitiationRecord record {|
    string reference;
    string firstPaymentDateTime;
    string finalPaymentDateTime;
    DebtorAccountRecord debtorAccount;
    CreditorAccountRecord creditorAccount;
    InstructedAmountRecord instructedAmount;

|};

type DebtorAccountRecord record {|
    string identification;
    string name;
|};

type CreditorAccountRecord record {|
    string identification;
    string name;
|};

type InstructedAmountRecord record {|
    string amount;
    string currency;
|};

table<AccountConsent> key(consentId) accountConsents = table [

];

type AccountConsent record {|
    readonly string consentId;
    string status;
    string statusUpdateDateTime;
    string creationDateTime;
    string transactionFromDateTime;
    string transactionToDateTime;
    string expirationDateTime;
    json[] permissions;
|};

mysql:Client mysql = check new (
    dbHost, dbUser, dbPassword, dbName, dbPort
);

service / on new http:Listener(9090) {

    # A resource for generating account consent.
    #
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post accountConsents(@http:Payload json consentResource) returns json|error {
        accountConsents.removeAll();
        io:println("Constructing Account Consent Response");

        string consentID = uuid:createType1AsString();

        AccountConsent|error accountConsent = {
            consentId: consentID,
            status: "AwaitingAuthorisation",
            statusUpdateDateTime: time:utcToString(time:utcNow()),
            creationDateTime: time:utcToString(time:utcNow()),
            transactionFromDateTime: check consentResource.Data.TransactionFromDateTime,
            transactionToDateTime: check consentResource.Data.TransactionToDateTime,
            expirationDateTime: check consentResource.Data.ExpirationDateTime,
            permissions: check consentResource.Data.Permissions.ensureType()
        };

        if !(accountConsent is error) {
            accountConsents.add(accountConsent);
            sql:ParameterizedQuery consentQuery = `INSERT INTO accountConsents (consent_id, consent_resource) VALUES (${consentID}, ${accountConsent.toString()})`;
            sql:ExecutionResult result = check mysql->execute(consentQuery);
            log:printInfo("Add account consent");
            io:println("Account Consent Created");

            if (result.affectedRowCount == 1) {
                return accountConsent.toJson();
            } else {
                return {"Message": "Failure in adding the account conent"};
            }
        } else {
            io:println("Error in constructing the Account Consent Response");
            return accountConsent;
        }
    }

    # A resource for getting account consent.
    #
    # + consentID - the consent ID.
    # + return - account information.
    resource function get accountConsents(string consentID) returns json|error {

        sql:ParameterizedQuery consentQuery = `SELECT consent_resource FROM accountConsents WHERE consent_id = ${consentID};`;
        stream<AccountConsent, sql:Error?> consentStream = mysql->query(consentQuery);
        AccountConsent accConsnent;

        io:print(consentStream)
        check from AccountConsent accountConsent in consentStream
            do {
                accConsnent = accountConsent;
            };

        io:println("Account Consent Response Retrieved");
        return accConsnent.toJson();
    }

    # A resource for generating payment consent.
    #
    # + consentResource - the consent resource.
    # + return - payment information.
    resource function post paymentConsents(@http:Payload json consentResource) returns json|error {
        paymentConsents.removeAll();
        string consentID = uuid:createType1AsString();
        PaymentConsent|error paymentConsent = generatePaymentConsent(consentID, consentResource);

        if !(paymentConsent is error) {
            paymentConsents.add(paymentConsent);

            sql:ParameterizedQuery consentQuery = `INSERT INTO paymentConsents (consent_id, consent_resource) VALUES (${consentID}, ${paymentConsent.toString()})`;
            sql:ExecutionResult result = check mysql->execute(consentQuery);
            log:printInfo("Add payment consent");
            io:println("Payment Consent Created");

            if (result.affectedRowCount == 1) {
                return paymentConsent.toJson();
            } else {
                return {"Message": "Failure in adding the payment conent"};
            }
        } else {
            io:println("Error in constructing the Payment Consent Response");
            return paymentConsent;
        }
    }

    # A resource for returning payment consent.
    #
    # + consentID - the consent ID.
    # + return - payment information.
    resource function get paymentConsents(string consentID) returns json|error {
        sql:ParameterizedQuery consentQuery = `SELECT consent_resource FROM paymentConsents WHERE consent_id = ${consentID};`;
        stream<PaymentConsent, sql:Error?> consentStream = mysql->query(consentQuery);
        PaymentConsent payConsnent;
        check from PaymentConsent paymentConsent in consentStream
            do {
                payConsnent = paymentConsent;
            };

        io:println("Payment Consent Response Retrieved");
        return payConsnent.toJson();
    }

    # A resource for clearing the consent records.
    # 
    # + return - consent delete information.
    resource function delete consentRecords() returns json|error {
        sql:ParameterizedQuery deleteAccountQuery = `DELETE * FROM accountConsents`;
        sql:ExecutionResult deleteAccResult = check mysql->execute(deleteAccountQuery);

        sql:ParameterizedQuery deletePaymentQuery = `DELETE * FROM accountConsents`;
        sql:ExecutionResult deletePayResult = check mysql->execute(deletePaymentQuery);

        if (deleteAccResult.affectedRowCount == 1 && deletePayResult.affectedRowCount == 1) {
            return {"Message": "Recordes successfully deleted"};
        } else {
            return error("Error deleting the records");
        }
    }
}

function generatePaymentConsent(string consentId, json consentResource) returns PaymentConsent|error {
    return {
        consentId: consentId,
        status: "AwaitingAuthorisation",
        statusUpdateDateTime: time:utcToString(time:utcNow()),
        creationDateTime: time:utcToString(time:utcNow()),
        permission: check consentResource.Data.Permission.ensureType(),
        initiation: {
            reference: check consentResource.Data.Initiation.Reference.ensureType(),
            firstPaymentDateTime: check consentResource.Data.Initiation.FirstPaymentDateTime.ensureType(),
            finalPaymentDateTime: check consentResource.Data.Initiation.FinalPaymentDateTime.ensureType(),
            debtorAccount: {identification: check consentResource.Data.Initiation.DebtorAccount.Identification.ensureType(), name: check consentResource.Data.Initiation.DebtorAccount.Name.ensureType()},
            creditorAccount: {identification: check consentResource.Data.Initiation.CreditorAccount.Identification.ensureType(), name: check consentResource.Data.Initiation.CreditorAccount.Name.ensureType()},
            instructedAmount: {amount: check consentResource.Data.Initiation.InstructedAmount.Amount.ensureType(), currency: check consentResource.Data.Initiation.InstructedAmount.Currency.ensureType()}
        }
    };
}
