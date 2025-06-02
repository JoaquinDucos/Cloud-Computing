from typing import Dict, Any
from .utils import table, create_response, handle_error, validate_table, extract_user_from_jwt

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Delete a recipe
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
        
        # Check if recipe exists and belongs to user
        existing_response = table.get_item(Key={'id': recipe_id})
        existing_recipe = existing_response.get('Item')
        
        if not existing_recipe:
            return create_response(404, {'error': 'Recipe not found'})
        
        # Check if user owns the recipe
        if existing_recipe.get('userId') != user_id:
            return create_response(403, {'error': 'You can only delete your own recipes'})
        
        # Delete the recipe
        table.delete_item(Key={'id': recipe_id})
        
        return create_response(200, {'message': 'Recipe deleted successfully'})
        
    except Exception as error:
        return handle_error(error) 