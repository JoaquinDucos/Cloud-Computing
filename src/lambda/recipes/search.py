from typing import Dict, Any
from .utils import table, create_response, handle_error, validate_table

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Search recipes by title
    """
    try:
        validate_table()
        
        # Get search query from query parameters
        query_params = event.get('queryStringParameters', {}) or {}
        search_term = query_params.get('q', '').strip()
        
        if not search_term:
            return create_response(400, {'error': 'Search term is required'})
        
        # Search recipes using the title-index GSI
        response = table.query(
            IndexName='TitleIndex',
            KeyConditionExpression='begins_with(title, :search_term)',
            ExpressionAttributeValues={
                ':search_term': search_term.lower()
            }
        )
        
        recipes = response.get('Items', [])
        
        # Handle pagination if there are more items
        while 'LastEvaluatedKey' in response:
            response = table.query(
                IndexName='TitleIndex',
                KeyConditionExpression='begins_with(title, :search_term)',
                ExpressionAttributeValues={
                    ':search_term': search_term.lower()
                },
                ExclusiveStartKey=response['LastEvaluatedKey']
            )
            recipes.extend(response.get('Items', []))
        
        return create_response(200, {'recipes': recipes})
        
    except Exception as error:
        return handle_error(error) 