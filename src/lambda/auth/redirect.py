import json
from typing import Dict, Any

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda function to redirect HTTP requests to HTTPS
    """
    
    # Extract request information
    request = event.get('Records', [{}])[0].get('cf', {}).get('request', {})
    headers = request.get('headers', {})
    
    # Check if request is HTTP
    if headers.get('cloudfront-forwarded-proto', [{}])[0].get('value') == 'http':
        # Construct HTTPS URL
        host = headers.get('host', [{}])[0].get('value', '')
        uri = request.get('uri', '')
        querystring = request.get('querystring', '')
        
        https_url = f"https://{host}{uri}"
        if querystring:
            https_url += f"?{querystring}"
        
        # Return redirect response
        return {
            'status': '301',
            'statusDescription': 'Moved Permanently',
            'headers': {
                'location': [{
                    'key': 'Location',
                    'value': https_url
                }]
            }
        }
    
    # If already HTTPS, continue with the request
    return request


def cognito_redirect_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda function to handle Cognito authentication redirects
    """
    try:
        # Extract query parameters
        query_params = event.get('queryStringParameters') or {}
        
        # S3 Frontend URL
        frontend_url = "http://cloud-computing-app-recetas-2025-dev-frontend.s3-website-us-east-1.amazonaws.com"
        
        # Check if this is a callback from Cognito
        if 'code' in query_params:
            # Redirect to home page with authorization code
            code = query_params['code']
            redirect_url = f"{frontend_url}/home.html?code={code}"
            
            if 'state' in query_params:
                state = query_params['state']
                redirect_url += f"&state={state}"
            
            return {
                'statusCode': 302,
                'headers': {
                    'Location': redirect_url,
                    'Cache-Control': 'no-cache, no-store, must-revalidate',
                    'Pragma': 'no-cache',
                    'Expires': '0'
                }
            }
        else:
            # Redirect to login page
            return {
                'statusCode': 302,
                'headers': {
                    'Location': f"{frontend_url}/index.html"
                }
            }
            
    except Exception as error:
        # Error fallback - redirect to login
        frontend_url = "http://cloud-computing-app-recetas-2025-dev-frontend.s3-website-us-east-1.amazonaws.com"
        return {
            'statusCode': 302,
            'headers': {
                'Location': f"{frontend_url}/index.html?error=redirect_error&error_description=Authentication callback failed"
            }
        } 