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
    Get a single recipe by ID for authenticated user
    """
    try:
        print(f"=== GET RECIPE HANDLER STARTED ===")
        print(f"Get event: {json.dumps(event, default=str)}")
        validate_table()
        
        # Extract user ID from JWT token
        try:
            user_id = extract_user_from_jwt(event)
            print(f"User ID extracted: {user_id}")
        except Exception as auth_error:
            print(f"Authentication error: {auth_error}")
            return create_response(401, {'error': 'Authentication failed', 'details': str(auth_error)})
        
        # Get recipe ID from path parameters
        path_params = event.get('pathParameters') or {}
        recipe_id = path_params.get('id')
        
        if not recipe_id:
            print("No recipe ID provided")
            return create_response(400, {'error': 'Recipe ID is required'})
        
        print(f"Looking for recipe ID: '{recipe_id}' (type: {type(recipe_id)})")
        
        # Get the recipe by ID - try both string and parsed formats
        try:
            print(f"Attempting DynamoDB get_item with key: {{'id': '{recipe_id}'}}")
            response = table.get_item(Key={'id': recipe_id})
            print(f"DynamoDB get_item response: {response}")
            
            # If not found and recipe_id looks like a number, try as string
            if 'Item' not in response and recipe_id.isdigit():
                print(f"Recipe not found with numeric ID, trying as string")
                response = table.get_item(Key={'id': str(recipe_id)})
                print(f"Second attempt response: {response}")
            
        except Exception as dynamo_error:
            print(f"DynamoDB get_item failed: {dynamo_error}")
            return handle_error(dynamo_error)
        
        if 'Item' not in response:
            print(f"Recipe '{recipe_id}' not found in database")
            
            # Try to list some recipes to see what IDs exist
            try:
                scan_response = table.scan(
                    FilterExpression=Attr('userId').eq(user_id),
                    ProjectionExpression='id, title',
                    Limit=5
                )
                available_recipes = scan_response.get('Items', [])
                print(f"Available recipes for user {user_id}: {available_recipes}")
            except Exception as scan_error:
                print(f"Error scanning for available recipes: {scan_error}")
            
            return create_response(404, {
                'error': 'Recipe not found', 
                'details': f"No recipe found with ID '{recipe_id}'"
            })
        
        recipe = response['Item']
        print(f"Found recipe: {recipe}")
        
        # Verify that the recipe belongs to the authenticated user
        if recipe.get('userId') != user_id:
            print(f"Recipe {recipe_id} does not belong to user {user_id} (belongs to {recipe.get('userId')})")
            return create_response(403, {'error': 'Access denied'})
        
        # Convert Decimal types to int for JSON serialization
        if 'time' in recipe:
            recipe['time'] = int(recipe['time'])
        
        # Basic data cleaning without risky operations
        print(f"Recipe before formatting: {recipe}")
        
        # Ensure we have basic fields
        if 'title' not in recipe or not recipe['title']:
            recipe['title'] = 'Receta sin título'
        if 'category' not in recipe or not recipe['category']:
            recipe['category'] = 'Sin categoría'
        if 'time' not in recipe:
            recipe['time'] = 0
            
        # Handle ingredients safely
        if 'ingredients' in recipe:
            if isinstance(recipe['ingredients'], str) and recipe['ingredients'].strip():
                # If it's a string that looks like JSON, try to parse it
                ingredients_str = recipe['ingredients'].strip()
                if ingredients_str.startswith('[') and ingredients_str.endswith(']'):
                    try:
                        import ast
                        recipe['ingredients'] = ast.literal_eval(ingredients_str)
                    except:
                        # If parsing fails, split by comma
                        recipe['ingredients'] = [ing.strip() for ing in ingredients_str.strip('[]').split(',') if ing.strip()]
                else:
                    # Split by comma for regular string
                    recipe['ingredients'] = [ing.strip() for ing in ingredients_str.split(',') if ing.strip()]
            elif not isinstance(recipe['ingredients'], list):
                recipe['ingredients'] = []
        else:
            recipe['ingredients'] = []
            
        # Handle instructions safely  
        if 'instructions' in recipe:
            if isinstance(recipe['instructions'], str) and recipe['instructions'].strip():
                instructions_str = recipe['instructions'].strip()
                if instructions_str.startswith('[') and instructions_str.endswith(']'):
                    try:
                        import ast
                        recipe['instructions'] = ast.literal_eval(instructions_str)
                    except:
                        # If parsing fails, split by newlines
                        recipe['instructions'] = [inst.strip() for inst in instructions_str.strip('[]').split('\n') if inst.strip()]
                else:
                    # Split by newlines for regular string
                    recipe['instructions'] = [inst.strip() for inst in instructions_str.split('\n') if inst.strip()]
            elif not isinstance(recipe['instructions'], list):
                recipe['instructions'] = ['No hay instrucciones disponibles']
        else:
            recipe['instructions'] = ['No hay instrucciones disponibles']
        
        print(f"Final recipe data being returned: {recipe}")
        print(f"=== GET RECIPE HANDLER COMPLETED SUCCESSFULLY ===")
        return create_response(200, recipe)
        
    except Exception as error:
        print(f"Get recipe error: {error}")
        import traceback
        traceback.print_exc()
        return handle_error(error) 