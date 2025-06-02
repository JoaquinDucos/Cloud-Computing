resource "aws_cognito_user_pool" "recipes_user_pool" {
  name = "${var.project_name}-${var.environment}-user-pool"

  # Password policy
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # User attributes
  username_attributes = ["email"]
  
  auto_verified_attributes = ["email"]

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Schema
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cognito_user_pool_client" "recipes_user_pool_client" {
  name         = "${var.project_name}-${var.environment}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.recipes_user_pool.id

  # Authentication flows for SPA
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Token validity
  id_token_validity     = 24
  access_token_validity = 24
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # OAuth settings for SPA
  supported_identity_providers = ["COGNITO"]
  
  callback_urls = [
    "https://jea0dpf2e4.execute-api.us-east-1.amazonaws.com/dev/auth/callback"
  ]
  
  logout_urls = [
    "https://jea0dpf2e4.execute-api.us-east-1.amazonaws.com/dev/auth/logout"
  ]

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true

  # SPA Configuration - No client secret
  generate_secret = false

  # Security
  prevent_user_existence_errors = "ENABLED"
  
  # Read and write attributes
  read_attributes = ["email", "name"]
  write_attributes = ["email", "name"]
}

resource "aws_cognito_user_pool_domain" "recipes_user_pool_domain" {
  domain       = "${var.project_name}-${var.environment}-${random_string.domain_suffix.result}"
  user_pool_id = aws_cognito_user_pool.recipes_user_pool.id
}

# Custom CSS for Cognito UI
resource "aws_cognito_user_pool_ui_customization" "recipes_ui" {
  client_id    = aws_cognito_user_pool_client.recipes_user_pool_client.id
  user_pool_id = aws_cognito_user_pool_domain.recipes_user_pool_domain.user_pool_id

  # Logo for Recetify - will be displayed at the top
  image_file = filebase64("${path.module}/recetify-logo.png")

  # Custom CSS for better UI
  css = <<EOF
/* Main container with white background for logo visibility */
.banner-customizable {
  background: white;
  color: #2c3e50;
  text-align: center;
  padding: 40px 20px;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  border-bottom: 3px solid #ff6b35;
}

.label-customizable {
  font-weight: 500;
  color: #2c3e50;
  font-size: 14px;
  margin-bottom: 8px;
}

.textDescription-customizable {
  padding-top: 15px;
  padding-bottom: 15px;
  display: block;
  font-size: 18px;
  max-width: 350px;
  color: #2c3e50;
  text-align: center;
  margin: 0 auto;
  font-weight: 600;
}

.idpDescription-customizable {
  padding-top: 10px;
  padding-bottom: 10px;
  display: block;
  font-size: 16px;
  max-width: 300px;
  color: #555;
  text-align: center;
}

/* Button styling with orange theme */
.submitButton-customizable {
  font-size: 14px;
  font-weight: bold;
  margin: 20px 0px 10px 0px;
  height: 48px;
  width: 100%;
  color: #fff;
  background: linear-gradient(135deg, #ff6b35 0%, #f7931e 100%);
  border: none;
  border-radius: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(255, 107, 53, 0.3);
  text-transform: uppercase;
  letter-spacing: 1px;
}

.submitButton-customizable:hover {
  color: #fff;
  background: linear-gradient(135deg, #e55a2b 0%, #e8821a 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 107, 53, 0.4);
}

/* Input fields with orange accents */
.inputField-customizable {
  height: 48px;
  width: 100%;
  color: #2c3e50;
  background-color: #fff;
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  font-size: 14px;
  padding: 12px 16px;
  transition: all 0.3s ease;
}

.inputField-customizable:focus {
  border-color: #ff6b35;
  outline: 0;
  box-shadow: 0 0 0 3px rgba(255, 107, 53, 0.1);
  background-color: #fefefe;
}

/* Main form background */
.background-customizable {
  background: linear-gradient(135deg, #fef7f0 0%, #fff5ee 100%);
  min-height: 100vh;
}

/* Error messages */
.errorMessage-customizable {
  color: #e74c3c;
  font-size: 14px;
  margin-top: 8px;
  font-weight: 500;
  background-color: #fef2f2;
  padding: 8px 12px;
  border-radius: 6px;
  border-left: 4px solid #e74c3c;
}

/* Form container */
.legalText-customizable {
  color: #6c757d;
  font-size: 12px;
  text-align: center;
  margin-top: 20px;
}

/* Links with orange theme */
.redirect-customizable {
  text-align: center;
  margin-top: 20px;
  color: #ff6b35;
  font-weight: 500;
}
EOF

  depends_on = [aws_cognito_user_pool_domain.recipes_user_pool_domain]
}

resource "random_string" "domain_suffix" {
  length  = 8
  special = false
  upper   = false
} 