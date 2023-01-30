import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/uuid;

# A service representing a network-accessible API
# bound to port `9090`.
 
string accountConsentId = uuid:createType1AsString();
string paymentConsentId = uuid:createType1AsString();

table<PaymentConsent> paymentConsents = table [

];


type PaymentConsent record {
    readonly string ConsentId;
    string Status;
    string StatusUpdateDateTime;
    string CreationDateTime;
    string Permissions;
    InitiationRecord Initiation;
};

type InitiationRecord record {
    string Reference;
    string FirstPaymentDateTime;
    string FinalPaymentDateTime;
    DebtorAccountRecord DebtorAccount;
    CreditorAccountRecord CreditorAccount;
    InstructedAmountRecord InstructedAmount;
    
};

type DebtorAccountRecord record {
    string Identification;
    string Name;
};

type CreditorAccountRecord record {
    string Identification;
    string Name;
};

type InstructedAmountRecord record {
    string Amount;
    string Currency;
};

table<AccountConsent> accountConsents = table [

];

type AccountConsent record {
    readonly string ConsentId;
    string Status;
    string StatusUpdateDateTime;
    string CreationDateTime;
    string TransactionFromDateTime;
    string TransactionToDateTime;
    string ExpirationDateTime;
    json[] Permissions;
};


service / on new http:Listener(9090) {

    # A resource for generating account consent.
    # 
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post accountConsents(@http:Payload json consentResource) returns json|error {
        io:println("Constructing Account Consent Response");

        AccountConsent accountConsent = {ConsentId: paymentConsentId, Status: "AwaitingAuthorisation", StatusUpdateDateTime: time:utcToString(time:utcNow()), CreationDateTime: time:utcToString(time:utcNow()), 
       TransactionFromDateTime: check consentResource.Data.TransactionFromDateTime, TransactionToDateTime: check consentResource.Data.TransactionToDateTime, ExpirationDateTime: check consentResource.Data.ExpirationDateTime, 
       Permissions: check consentResource.Data.Permissions.ensureType()};

        accountConsents.add(accountConsent);

        io:println("Account Consent Response Constructed");
        
        return accountConsent.toString().toJson();
    }

    # A resource for getting account consent.
    # 
    # + consentID - the consent ID.
    # + return - account information.
    resource function get accountConsents(string consentID) returns json|error {
        AccountConsent[] accountConsent = from var consent in accountConsents
        where consent.ConsentId == consentID
        select consent;

        io:println("Account Consent Response Retrieved");
        if (accountConsent.length() > 0) {
            return accountConsent[0].toString().toJson();
        } else {
            return {};
        }
    }

    # A resource for generating payment consent.
    # 
    # + consentResource - the consent resource.
    # + return - payment information.
    resource function post paymentConsents(@http:Payload json consentResource) returns json|error {
        io:println("Constructing Account Consent Response");
        
        PaymentConsent paymentConsent = {ConsentId: accountConsentId, Status: "AwaitingAuthorisation", StatusUpdateDateTime: time:utcToString(time:utcNow()), CreationDateTime: time:utcToString(time:utcNow()), Permissions: check consentResource.Data.Permissions.ensureType(), 
        Initiation: {Reference: check consentResource.Data.Initiation.Reference.ensureType(), FirstPaymentDateTime: check consentResource.Data.Initiation.FirstPaymentDateTime.ensureType(), FinalPaymentDateTime: check consentResource.Data.Initiation.FinalPaymentDateTime.ensureType(), 
        DebtorAccount: {Identification: check consentResource.Data.Initiation.DebtorAccount.Identification.ensureType(), Name: check consentResource.Data.Initiation.DebtorAccount.Name.ensureType()}, CreditorAccount: {Identification: check consentResource.Data.Initiation.CreditorAccount.Identification.ensureType(), 
        Name: check consentResource.Data.Initiation.CreditorAccount.Name.ensureType()}, InstructedAmount: {Amount: check consentResource.Data.Initiation.InstructedAmount.Amount.ensureType(), Currency: check consentResource.Data.Initiation.InstructedAmount.Currency.ensureType()}}};

        paymentConsents.add(paymentConsent);

        io:println("Payment Consent Response Constructed");
        
        return paymentConsent.toString().toJson();
    }

    # A resource for returning payment consent.
    # 
    # + consentID - the consent ID.
    # + return - payment information.
    resource function get paymentConsents(string consentID) returns json|error {
        PaymentConsent[] paymentConsent = from var consent in paymentConsents
        where consent.ConsentId == consentID
        select consent;

        io:println("Account Consent Response Retrieved");
        if (paymentConsent.length() > 0) {
            return paymentConsent[0].toString().toJson();
        } else {
            return {};
        }
    }
}
