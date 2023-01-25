import ballerina/http;
import cgnzntpoc/funding_banks_consent_service;

# A service representing a network-accessible API
# bound to port `9090`.
# configurable string clientId = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

service /aopen\-banking/v1\.0/aisp on new http:Listener(9090) {

    # A resource for generating greetings
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post account\-access\-consents(@http:Payload json consentResource) returns json|error {

    }
}
