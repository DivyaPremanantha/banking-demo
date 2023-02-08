import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/uuid;
import ballerina/regex;

# A service representing a network-accessible API
# bound to port `9090`.

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

service / on new http:Listener(9090) {

    # A resource for generating account consent.
    #
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post accountConsents(@http:Payload json consentResource) returns json|error {
        io:println("Constructing Account Consent Response");

        AccountConsent|error accountConsent = {
            consentId: uuid:createType1AsString(),
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
            io:println("Account Consent Response Constructed");
            return accountConsent.toJson();
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
        AccountConsent[] accountConsent = from var consent in accountConsents
            where consent.consentId == consentID
            select consent;

        io:println("Account Consent Response Retrieved");
        if (accountConsent.length() > 0) {
            return accountConsent[0].toJson();
        } else {
            return {};
        }
    }

    # A resource for generating payment consent.
    #
    # + consentResource - the consent resource.
    # + return - payment information.
    resource function post paymentConsents(@http:Payload json consentResource) returns json|error {
        io:println("Constructing Payment Consent Response");

        PaymentConsent|error paymentConsent = generatePaymentConsent(consentResource);

        if !(paymentConsent is error) {
            io:println("Payment Consent Response Constructed");
            paymentConsents.add(paymentConsent);
            return paymentConsent.toJson();
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
        PaymentConsent[] paymentConsent = from var consent in paymentConsents
            where consent.consentId == consentID
            select consent;

        io:println("Account Consent Response Retrieved");
        if (paymentConsent.length() > 0) {
            return paymentConsent[0].toJson();
        } else {
            return {};
        }
    }
    
    # Validate consentID.
    #
    # + consentID - the consent ID.
    # + return - payment information.
    resource function get validateConsents(string consentID, string scope) returns boolean|error {
        if (regex:matches(scope, "^.*payments.*$")) {
            PaymentConsent[] paymentConsent = from var consent in paymentConsents
                where consent.consentId == consentID
                select consent;

            io:println("Payment Consent Response Retrieved");
            if (paymentConsent.length() > 0) {
                return true;
            } else {
                return false;
            }
        } else {
            AccountConsent[] accountConsent = from var accConsent in accountConsents
                where accConsent.consentId == consentID
                select accConsent;

            io:println("Account Consent Response Retrieved");
            if (accountConsent.length() > 0) {
                return true;
            } else {
                return false;
            }
        }
    }

    # A resource for clearing the consent records.
    resource function delete consentRecords() {
        accountConsents.removeAll();
        paymentConsents.removeAll();
    }
}

function generatePaymentConsent(json consentResource) returns PaymentConsent|error {
    return {
        consentId: uuid:createType1AsString(),
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

