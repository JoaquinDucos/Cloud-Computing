from typing import Dict, Any
from boto3.dynamodb.conditions import Attr
from .utils import table, create_response, handle_error, validate_table, extract_user_from_jwt
import json

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