const jwt = require("jsonwebtoken");
const User = require("../models/user.model");

const authenticate = async (req, res, next) => {
    // Retrieve the token from either the Authorization header or cookies
    const token =
        req.header("Authorization")?.replace("Bearer ", "") ||
        req.cookies?.access_token;

    if (!token) {
        return res.status(401).json({ error: "Authentication required" });
    }

    try {
        // Verify the token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Find the user by the decoded ID
        const user = await User.findById(decoded.id);
        if (!user) {
            return res.status(401).json({ error: "User not found" });
        }

        // Attach the user and token details to the request object
        req.user = user;
        req.token = token;

        next();
    } catch (error) {
        res.status(401).json({ error: "Invalid or expired token" });
    }
};

module.exports = authenticate;
