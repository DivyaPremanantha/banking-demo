import ballerina/http;
import ballerina/regex;
import ballerina/io;
# A service representing a network-accessible API
# bound to port `9090`.

configurable string client_id = ?;

service / on new http:Listener(9090) {

    resource function get authorize(string redirect_uri, string scope, string consentID) returns string {
        if consentID is "" {
            io:println("ConsentID is not sent in request");
            return "https://accounts.asgardeo.io/t/choreotestorganization/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_request&oauthErrorMsg=Empty+ConsentID";
        }
        if client_id is "" {
            io:println("ClientID is not sent in request");
            return "https://accounts.asgardeo.io/t/choreotestorganization/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_request&oauthErrorMsg=Invalid+authorization+request";
        }
        if scope is "" {
            io:println("Scopes is not sent in request");
            return "https://accounts.asgardeo.io/t/choreotestorganization/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_request&oauthErrorMsg=Scopes+not+found";
        }
        if !consentID.equalsIgnoreCaseAscii("343eea20-3f9d-4c12-8777-fe446c554210") {
            io:println("Invalid ConsentID");
            return "https://accounts.asgardeo.io/t/choreotestorganization/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_request&oauthErrorMsg=ConsentID+Not+Valid";
        }
        string[] scopeList = regex:split(scope, " ");
        foreach var item in scopeList {
            if (!(item is "accounts" || item is "transactions" || item is "openid")) {
                io:println("Invalid scope "+ item);
                return "https://accounts.asgardeo.io/t/choreotestorganization/authenticationendpoint/oauth2_error.do?oauthErrorCode=invalid_request&oauthErrorMsg=Invalid+scopes";
            }
        }
        string encodedScope = regex:replace(scope, " ", "%20");

        io:println("Redirecting to the authorization endpoint");
        return "https://api.asgardeo.io/t/choreotestorganization/oauth2/authorize?scope=" + encodedScope + "&response_type=code&redirect_uri=" + redirect_uri + "&client_id=" + client_id;
    }
}
