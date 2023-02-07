import ballerina/http;
import cgnzntpoc/fundingbankconsentmanagement;
import cgnzntpoc/fundingbankbackend;
import cgnzntpoc/cognizantcorebankbackend;

configurable string consentServiceClientId = ?;
configurable string consentServiceClientSecret = ?;
configurable string fundingBankClientId = ?;
configurable string fundingBankClientSecret = ?;
configurable string cognizantBankClientId = ?;
configurable string cognizantBankClientSecret = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings

    resource function delete greeting() returns http:Response|error{
        fundingbankconsentmanagement:Client consentService = check new (config = {
            auth: {
                clientId: consentServiceClientId,
                clientSecret: consentServiceClientSecret
            }
        });

        cognizantcorebankbackend:Client cognizantBackend = check new (config = {
            auth: {
                clientId: cognizantBankClientId,
                clientSecret: cognizantBankClientSecret
            }
        });

        fundingbankbackend:Client fundingBackend = check new (config = {
            auth: {
                clientId: fundingBankClientId,
                clientSecret: fundingBankClientSecret
            }
        });

        http:Response|error consentResponse = consentService ->/consentRecords.delete();
        http:Response|error fundingBankResponse = fundingBackend ->/records.delete();
        http:Response|error cognizantResponse = cognizantBackend ->/r

        if (consentResponse is error) {
            return consentResponse;
        } else if (fundingBackend is error) {
            return fundingBackend;
        } else if (cognizantBackend is error) {
            return consentResponse;
        }
    }
}
