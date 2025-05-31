from typing import Dict, Any
from .utils import table, create_response, handle_error, validate_table, Recipe

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Get a single recipe by ID
    """
    try:
        validate_table()
        
        # Get recipe ID from path parameters
        recipe_id = event.get('pathParameters', {}).get('id')
        if not recipe_id:
            return create_response(400, {'error': 'Recipe ID is required'})
        
        # Get the recipe from DynamoDB
        response = table.get_item(
            Key={'id': recipe_id}
        )
        
        recipe = response.get('Item')
        if not recipe:
            return create_response(404, {'error': 'Recipe not found'})
        
        return create_response(200, {'recipe': recipe})
        
    except Exception as error:
        return handle_error(error) 