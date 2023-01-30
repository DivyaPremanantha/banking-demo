import ballerina/http;
import cgnzntpoc/fundingbankconsentmanagement;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.
configurable string consentServiceClientId = ?;
configurable string consentServiceClientSecret = ?;

service /aopen\-banking/v1\.0/aisp on new http:Listener(9090) {

    # Resource for generating payment consent.
    # + consentResource - the consent resource.
    # + return - account information.
    @http:ResourceConfig {
        consumes: ["application/json"],
        produces: ["application/json"]
    }
    resource function post payment\-access\-consents(@http:Payload json consentResource) returns json|error {
        fundingbankconsentmanagement:Client consentService = check new (config = {
            auth: {
                clientId: consentServiceClientId,
                clientSecret: consentServiceClientSecret
            }
        });
        io:println("Account Consent Service Invoked");
        return check consentService ->/paymentConsents.post(consentResource);
    }

    # Resource to return payment consent.
    # + consentId - the consent resource.
    # + return - account information.
    resource function get payment\-access\-consents(string consentId) returns json|error {
        fundingbankconsentmanagement:Client consentService = check new (config = {
            auth: {
                clientId: consentServiceClientId,
                clientSecret: consentServiceClientSecret
            }
        });
        return check consentService ->/paymentConsents(consentId);
    }
}
