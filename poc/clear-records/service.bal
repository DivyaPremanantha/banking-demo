import ballerina/http;
import cgnzntpoc/fundingbankconsentmanagement;
import cgnzntpoc/fundingbankbackend;
import cgnzntpoc/cognizantcorebankbackend_no;

configurable string consentServiceClientId = ?;
configurable string consentServiceClientSecret = ?;
configurable string fundingBankClientId = ?;
configurable string fundingBankClientSecret = ?;
configurable string cognizantBankClientId = ?;
configurable string cognizantBankClientSecret = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for deleting the records
    # + return - The response of the record deletion invocation
    resource function delete records() returns json|error{
        fundingbankconsentmanagement:Client consentService = check new (config = {
            auth: {
                clientId: consentServiceClientId,
                clientSecret: consentServiceClientSecret
            }
        });

        cognizantcorebankbackend_no:Client cognizantBackend = check new (config = {
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

        http:Response|error consentResponse = check consentService ->/consentRecords.delete();
        http:Response|error fundingBankResponse = check fundingBackend ->/records.delete();
        http:Response|error cognizantResponse = check cognizantBackend ->/records.delete();

        if !(consentResponse is error || fundingBankResponse is error || cognizantResponse is error) {
            return {"Message": "Records successfully deleted"};
        } else {
            return {"Message": "Error in deleting the records"};
        }
    }
}
