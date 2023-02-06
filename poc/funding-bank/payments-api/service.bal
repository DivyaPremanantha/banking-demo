import ballerina/http;
import cgnzntpoc/fundingbankconsentmanagement;
import cgnzntpoc/fundingbankbackend;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.
configurable string consentServiceClientId = ?;
configurable string consentServiceClientSecret = ?;
configurable string fundingBankClientId = ?;
configurable string fundingBankClientSecret = ?;

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
        io:println("Payment Consent Service to generate consent invoked.");
        return check consentService ->/paymentConsents.post(consentResource);
    }

    # Resource to return payment consent.
    # + consentId - the consent resource.
    # + return - account information.
    resource function get payment\-access\-consents(string consentId) returns json|error {
        fundingbankconsentmanagement:Client consentService = check new (config = {
            auth: {
                clientId: fundingBankClientId,
                clientSecret: fundingBankClientSecret
            }
        });
        io:println("Payment Consent Service to retrieve consent invoked.");
        return check consentService ->/paymentConsents(consentId);
    }

    # Resource to return payments.
    # + return - account information.
    resource function post payments(@http:Payload json paymentResource) returns json|error {
        
        io:println("Accounts endpoint invoked.");
        fundingbankbackend:Client fundingbankbackendEp = check new (config = {
            auth: {
                clientId: fundingBankClientId,
                clientSecret: fundingBankClientSecret
            }
        });
        return check fundingbankbackendEp ->/payments.post(paymentResource);
    }
}
