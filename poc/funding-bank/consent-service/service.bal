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
configurable string dbHost = "mysql-db-cgnzntpoc.mysql.database.azure.com";
configurable string dbUser = "divya";
configurable string dbPassword = "WtkMy#45%jsdUldt#";
configurable string dbName = "cgnzntpoc";
configurable int dbPort = 3306;

type PaymentConsents record {
    json consentResource;
};

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

type AccountConsents record {
    json consentResource;
};

type AccountConsent record {|
    string consentId;
    string status;
    string statusUpdateDateTime;
    string creationDateTime;
    string transactionFromDateTime;
    string transactionToDateTime;
    string expirationDateTime;
    json[] permissions;
|};

mysql:Client mysql = check new (
    dbHost, dbUser, dbPassword, dbName, dbPort, connectionPool = { maxOpenConnections: 5 }
);
service / on new http:Listener(9090) {

    # A resource for generating account consent.
    #
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post accountConsents(@http:Payload json consentResource) returns json|error {
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
            sql:ParameterizedQuery consentQuery = `INSERT INTO accountConsents (consentId, consentResource) VALUES (${consentID}, ${accountConsent.toString()})`;
            sql:ExecutionResult result = check mysql->execute(consentQuery);
            log:printInfo("Add account consent");
            io:println("Account Consent Created");

            if (result.affectedRowCount == 1) {
                return accountConsent.toJson();
            } else {
                return {"Message": "Failure in adding the account conent."};
            }
        } else {
            io:println("Error in constructing the Account Consent Response.");
            return accountConsent;
        }
    }

    # A resource for getting account consent.
    #
    # + consentID - the consent ID.
    # + return - account information.
    resource function get accountConsents(string consentID) returns json|error {
        io:println("Log - 1");
        sql:ParameterizedQuery consentQuery = `SELECT consentResource FROM accountConsents WHERE consentId = ${consentID};`;
        stream<AccountConsents, sql:Error?> consentStream = mysql->query(consentQuery);
        json accConsnent;
        check from AccountConsents accountConsent in consentStream
            do {
                accConsnent = accountConsent.consentResource;
            };
        check consentStream.close();
        io:println("Account Consent Response Retrieved");
        return accConsnent;
    }

    # A resource for generating payment consent.
    #
    # + consentResource - the consent resource.
    # + return - payment information.
    resource function post paymentConsents(@http:Payload json consentResource) returns json|error {
        string consentID = uuid:createType1AsString();
        PaymentConsent|error paymentConsent = generatePaymentConsent(consentID, consentResource);

        if !(paymentConsent is error) {
            sql:ParameterizedQuery consentQuery = `INSERT INTO paymentConsents (consentId, consentResource) VALUES (${consentID}, ${paymentConsent.toString()})`;
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
        sql:ParameterizedQuery consentQuery = `SELECT consentResource FROM paymentConsents WHERE consentId = ${consentID};`;
        stream<PaymentConsents, sql:Error?> consentStream = mysql->query(consentQuery);
        json payConsnent;
        check from PaymentConsents paymentConsent in consentStream
            do {
                payConsnent = paymentConsent.consentResource;
            };
        check consentStream.close();
        io:println("Payment Consent Response Retrieved");
        return payConsnent;
    }

    # A resource for clearing the consent records.
    # 
    # + return - consent delete information.
    resource function delete consentRecords() returns json|error {
        sql:ParameterizedQuery deleteAccountQuery = `DELETE FROM accountconsents`;
        sql:ExecutionResult deleteAccResult = check mysql->execute(deleteAccountQuery);

        sql:ParameterizedQuery deletePaymentQuery = `DELETE FROM paymentconsents`;
        sql:ExecutionResult deletePayResult = check mysql->execute(deletePaymentQuery);

        if (deleteAccResult.affectedRowCount >= 0 && deletePayResult.affectedRowCount >= 0) {
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
