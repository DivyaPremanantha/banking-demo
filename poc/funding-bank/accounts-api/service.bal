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

    # Resource to return accounts.
    # + return - account information.
    resource function get accounts() returns json|error {
        
        io:println("Accounts endpoint invoked");
        fundingbankbackend:Client fundingbankbackendEp = check new (config = {
            auth: {
                clientId: fundingBankClientId,
                clientSecret: fundingBankClientSecret
            }
        });
        return check fundingbankbackendEp ->/accounts;
    }

    # Resource to return transactions.
    # + return - account information.
    resource function get transactions() returns json|error {
        
        io:println("Transactions endpoint invoked");
        fundingbankbackend:Client fundingbankbackendEp = check new (config = {
            auth: {
                clientId: fundingBankClientId,
                clientSecret: fundingBankClientSecret
            }
        });
        return check fundingbankbackendEp ->/transactions;
    }
}
