// Cognito authentication - Uses global configuration
class CognitoAuth {
    constructor() {
        this.config = window.APP_CONFIG.COGNITO;
        this.isAuthenticated = false;
        this.tokens = null;
        this.user = null;
    }

    // Initialize authentication
    async initialize() {
        // Check if we have tokens in localStorage
        const tokens = this.getStoredTokens();
        if (tokens && !this.isTokenExpired(tokens.idToken)) {
            this.tokens = tokens;
            this.isAuthenticated = true;
            this.user = this.parseTokenPayload(tokens.idToken);
            return true;
        }
        
        // Check if we have an authorization code in URL
        const urlParams = new URLSearchParams(window.location.search);
        const code = urlParams.get('code');
        
        if (code) {
            try {
                await this.exchangeCodeForTokens(code);
                // Remove code from URL
                window.history.replaceState({}, document.title, window.location.pathname);
                return true;
            } catch (error) {
                console.error('Error exchanging code for tokens:', error);
                this.logout();
                return false;
            }
        }
        
        return false;
    }

    // Exchange authorization code for tokens
    async exchangeCodeForTokens(code) {
        const tokenEndpoint = `https://$${this.config.domain}.auth.$${this.config.region}.amazoncognito.com/oauth2/token`;
        
        const params = new URLSearchParams({
            grant_type: 'authorization_code',
            client_id: this.config.clientId,
            code: code,
            redirect_uri: this.config.redirectUri
        });

        const response = await fetch(tokenEndpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params
        });

        if (!response.ok) {
            throw new Error('Failed to exchange code for tokens');
        }

        const tokens = await response.json();
        this.storeTokens(tokens);
        this.tokens = tokens;
        this.isAuthenticated = true;
        this.user = this.parseTokenPayload(tokens.id_token);
    }

    // Redirect to Cognito login
    login() {
        const loginUrl = `https://$${this.config.domain}.auth.$${this.config.region}.amazoncognito.com/login?` +
            `client_id=$${this.config.clientId}&` +
            `response_type=code&` +
            `scope=email+openid+profile&` +
            `redirect_uri=$${encodeURIComponent(this.config.redirectUri)}`;
        
        window.location.href = loginUrl;
    }

    // Logout user
    logout() {
        this.clearStoredTokens();
        this.isAuthenticated = false;
        this.tokens = null;
        this.user = null;
        
        const logoutUrl = `https://$${this.config.domain}.auth.$${this.config.region}.amazoncognito.com/logout?` +
            `client_id=$${this.config.clientId}&` +
            `logout_uri=$${encodeURIComponent(this.config.logoutUri)}`;
        
        window.location.href = logoutUrl;
    }

    // Get access token for API calls
    getAccessToken() {
        return this.tokens ? this.tokens.accessToken : null;
    }

    // Get ID token for API calls
    getIdToken() {
        return this.tokens ? this.tokens.idToken : null;
    }

    // Get user information
    getUser() {
        return this.user;
    }

    // Store tokens in localStorage
    storeTokens(tokens) {
        localStorage.setItem('cognito_tokens', JSON.stringify({
            accessToken: tokens.access_token,
            idToken: tokens.id_token,
            refreshToken: tokens.refresh_token,
            expiresAt: Date.now() + (tokens.expires_in * 1000)
        }));
    }

    // Get tokens from localStorage
    getStoredTokens() {
        const stored = localStorage.getItem('cognito_tokens');
        return stored ? JSON.parse(stored) : null;
    }

    // Clear stored tokens
    clearStoredTokens() {
        localStorage.removeItem('cognito_tokens');
    }

    // Check if token is expired
    isTokenExpired(token) {
        try {
            const payload = this.parseTokenPayload(token);
            return Date.now() >= payload.exp * 1000;
        } catch (error) {
            return true;
        }
    }

    // Parse JWT token payload
    parseTokenPayload(token) {
        try {
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
            return JSON.parse(jsonPayload);
        } catch (error) {
            throw new Error('Invalid token');
        }
    }

    // Make authenticated API request
    async makeAuthenticatedRequest(url, options = {}) {
        if (!this.isAuthenticated) {
            throw new Error('User not authenticated');
        }

        const token = this.getAccessToken();
        if (!token) {
            throw new Error('No access token available');
        }

        const headers = {
            'Authorization': `Bearer $${token}`,
            'Content-Type': 'application/json',
            ...options.headers
        };

        return fetch(url, {
            ...options,
            headers
        });
    }
}

// Global auth instance - will be created when config is available
let auth = null;

// Function to initialize auth when config is ready
function initializeAuth() {
    if (window.APP_CONFIG && window.APP_CONFIG.COGNITO) {
        auth = new CognitoAuth();
        return true;
    }
    return false;
}

// Wait for config to be available and then initialize
function waitForConfigAndInitialize() {
    if (initializeAuth()) {
        // Config is ready, auth is initialized
        document.dispatchEvent(new CustomEvent('authReady'));
    } else {
        // Config not ready yet, wait a bit and try again
        setTimeout(waitForConfigAndInitialize, 10);
    }
}

// Start the initialization process
waitForConfigAndInitialize(); 