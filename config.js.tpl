// Configuration file - Generated dynamically by Terraform
window.APP_CONFIG = {
    API_GATEWAY_URL: "${api_gateway_url}",
    COGNITO: {
        userPoolId: "${user_pool_id}",
        clientId: "${user_pool_client_id}",
        domain: "${user_pool_domain}",
        region: "${aws_region}",
        redirectUri: "${api_gateway_url}/auth/callback",
        logoutUri: "${api_gateway_url}/auth/logout"
    }
}; 