import ballerina/http;
import cgnzntpoc/fundingbankconsentmanagement;

# A service representing a network-accessible API
# bound to port `9090`.
configurable string consentServiceClientId = ?;
configurable string consentServiceClientSecret = ?;

service /aopen\-banking/v1\.0/aisp on new http:Listener(9090) {

    # A resource for generating greetings
    # + consentResource - the consent resource.
    # + return - account information.
    resource function post account\-access\-consents(@http:Payload json consentResource) returns json|error {
        fundingbankconsentmanagement:Client consentService = check new (config = {
            auth: {
                clientId: consentServiceClientId,
                clientSecret: consentServiceClientSecret
            }
        });
        return check consentService ->/accountConsents.post(consentResource);
    }

}
