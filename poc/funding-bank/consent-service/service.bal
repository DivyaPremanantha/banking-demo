import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/uuid;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating account consent.
    # 
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post account\-access\-consents(@http:Payload json consentResource) returns json|error {
        io:println("Constructing Account Consent Response");
        json mapJson = {"Data": {"ConsentId": uuid:createType1AsString(), "Status": "AwaitingAuthorisation", "StatusUpdateDateTime": time:utcToString(time:utcNow()), "CreationDateTime": time:utcToString(time:utcNow())}};
        json|error consentResponse = consentResource.mergeJson(mapJson);
        io:println("Account Consent Response Constructed");
        return consentResponse;
    }

    # A resource for getting account consent.
    # 
    # + consentID - the consent ID.
    # + return - account information.
    resource function get account\-access\-consents(string consentID) returns json|error {
        json|error consentResponse = "{}";
        io:println("Account Consent Response Constructed");
        return consentResponse;
    }
}