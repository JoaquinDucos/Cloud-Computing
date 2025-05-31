from typing import TypedDict, Dict, Any, Optional
from datetime import datetime
import json
import os
import boto3
from botocore.exceptions import ClientError

# Types
class Recipe(TypedDict):
    id: str
    userId: str
    title: str
    description: str
    time: int
    category: str
    ingredients: list[str]
    instructions: list[str]
    imageUrl: Optional[str]
    createdAt: str
    updatedAt: str

class APIResponse(TypedDict):
    statusCode: int
    body: str
    headers: Dict[str, str]

# Constants
RECIPES_TABLE = os.environ.get('RECIPES_TABLE', '')
IMAGES_BUCKET = os.environ.get('IMAGES_BUCKET', '')

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')
table = dynamodb.Table(RECIPES_TABLE)

def create_response(status_code: int, body: Any) -> APIResponse:
    """Create a standardized API response"""
    return {
        'statusCode': status_code,
        'body': json.dumps(body),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Credentials': 'true'
        }
    }

def handle_error(error: Exception) -> APIResponse:
    """Standardized error handling for Lambda functions"""
    error_message = str(error)
    status_code = 500

    if isinstance(error, ClientError):
        if error.response['Error']['Code'] == 'ResourceNotFoundException':
            status_code = 404
        elif error.response['Error']['Code'] == 'ValidationException':
            status_code = 400
    
    return create_response(status_code, {'error': error_message})

def validate_table() -> None:
    """Validate that the DynamoDB table name is configured"""
    if not RECIPES_TABLE:
        raise ValueError("RECIPES_TABLE environment variable is not set")

def validate_bucket() -> None:
    """Validate that the S3 bucket name is configured"""
    if not IMAGES_BUCKET:
        raise ValueError("IMAGES_BUCKET environment variable is not set") 