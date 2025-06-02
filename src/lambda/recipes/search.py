from typing import Dict, Any
from boto3.dynamodb.conditions import Attr, Contains
from .utils import table, create_response, handle_error, validate_table, extract_user_from_jwt
import json

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Search recipes by title, category, or ingredients for authenticated user
    """
    try:
        print(f"Search event: {json.dumps(event, default=str)}")
        validate_table()
        
        # Extract user ID from JWT token
        try:
            user_id = extract_user_from_jwt(event)
            print(f"User ID extracted: {user_id}")
        except Exception as auth_error:
            print(f"Authentication error: {auth_error}")
            return create_response(401, {'error': 'Authentication failed', 'details': str(auth_error)})
        
        # Get query parameters
        query_params = event.get('queryStringParameters') or {}
        print(f"Query parameters: {query_params}")
        
        title = query_params.get('title')
        category = query_params.get('category')
        ingredients = query_params.get('ingredients')
        
        if not any([title, category, ingredients]):
            return create_response(400, {'error': 'At least one search parameter is required'})
        
        # Start with user filter - ALWAYS filter by user
        filter_expression = Attr('userId').eq(user_id)
        
        if title:
            title_filter = Contains(Attr('title'), title.lower())
            filter_expression = filter_expression & title_filter
        
        if category:
            category_filter = Attr('category').eq(category)
            filter_expression = filter_expression & category_filter
        
        if ingredients:
            # Split ingredients by comma and search for any of them
            ingredient_list = [ing.strip() for ing in ingredients.split(',')]
            ingredient_filters = None
            
            for ingredient in ingredient_list:
                ingredient_filter = Contains(Attr('ingredients'), ingredient.lower())
                ingredient_filters = ingredient_filter if ingredient_filters is None else ingredient_filters | ingredient_filter
            
            filter_expression = filter_expression & ingredient_filters
        
        # Perform the scan with filter (always includes user filter)
        print(f"Filter expression: {filter_expression}")
        response = table.scan(FilterExpression=filter_expression)
        
        recipes = response.get('Items', [])
        print(f"Found {len(recipes)} recipes")
        
        # Convert Decimal types to int for JSON serialization
        for recipe in recipes:
            if 'time' in recipe:
                recipe['time'] = int(recipe['time'])
        
        return create_response(200, recipes)
        
    except Exception as error:
        print(f"Search error: {error}")
        import traceback
        traceback.print_exc()
        return handle_error(error) 