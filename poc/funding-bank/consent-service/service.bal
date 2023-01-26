import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/uuid;

# A service representing a network-accessible API
# bound to port `9090`.
 
 string accountConsentId = uuid:createType1AsString();
 string accounConsenttUpdateDateTime = "";

table<AccountConsent> accountConsents = table [
    {ConsentId:  accountConsentId, Status: "AwaitingAuthorisation", StatusUpdateDateTime: accounConsenttUpdateDateTime, CreationDateTime: accounConsenttUpdateDateTime}
];

type AccountConsent record {
    readonly string ConsentId;
    string Status;
    string StatusUpdateDateTime;
    string CreationDateTime;
};
service / on new http:Listener(9090) {

    # A resource for generating account consent.
    # 
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post accountConsents(@http:Payload json consentResource) returns json|error {
        io:println("Constructing Account Consent Response");
        accounConsenttUpdateDateTime = time:utcToString(time:utcNow());
        io:println("Account Consent Response Constructed");

        AccountConsent[] accountConsent = from var consent in accountConsents
        where consent.ConsentId == accountConsentId
        select consent;

        return accountConsent[0].toJsonString();
    }

    # A resource for getting account consent.
    # 
    # + consentID - the consent ID.
    # + return - account information.
    resource function get accountConsents(string consentID) returns json|error {
        AccountConsent[] accountConsent = from var consent in accountConsents
        where consent.ConsentId == consentID
        select consent;

        return accountConsent[0].toJsonString();
    }
}
