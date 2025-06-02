from typing import Dict, Any
from boto3.dynamodb.conditions import Attr
import json
import os
import boto3
import base64
from botocore.exceptions import ClientError

# Initialize AWS clients directly
dynamodb = boto3.resource('dynamodb')
RECIPES_TABLE = os.environ.get('RECIPES_TABLE', '')
table = dynamodb.Table(RECIPES_TABLE)

def create_response(status_code: int, body: Any) -> Dict[str, Any]:
    """Create a standardized API response"""
    return {
        'statusCode': status_code,
        'body': json.dumps(body),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Credentials': 'true'
        }
    }

def handle_error(error: Exception) -> Dict[str, Any]:
    """Standardized error handling for Lambda functions"""
    error_message = str(error)
    status_code = 500

    if isinstance(error, ClientError):
        if error.response['Error']['Code'] == 'ResourceNotFoundException':
            status_code = 404
        elif error.response['Error']['Code'] == 'ValidationException':
            status_code = 400
    
    return create_response(status_code, {'error': error_message})

def validate_table() -> None:
    """Validate that the DynamoDB table name is configured"""
    if not RECIPES_TABLE:
        raise ValueError("RECIPES_TABLE environment variable is not set")

def extract_user_from_jwt(event: Dict[str, Any]) -> str:
    """Extract user ID from JWT token in the event"""
    try:
        # Get the JWT claims from API Gateway authorizer
        request_context = event.get('requestContext', {})
        authorizer = request_context.get('authorizer', {})
        jwt_claims = authorizer.get('jwt', {}).get('claims', {})
        
        # Extract user ID from 'sub' claim (standard JWT claim for user ID)
        user_id = jwt_claims.get('sub')
        
        if not user_id:
            # Fallback: try to get from 'cognito:username' claim
            user_id = jwt_claims.get('cognito:username')
        
        if not user_id:
            raise ValueError("User ID not found in JWT token")
            
        return user_id
        
    except Exception as error:
        print(f"Error extracting user from JWT: {error}")
        raise ValueError("Invalid or missing authentication token")

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    List all recipes for authenticated user
    """
    try:
        print(f"List event: {json.dumps(event, default=str)}")
        validate_table()
        
        # Extract user ID from JWT token
        try:
            user_id = extract_user_from_jwt(event)
            print(f"User ID extracted: {user_id}")
        except Exception as auth_error:
            print(f"Authentication error: {auth_error}")
            return create_response(401, {'error': 'Authentication failed', 'details': str(auth_error)})
        
        # Scan table filtering by userId
        print(f"Filtering recipes for user: {user_id}")
        response = table.scan(
            FilterExpression=Attr('userId').eq(user_id)
        )
        recipes = response.get('Items', [])
        print(f"Found {len(recipes)} recipes for user")
        
        # Convert Decimal types to int for JSON serialization
        for recipe in recipes:
            if 'time' in recipe:
                recipe['time'] = int(recipe['time'])
        
        return create_response(200, recipes)
        
    except Exception as error:
        print(f"List error: {error}")
        import traceback
        traceback.print_exc()
        return handle_error(error) 