from typing import Dict, Any
from .utils import table, create_response, handle_error, validate_table

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Delete a recipe
    """
    try:
        validate_table()
        
        # Get recipe ID from path parameters
        recipe_id = event.get('pathParameters', {}).get('id')
        if not recipe_id:
            return create_response(400, {'error': 'Recipe ID is required'})
        
        # Delete the recipe
        response = table.delete_item(
            Key={'id': recipe_id},
            ReturnValues='ALL_OLD'
        )
        
        # Check if the item existed
        deleted_recipe = response.get('Attributes')
        if not deleted_recipe:
            return create_response(404, {'error': 'Recipe not found'})
        
        return create_response(200, {'message': 'Recipe deleted successfully'})
        
    except Exception as error:
        return handle_error(error) 