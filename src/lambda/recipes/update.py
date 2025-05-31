from typing import Dict, Any
import json
from datetime import datetime
from .utils import table, create_response, handle_error, validate_table

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Update an existing recipe
    """
    try:
        validate_table()
        
        # Get recipe ID from path parameters
        recipe_id = event.get('pathParameters', {}).get('id')
        if not recipe_id:
            return create_response(400, {'error': 'Recipe ID is required'})
        
        # Parse request body
        body = json.loads(event.get('body', '{}'))
        if not body:
            return create_response(400, {'error': 'Request body is required'})
        
        # Build update expression
        update_expressions = []
        expression_values = {}
        expression_names = {}
        
        # Map of fields that can be updated
        updatable_fields = {
            'title': 'title',
            'description': 'description',
            'ingredients': 'ingredients',
            'instructions': 'instructions',
            'imageUrl': 'imageUrl'
        }
        
        # Build expressions for each field present in the request
        for key, attr_name in updatable_fields.items():
            if key in body:
                update_expressions.append(f'#{key} = :{key}')
                expression_names[f'#{key}'] = attr_name
                expression_values[f':{key}'] = body[key]
        
        # Add updatedAt timestamp
        update_expressions.append('#updatedAt = :updatedAt')
        expression_names['#updatedAt'] = 'updatedAt'
        expression_values[':updatedAt'] = datetime.utcnow().isoformat()
        
        if not update_expressions:
            return create_response(400, {'error': 'No fields to update'})
        
        # Update the recipe
        response = table.update_item(
            Key={'id': recipe_id},
            UpdateExpression='SET ' + ', '.join(update_expressions),
            ExpressionAttributeNames=expression_names,
            ExpressionAttributeValues=expression_values,
            ReturnValues='ALL_NEW'
        )
        
        updated_recipe = response.get('Attributes', {})
        return create_response(200, {'recipe': updated_recipe})
        
    except Exception as error:
        return handle_error(error) 