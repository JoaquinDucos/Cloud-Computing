from typing import Dict, Any
from .utils import table, create_response, handle_error, validate_table, extract_user_from_jwt

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Get a specific recipe by ID
    """
    try:
        validate_table()
        
        # Extract user ID from JWT token
        user_id = extract_user_from_jwt(event)
        
        # Get recipe ID from path parameters
        path_parameters = event.get('pathParameters', {})
        recipe_id = path_parameters.get('id')
        
        if not recipe_id:
            return create_response(400, {'error': 'Recipe ID is required'})
        
        # Get the recipe from DynamoDB
        response = table.get_item(Key={'id': recipe_id})
        recipe = response.get('Item')
        
        if not recipe:
            return create_response(404, {'error': 'Recipe not found'})
        
        # Convert Decimal types to int for JSON serialization
        if 'time' in recipe:
            recipe['time'] = int(recipe['time'])
        
        return create_response(200, recipe)
        
    except Exception as error:
        return handle_error(error) 