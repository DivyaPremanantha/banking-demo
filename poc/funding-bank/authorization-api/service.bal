import ballerina/http;
import ballerina/regex;
import ballerina/io;
import cgnzntpoc/fundingbankconsentmanagement;

# A service representing a network-accessible API
# bound to port `9090`.

configurable string accountsAppClientId = ?;
configurable string paymentsAppClientId = ?;
configurable string consentServiceClientId = ?;
configurable string consentServiceClientSecret = ?;
boolean isValidConsentID = false;
service / on new http:Listener(9090) {

    resource function get authorize(string redirect_uri, string scope, string consentID) returns string|error {
        if consentID is "" {
            io:println("ConsentID is not sent in request.");
            return "https://accounts.asgardeo.io/t/fundingbank/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_request&oauthErrorMsg=Empty+ConsentID";
        }
        if accountsAppClientId is "" || paymentsAppClientId is "" {
            io:println("ClientID is not sent in request");
            return "https://accounts.asgardeo.io/t/fundingbank/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_request&oauthErrorMsg=Invalid+authorization+request";
        }
        if scope is "" {
            io:println("Scopes is not sent in request");
            return "https://accounts.asgardeo.io/t/fundingbank/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_request&oauthErrorMsg=Scopes+not+found";
        }
        string[] scopeList = regex:split(scope, " ");
        foreach var item in scopeList {
            if (!(item is "accounts" || item is "transactions" || item is "openid" || item is "payments")) {
                io:println("Invalid scope "+ item);
                return "https://accounts.asgardeo.io/t/fundingbank/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_request&oauthErrorMsg=Invalid+scopes";
            }
        }

        fundingbankconsentmanagement:Client consentService = check new (config = {
            auth: {
                clientId: consentServiceClientId,
                clientSecret: consentServiceClientSecret
            }
        });

        string encodedScope = regex:replace(scope, " ", "%20");

        if regex:matches(scope, "^.*payments.*$") {
            isValidConsentID = check consentService ->/validateConsents(consentID, "payments");
            io:println(scope);
            io:println(isValidConsentID);
        } else {
            isValidConsentID = check consentService ->/validateConsents(consentID, "accounts");
        }

        // if !(isValidConsentID) {
        //     return "https://accounts.asgardeo.io/t/fundingbank/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_consentID&oauthErrorMsg=Invalid+consentID";
        // }

        io:println("Redirecting to the authorization endpoint.");

        if regex:matches(scope, "^.*payments.*$") {
            return "https://api.asgardeo.io/t/fundingbank/oauth2/authorize?scope=" + encodedScope + "&response_type=code&redirect_uri=" + redirect_uri + "&client_id=" + paymentsAppClientId;
        } else {
            return "https://api.asgardeo.io/t/fundingbank/oauth2/authorize?scope=" + encodedScope + "&response_type=code&redirect_uri=" + redirect_uri + "&client_id=" + accountsAppClientId;
        }
    }
}
