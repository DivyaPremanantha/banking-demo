import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/uuid;

# A service representing a network-accessible API
# bound to port `9090`.
 
 string accountConsentId = uuid:createType1AsString();

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
    string[] Permissions;
    object{} Meta;
    object{} Risk;
    object{} Links;
};
service / on new http:Listener(9090) {

    # A resource for generating account consent.
    # 
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post accountConsents(@http:Payload json consentResource) returns json|error {
        io:println("Constructing Account Consent Response");

        AccountConsent accConsent = {ConsentId: accountConsentId, Status: "AwaitingAuthorisation", StatusUpdateDateTime: time:utcToString(time:utcNow()), CreationDateTime: time:utcToString(time:utcNow()), 
       TransactionFromDateTime: check consentResource.Data.TransactionFromDateTime, TransactionToDateTime: check consentResource.Data.TransactionToDateTime, ExpirationDateTime: check consentResource.Data.ExpirationDateTime, 
       Permissions: check consentResource.Data.Permissions.ensureType(), Meta: check consentResource.Data.Meta.ensureType(), Risk: check consentResource.Data.Risk.ensureType(), Links: object {}};

        accountConsents.add(accConsent);

        io:println("Account Consent Response Constructed");
        
        return accConsent.toString().toJson();
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
        return accountConsent[0].toString().toJson();
    }

    # A resource for generating payment consent.
    # 
    # + consentResource - the consent resource.
    # + return - payment information.
    resource function post paymentConsents(@http:Payload json consentResource) returns json|error {
    }
}
