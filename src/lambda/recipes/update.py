from typing import Dict, Any
import json
from datetime import datetime
from .utils import table, create_response, handle_error, validate_table, extract_user_from_jwt

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Update an existing recipe
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
            return create_response(403, {'error': 'You can only update your own recipes'})
        
        # Parse request body
        body = json.loads(event.get('body', '{}'))
        
        # Prepare update expression and values
        update_expression = "SET updatedAt = :updatedAt"
        expression_values = {
            ':updatedAt': datetime.utcnow().isoformat()
        }
        
        # Add fields to update if they exist in the request
        if 'title' in body:
            update_expression += ", title = :title"
            expression_values[':title'] = body['title']
        
        if 'description' in body:
            update_expression += ", description = :description"
            expression_values[':description'] = body['description']
        
        if 'time' in body:
            update_expression += ", #time = :time"
            expression_values[':time'] = int(body['time'])
        
        if 'category' in body:
            update_expression += ", category = :category"
            expression_values[':category'] = body['category']
        
        if 'ingredients' in body:
            update_expression += ", ingredients = :ingredients"
            expression_values[':ingredients'] = body['ingredients']
        
        if 'instructions' in body:
            update_expression += ", instructions = :instructions"
            expression_values[':instructions'] = body['instructions'] if isinstance(body['instructions'], list) else body['instructions'].split('\n')
        
        if 'imageUrl' in body:
            update_expression += ", imageUrl = :imageUrl"
            expression_values[':imageUrl'] = body['imageUrl']
        
        # Update the recipe
        expression_names = {'#time': 'time'} if 'time' in body else None
        
        response = table.update_item(
            Key={'id': recipe_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_values,
            ExpressionAttributeNames=expression_names,
            ReturnValues="ALL_NEW"
        )
        
        updated_recipe = response['Attributes']
        
        # Convert Decimal types to int for JSON serialization
        if 'time' in updated_recipe:
            updated_recipe['time'] = int(updated_recipe['time'])
        
        return create_response(200, {'recipe': updated_recipe})
        
    except Exception as error:
        return handle_error(error) 