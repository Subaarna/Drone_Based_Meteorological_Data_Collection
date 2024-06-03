const jwt = require('jsonwebtoken');
const secretKey = "secret-key";

function GenerateAccessToken(userID) {
    try {
        const expirationTime = Math.floor(Date.now() / 1000) + accessTokenDuration;
        const claims = {
            sub: userID,
            exp: expirationTime,
        };
        const token = jwt.sign(claims, secretKey, { algorithm: 'HS256' });
        return token;
    } catch (error) {
        console.error("Error in GenerateAccessToken: ", error);
        throw error;
    }
}

function GenerateRefreshToken(userID) {
    try {
        const expirationTime = Math.floor(Date.now() / 1000) + refreshTokenDuration;
        const claims = {
            sub: userID,
            exp: expirationTime,
        };
        const token = jwt.sign(claims, secretKey, { algorithm: 'HS256' });
        return token;
    } catch (error) {
        console.error("Error in GenerateRefreshToken: ", error);
        throw error;
    }
}

function generateVerificationToken() {
    try {
        // Generate a random verification token 
        const verificationToken = Math.random().toString(36).substring(2);
        return verificationToken;
    } catch (error) {
        console.error("Error generating verification token: ", error);
        throw error;
    }
}

function RefreshTokens(refreshToken) {
    try {
        //parsing the refresh token
        const token = jwt.verify(refreshToken, secretKey);

        //verify that token is valid and not expired
        if (!token) {
            throw new Error("Invalid token");
        }
        //Get userID from refresh Tokens    
        const userID = token.sub;

        //Generate new access token and refresh token
        const newAccessToken = GenerateAccessToken(userID);
        const newRefreshToken = GenerateRefreshToken(userID);

        return { newAccessToken, newRefreshToken };
    } catch (error) {
        console.error("Error refreshing tokens:", error);
        throw error;
    }
}

function IsAuthenticated(req, res, next) {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ message: "You are not authorized" });
        }

        const tokenString = authHeader.split("Bearer ")[1];
        console.log("Received token:", tokenString); // Log the token for debugging

        const decodedToken = jwt.verify(tokenString, secretKey);
        if (!decodedToken) {
            return res.status(401).json({ message: "Invalid token" });
        }

        // Check if the token has expired
        const currentTimestamp = Math.floor(Date.now() / 1000);
        if (decodedToken.exp < currentTimestamp) {
            return res.status(401).json({ message: "Token has expired" });
        }

        next();
    } catch (error) {
        console.error("Error authenticating:", error);
        return res.status(500).json({ message: "Internal server error" });
    }
}

function GetIdFromAccessToken(req) {
    try {
        const authHeader = req.headers.authorization;

        // Check if auth header is empty
        if (!authHeader) {
            throw new Error("Auth Header is empty.");
        }
        console.log("Auth Header:", authHeader);
        const tokenString = authHeader.split("Bearer ")[1];
        console.log("Token String:", tokenString); // Add this line for debugging
        const decodedToken = jwt.verify(tokenString, secretKey);
        const tokenclaims = decodedToken;
        if (!tokenclaims) {
            throw new Error("Token claims not found.");
        }
        return tokenclaims.sub;
    } catch (error) {
        console.error("Error getting access token:", error);
        throw new Error("Cannot get access token.");
    }
}

const accessTokenDuration = 24 * 60 * 60; // Access token duration in seconds (24hours)
const refreshTokenDuration = 24 * 60 * 60; // Refresh token duration in seconds (24 hours)

const testToken = "Bearer (yourtoken)";
const mockReq = { headers: { authorization: testToken } };

module.exports = {
    GenerateRefreshToken,
    GenerateAccessToken,
    RefreshTokens,
    IsAuthenticated,
    GetIdFromAccessToken,
    generateVerificationToken,
};
