import ballerina/http;
import cgnzntpoc/fundingbankconsentmanagement;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.
configurable string consentServiceClientId = ?;
configurable string consentServiceClientSecret = ?;

service /aopen\-banking/v1\.0/aisp on new http:Listener(9090) {

    # Resource for generating account consent.
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post account\-access\-consents(@http:Payload json consentResource) returns json|error {
        fundingbankconsentmanagement:Client consentService = check new (config = {
            auth: {
                clientId: consentServiceClientId,
                clientSecret: consentServiceClientSecret
            }
        });
        
        io:println("Account Consent Service to generate consent invoked");
        return check consentService ->/accountConsents.post(consentResource);
    }

    # Resource to return account consent.
    # + consentId - the consent resource.
    # + return - account information.
    resource function get account\-access\-consents(string consentId) returns json|error {
        fundingbankconsentmanagement:Client consentService = check new (config = {
            auth: {
                clientId: consentServiceClientId,
                clientSecret: consentServiceClientSecret
            }
        });
        io:println("Account Consent Service to retrieve consent invoked");
        return check consentService ->/accountConsents(consentId);
    }
}
