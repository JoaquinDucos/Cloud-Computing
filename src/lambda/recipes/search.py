from typing import Dict, Any
from boto3.dynamodb.conditions import Attr, Contains
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
    Search recipes by title, category, or ingredients for authenticated user
    """
    try:
        print(f"=== SEARCH HANDLER STARTED ===")
        print(f"Search event: {json.dumps(event, default=str)}")
        validate_table()
        
        # Extract user ID from JWT token
        try:
            user_id = extract_user_from_jwt(event)
            print(f"User ID extracted: {user_id}")
        except Exception as auth_error:
            print(f"Authentication error: {auth_error}")
            return create_response(401, {'error': 'Authentication failed', 'details': str(auth_error)})
        
        # Get query parameters
        query_params = event.get('queryStringParameters') or {}
        print(f"Raw query parameters: {query_params}")
        
        title = query_params.get('title', '').strip() if query_params.get('title') else None
        category = query_params.get('category', '').strip() if query_params.get('category') else None
        ingredients = query_params.get('ingredients', '').strip() if query_params.get('ingredients') else None
        
        print(f"Parsed parameters - title: '{title}', category: '{category}', ingredients: '{ingredients}'")
        
        # Check if any parameter has actual content
        has_title = title and len(title) > 0
        has_category = category and len(category) > 0
        has_ingredients = ingredients and len(ingredients) > 0
        
        print(f"Parameter validation - has_title: {has_title}, has_category: {has_category}, has_ingredients: {has_ingredients}")
        
        if not any([has_title, has_category, has_ingredients]):
            print("No valid search parameters found")
            return create_response(400, {'error': 'At least one search parameter is required (UPDATED VERSION)'})
        
        # Start with user filter - ALWAYS filter by user
        filter_expression = Attr('userId').eq(user_id)
        print(f"Base filter: userId = {user_id}")
        
        if has_title:
            print(f"Adding title filter for: {title}")
            # Use case-insensitive search by storing titles in lowercase and searching in lowercase
            title_filter = Contains(Attr('title'), title.lower())
            filter_expression = filter_expression & title_filter
        
        if has_category:
            print(f"Adding category filter for: {category}")
            # Categories should match exactly (case-insensitive)
            category_filter = Attr('category').eq(category.lower())
            filter_expression = filter_expression & category_filter
        
        if has_ingredients:
            print(f"Adding ingredients filter for: {ingredients}")
            # Split ingredients by comma and search for any of them
            ingredient_list = [ing.strip() for ing in ingredients.split(',')]
            ingredient_filters = None
            
            for ingredient in ingredient_list:
                if ingredient:  # Only add filter if ingredient is not empty
                    ingredient_filter = Contains(Attr('ingredients'), ingredient.lower())
                    ingredient_filters = ingredient_filter if ingredient_filters is None else ingredient_filters | ingredient_filter
            
            if ingredient_filters:  # Only add to filter if we have valid ingredient filters
                filter_expression = filter_expression & ingredient_filters
        
        # Perform the scan with filter (always includes user filter)
        print(f"Final filter expression: {filter_expression}")
        
        try:
            response = table.scan(FilterExpression=filter_expression)
            print(f"DynamoDB scan successful")
        except Exception as dynamo_error:
            print(f"DynamoDB scan failed: {dynamo_error}")
            raise dynamo_error
        
        recipes = response.get('Items', [])
        print(f"Found {len(recipes)} recipes for user {user_id}")
        
        # Convert Decimal types to int for JSON serialization
        for recipe in recipes:
            if 'time' in recipe:
                recipe['time'] = int(recipe['time'])
        
        print(f"=== SEARCH HANDLER COMPLETED SUCCESSFULLY ===")
        return create_response(200, recipes)
        
    except Exception as error:
        print(f"Search error: {error}")
        import traceback
        traceback.print_exc()
        return handle_error(error) 