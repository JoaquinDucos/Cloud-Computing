from typing import Dict, Any
from .utils import table, create_response, handle_error, validate_table, Recipe

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    List all recipes
    """
    try:
        validate_table()
        
        # Scan the table for all recipes
        response = table.scan()
        recipes: list[Recipe] = response.get('Items', [])
        
        # Handle pagination if there are more items
        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            recipes.extend(response.get('Items', []))
        
        return create_response(200, {'recipes': recipes})
        
    except Exception as error:
        return handle_error(error) 