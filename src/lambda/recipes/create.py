from typing import Dict, Any
import json
import uuid
from datetime import datetime
from .utils import table, create_response, handle_error, validate_table, Recipe, extract_user_from_jwt

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Create a new recipe
    """
    try:
        validate_table()
        
        # Extract user ID from JWT token
        user_id = extract_user_from_jwt(event)
        
        # Parse request body
        body = json.loads(event.get('body', '{}'))
        
        # Validate required fields
        required_fields = ['title', 'time', 'category', 'ingredients', 'instructions']
        missing_fields = [field for field in required_fields if field not in body]
        if missing_fields:
            return create_response(400, {
                'error': f'Missing required fields: {", ".join(missing_fields)}'
            })
        
        # Create recipe object
        current_time = datetime.utcnow().isoformat()
        recipe: Recipe = {
            'id': str(uuid.uuid4()),
            'userId': user_id,  # Use user ID from JWT token
            'title': body['title'],
            'description': body.get('description', ''),
            'time': int(body['time']),
            'category': body['category'],
            'ingredients': body['ingredients'],
            'instructions': body['instructions'] if isinstance(body['instructions'], list) else body['instructions'].split('\n'),
            'imageUrl': body.get('imageUrl'),
            'createdAt': current_time,
            'updatedAt': current_time
        }
        
        # Save to DynamoDB
        table.put_item(Item=recipe)
        
        return create_response(201, {'recipe': recipe})
        
    except Exception as error:
        return handle_error(error) 